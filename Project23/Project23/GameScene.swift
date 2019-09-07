//
//  GameScene.swift
//  Project23
//
//  Created by Dillon McElhinney on 9/2/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum SequenceType: CaseIterable {
    case oneNoBomb
    case one
    case twoWithOneBomb
    case two
    case three
    case four
    case chain
    case fastChain
}

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }

    var livesImages: [SKSpriteNode] = []
    var lives = 3

    var activeSlicePoints: [CGPoint] = []
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!

    var isSwooshSoundActive = false

    var activeEnemies: [SKSpriteNode] = []

    var bombSoundEffect: AVAudioPlayer?

    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true

    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()

        sequence = [.oneNoBomb,
                    .oneNoBomb,
                    .twoWithOneBomb,
                    .twoWithOneBomb,
                    .three,
                    .one,
                    .chain]

        let possible = SequenceType.allCases
        (0 ... 1000).forEach { _ in
            if let nextSequence = possible.randomElement() {
                sequence.append(nextSequence)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
        { [weak self] in
            self?.tossEnemies()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            let enemies = activeEnemies.enumerated().reversed()
            for (index, node) in enemies {
                if node.position.y < -140 {
                    node.removeAllActions()

                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()

                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                let queue = DispatchQueue.main
                queue.asyncAfter(deadline: .now() + popupTime) {
                    [weak self] in self?.tossEnemies()
                }

                nextSequenceQueued = true
            }
        }
        
        let bombCount = activeEnemies.reduce(0) {
            let modifier = $1.name == "bombContainer" ? 0 : 1
            return $0 + modifier
        }

        if bombCount == 0 {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else { return }

        activeSlicePoints.removeAll(keepingCapacity: true)

        let location = touch.location(in: self)
        activeSlicePoints.append(location)

        redrawActiveSlice()

        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard !isGameEnded, let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()

        if !isSwooshSoundActive {
            playSwooshSound()
        }

        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                destroyPenguin(node)
            } else if node.name == "bomb" {
                destroyBomb(node)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        activeSliceBG.run(fadeOut)
        activeSliceFG.run(fadeOut)
    }

    private func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }

        if activeSlicePoints.count > 12 {
            let toRemove = activeSlicePoints.count - 12
            activeSlicePoints.removeFirst(toRemove)
        }

        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])

        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }

        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }

    private func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }

    private func createLives() {
        (0 ..< 3).forEach {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")

            let x = CGFloat(834 + ($0 * 70))
            spriteNode.position = CGPoint(x: x, y: 720)
            addChild(spriteNode)

            livesImages.append(spriteNode)
        }
    }

    private func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2

        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3

        activeSliceBG.strokeColor = UIColor(red: 1,
                                            green: 0.9,
                                            blue: 0,
                                            alpha: 1)
        activeSliceBG.lineWidth = 9
        activeSliceBG.lineCap = .round

        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        activeSliceFG.lineCap = .round

        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }

    private func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode

        var enemyType = Int.random(in: 0...6)

        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }

        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"

            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)

            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }

            if let path = Bundle.main.url(forResource: "sliceBombFuse",
                                          withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }

            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf",
                                            waitForCompletion: false))
            enemy.name = "enemy"
        }

        let randomX = Int.random(in: 64...960)
        let randomPosition = CGPoint(x: randomX,
                                     y: -128)
        enemy.position = randomPosition

        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        let randomXVelocity: Int

        let outsideXVel = Int.random(in: 8...15)
        let insideXVel = Int.random(in: 3...5)

        if randomPosition.x < 256 {
            randomXVelocity = outsideXVel
        } else if randomPosition.x < 512 {
            randomXVelocity = insideXVel
        } else if randomPosition.x < 768 {
            randomXVelocity = -insideXVel
        } else {
            randomXVelocity = -outsideXVel
        }

        let randomYVelocity = Int.random(in: 24...32)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40,
                                               dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0

        addChild(enemy)
        activeEnemies.append(enemy)
    }

    func tossEnemies() {
        guard !isGameEnded else { return }

        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)

        case .one:
            createEnemy()

        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)

        case .two:
            (1...2).forEach { _ in self.createEnemy() }

        case .three:
            (1...3).forEach { _ in self.createEnemy() }

        case .four:
            (1...4).forEach { _ in self.createEnemy() }

        case .chain:
            let queue = DispatchQueue.main
            (0...4).forEach { [weak self] in
                let offset = chainDelay / 5.0 * Double($0)
                queue.asyncAfter(deadline: .now() + offset) {
                     self?.createEnemy()
                }
            }

        case .fastChain:
            let queue = DispatchQueue.main
            (0...4).forEach { [weak self] in
                let offset = chainDelay / 10.0 * Double($0)
                queue.asyncAfter(deadline: .now() + offset) {
                    self?.createEnemy()
                }
            }
        }

        sequencePosition += 1
        nextSequenceQueued = false
    }

    private func playSwooshSound() {
        isSwooshSoundActive = true

        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        let swooshSound = SKAction.playSoundFileNamed(soundName,
                                                      waitForCompletion: true)

        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }

    private func destroyPenguin(_ node: SKSpriteNode) {
        if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
            emitter.position = node.position
            addChild(emitter)
        }

        node.name = ""
        node.physicsBody?.isDynamic = false

        let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        let seq = SKAction.sequence([group, .removeFromParent()])
        node.run(seq)

        score += 1
        if let index = activeEnemies.firstIndex(of: node) {
            activeEnemies.remove(at: index)
        }
        run(SKAction.playSoundFileNamed("whack.caf",
                                        waitForCompletion: false))
    }

    private func destroyBomb(_ node: SKSpriteNode) {
        guard let bombContainer = node.parent as? SKSpriteNode else { return }

        if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
            emitter.position = bombContainer.position
            addChild(emitter)
        }

        node.name = ""
        bombContainer.physicsBody?.isDynamic = false

        let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])

        let seq = SKAction.sequence([group, .removeFromParent()])
        bombContainer.run(seq)

        if let index = activeEnemies.firstIndex(of: bombContainer) {
            activeEnemies.remove(at: index)
        }

        run(SKAction.playSoundFileNamed("explosion.caf",
                                        waitForCompletion: false))
        endGame(triggeredByBomb: true)
    }

    private func subtractLife() {
        lives -= 1

        run(SKAction.playSoundFileNamed("wrong.caf",
                                        waitForCompletion: false))

        var life: SKSpriteNode

        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")

        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.2))
    }

    func endGame(triggeredByBomb: Bool) {
        guard !isGameEnded else { return }

        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false

        bombSoundEffect?.stop()
        bombSoundEffect = nil

        if triggeredByBomb {
            let newTexture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages.forEach { $0.texture = newTexture }
        }
    }

}

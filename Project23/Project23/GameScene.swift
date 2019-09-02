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

    var createdEnemies = 0
    var timer: Timer?
    
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

        timer = Timer.scheduledTimer(withTimeInterval: 0.5,
                             repeats: true) { _ in
            self.createEnemy()
            self.createdEnemies += 1
            if self.createdEnemies > 20 {
                self.timer?.invalidate()
                self.timer = nil
            }

        }
    }

    override func update(_ currentTime: TimeInterval) {
        
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()

        if !isSwooshSoundActive {
            playSwooshSound()
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

}

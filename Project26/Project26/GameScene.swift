//
//  GameScene.swift
//  Project26
//
//  Created by Dillon McElhinney on 9/28/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16

    static let playerContactTests: UInt32 = {
        var val: UInt32 = 0
        val |= CollisionTypes.star.rawValue
        val |= CollisionTypes.vortex.rawValue
        val |= CollisionTypes.finish.rawValue

        return val
    }()
}

class GameScene: SKScene {

    var motionManager: CMMotionManager!
    var player: SKSpriteNode!
    var isGameOver = false
    var currentLevel = 0

    var scoreLabel: SKLabelNode! = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: 16, y: 16)
        label.zPosition = 2
        return label
    }()

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var portals: [SKNode] = []
    private var _portalIndex = 0
    var portalIndex: Int {
        get {
            return _portalIndex
        }
        set {
            _portalIndex = newValue % portals.count
        }
    }
    var shouldTeleport = true

    override func didMove(to view: SKView) {

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        addChild(scoreLabel)
        score = 0

        loadLevel()

        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        if let accelerometerData = motionManager.accelerometerData {
            let dx = accelerometerData.acceleration.y * -50
            let dy = accelerometerData.acceleration.x * 50
            physicsWorld.gravity = CGVector(dx: dx, dy: dy)
        }
    }

    func loadLevel() {
        isGameOver = true
        currentLevel += 1
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)",
                                             withExtension: "txt") else {
            endGame()
            return
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        children.forEach {
            guard $0 != scoreLabel else { return }
            let fade = SKAction.fadeOut(withDuration: 1)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fade, remove])
            $0.run(sequence)
        }

        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        let lines = levelString.components(separatedBy: "\n")

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let x = (64 * column) + 32
                let y = (64 * row) + 32
                let position = CGPoint(x: x, y: y)

                if letter == "x" {
                    self.loadWall(at: position)
                } else if letter == "v"  {
                    loadVortex(at: position)
                } else if letter == "s"  {
                    loadStar(at: position)
                } else if letter == "f"  {
                    loadFinish(at: position)
                } else if letter == "p" {
                    loadPortal(at: position)
                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }

        self.player?.removeFromParent()
        self.createPlayer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isGameOver = false
        }
    }

    func addNode(_ node: SKNode?) {
        guard let node = node else { return }
        node.alpha = 0
        addChild(node)
        let fade = SKAction.fadeIn(withDuration: 1)
        node.run(fade)
    }

    func loadWall(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position

        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addNode(node)
    }

    func loadVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi,
                                                        duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addNode(node)
    }

    func loadStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addNode(node)
    }

    func loadFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addNode(node)
    }

    func loadPortal(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "portal")
        node.name = "portal"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi,
                                                        duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0

        portals.append(node)
        addNode(node)
    }

    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.playerContactTests
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }

    func endGame() {
        let gameOverNode = SKLabelNode(fontNamed: "Chalkduster")
        gameOverNode.horizontalAlignmentMode = .center
        gameOverNode.fontSize = 64
        gameOverNode.position = CGPoint(x: 512, y: 360)
        gameOverNode.zPosition = 2
        gameOverNode.text = "You Made It To The End!"
        gameOverNode.setScale(0.0001)
        addChild(gameOverNode)
        let duration = 0.5
        gameOverNode.run(SKAction.scale(to: 1, duration: duration))

        let moveAction = SKAction.move(to: CGPoint(x: 48, y: 300),
                                       duration: duration)
        let scaleAction = SKAction.scale(to: 2, duration: duration)
        let group = SKAction.group([moveAction, scaleAction])
        scoreLabel.run(group)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    func nextPortal(from portal: SKNode) -> SKNode {
        var nextPortal = portals[portalIndex]
        if nextPortal === portal {
            portalIndex += 1
            nextPortal = portals[portalIndex]
        }
        portalIndex += 1
        return nextPortal
    }

    func playerCollided(with node: SKNode) {
        switch node.name {
        case "vortex":
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position,
                                     duration: 0.25)
            let scale = SKAction.scale(to: 0.0001,
                                       duration: 0.25)
            let remove = SKAction.removeFromParent()
            let actions = [move, scale, remove]
            let sequence = SKAction.sequence(actions)

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
            break
        case "star":
            node.removeFromParent()
            score += 1
        case "portal":
            guard shouldTeleport else { return }
            shouldTeleport = false
            player.physicsBody?.isDynamic = false
            isGameOver = true

            let move = SKAction.move(to: node.position,
                                     duration: 0.25)
            let scale = SKAction.scale(to: 0.0001,
                                       duration: 0.25)
            let remove = SKAction.removeFromParent()
            let actions = [move, scale, remove]
            let sequence = SKAction.sequence(actions)

            player.run(sequence) { [weak self] in
                if let portal = self?.nextPortal(from: node) {
                    self?.player.position = portal.position
                }
                self?.player.setScale(1)
                self?.player.physicsBody?.isDynamic = true
                self?.addNode(self?.player)
                self?.isGameOver = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.shouldTeleport = true
                }
            }
        case "finish":
            node.removeFromParent()
            score += 5
            loadLevel()
        default:
            fatalError("What did we collide with?\n\(node)")
        }
    }
}

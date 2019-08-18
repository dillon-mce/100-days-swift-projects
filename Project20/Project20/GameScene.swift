//
//  GameScene.swift
//  Project20
//
//  Created by Dillon McElhinney on 8/14/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var gameTimer: Timer?
    private var fireworks: [SKNode] = []

    private let leftEdge = -22
    private let bottomEdge = -22
    private let rightEdge = 1024 + 22

    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }

    private var numberOfLaunches = 0 {
        didSet {
            if numberOfLaunches >= 10 {
                gameTimer?.invalidate()
            }
        }
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 120, y: 16)
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        score = 0

        gameTimer =
            Timer.scheduledTimer(timeInterval: 6,
                                 target: self,
                                 selector: #selector(launchFireworks),
                                 userInfo: nil,
                                 repeats: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }

    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }

    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            for parent in fireworks {
                guard let firework = parent.children.first
                    as? SKSpriteNode else { continue }

                if firework.name == "selected"
                    && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }

    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800

        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0,
                           x: 512, y: bottomEdge)
            createFirework(xMovement: 0,
                           x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0,
                           x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0,
                           x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0,
                           x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0,
                           x: 512, y: bottomEdge)
            createFirework(xMovement: -200,
                           x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100,
                           x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100,
                           x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200,
                           x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount,
                           x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount,
                           x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount,
                           x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount,
                           x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount,
                           x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount,
                           x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount,
                           x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount,
                           x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount,
                           x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount,
                           x: rightEdge, y: bottomEdge)

        default:
            break
        }
        numberOfLaunches += 1
    }

    let colors: [UIColor] = [.cyan, .green, .red]
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {

        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        firework.color = colors.randomElement()!

        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        let move = SKAction.follow(path.cgPath,
                                   asOffset: true,
                                   orientToPath: true,
                                   speed: 200)
        node.run(move)

        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }

        fireworks.append(node)
        addChild(node)
    }

    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            let wait = SKAction.wait(forDuration: 1)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([wait, remove])
            emitter.run(sequence)
        }

        firework.removeFromParent()
    }

    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated()
                                                   .reversed() {
            guard let firework =
                fireworkContainer.children.first as? SKSpriteNode else {
                    continue
                }

            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        score += numExploded * numExploded * 200
    }
}

//
//  GameScene.swift
//  Project11
//
//  Created by Dillon McElhinney on 7/3/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ballNames: [String] = []
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var remainingLabel: SKLabelNode!

    var remainingBalls = 5 {
        didSet {
            remainingLabel.text = "Remaining: \(remainingBalls)"
        }
    }
    
    var editLabel: SKLabelNode!

    var isInEditingMode: Bool = false {
        didSet {
            editLabel.text = isInEditingMode ? "Done" : "Edit"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let url = Bundle.main.bundleURL
        if let files = try? FileManager.default.contentsOfDirectory(atPath: url.path) {
            ballNames = files.filter({ $0.hasPrefix("ball") && !$0.contains("@2x") })
            print(ballNames)
        } else {
            fatalError("Couldn't load any ball names")
        }
        
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        for i in 0..<5 {
            let x = i * 256
            makeBouncer(at: CGPoint(x: x, y: 0))
        }
        
        var isGood = false
        for i in 0..<4 {
            let x = i * 256 + 128
            isGood.toggle()
            makeSlot(at: CGPoint(x: x, y: 0), isGood: isGood)
        }
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        remainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingLabel.text = "Remaining: 5"
        remainingLabel.horizontalAlignmentMode = .right
        remainingLabel.position = CGPoint(x: 980, y: 660)
        addChild(remainingLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)

            if objects.contains(editLabel) {
                isInEditingMode.toggle()
            } else {
                if isInEditingMode {
                    makeBox(at: location)
                } else {
                    makeBall(at: location)
                }
            }
        }
    }
    
    func makeBall(at position: CGPoint) {
        guard position.y > 600 else { return }
        guard remainingBalls > 0 else { return }
        remainingBalls -= 1
        let ball = SKSpriteNode(imageNamed: ballNames.randomElement()!)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.restitution = 0.4
        ball.position = position
        ball.name = "ball"
        addChild(ball)
    }
    
    func makeBox(at position: CGPoint) {
        guard position.y < 550, position.y > 100 else { return }
        let size = CGSize(width: Int.random(in: 16...128),
                          height: 16)
        let box = SKSpriteNode(color: randomColor(),
                               size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = position
        box.name = "box"
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        
        addChild(box)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.zPosition = 1
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi,
                                   duration: Double.random(in: 8...15))
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            remainingBalls += 1
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box" {
            score += 1
            object.removeFromParent()
        }
    }

    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0.3...1)
        let green = CGFloat.random(in: 0.3...1)
        let blue = CGFloat.random(in: 0.3...1)
        
        return UIColor(red: red,
                       green: green,
                       blue: blue,
                       alpha: 1)
    }
}

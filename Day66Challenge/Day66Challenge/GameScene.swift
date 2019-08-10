//
//  GameScene.swift
//  Day66Challenge
//
//  Created by Dillon McElhinney on 8/8/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var timer: Timer!
    var moveInterval: TimeInterval = 0
    var timerInterval: TimeInterval = 0 {
        didSet {
            moveInterval = timerInterval * 3
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    private var isGameOver = false
    private let scoreLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "Chalkduster")
        node.fontSize = 48
        node.horizontalAlignmentMode = .left
        node.position = CGPoint(x: 120, y: 64)
        node.zPosition = 101
        
        return node
    }()
    
    var remainingShots: Int = 0 {
        didSet {
            remainingShotsNode.texture = SKTexture(imageNamed: "shots\(remainingShots)")
        }
    }

    private let remainingShotsNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "shots3")
        node.position = CGPoint(x: 860, y: 84)
        node.zPosition = 101
        
        return node
    }()
    
    private let gameOverNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "game-over")
        node.position = CGPoint(x: 512, y: 384)
        node.zPosition = 101
        
        return node
    }()
    
    override func didMove(to view: SKView) {
        
        setUpBackground()
        
        restartGame()
        
    }
    
    private var startTouchPoint: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        guard !isGameOver else { restartGame(); return }
        
        let touch = touches.first!
        let location = touch.location(in: self)
        startTouchPoint = location
        
        guard remainingShots > 0 else { return }

        // Update remaining shots
        remainingShots -= 1
        
        let locationNodes = nodes(at: location)
        
        let targets = locationNodes.filter { $0.name == SKNode.targetIdentifier }
                                     .sorted { $0.zPosition > $1.zPosition }
        
        if let target = targets.first {
            shootTarget(target)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver,
            let startTouchPoint = startTouchPoint else { return }

        let touch = touches.first!
        let location = touch.location(in: self)
        let delta = startTouchPoint.y - location.y

        if delta > 200 {
            reloadBullets()
        }
        self.startTouchPoint = nil
    }
    
    private func shootTarget(_ node: SKNode) {
        
        // Update score
        score += 15 / Int(node.zPosition)

        // Animate out and remove
        node.removeAllActions()
        let duration = 0.4
        let scaleAction = SKAction.scaleX(by: 0.9,
                                          y: 0.7,
                                          duration: duration)
        let moveAction = SKAction.moveBy(x: 0,
                                         y: -30,
                                         duration: duration)
        let fadeAction = SKAction.fadeAlpha(to: 0,
                                            duration: duration)
        let group = [scaleAction,
                     moveAction,
                     fadeAction]

        let groupAction = SKAction.group(group)
        let removeAction = SKAction.run {
            node.removeFromParent()
        }
        let sequence = SKAction.sequence([groupAction, removeAction])
        node.run(sequence)
    }
    
    private var deployedNodes = 0 {
        didSet {
            if deployedNodes >= 6 {
                deployedNodes = 0
                resetTimer()
            }
        }
    }
    private let targets = ["target0", "target1", "target2", "target3"]
    private let sticks = ["stick0", "stick1", "stick2"]
    private func addTarget() {
        let targetName = targets.randomElement()!
        let target = SKSpriteNode(imageNamed: targetName)
        target.name = SKNode.targetIdentifier
        addChild(target)

        let stickName = sticks.randomElement()!
        let stick = SKSpriteNode(imageNamed: stickName)
        stick.position = CGPoint(x: 0, y: -116)
        target.addChild(stick)

        let kind = Int.random(in: 1...3)
        let moveAction: SKAction
        if kind == 1 {
            // Front row
            target.position = CGPoint(x: 0, y: 280)
            target.setScale(1.2)
            target.zPosition = 5
            
            moveAction = SKAction.moveBy(x: 1080,
                                         y: 0,
                                         duration: moveInterval * 1.15)
        } else if kind == 2 {
            // Middle row
            target.position = CGPoint(x: 1024, y: 380)
            target.xScale = -1
            target.zPosition = 3
            
            moveAction = SKAction.moveBy(x: -1080,
                                         y: 0,
                                         duration: moveInterval)
        } else if kind == 3 {
            // Back row
            target.position = CGPoint(x: 0, y: 460)
            target.setScale(0.8)
            target.zPosition = 1
            
            moveAction = SKAction.moveBy(x: 1080,
                                         y: 0,
                                         duration: moveInterval * 0.85)
        }  else { return }

        let removeAction = SKAction.run {
            stick.removeFromParent()
            target.removeFromParent()
        }

        let sequence = SKAction.sequence([moveAction, removeAction])
        target.run(sequence)
        deployedNodes += 1
    }
    
    private func reloadBullets() {
        // update score
        score -= 5
        
        // update remaining bullets
        remainingShots = 3
    }
    
    private func resetTimer() {
        timer?.invalidate()

        if timerInterval < 0.35 { endGame(); return }

        timer = Timer.scheduledTimer(withTimeInterval: timerInterval,
                                     repeats: true,
                                     block: { _ in
            self.addTarget()
        })

        timerInterval *= 0.9
    }
    
    private func endGame() {

        gameOverNode.setScale(0)
        addChild(gameOverNode)
        let waitAction = SKAction.wait(forDuration: 1)
        let scaleAction = SKAction.scale(to: 1, duration: 0.2)
        let waitAction2 = SKAction.wait(forDuration: 3)
        let endGameAction = SKAction.run {
            self.isGameOver = true
        }
        
        let sequence = [waitAction,
                        scaleAction,
                        waitAction2,
                        endGameAction]
        
        let sequenceAction = SKAction.sequence(sequence)
        gameOverNode.run(sequenceAction)
    }
    
    private func restartGame() {
        isGameOver = false
        
        gameOverNode.removeFromParent()
        
        score = 0
        remainingShots = 3
        timerInterval = 1
        startTouchPoint = nil
        
        resetTimer()
    }
    
    private func setUpBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 512, y: 384)
        background.setScale(1.28)
        background.zPosition = -1
        addChild(background)
        
        let curtain = SKSpriteNode(imageNamed: "curtains")
        curtain.position = CGPoint(x: 512, y: 384)
        curtain.setScale(1.28)
        curtain.zPosition = 100
        addChild(curtain)
        
        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 512, y: 384)
        grass.setScale(1.28)
        addChild(grass)
        
        let waterBG = SKSpriteNode(imageNamed: "water-bg")
        waterBG.position = CGPoint(x: 512, y: 248)
        waterBG.setScale(1.28)
        waterBG.zPosition = 2
        addChild(waterBG)
        
        let upAction1 = SKAction.moveBy(x: 0, y: -10, duration: 1.5)
        let downAction1 = SKAction.moveBy(x: 0, y: 10, duration: 1.5)
        let sequence1 = SKAction.sequence([upAction1, downAction1])
        let repeatAction1 = SKAction.repeatForever(sequence1)
        waterBG.run(repeatAction1)

        let waterFG = SKSpriteNode(imageNamed: "water-fg")
        waterFG.position = CGPoint(x: 512, y: 180)
        waterFG.setScale(1.28)
        waterFG.zPosition = 4
        addChild(waterFG)

        let upAction2 = SKAction.moveBy(x: 0, y: -12, duration: 1)
        let downAction2 = SKAction.moveBy(x: 0, y: 12, duration: 1)
        let sequence2 = SKAction.sequence([upAction2, downAction2])
        let repeatAction2 = SKAction.repeatForever(sequence2)
        waterFG.run(repeatAction2)
        
        addChild(remainingShotsNode)
        addChild(scoreLabel)
    }
}

extension SKNode {
    static let targetIdentifier = "Target"
}

//
//  GameScene.swift
//  Project17
//
//  Created by Dillon McElhinney on 7/28/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var isTracking = false

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var timeInterval: TimeInterval = 0.35
    var enemyCounter = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black

        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        resetGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard !isGameOver else {
            resetGame()
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let nodes = Set(self.nodes(at: location))
        // Only start tracking if the touch is in the spaceship
        if nodes.contains(player) { isTracking = true }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard isTracking else { return }
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        isTracking = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        endGame()
    }
    
    @objc func createEnemy() {
        guard !isGameOver else { return }
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        let y = Int.random(in: 50...736)
        sprite.position = CGPoint(x: 1200, y: y)
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!,
                                           size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.linearDamping = 0
        
        enemyCounter += 1

        if enemyCounter >= 20 {
            enemyCounter = 0
            timeInterval -= 0.01
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(createEnemy),
                                             userInfo: nil, repeats: true)
        }
    }
    
    func endGame() {
        isGameOver = true
        gameTimer?.invalidate()
        
        let waitAction = SKAction.wait(forDuration: 0)
        let moveAction = SKAction.move(to: CGPoint(x: 512, y: 360), duration: 0.6)
        let scaleAction = SKAction.scale(to: 3, duration: 0.6)
        let groupAction = SKAction.group([moveAction, scaleAction])
        scoreLabel.run(SKAction.sequence([waitAction, groupAction]))
    }
    
    func resetGame() {
        isGameOver = false
        
        player?.removeFromParent()
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!,
                                           size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel?.removeFromParent()
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 120, y: 16)
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                         target: self,
                                         selector: #selector(createEnemy),
                                         userInfo: nil, repeats: true)
    }
}

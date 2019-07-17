//
//  WhackSlot.swift
//  Project14
//
//  Created by Dillon McElhinney on 7/15/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit

class WhackSlot: SKNode {
    
    var isVisible = false
    var isHit = false
    var charNode: SKSpriteNode!
    let charOrigin = CGPoint(x: 0, y: -90)
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")

        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = charOrigin
        charNode.name = "character"
        cropNode.addChild(charNode)

        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        addEmitter(called: "mud", at: CGPoint(x: 10, y: -30))
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        charNode.run(SKAction.move(to: charOrigin, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        addEmitter(called: "smoke",
                   at: charNode.position,
                   with: 2)
        
        let smash = SKAction.scaleY(to: 0.3,
                                    duration: 0.12)
        let hide = SKAction.move(to: charOrigin,
                                 duration: 0.25)
        let notVisible = SKAction.run { [unowned self] in
            self.isVisible = false
        }
        charNode.run(SKAction.sequence([smash, hide, notVisible]))
    }
    
    private func addEmitter(called name: String,
                            at position: CGPoint,
                            with zPosition: CGFloat = 0) {
        
        if let emitter = SKEmitterNode(fileNamed: name) {
            emitter.position = position
            emitter.zPosition = zPosition
            
            let numParticles = Double(emitter.numParticlesToEmit)
            let lifetime = Double(emitter.particleLifetime)
            let emitterDuration = numParticles * lifetime
            
            let addEmitterAction = SKAction.run { self.addChild(emitter) }
            let waitAction = SKAction.wait(forDuration: emitterDuration)
            let removeAction = SKAction.run { emitter.removeFromParent() }
            let actions = [addEmitterAction, waitAction, removeAction]
            let sequence = SKAction.sequence(actions)
            run(sequence)
        }
        
    }
    
}

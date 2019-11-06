//
//  GameScene.swift
//  Project29
//
//  Created by Dillon McElhinney on 11/4/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene {
    
    weak var viewController: GameViewController!

    var buildings: [BuildingNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669,
                                  saturation: 0.99,
                                  brightness: 0.67,
                                  alpha: 1)

        createBuildings()
    }

    func launch(angle: Int, velocity: Int) {
    }

    private func createBuildings() {
        var currentX: CGFloat = -15

        while currentX < 1024 {
            let width = Int.random(in: 2...4) * 40
            let height = Int.random(in: 300...600)
            let size = CGSize(width: width,
                              height: height)
            currentX += size.width + 2

            let building = BuildingNode(color: UIColor.red,
                                        size: size)
            let x = currentX - (size.width / 2)
            let y = size.height / 2
            building.position = CGPoint(x: x, y: y)
            building.setup()
            addChild(building)

            buildings.append(building)
        }
    }
   
}

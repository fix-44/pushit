//
//  brickModel.swift
//  pushit
//
//  Created by Octavian on 22/02/24.
//

import Foundation
import UIKit
import SpriteKit

class bricks {
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    
    var spriteNode : SKShapeNode
    var size: CGSize
    var color : UIColor
    var position: CGPoint
    init(size:CGSize, color: UIColor, position: CGPoint, name: String) {
        self.size = size
        self.color = color
        self.position = position
        spriteNode = SKShapeNode(rectOf: size )
        spriteNode.fillColor = self.color
        spriteNode.position = position
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: size )
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.isDynamic = false
        spriteNode.physicsBody?.categoryBitMask = CollisionCategory.brick.rawValue
        spriteNode.physicsBody?.collisionBitMask = CollisionCategory.item.rawValue | CollisionCategory.player.rawValue
        spriteNode.physicsBody?.contactTestBitMask = CollisionCategory.item.rawValue | CollisionCategory.player.rawValue
        spriteNode.name = name
        spriteNode.scene?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    func updateValueColor(color : UIColor){
//        colorValue = colorValue == 0 ? 1 : 0
        spriteNode.fillColor = color
    }
    
}

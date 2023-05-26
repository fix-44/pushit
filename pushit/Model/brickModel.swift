//
//  brickModel.swift
//  pushit
//
//  Created by Octavian on 22/05/23.
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
    var colorValue : Int
    var position: CGPoint
    init(size:CGSize, colorValue:Int, position: CGPoint, name: String) {
        self.size = size
        self.colorValue = colorValue
        self.position = position
        spriteNode = SKShapeNode(rectOf: size )
        spriteNode.fillColor = self.colorValue == 0  ? blue : green
        spriteNode.position = position
        
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: size )
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.isDynamic = false
        spriteNode.physicsBody?.categoryBitMask = CollisionCategory.brick.rawValue
        spriteNode.physicsBody?.collisionBitMask = CollisionCategory.item.rawValue | CollisionCategory.player.rawValue
        spriteNode.physicsBody?.contactTestBitMask = CollisionCategory.item.rawValue | CollisionCategory.player.rawValue
        spriteNode.name = name
        
    }
    
    func updateValueColor(){
        colorValue = colorValue == 0 ? 1 : 0
        spriteNode.fillColor = self.colorValue == 0  ? blue : green
    }
    
}

//
//  PlayerModel.swift
//  pushit
//
//  Created by Octavian on 22/05/23.
//

import Foundation
import UIKit
import SpriteKit

class players {
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    var spriteNode : SKShapeNode
    var radius: CGFloat
    var position: CGPoint
    var color: UIColor
    var isPulling : Bool = false
    var maxSpeed : CGFloat = 200
    let defaultMass = 0.1
    let defaultRestitution = 0.7
    let defaultDamping = 0.5
    var speed : CGFloat = 0
    var HP : Int = 20
    
    
    
    init(radius:CGFloat, active:Bool, position: CGPoint, color: UIColor, name : String) {
        self.radius = radius
        self.position = position
        self.color = color
        spriteNode = SKShapeNode(circleOfRadius: radius)
        spriteNode.fillColor = color
        spriteNode.position = position
        spriteNode.strokeColor = .white
        spriteNode.lineWidth = 3
        spriteNode.name = name
        
        spriteNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.linearDamping = defaultDamping
        spriteNode.physicsBody?.restitution = defaultRestitution
        spriteNode.physicsBody?.mass = defaultMass
        spriteNode.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue
        spriteNode.physicsBody?.collisionBitMask = CollisionCategory.item.rawValue | CollisionCategory.brick.rawValue | CollisionCategory.player.rawValue
        spriteNode.physicsBody?.contactTestBitMask = CollisionCategory.item.rawValue | CollisionCategory.brick.rawValue | CollisionCategory.player.rawValue
        
    }
    
    func toggleIsPulling(){
        isPulling.toggle()
    }
    
    func updateMaxSpeed(delta : CGFloat){
        maxSpeed += delta
    }

    func updateMass(delta :CGFloat){
        spriteNode.physicsBody?.mass += delta
    }
    
}

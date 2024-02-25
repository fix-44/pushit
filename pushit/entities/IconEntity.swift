//
//  IconEntity.swift
//  pushit
//
//  Created by Octavian on 22/02/24.
//


import Foundation
import UIKit
import SpriteKit

class playerIcon {
    var spriteNode : SKShapeNode
    var radius: CGFloat
    var position: CGPoint
    var color: UIColor
    var owner: String
    
    
    init(radius:CGFloat, position: CGPoint, color: UIColor, name : String, owner : String) {
        self.radius = radius
        self.position = position
        self.color = color
        self.owner = owner
        spriteNode = SKShapeNode(circleOfRadius: radius)
        spriteNode.fillColor = color
        spriteNode.position = position
        spriteNode.strokeColor = .white
        spriteNode.lineWidth = 5
        spriteNode.name = name
        
    }
    
    
}

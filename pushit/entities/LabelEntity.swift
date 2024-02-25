//
//  LabelModel.swift
//  pushit
//
//  Created by Octavian on 22/02/24.
//

import Foundation
import UIKit
import SpriteKit
import SwiftUI
class texts {
    var spriteNode : SKLabelNode
    var position : CGPoint?
    var fontSize : CGFloat?
    var color : UIColor?
    var text : String?
    var owner : String
    
    init(position: CGPoint, fontSize: CGFloat, color: UIColor, text: String, name : String, owner: String) {
        self.position = position
        self.fontSize = fontSize
        self.color = color
        self.text = text
        self.owner = owner
        spriteNode = SKLabelNode(text: text)
        spriteNode.name = name
        spriteNode.position = position
        spriteNode.fontName = "SF Pro"
        spriteNode.fontSize = fontSize
        spriteNode.horizontalAlignmentMode = .left
        
    }
}

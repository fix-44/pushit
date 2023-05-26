//
//  GameScene.swift
//  pushit
//
//  Created by Octavian on 21/05/23.
//

import SpriteKit
import GameplayKit
import AVFoundation

class HomeScene: SKScene, SKPhysicsContactDelegate {
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    let hideColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    let totalAllBrick = 40
    var totalgreenBrick = 20
    var totalblueBrick = 20
    var brickList : [bricks] = []
    var player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1")
    var player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2")
    var title = texts(position: CGPoint(x: 200,y: 400), fontSize: 36, color: .white, text: "PUSH IT", name: "title")
    var playersList : [players] = []
    var audioPlayer: AVAudioPlayer?
    
    private var pullStartTime: TimeInterval = 0.0
    private var initialPosition: CGPoint = .zero
    private var lineNode: SKShapeNode?
    private var startPoint: CGPoint?
    
    let bounceWithBall = SKAction.playSoundFileNamed("bouncePlayer", waitForCompletion: false)
    
    let bounceBrick = SKAction.playSoundFileNamed("bounceBrick", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        addBackground()
        generateBrick()
        addPlayer()
        title.spriteNode.horizontalAlignmentMode = .center
        addChild(title.spriteNode)
        startContinuousMovement()
        if let soundURL = Bundle.main.url(forResource: "Home", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.numberOfLoops = -1
            } catch {
                print("Failed to load sound file: \(error)")
            }
        }
        audioPlayer?.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        switchToGameScene()
        
    }
    
    
    func startContinuousMovement() {
            // Create a vector representing the direction of movement
            let direction1 = CGVector(dx: 80.0, dy: 200.0) // Adjust the dx and dy values according to the desired direction
            let direction2 = CGVector(dx: -200.0, dy: -80.0)
            // Apply a continuous impulse to the node in the specified direction
            let impulseAction1 = SKAction.applyImpulse(direction1, duration: 3)
            let impulseAction2 = SKAction.applyImpulse(direction2, duration: 3)
        
            let repeatAction1 = SKAction.repeatForever(impulseAction1)
            let repeatAction2 = SKAction.repeatForever(impulseAction2)
            player1.spriteNode.run(repeatAction1)
            player2.spriteNode.run(repeatAction2)
        }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bitMaskA = contact.bodyA.categoryBitMask
        let bitMaskB = contact.bodyB.categoryBitMask
        
        //collide player and brick
        if checkContactBitMask(expectedBody: bitMaskA, unexpectedBody: bitMaskB, expectedBitMask: CollisionCategory.brick.rawValue, unexpectedBitMask: CollisionCategory.player.rawValue) {
//            run(bounceBrick)
            for brick in brickList {
                for player in playersList {
                        if brick.spriteNode.name == contact.bodyA.node?.name && player.spriteNode.name == contact.bodyB.node?.name{
                            if !brick.spriteNode.fillColor.isEqual(player.spriteNode.fillColor){
                                brick.updateValueColor()
                                run(bounceBrick)
                            } else {
                                run(bounceWithBall)
                            }
                            break
                    }
                }
            }
            
        } else if checkContactBitMask(expectedBody: bitMaskB, unexpectedBody: bitMaskA, expectedBitMask: CollisionCategory.brick.rawValue, unexpectedBitMask: CollisionCategory.player.rawValue){
            for brick in brickList {
                for player in playersList {
                        if brick.spriteNode.name == contact.bodyB.node?.name && player.spriteNode.name == contact.bodyA.node?.name{
                            if !brick.spriteNode.fillColor.isEqual(player.spriteNode.fillColor){
                                brick.updateValueColor()
                                run(bounceBrick)
                            } else {
                                run(bounceWithBall)
                            }
                            break
                    }
                }
            }
            
        } else if checkContactBitMask(expectedBody: bitMaskB, unexpectedBody: bitMaskA, expectedBitMask: CollisionCategory.player.rawValue, unexpectedBitMask: CollisionCategory.player.rawValue){
            run(bounceWithBall)
        }
    }
    
    func checkContactBitMask(expectedBody: UInt32, unexpectedBody: UInt32, expectedBitMask: UInt32, unexpectedBitMask: UInt32) -> Bool{
        if expectedBody == expectedBitMask && unexpectedBody == unexpectedBitMask {
            return true
        } else {
            return false
        }
    }

    
    func changeColorBrick(brickBodyName:String, playerBodyName:String){
        for brick in brickList {
            for player in playersList {
                    if brick.spriteNode.name == brickBodyName && player.spriteNode.name == playerBodyName{
                        print(brick.spriteNode.fillColor)
                        print(player.spriteNode.fillColor)
                        if brick.spriteNode.fillColor.isEqual(player.spriteNode.fillColor){
                            brick.updateValueColor()
                        }
                        break
                }
            }
        }
    }
    
    func getDistance(nodeA : CGPoint, nodeB : CGPoint) -> CGFloat{
        return sqrt(pow(nodeA.x-nodeB.x,2) + pow(nodeA.y-nodeB.y,2))
    }
    
    
    
    
    func addBackground() {
        let sceneRect = CGRect(x: 0, y: 0, width: size.width+5, height: size.height+5)
        let backgroundRect = SKShapeNode(rect: sceneRect)
        backgroundRect.fillColor = darkBlue
        backgroundRect.position = CGPoint(x: -2, y: -2)
        backgroundRect.zPosition = -1000
        addChild(backgroundRect)
    }
    
    func generateBrick() {
        var botBrickX = 45
        var botBrickY = 735
        var rightBrickX = 365
        var rightBrickY = 715
        var topBrickX = 345
        var topBrickY = 95
        var leftBrickX = 25
        var leftBrickY = 115
        for i in 1...totalAllBrick {
            var sizeBrick = CGSize(width: 50, height: 10)
            var positionBrick = CGPoint(x: 0, y: 0)
            var colorValue = i%2==0 ? 0 : 1
            if i <= 7 {
                positionBrick = CGPoint(x: botBrickX, y: botBrickY)
                botBrickX += 50
            }  else if i <= 20 {
                positionBrick = CGPoint(x: rightBrickX, y: rightBrickY)
                rightBrickY -= 50
                sizeBrick = CGSize(width: 10, height: 50)
            }  else if i <= 27 {
                positionBrick = CGPoint(x: topBrickX, y: topBrickY)
                topBrickX -= 50
            } else if i <= 40 {
                positionBrick = CGPoint(x: leftBrickX, y: leftBrickY)
                leftBrickY += 50
                sizeBrick = CGSize(width: 10, height: 50)
            }
            
            var brick =  pushit.bricks(size: sizeBrick, colorValue: colorValue, position: positionBrick, name: String(i))
            brickList.append(brick)
            addChild(brick.spriteNode)
        }
    }
    
    func generatePlayer(){
        
    }
    
    func addPlayer(){
        player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1")
        player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2")
        playersList.append(player1)
        playersList.append(player2)
        addChild(player1.spriteNode)
        addChild(player2.spriteNode)
    }
    
    func switchToGameScene() {
        audioPlayer?.stop()
        if let view = self.view {
            let gameScene = GameScene(size: view.bounds.size)
            view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

    
}

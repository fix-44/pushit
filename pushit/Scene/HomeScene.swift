//
//  GameScene.swift
//  pushit
//
//  Created by Octavian on 22/02/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class HomeScene: SKScene, SKPhysicsContactDelegate {
    var totalBrickWidth : Int = 10
    var totalBrickHeigh : Int = 14
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    let hideColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    let totalAllBrick = 40
    var totalgreenBrick = 20
    var totalblueBrick = 20
    var brickList : [bricks] = []
    var player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1", turnID: 0)
    var player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2", turnID: 1)
    var title = texts(position: CGPoint(x: 200,y: 400), fontSize: 50, color: .white, text: "PUSH IT", name: "title", owner: "none")

    
    var playersList : [players] = []
    var audioPlayer: AVAudioPlayer?
    var modeList : [texts]  = []
    

    
    let bounceWithBall = SKAction.playSoundFileNamed("bouncePlayer", waitForCompletion: false)
    
    let bounceBrick = SKAction.playSoundFileNamed("bounceBrick", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        let screenSize = view.bounds.size
        addBackground()
        generateBrick()
        addPlayer()
        title.spriteNode.horizontalAlignmentMode = .center
        title.spriteNode.position = CGPoint(x: screenSize.width*0.5, y: screenSize.height*0.5)
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
        for touch in touches {
            let touchLocation = touch.location(in: self)
            for mode in modeList {
                if mode.spriteNode.contains(touchLocation) {
                    let playerCount = Int(mode.spriteNode.name!)
                    GameManager.sharedData.playerCount = playerCount!
                    if let view = self.view {
                        let GameScene = GameScene(size: view.bounds.size)
                        view.presentScene(GameScene, transition: SKTransition.fade(withDuration: 0.5))
                    }
                }
            }
        }
        title.spriteNode.removeFromParent()
        showModeOptions()
        
    }
    
    
    func startContinuousMovement() {
            // Create a vector representing the direction of movement
        let dx1 = Double.random(in: -200...200)
        let dx2 = Double.random(in: -200...200)
        let dy1 = Double.random(in: -200...200)
        let dy2 = Double.random(in: -200...200)
        let direction1 = CGVector(dx: dx1, dy: dy1)
        let direction2 = CGVector(dx: dx2, dy: dy2)
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
                                brick.updateValueColor(color: player.spriteNode.fillColor)
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
                                brick.updateValueColor(color: player.spriteNode.fillColor)
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
                            brick.updateValueColor(color : player.spriteNode.fillColor)
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
        let screenWidth = self.size.width
        let screenHeight = self.size.height
//        let screenWidth : Double = screenSize.width*screenScale
//        let screenHeight : Double = screenSize.height*screenScale

        let marginWidthRatio : Double = 0.2
        let marginWidth : Double = 0.5*marginWidthRatio*screenWidth
        let brickLenghtSize : Double =  (screenWidth - 2*marginWidth)/Double(totalBrickWidth)
        let marginHeight : Double = 0.5*(screenHeight - brickLenghtSize*Double(totalBrickHeigh))
        let ratioBrickThick : Double = 0.2
        let brickThickSize = brickLenghtSize*ratioBrickThick
        let cornerGab : Double = 0.5*brickThickSize
//        var cornerGab : Double = 0
        
        var botBrickX = marginWidth+0.5*brickLenghtSize
//        var botBrickY = marginHeight+Double(totalBrickHeigh)*brickLenghtSize+cornerGab
        let botBrickY = screenHeight-marginHeight+cornerGab
        
        var topBrickX = marginWidth+0.5*brickLenghtSize
        let topBrickY = marginHeight-cornerGab

        let leftBrickX = marginWidth-cornerGab
        var leftBrickY = marginHeight+0.5*brickLenghtSize
        
        let rightBrickX = marginWidth+Double(totalBrickWidth)*brickLenghtSize+cornerGab
        var rightBrickY = marginHeight+0.5*brickLenghtSize

        
        //Horizontal Brick
        
        for i in 1...totalBrickWidth{
            let sizeBrick = CGSize(width: brickLenghtSize, height: brickThickSize)
            var positionBrick = CGPoint(x: botBrickX, y: botBrickY)
            var brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            print(brick)
            botBrickX+=brickLenghtSize
            positionBrick = CGPoint(x: topBrickX, y: topBrickY)
            brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            topBrickX+=brickLenghtSize
        }
        
        for i in 1...totalBrickHeigh{
            let sizeBrick = CGSize(width: brickThickSize, height: brickLenghtSize)
            var positionBrick = CGPoint(x: rightBrickX, y: rightBrickY)
            
            var brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            print(brick)
            rightBrickY+=brickLenghtSize
            positionBrick = CGPoint(x: leftBrickX, y: leftBrickY)
            brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            leftBrickY+=brickLenghtSize
        }
    }

    func playerSize() -> Double{
        let screenWidth = self.size.width
        let marginWidthRatio : Double = 0.2
        let marginWidth : Double = 0.5*marginWidthRatio*screenWidth
        let playerSize : Double =  (screenWidth - 2*marginWidth)*0.5/Double(totalBrickWidth)
        return playerSize
    }
    
    func addPlayer(){
        let playerSize = playerSize()
        player1 = players(radius: playerSize, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1", turnID: 0)
        player2 = players(radius: playerSize, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2", turnID: 1)
        playersList.append(player1)
        playersList.append(player2)
        addChild(player1.spriteNode)
        addChild(player2.spriteNode)
        player1.spriteNode.physicsBody?.restitution = 1
        player1.spriteNode.physicsBody?.linearDamping = 0.1
        player1.spriteNode.physicsBody?.restitution = 0.1
        player1.spriteNode.physicsBody?.friction = 0
        
        player2.spriteNode.physicsBody?.restitution = 1
        player2.spriteNode.physicsBody?.linearDamping = 0.1
        player2.spriteNode.physicsBody?.restitution = 0.1
        player2.spriteNode.physicsBody?.friction = 0
    }
    
    func switchToGameScene() {
        audioPlayer?.stop()
        if let view = self.view {
            let gameScene = GameScene(size: view.bounds.size)
            view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

    func showModeOptions(){
        let screenSize = view?.bounds.size
        let textPosition = [
            CGPoint(x: screenSize!.width*0.35, y: screenSize!.height*0.6),
            CGPoint(x: screenSize!.width*0.65, y: screenSize!.height*0.6),
            CGPoint(x: screenSize!.width*0.5, y: screenSize!.height*0.45)
            
        ]
        
        let modeTextList = [
            "2 Players",
            "3 Players",
            "4 Players"
        ]
        
        for i in 0..<modeTextList.count {
            let mode = texts(position: textPosition[i], fontSize: 35, color: .white, text: modeTextList[i],  name: "\(i+2)", owner: "none")
            mode.spriteNode.horizontalAlignmentMode = .center
            mode.spriteNode.verticalAlignmentMode = .center
            modeList.append(mode)
            addChild(mode.spriteNode)
        }
        
        
        
    }
    
}

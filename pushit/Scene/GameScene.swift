//
//  GameScene.swift
//  pushit
//
//  Created by Octavian on 21/05/23.
//

import SpriteKit
import GameplayKit
import CoreHaptics
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    let hideColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    let totalAllBrick = 40
    var totalgreenBrick = 20
    var totalblueBrick = 20
    var brickList : [bricks] = []
    var player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1")
    let player1Icon = players(radius: 25, active: false, position: CGPoint(x: 60, y: 50), color: UIColor(named: "blueColor") ?? .blue, name: "player1Icon")
    var labelPlayer1HP = texts(position: CGPoint(x: 100, y: 55), fontSize: 20, color: .white, text: "20", name: "labelPlayer1HP")
    var labelPlayer1Weight = texts(position: CGPoint(x: 100, y: 35), fontSize: 20, color: .white, text: "20", name: "labelPlayer1Weight")
    var player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2")
    let player2Icon = players(radius: 25, active: false, position: CGPoint(x: 60, y: 780), color: UIColor(named: "greenColor") ?? .green, name: "player2Icon")
    var labelPlayer2HP = texts(position: CGPoint(x: 100, y: 785), fontSize: 20, color: .white, text: "20", name: "labelPlayer2HP")
    var labelPlayer2Weight = texts(position: CGPoint(x: 100, y: 765), fontSize: 20, color: .white, text: "20", name: "labelPlayer2Weight")
    
    var playersList : [players] = []
    var pinPoint = SKShapeNode(circleOfRadius: 5)
    var isPulling = false
    var turn = "player1"
    
    private var hapticManager: HapticManager?
    
    private var initialPosition: CGPoint = .zero
    private var lineNode: SKShapeNode?
    private var startPoint: CGPoint?
    
    var gameOver : Bool = false
    
    var audioPlayer : AVAudioPlayer?
    let bounceWithBall = SKAction.playSoundFileNamed("bouncePlayer", waitForCompletion: false)
    
    let bounceBrick = SKAction.playSoundFileNamed("bounceBrick", waitForCompletion: false)

    let cheer = SKAction.repeatForever(SKAction.playSoundFileNamed("cheer", waitForCompletion: true))

    
            
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        if let soundURL = Bundle.main.url(forResource: "Game", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.numberOfLoops = -1
            } catch {
                print("Failed to load sound file: \(error)")
            }
        }
        audioPlayer?.play()
        

//        let repeatAction = SKAction.repeatForever(action)

//        removeAllActions()
        addBackground()
        generateBrick()
        addAttributGame()
        addPlayer()
        createPinPoin()
        hapticManager = HapticManager()
        

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//
        if gameOver {
            switchToHomeScene()
        }

        
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if player1.spriteNode.contains(touchLocation) && turn == "player1" {
                player1.isPulling = true
                initialPosition = player1.spriteNode.position
                pinPoint.position = initialPosition
                pinPoint.fillColor = .white
                startPoint = pinPoint.position
                // Create and add the line node
                lineNode = SKShapeNode()
                addChild(lineNode!)
            } else if(player2.spriteNode.contains(touchLocation)) && turn == "player2"{
                player2.isPulling = true
                initialPosition = player2.spriteNode.position
                pinPoint.position = initialPosition
                pinPoint.fillColor = .white
                startPoint = pinPoint.position
                // Create and add the line node
                lineNode = SKShapeNode()
                addChild(lineNode!)
            }
        }

        
        
        
//        let speed: CGFloat = 500.0 // The speed of movement
//        let angleInDegrees: CGFloat = 45.0 // The desired angle in degrees
//
//        // Convert the angle from degrees to radians
//        let angleInRadians = angleInDegrees * CGFloat.pi / 180.0
//
//        // Calculate the x and y components of the vector using trigonometry
//        let dx = cos(angleInRadians) * speed
//        let dy = sin(angleInRadians) * speed
//
//
//
//        let impulse = CGVector(dx: dx, dy: dy)
//        // Apply the impulse to the circle's physics body
//        player1.spriteNode.physicsBody?.applyImpulse(impulse)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                let touchLocation = touch.location(in: self)

                if player1.isPulling {
                    player1.speed =  getDistance(nodeA: initialPosition, nodeB: touchLocation)
                    let speed: CGFloat = min(player1.speed, player1.maxSpeed)
                    player1.speed = speed
                    updateLabelAtrributs()
                    
                    pinPoint.position = touchLocation
                    // Create a path for the line segment
                    let path = CGMutablePath()
//                    startPoint = player1.position
                    path.move(to: startPoint ?? touchLocation)
                    path.addLine(to: touchLocation)

                    // Update the path of the line node
                    lineNode?.path = path
                    lineNode?.strokeColor = .white
                    lineNode?.lineWidth = 3.0

                    // Add arrow at the end of the line
//                    addArrow(at: touchLocation, towards: startPoint ?? touchLocation)
                } else if (player2.isPulling){
                    player2.speed =  getDistance(nodeA: initialPosition, nodeB: touchLocation)
                    let speed: CGFloat = min(player2.speed, player2.maxSpeed)
                    player2.speed = speed
                    updateLabelAtrributs()
                    pinPoint.position = touchLocation
                    // Create a path for the line segment
                    let path = CGMutablePath()
//                    startPoint = player1.position
                    path.move(to: startPoint ?? touchLocation)
                    path.addLine(to: touchLocation)

                    // Update the path of the line node
                    lineNode?.path = path
                    lineNode?.strokeColor = .white
                    lineNode?.lineWidth = 3.0

                   
                }
            }
        }
    

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player1.isPulling == true {
            player1.isPulling = false
            pinPoint.fillColor = hideColor
            let angle = atan2(-1*(pinPoint.position.y - player1.spriteNode.position.y), -1*(pinPoint.position.x - player1.spriteNode.position.x))
            
            let speed: CGFloat = min(player1.speed, player1.maxSpeed)

            
            let dx = cos(angle) * speed
            let dy = sin(angle) * speed

            // Apply an impulse to the physics body of the circle
            let impulse = CGVector(dx: dx, dy: dy)
            player1.spriteNode.physicsBody?.applyImpulse(impulse)
            lineNode?.removeFromParent()
            lineNode = nil

               // Reset the start point
            startPoint = nil
//            player1.spriteNode.physicsBody?.applyImpulse(launchDirection * -200)
            player1.speed = 0
            turn = "player2"
            updateLabelAtrributs()
            changeAnimationStoke()
            
        } else if player2.isPulling == true {
            player2.isPulling = false
            pinPoint.fillColor = hideColor
            let angle = atan2(-1*(pinPoint.position.y - player2.spriteNode.position.y), -1*(pinPoint.position.x - player2.spriteNode.position.x))
            
            let speed: CGFloat = min(player2.speed, player2.maxSpeed)
            let dx = cos(angle) * speed
            let dy = sin(angle) * speed

            // Apply an impulse to the physics body of the circle
            let impulse = CGVector(dx: dx, dy: dy)
            player2.spriteNode.physicsBody?.applyImpulse(impulse)
            lineNode?.removeFromParent()
            lineNode = nil

               // Reset the start point
            startPoint = nil
//            player1.spriteNode.physicsBody?.applyImpulse(launchDirection * -200)
            player2.speed = 0
            turn = "player1"
            updateLabelAtrributs()
            changeAnimationStoke()
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bitMaskA = contact.bodyA.categoryBitMask
        let bitMaskB = contact.bodyB.categoryBitMask
        
        //collide player and brick
        if checkContactBitMask(expectedBody: bitMaskA, unexpectedBody: bitMaskB, expectedBitMask: CollisionCategory.brick.rawValue, unexpectedBitMask: CollisionCategory.player.rawValue) {

            for brick in brickList {
                for player in playersList {
                        if brick.spriteNode.name == contact.bodyA.node?.name && player.spriteNode.name == contact.bodyB.node?.name{
                            if !brick.spriteNode.fillColor.isEqual(player.spriteNode.fillColor){
                                brick.updateValueColor()
                                print(player.spriteNode.name)
                                if player.spriteNode.name == player1.spriteNode.name {
                                    player1.HP -= gameOver ? 0 : 1
                                    gameOver = player1.HP == 0 ? true : false
                                    updateLabelAtrributs()
                                    hapticManager?.playSlice()
                                } else if player.spriteNode.name == player2.spriteNode.name {
                                    player2.HP -= gameOver ? 0 : 1
                                    gameOver = player2.HP == 0 ? true : false
                                    updateLabelAtrributs()
                                    hapticManager?.playSlice()
                                }
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
                                if player.spriteNode.name == "player1" {
                                    player1.HP -= gameOver ? 0 : 1
                                    gameOver = player1.HP == 0 ? true : false
                                    updateLabelAtrributs()
                                    hapticManager?.playSlice()
                                } else if player.spriteNode.name == "player2" {
                                    player2.HP -= gameOver ? 0 : 1
                                    gameOver = player2.HP == 0 ? true : false
                                    updateLabelAtrributs()
                                    hapticManager?.playSlice()
                                }
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
        
        if player1.HP == 0 {
            player1.spriteNode.removeFromParent()
            winnerText(winner: "GREEN")
        } else if (player2.HP == 0) {
            player2.spriteNode.removeFromParent()
            winnerText(winner: "BLUE")
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
    
    
    

    override func update(_ currentTime: TimeInterval) {
        
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
    
    func createPinPoin(){
        pinPoint.fillColor = hideColor
        pinPoint.position = CGPoint(x: 200, y: 200)
        pinPoint.strokeColor = hideColor
        addChild(pinPoint)
    }
    
    func addPlayer(){
        player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1")
        player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2")
        playersList.append(player1)
        playersList.append(player2)
        changeAnimationStoke()
        addChild(player1.spriteNode)
        addChild(player2.spriteNode)
    }
    
    func changeAnimationStoke(){
        if turn == "player1" {
            player1.spriteNode.strokeColor = .white
            player2.spriteNode.strokeColor = hideColor
        } else if turn == "player2" {
            player1.spriteNode.strokeColor = hideColor
            player2.spriteNode.strokeColor = .white
        } else {
            player1.spriteNode.strokeColor = hideColor
            player2.spriteNode.strokeColor = hideColor
        }
    }
    
    func addAttributGame(){
        addChild(player1Icon.spriteNode)
        addChild(player2Icon.spriteNode)
        labelPlayer1HP.spriteNode.text = "HP : \(player1.HP)"
        labelPlayer2HP.spriteNode.text = "HP : \(player2.HP)"
        labelPlayer1Weight.spriteNode.text = "Power : \(Int(player1.speed*100/player1.maxSpeed))%"
        labelPlayer2Weight.spriteNode.text = "Power : \(Int(player2.speed*100/player2.maxSpeed))%"
        addChild(labelPlayer1Weight.spriteNode)
        addChild(labelPlayer2Weight.spriteNode)
        addChild(labelPlayer1HP.spriteNode)
        addChild(labelPlayer2HP.spriteNode)
    }
    func updateLabelAtrributs(){
        labelPlayer1HP.spriteNode.text = "HP : \(player1.HP)"
        labelPlayer2HP.spriteNode.text = "HP : \(player2.HP)"
        labelPlayer1Weight.spriteNode.text = "Power : \(Int(player1.speed*100/player1.maxSpeed))%"
        labelPlayer2Weight.spriteNode.text = "Power : \(Int(player2.speed*100/player2.maxSpeed))%"
    }
    
    func winnerText(winner : String){
        let win = texts(position: CGPoint(x: 200,y: 400), fontSize: 36, color: .white, text: winner + " WIN", name: "win")
        let pressAny = texts(position: CGPoint(x: 200,y: 380), fontSize: 12, color: .white, text: "press any to back home", name: "pressAny")
        win.spriteNode.horizontalAlignmentMode = .center
        pressAny.spriteNode.horizontalAlignmentMode = .center
        addChild(win.spriteNode)
        addChild(pressAny.spriteNode)
        gameOver = true
        run(cheer)
    }
 
    func switchToHomeScene() {
//        audioPlayer?.stop()
        if let view = self.view {
            let homeScene = HomeScene(size: view.bounds.size)
            view.presentScene(homeScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
    
}

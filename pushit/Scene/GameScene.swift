//
//  GameScene.swift
//  pushit
//
//  Created by Octavian on 22/02/24.
//

import SpriteKit
import GameplayKit
import CoreHaptics
import AVFoundation
import UIKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    let blue = UIColor(named: "blueColor") ?? .blue
    let green = UIColor(named: "greenColor") ?? .green
    let darkBlue = UIColor(named: "midColor") ?? .black
    let hideColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    var colorList = [
        UIColor(named: "blueColor") ?? .blue,
        UIColor(named: "greenColor") ?? .green,
        UIColor(named: "pinkColor") ?? .systemPink,
        UIColor(named: "redColor") ?? .red
    ]
    
    var marginWidthRatio : Double = 0.25
    var totalBrickWidth : Int = 10
    var totalBrickHeigh : Int = 14
    let totalAllBrick = 40

    var brickList : [bricks] = []
    var player1 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 200), color: UIColor(named: "blueColor") ?? .blue, name: "Player1", turnID: 0)
//    let player1Icon = players(radius: 25, active: false, position: CGPoint(x: 60, y: 50), color: UIColor(named: "blueColor") ?? .blue, name: "player1Icon")
//    var labelPlayer1HP = texts(position: CGPoint(x: 100, y: 55), fontSize: 20, color: .white, text: "20", name: "labelPlayer1HP")
//    var labelPlayer1Weight = texts(position: CGPoint(x: 100, y: 35), fontSize: 20, color: .white, text: "20", name: "labelPlayer1Weight")
    var player2 = players(radius: 25, active: true, position: CGPoint(x: 200, y: 600), color: UIColor(named: "greenColor") ?? .green, name: "Player2", turnID: 0)
//    let player2Icon = players(radius: 25, active: false, position: CGPoint(x: 60, y: 780), color: UIColor(named: "greenColor") ?? .green, name: "player2Icon")
//    var labelPlayer2HP = texts(position: CGPoint(x: 100, y: 785), fontSize: 20, color: .white, text: "20", name: "labelPlayer2HP")
//    var labelPlayer2Weight = texts(position: CGPoint(x: 100, y: 765), fontSize: 20, color: .white, text: "20", name: "labelPlayer2Weight")
//    
    var playersList : [players] = []
    var playerIconList : [playerIcon] = []
    var playerHPLabelList : [texts] = []
    var playerPowerLabelList : [texts] = []
    
    var pinPoint = SKShapeNode(circleOfRadius: 5)
    var isPulling = false
    var turn = "player1"
    var turnCount = 0
    var turnIsOn = false
    var turnList : [Int] = []
    
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
                audioPlayer?.numberOfLoops =     -1
            } catch {
                print("Failed to load sound file: \(error)")
            }
        }
        audioPlayer?.play()
    
        addBackground()
        addPlayer()
        generateBrick()
        addAttributGame()
        createPinPoin()
        hapticManager = HapticManager()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver {
            switchToHomeScene()
        }
        
        
        for touch in touches {
            let turnPosition = turnList.first
            let touchLocation = touch.location(in: self)
            for player in playersList {
                if player.spriteNode.contains(touchLocation) && player.spriteNode.name == playersList[turnPosition!].spriteNode.name {
                    player.isPulling = true
                    initialPosition = player.spriteNode.position
                    pinPoint.position = initialPosition
                    pinPoint.fillColor = .white
                    startPoint = pinPoint.position
                    // Create and add the line node
                    lineNode = SKShapeNode()
                    addChild(lineNode!)
                }
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            for player in playersList {
                if player.isPulling {
                    player.speed =  getDistance(nodeA: initialPosition, nodeB: touchLocation)
                    let speed: CGFloat = min(player.speed, player.maxSpeed)
                    player.speed = speed
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
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for player in playersList{
            if player.isPulling == true {
                player.isPulling = false
                pinPoint.fillColor = hideColor
                let angle = atan2(-1*(pinPoint.position.y - player.spriteNode.position.y), -1*(pinPoint.position.x - player.spriteNode.position.x))
                
                let speed: CGFloat = min(player.speed, player.maxSpeed)
                
                
                let dx = cos(angle) * speed
                let dy = sin(angle) * speed
                
                // Apply an impulse to the physics body of the circle
                let impulse = CGVector(dx: dx, dy: dy)
                player.spriteNode.physicsBody?.applyImpulse(impulse)
                lineNode?.removeFromParent()
                lineNode = nil
                
                // Reset the start point
                startPoint = nil
                //            player1.spriteNode.physicsBody?.applyImpulse(launchDirection * -200)
                player.speed = 0
                updateTurnList()
                updateLabelAtrributs()
                changeAnimationStoke()
            }
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
                                brick.updateValueColor(color: player.spriteNode.fillColor)
                                player.HP -= gameOver ? 0 : 1
                                updateLabelAtrributs()
                                killPlayer()
                                gameOver = isGameOver()
                                hapticManager?.playSlice()
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
                                player.HP -= gameOver ? 0 : 1
                                killPlayer()
//                                gameOver = player1.HP == 0 ? true : false
                                gameOver = isGameOver()
                                updateLabelAtrributs()
                                hapticManager?.playSlice()
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
        
        if gameOver {
            winnerText(winner: "GREEN")
        }
        
        if player1.HP == 0 {
            player1.spriteNode.removeFromParent()
            
        } else if (player2.HP == 0) {
            player2.spriteNode.removeFromParent()
            winnerText(winner: "BLUE")
        }
//        changeAnimationStoke()
        
    }
    
    
    func checkContactBitMask(expectedBody: UInt32, unexpectedBody: UInt32, expectedBitMask: UInt32, unexpectedBitMask: UInt32) -> Bool{
        if expectedBody == expectedBitMask && unexpectedBody == unexpectedBitMask {
            return true
        } else {
            return false
        }
    }

    
//    func changeColorBrick(brickBodyName:String, playerBodyName:String){
//        for brick in brickList {
//            for player in playersList {
//                    if brick.spriteNode.name == brickBodyName && player.spriteNode.name == playerBodyName{
//                        print(brick.spriteNode.fillColor)
//                        print(player.spriteNode.fillColor)
//                        if brick.spriteNode.fillColor.isEqual(player.spriteNode.fillColor){
//                            brick.updateValueColor()
//                        }
//                        break
//                }
//            }
//        }
//    }
    
    func getDistance(nodeA : CGPoint, nodeB : CGPoint) -> CGFloat{
        return sqrt(pow(nodeA.x-nodeB.x,2) + pow(nodeA.y-nodeB.y,2))
    }
    
    
    

    override func update(_ currentTime: TimeInterval) {
        
            var isAllPlayerStop = true
            for player in playersList {
                if isPlayerMoving(player) {
                    isAllPlayerStop = false
                    break
                }
            }
            if isAllPlayerStop {
                changeAnimationStoke()
                turnIsOn = false
                
            }
        

    }
    
    func isPlayerMoving(_ player: players) -> Bool {
        guard let physicsBody = player.spriteNode.physicsBody else {
            print("Node does not have a physics body.")
            return false
        }
        

        let minimumSpeedThreshold: CGFloat = 0.0
        
        // Calculate the speed using the Pythagorean theorem
        let speed = sqrt(pow(physicsBody.velocity.dx, 2) + pow(physicsBody.velocity.dy, 2))
        
        // Check if the speed exceeds the threshold
        if speed > minimumSpeedThreshold {
            return true
        } else {
            return false
        }
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
        
        //Horizontal Bricks
        for i in 1...totalBrickWidth{
            let sizeBrick = CGSize(width: brickLenghtSize, height: brickThickSize)
            var positionBrick = CGPoint(x: botBrickX, y: botBrickY)
            var brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            botBrickX+=brickLenghtSize
            
            positionBrick = CGPoint(x: topBrickX, y: topBrickY)
            brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            topBrickX+=brickLenghtSize
        }
        
        //Vertical Bricks
        for i in 1...totalBrickHeigh{
            let sizeBrick = CGSize(width: brickThickSize, height: brickLenghtSize)
            var positionBrick = CGPoint(x: rightBrickX, y: rightBrickY)
            var brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            rightBrickY+=brickLenghtSize
            positionBrick = CGPoint(x: leftBrickX, y: leftBrickY)
            brick =  bricks(size: sizeBrick, color: blue, position: positionBrick, name: String(brickList.count))
            brickList.append(brick)
            addChild(brick.spriteNode)
            leftBrickY+=brickLenghtSize
        }
        brickList.shuffle()
        for i in 0..<brickList.count {
            brickList[i].updateValueColor(color: colorList[i%colorList.count])
        }
    }
    

    func createPinPoin(){
        pinPoint.fillColor = hideColor
        pinPoint.position = CGPoint(x: 200, y: 200)
        pinPoint.strokeColor = hideColor
        addChild(pinPoint)
    }
    
    func playerSize() -> Double{
        let screenSize = view?.bounds.size
        let screenWidth = self.size.width
        let marginWidthRatio : Double = 0.2
        let marginWidth : Double = 0.5*marginWidthRatio*screenWidth
        let playerSize : Double =  (screenWidth - 2*marginWidth)*0.5/Double(totalBrickWidth)
        return playerSize
    }
    
    
    func addPlayer(){
        let screenSize = view?.bounds.size
        let playerSize : Double =  playerSize()
        let playerCount : Int = GameManager.sharedData.playerCount
        let playerPositions = playerPositions(playerCount: playerCount)
        playersList.removeAll()
        for i in 0..<playerCount {
            let playerName = "player\(i+1)"
            let player = players(radius: playerSize, active: true, position: playerPositions[i], color: colorList[i], name: playerName, turnID: i)
            playersList.append(player)
            turnList.append(i)
            addChild(player.spriteNode)
//            addChild(player2.spriteNode)
        }
        
//        turnList.shuffle()
        changeAnimationStoke()
        
        colorList.removeAll()
        for player in playersList {
            colorList.append(player.color)
        }
    }
    
        

    func playerPositions(playerCount: Int) -> [CGPoint]{
        let screenSize = view?.bounds.size
        var playerPosition : [CGPoint] = [
            CGPoint(x: screenSize!.width * 0.5, y: screenSize!.height * 0.25),
            CGPoint(x: screenSize!.width * 0.5, y: screenSize!.height * 0.75)
        ]
        if playerCount == 3 {
            playerPosition = [
                CGPoint(x: screenSize!.width * 0.5, y: screenSize!.height * 0.25),
                CGPoint(x: screenSize!.width * (1/3), y: screenSize!.height * 0.75),
                CGPoint(x: screenSize!.width * (2/3), y: screenSize!.height * 0.75)
        ]
        } else if playerCount == 4 {
            playerPosition = [
                CGPoint(x: screenSize!.width * 0.25, y: screenSize!.height * 0.25),
                CGPoint(x: screenSize!.width * 0.75, y: screenSize!.height * 0.25),
                CGPoint(x: screenSize!.width * 0.25, y: screenSize!.height * 0.75),
                CGPoint(x: screenSize!.width * 0.75, y: screenSize!.height * 0.75)
        ]
        }
        
        return playerPosition
        
    }
        
    func changeAnimationStoke(){
        var turnPosition = turnList.first
        for player in playersList {
            player.spriteNode.strokeColor = hideColor
        }
        playersList[turnPosition!].spriteNode.strokeColor = .white
        
    }
    
    func addAttributGame(){
        
        let screenSize = view?.bounds.size
        for i in 0..<playersList.count{
            let player = playersList[i]
            let playerIcon = playerIcon(radius: player.radius*0.8,  position: CGPoint(x: screenSize!.width*(0.05+0.25*CGFloat(i)), y: screenSize!.height*0.05), color: player.color, name: "player\(i+1)Icon", owner: player.spriteNode.name!)
            let playerHPLabel = texts(position: CGPoint(x: playerIcon.position.x+40, y: playerIcon.position.y+5), fontSize: 20, color: .white, text: "HP : \(player.HP)", name: "player\(i+1)HPLabel", owner:  player.spriteNode.name!)
            let playerPowerLabel = texts(position: CGPoint(x: playerIcon.position.x+40, y: playerIcon.position.y-15), fontSize: 20, color: .white, text: "Power : \(Int(player1.speed*100/player1.maxSpeed))%", name: "player\(i+1)PowerLabel", owner: player.spriteNode.name!)
            
            playerIconList.append(playerIcon)
            playerHPLabelList.append(playerHPLabel)
            playerPowerLabelList.append(playerPowerLabel)
            addChild(playerIcon.spriteNode)
            addChild(playerHPLabel.spriteNode)
            addChild(playerPowerLabel.spriteNode)
        }

    }
    func updateLabelAtrributs(){
        for player in playersList {
            for playerHP in playerHPLabelList {
                if playerHP.owner == player.spriteNode.name {
                    playerHP.spriteNode.text = "HP : \(player.HP < 0 ? 0 : player.HP)"
                }
            }
            
            for playerPower in playerPowerLabelList {
                if playerPower.owner == player.spriteNode.name {
                    playerPower.spriteNode.text = "Power : \(Int(player.speed*100/player.maxSpeed))%"
                }
                
            }
        }
    }
    
    func winnerText(winner : String){
        var screenSize = view?.bounds.size
        let end = texts(position: CGPoint(x: screenSize!.width*0.5,y: screenSize!.height*0.5), fontSize: 36, color: .white, text: "Game is Over", name: "end", owner: "none")
        let pressAny = texts(position: CGPoint(x: screenSize!.width*0.5,y: screenSize!.height*0.5-20), fontSize: 12, color: .white, text: "press any to back home", name: "pressAny", owner: "none")
        end.spriteNode.horizontalAlignmentMode = .center
        pressAny.spriteNode.horizontalAlignmentMode = .center
        addChild(end.spriteNode)
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
    
    func killPlayer(){
        for player in playersList{
            if player.HP < 1 {
                player.spriteNode.removeFromParent()
//                playersList.removeAll{$0.spriteNode.name == player.spriteNode.name}
                removeItemfromTurnList(turnID: player.turnID)
                changeAnimationStoke()
            }
        }
    }
    
    func removeItemfromTurnList(turnID : Int){
        if turnList.count > 1 {
            turnList.removeAll{$0 == turnID}
            print(turnList)
        }
    }
    
    func updateTurnList(){
        var firstTurnID = turnList.first
        turnList.remove(at: 0)
        turnList.append(firstTurnID!)
        print(turnList)
    }
    
    func isGameOver() -> Bool{
        if turnList.count < 2 {
            return true
        }
        return false
    }
    
}

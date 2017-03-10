//
//  GameScene.swift
//  MazeDemo
//
//  Created by Surasak Wattanapradit on 5/6/2559 BE.
//  Copyright (c) 2559 Surasak Wattanapradit. All rights reserved.
//
import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case Player = 1
    case Wall = 2
    case Item = 3
    case Trap = 4
    case Finish = 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager! //ทำงานกับ Accelerometer

    var gameOver: Bool = false;
    var gamePause: Bool = false;
    var life:Int = 3;
    var currentPage: String = "home"; //home, level, end, gameover
    var currentLevel:Int = 0
    let maxLevel: Int = 10;
    let numSize: Int = 64;
    let numCol: Int = 16;
    let numRow: Int = 12;
    
    var playerSpawn = CGPoint(x: 96, y: 672)
    var player: SKSpriteNode!
    var btnHome: SKSpriteNode!
    var btnPlay: SKSpriteNode!
    var btnPause: SKSpriteNode!
    var btnResume: SKSpriteNode!
    var btnHomeText: SKSpriteNode!
    var viewBgPause: SKSpriteNode!
    var lifeLabel: SKLabelNode!
    
    let imgBg = ["floor-glass-2", "floor-glass-2", "floor-glass-2", "floor-glass-2", "floor-glass-2", "floor-stone-2", "floor-stone-2", "floor-stone-2", "floor-stone-2", "floor-snow-2"] //BG Each Level

    override func didMoveToView(view: SKView) {
    	backgroundColor = SKColor.blackColor();
        startGame()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
    
            if(!pressBtnOnLevelPage(location)){
                //Not Press on Btn
                lastTouchPosition = location;
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            if(!pressBtnOnLevelPage(location)){
                //Not Press on Btn
                lastTouchPosition = location;
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastTouchPosition = nil

        if let touch = touches.first { //เวลาสัมผัสหลายๆนิ้ว จะคิดแค่นิ้วแรก
        	let location = touch.locationInNode(self);
            
            //Page
            if(currentPage == "home"){
                if(btnPlay.containsPoint(location)){
                    currentPage = "level";
                    currentLevel = 1;
                    resetScene();
                }
            }else if(currentPage == "level"){
                
                //Btn Pause
                if(!btnPause.hidden && btnPause.containsPoint(location)){
                    self.runAction(SKAction.runBlock(self.setPauseGame));
                }
                
                //Btn Resume
                if(!btnResume.hidden && btnResume.containsPoint(location)){
                    setPauseGame();
                }
                
                //Btn Home Text
                if(!btnHomeText.hidden && btnHomeText.containsPoint(location)){
                    currentPage = "home";
                    setPauseGame();
                    resetScene();
                }
            }else{
                
                //Btn Home
                if(btnHome.containsPoint(location)){
                    currentPage = "home";
                    resetScene();
                }
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        lastTouchPosition = nil
    }
   
    override func update(currentTime: CFTimeInterval) {
        if(!gameOver && !gamePause && currentPage == "level") {
    #if (arch(i386) || arch(x86_64))
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x , y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x/100 , dy: diff.y/100)
            }
    #else
            if let accelerometerData = motionManager.accelerometerData{
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -10 , dy: accelerometerData.acceleration.x * 10)
            }
    #endif
        }
    }
    
    func pressBtnOnLevelPage(location: CGPoint) -> Bool {
        //Press on Button or not
        
        if(currentPage == "level"){
            if(!btnPause.hidden){
                //if this btn is show
                return btnPause.containsPoint(location);
            }
            
            if(!btnResume.hidden){
                //if this btn is show
                btnResume.containsPoint(location);
            }
        }
        
        return false;
    }
    
    func setPauseGame(){
        gamePause = !gamePause;
        btnPause.hidden = gamePause;
        btnResume.hidden = !gamePause;
        btnHomeText.hidden = !gamePause;
        viewBgPause.hidden = !gamePause;
        self.view?.paused = gamePause;
    }
    
    func updateTextLife(){
        lifeLabel.text = "Level: \(currentLevel) | Life: \(life)";
    }

    func resetScene(){
    	self.removeAllActions();
		self.removeAllChildren();
		startGame()
    }

	func startGame(){ //แยกFuncออกมาเพื่อ เอาไปใช้ตอนเรียกเกมส์ใหม่อีกรอบ
    	
        if(currentPage == "home"){
        	//home
            
            //reset value
            currentLevel = 1;
            life = 3;
            
            //BGIndex
            let bgImg = SKSpriteNode(imageNamed: "bg-home");
            bgImg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
            bgImg.zPosition = -10;
            addChild(bgImg);

        	//Btn Play
            //btnPlay = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 100, height: 100));
        	btnPlay = SKSpriteNode(imageNamed: "btn-play");
        	btnPlay.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 70);
        	addChild(btnPlay);
        }else if(currentPage == "level"){
        	//Level
            
            if(currentLevel > maxLevel){
                //if Finish Final Map, Go The End Page
                
                currentPage = "end";
                resetScene();
            }else if(life > 0){
                //Can Play
                
                //View Top bar Menu
                let viewTopBarMenu = SKSpriteNode(color: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7), size: CGSize(width: numCol * numSize, height: numSize));
                viewTopBarMenu.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGFloat((numRow * numSize) - (numSize / 2)));
                viewTopBarMenu.zPosition = 9;
                addChild(viewTopBarMenu);
                
                //Text Level and Life
                lifeLabel = SKLabelNode(fontNamed: "Helvetica Neue")
                lifeLabel.horizontalAlignmentMode = .Left
                lifeLabel.position = CGPoint(x: numSize, y: (numRow * numSize) - 46);
                lifeLabel.zPosition = 10;
                addChild(lifeLabel)
                
                //View BG Pause Menu
                viewBgPause = SKSpriteNode(color: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7), size: CGSize(width: numCol * numSize, height: numRow * numSize));
                viewBgPause.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
                viewBgPause.zPosition = 99;
                addChild(viewBgPause);
                viewBgPause.hidden = true;
                
                //Btn Pause
                btnPause = SKSpriteNode(imageNamed: "btn-pause");
                btnPause.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGFloat((12 * numSize) - (numSize / 2)));
                btnPause.zPosition = 100;
                addChild(btnPause);
                
                //Btn Resume
                btnResume = SKSpriteNode(imageNamed: "btn-resume");
                btnResume.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
                btnResume.zPosition = 100;
                addChild(btnResume);
                btnResume.hidden = true;
                
                //Btn Home Text
                btnHomeText = SKSpriteNode(imageNamed: "btn-home-text");
                btnHomeText.position.x = CGFloat(CGRectGetMidX(self.frame));
                btnHomeText.position.y = CGFloat(CGRectGetMidY(self.frame) + 100);
                btnHomeText.zPosition = 100;
                addChild(btnHomeText);
                btnHomeText.hidden = true;
                
                loadLevel()
                creatPlayer()
                
                motionManager = CMMotionManager()
                motionManager.startAccelerometerUpdates()
                
            }else{
                //Game Over, Go Game Over Page
                
                currentPage = "gameover";
                resetScene();
            }
        
    	}else if(currentPage == "end"){
    		//The end, Congratulation

    		//Text End
    		let endLabel = SKLabelNode(fontNamed: "Helvetica Neue");
    			endLabel.text = "Congratulation!!!";
        		endLabel.position = CGPoint(x: numCol * numSize / 2, y: numRow * numSize / 2 + 200);
        	addChild(endLabel);
            
            //Player Img
            let toon = SKSpriteNode(imageNamed: "player-big")
            toon.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            toon.size = CGSize(width: 150, height: 150);
            addChild(toon)

        	//Btn Go Home
        	btnHome = SKSpriteNode(imageNamed: "btn-home");
			btnHome.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 200);
            btnHome.size = CGSize(width: 100, height: 100);
        	addChild(btnHome);

        }else{
            //Game Over
        
            let overLabel = SKLabelNode(fontNamed: "Helvetica Neue");
            overLabel.text = "Game Over!";
            overLabel.position = CGPoint(x: numCol * numSize / 2, y: numRow * numSize / 2 + 150);
            addChild(overLabel);
            
            //Btn Go Home
            btnHome = SKSpriteNode(imageNamed: "btn-home");
            btnHome.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 70);
            addChild(btnHome);
        }

    }
    
    func creatPlayer() {
        
        //set Gravity to Default
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) //ทำให้เกมส์ไม่คิดแรงโน้มถ่วงของโลก (โลกความเป็นจริง)
        physicsWorld.contactDelegate = self
        
        if(life > 0){
            updateTextLife();
            
            player = SKSpriteNode(imageNamed: "player")
            player.position = playerSpawn
            player.zPosition = CGFloat(-numRow + 1)
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
            player.physicsBody!.allowsRotation = true //หมุนเวลาเคลื่อนที
            player.physicsBody!.linearDamping = 0.5 //ความลื่น
            player.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
            player.physicsBody!.contactTestBitMask = CollisionTypes.Item.rawValue | CollisionTypes.Trap.rawValue | CollisionTypes.Finish.rawValue
            player.physicsBody!.collisionBitMask=CollisionTypes.Wall.rawValue
            
            addChild(player)
            
        }else{
            
            currentPage = "gameover";
            resetScene();
            
        }

    }
    
    func createProp(name: String, position: CGPoint, zIndex: CGFloat, type: String){
        
        let node = SKSpriteNode(imageNamed: name)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        node.position = position
        node.zPosition = zIndex
        node.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(numSize / 2), center: CGPoint(x: 0, y: numSize / 2))
        node.physicsBody!.dynamic = false
        
        //type, wall, trap, item, finish
        
        switch(type) {
            
        case "wall":
            node.physicsBody!.categoryBitMask = CollisionTypes.Wall.rawValue
            
        case "trap":
            node.name = "trap"
            node.physicsBody!.categoryBitMask = CollisionTypes.Trap.rawValue
            
        case "item":
            node.name = "item"
            node.physicsBody!.categoryBitMask = CollisionTypes.Item.rawValue
            
        case "finish":
            node.name = "finish"
            node.physicsBody!.categoryBitMask = CollisionTypes.Finish.rawValue
            
        default:
            break
        }
        
        if(type != "wall"){
            node.physicsBody!.contactTestBitMask = CollisionTypes.Player.rawValue
            node.physicsBody!.collisionBitMask = 0
        }
        
        addChild(node)
        
    }
    
    func loadLevel() {
    
        if let levelPath = NSBundle.mainBundle().pathForResource("level\(currentLevel)", ofType: "txt"){
            if let levelString = try? String(contentsOfFile: levelPath, usedEncoding: nil){
                let lines = levelString.componentsSeparatedByString("\n")
            
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: (64 * column) + 32 , y: (64 * row))
                        
                        let background = SKSpriteNode(imageNamed: imgBg[currentLevel - 1])
                        background.zPosition = CGFloat(-numRow + -1)
                        background.position = position
                        background.position.y += CGFloat(numSize / 2)
                        addChild(background)
                        
                        switch(letter){
                            
                        case "Z":
                            playerSpawn = position
                            playerSpawn.y += 32
                            
                        case "A":
                            createProp("prop-box-1", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "B":
                            createProp("prop-chest-1", position: position, zIndex: CGFloat(-row), type: "item")

                        case "C":
                            createProp("prop-pad-1", position: position, zIndex: CGFloat(-row), type: "pad")

                        case "D":
                            createProp("prop-pad-2", position: position, zIndex: CGFloat(-row), type: "pad")

                        case "E":
                            createProp("prop-stone-1", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "F":
                            createProp("prop-stone-2", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "G":
                            createProp("prop-stone-3", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "H":
                            createProp("prop-trap-1", position: position, zIndex: CGFloat(-row), type: "trap")

                        case "I":
                            createProp("prop-trap-2", position: position, zIndex: CGFloat(-row), type: "trap")

                        case "J":
                            createProp("prop-tree-1", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "K":
                            createProp("prop-tree-2", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "L":
                            createProp("prop-tree-3", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "M":
                            createProp("prop-tree-4", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "N":
                            createProp("prop-tree-5", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "O":
                            createProp("prop-tree-6", position: position, zIndex: CGFloat(-row), type: "wall")

                        case "P":
                            createProp("prop-water-1", position: position, zIndex: CGFloat(-numRow), type: "trap")

                        case "Q":
                            createProp("prop-warp-1", position: position, zIndex: CGFloat(-row), type: "finish")
                            
                        default: break
                            
                        }
                        
                    }
                }
            }
        }
        
    }

	func didBeginContact(contact: SKPhysicsContact){
		if contact.bodyA.node == player {
			playerCollidedWithNode(contact.bodyB.node!)
       	}
        else if contact.bodyB.node == player {
           	playerCollidedWithNode(contact.bodyA.node!)
       	}
   	}
    
    func playerDie(node: SKNode){
        let move = SKAction.moveTo(CGPoint(x: node.position.x, y: node.position.y + 32) , duration: 0.25)
        let scale = SKAction.scaleTo(0.0001, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, scale, remove])
        
        player.runAction(sequence){ [unowned self] in
            self.creatPlayer()
            self.gameOver = false
        }
    }

	func playerCollidedWithNode(node: SKNode){
		if node.name == "trap"{
			player.physicsBody?.dynamic = false
			gameOver = true
			life -= 1
            playerDie(node)
		}
		else if node.name == "item" {
			node.removeFromParent()
			life += 1
            updateTextLife();
		}
		else if node.name == "finish" {
			currentLevel += 1
			node.removeFromParent()
			resetScene()
		}
	}
 

}
//
//  GameScene.swift
//  Shrimpswim
//
//  Created by YashimaMasafumi on 2021/04/18.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    //衝突判定
    struct ColliderType {
        static let Player:UInt32 = 1<<0
        static let World:UInt32 = 1<<1
        static let Coral:UInt32 = 1<<2
        static let Score:UInt32 = 1<<3
        static let None:UInt32 = 1<<4
    }
    
    //プレイヤーシュリンプのアニメーションの設定
    struct Constants {
        static let PlayerImages = ["shrimp01","shrimp02","shrimp03","shrimp04"]
    }
    
    var baseNode:SKNode!
    var coralNode:SKNode!
    var player:SKSpriteNode!
    
    var scoreLabelNode:SKLabelNode!
    var score = 0
    
    override func didMove(to view: SKView) {
        //物理シミュレーションを設定
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        //全ノードの親となるノードを生成
        baseNode = SKNode()
//        baseNode?.speed = 1
        self.addChild(baseNode)
        
        //障害物を生成するノードを生成
        coralNode = SKNode()
        baseNode.addChild(coralNode)
        
        //背景画像を構築
        self.setupBackgroundSea()
        //岩山画像を構築
        self.setupBackgroundRock()
        //地面天井画像を構築
        self.setupCeilingAndLand()
        //プレイキャラを構築
        self.setupPlayer()
        //珊瑚を構築
        self.setupCoral()
        //スコアラベルを構築
        self.setupScoreLabel()
    }
    
    //タップ時の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: self)
        //プレーヤーに与えられている重力をゼロにする
        player.physicsBody?.velocity = CGVector.zero
        //プレイヤーにy方向へ力を加える
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 23))
//        }
    }
    
    //衝突が起こった時に呼ばれるメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        //すでにゲームオーバー状態の場合（珊瑚に当たった後地面にも衝突するため2度目の処理を行わないようにするため）
        if baseNode.speed <= 0 {
            return
        }
        
        let rawScoreType = ColliderType.Score
//        let rawNoneType = ColliderType.None
        if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType || (contact.bodyB.categoryBitMask & rawScoreType) == rawScoreType {
            print("DEBUG_PRINT:スコアと衝突")
            //スコアを加算しラベルに反映
            score += 1
            scoreLabelNode.text = "\(score)"
            
            //スコアラベルをアニメーション
            let scaleUpAnime = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDownAnime = SKAction.scale(to: 1.0, duration: 0.1)
            scoreLabelNode.run(SKAction.sequence([scaleUpAnime,scaleDownAnime]))
        }
//        else if (contact.bodyA.categoryBitMask & rawNoneType) == rawNoneType || (contact.bodyB.categoryBitMask & rawNoneType) == rawNoneType {
//            //何もしない
//        }
        else {
            //baseNodeに追加されたもの全てのアニメーションを停止
            baseNode.speed = 0
            //プレイキャラのBitMaskを変更
            player.physicsBody?.collisionBitMask = ColliderType.World
            //プレイキャラに回転アニメーションを実行
            let rolling = SKAction.rotate(byAngle:(CGFloat(Double.pi))*player.position.y*0.01, duration: 1)
            player.run(rolling, completion: {
                //アニメーション終了時にプレイキャラのアニメーションを停止
                self.player.speed = 0
            })
        }
    }
    
    //背景の配置
    func setupBackgroundSea() {
        //背景画像を読み込む
        let texture = SKTexture(imageNamed: "background")
        texture.filteringMode = .nearest
        
        //必要な画像枚数を算出
        let needNumber = 2 + Int(self.frame.size.width/texture.size().width)
        
        //アニメーション作成
        let moveAnime = SKAction.moveBy(x: -texture.size().width, y: 0, duration:TimeInterval(texture.size().width/10))
        let resetAnime = SKAction.moveBy(x: texture.size().width, y: 0, duration: 0)
        let repeatForeverAnime = SKAction.repeatForever(SKAction.sequence([moveAnime,resetAnime]))
        
        //画像の配置とアニメーションの設定
        for i in 0...needNumber {
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = self.size
            sprite.zPosition = -100
            sprite.position = CGPoint(x: CGFloat(i)*sprite.size.width + sprite.size.width/2, y: self.frame.size.height/2)
            sprite.run(repeatForeverAnime)
            baseNode.addChild(sprite)
        }
    }
    
    //岩山の配置
    func setupBackgroundRock() {
        //岩山画像を読み込む
        let under = SKTexture(imageNamed: "rock_under")
        under.filteringMode = .nearest
        let above = SKTexture(imageNamed: "rock_above")
        above.filteringMode = .nearest
        
        //必要な画像枚数を算出
        let needNumber = 2 + Int(self.size.width/under.size().width)
        
        //アニメーションの設定
        let moveUnderAnime = SKAction.moveBy(x: -under.size().width, y: 0, duration: TimeInterval(under.size().width/20))
        let resetUnderAnime = SKAction.moveBy(x: under.size().width, y: 0, duration: 0)
        let repeatForeverUnderAnime = SKAction.repeatForever(SKAction.sequence([moveUnderAnime,resetUnderAnime]))
        
        //画像の配置とアニメーションの設定
        for i in 0...needNumber {
            //岩山(下)の構築
            let underSprite = SKSpriteNode(texture: under)
            underSprite.zPosition = -50
            underSprite.position = CGPoint(x: CGFloat(i)*underSprite.size.width, y: underSprite.size.height/2)
            underSprite.run(repeatForeverUnderAnime)
            baseNode.addChild(underSprite)
            //岩山(上)の構築
            let aboveSprite = SKSpriteNode(texture: above)
            aboveSprite.zPosition = -50
            aboveSprite.position = CGPoint(x: CGFloat(i)*aboveSprite.size.width, y: self.frame.size.height - above.size().height/2)
            aboveSprite.run(repeatForeverUnderAnime)
            baseNode.addChild(aboveSprite)
        }
    }
    
    //障害物の地面天井の配置
    func setupCeilingAndLand() {
        //地面画像を読み込み
        let land = SKTexture(imageNamed: "land")
        land.filteringMode = .nearest
        //天井画像を読み込み
        let ceiling = SKTexture(imageNamed: "ceiling")
        ceiling.filteringMode = .nearest
        
        //必要な画像枚数を算出
        let needNumber = 2 + Int(self.frame.size.width/land.size().width)
        
        //アニメーションを作成
        let moveLandAnime = SKAction.moveBy(x: -land.size().width, y: 0, duration: TimeInterval(land.size().width/100))
        let resetLandAnime = SKAction.moveBy(x: land.size().width, y: 0, duration: 0)
        let repeatForeverLandAnime = SKAction.repeatForever(SKAction.sequence([moveLandAnime,resetLandAnime]))
        
        //画像の配置とアニメーションの設定
        for i in 0...needNumber {
            let landsprite = SKSpriteNode(texture: land)
            landsprite.position = CGPoint(x: CGFloat(i)*landsprite.size.width, y: landsprite.size.height/2)
            let ceilingsprite = SKSpriteNode(texture: ceiling)
            ceilingsprite.position = CGPoint(x: CGFloat(i)*ceilingsprite.size.width, y: self.frame.size.height - ceilingsprite.size.height/2)
            
            //画像に物理シミュレーションを設定
            landsprite.physicsBody = SKPhysicsBody(texture: land, size: land.size())
            landsprite.physicsBody?.isDynamic = false
            landsprite.physicsBody?.categoryBitMask = ColliderType.World
            landsprite.run(repeatForeverLandAnime)
            baseNode.addChild(landsprite)
            ceilingsprite.physicsBody = SKPhysicsBody(texture: ceiling, size: ceiling.size())
            ceilingsprite.physicsBody?.isDynamic = false
            ceilingsprite.physicsBody?.categoryBitMask = ColliderType.World
            ceilingsprite.run(repeatForeverLandAnime)
            baseNode.addChild(ceilingsprite)
        }
    }
    
    //プレイヤーシュリンプの配置
    func setupPlayer() {
        //Plyaerのパラパラアニメーション作成に必要なSKTextureクラスの配列を定義
        var playerTexture = [SKTexture]()
        
        //パラパラアニメーションに必要な画像を読み込む
        for imageName in Constants.PlayerImages {
            let texture = SKTexture(imageNamed: imageName)
            texture.filteringMode = .linear
            playerTexture.append(texture)
        }
        //パラパラ漫画のアニメーションを作成
        let playerAnime = SKAction.animate(with: playerTexture, timePerFrame: 0.2)
        let loopAnimation = SKAction.repeatForever(playerAnime)
        
        //キャラクターを生成しアニメーションを設定
        player = SKSpriteNode(texture: playerTexture[0])
        player.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.6)
        player.run(loopAnimation)
        
        //物理シミュレーションを設定
//        player.physicsBody = SKPhysicsBody(texture: playerTexture[0], size: playerTexture[0].size())
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
//        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        
        //自分自身にPlayerカテゴリを設定
        player.physicsBody?.categoryBitMask = ColliderType.Player
        //衝突判定相手にWorldとCoralを設定
        player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
        player.physicsBody?.contactTestBitMask = ColliderType.World | ColliderType.Coral
        
        self.addChild(player)
    }
    
    //珊瑚の配置
    func setupCoral() {
        //珊瑚画像を読み取り
        let coralUnder = SKTexture(imageNamed: "coral_under")
        coralUnder.filteringMode = .linear
        let coralAbove = SKTexture(imageNamed: "coral_above")
        coralAbove.filteringMode = .linear
        
        //移動する距離を算出
        let distanceToMove = CGFloat(self.frame.size.width + 2*coralAbove.size().width)
        
        //アニメーションを作成
        let moveAnime = SKAction.moveBy(x: -distanceToMove, y: 0, duration: TimeInterval(distanceToMove/100))
        let removeAnime = SKAction.removeFromParent()
        let coralAnime = SKAction.sequence([moveAnime,removeAnime])
        
        //珊瑚を生成するメソッドを呼び出すアニメーションを作成
        let newCoralAnime = SKAction.run({
            //珊瑚に関するノードを載せるノードを作成
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.size.width + coralUnder.size().width*2, y: 0)
            coral.zPosition = -50
            
            //地面から伸びる珊瑚のy座標を算出
            let hight = self.frame.size.height/12
            let y = CGFloat.random(in: 0...hight*2) + hight
            
            //地面から伸びる珊瑚を作成
            let under = SKSpriteNode(texture: coralUnder)
            under.position = CGPoint(x: 0, y: y)
            
            //珊瑚に物理シミュレーションを設定
            under.physicsBody = SKPhysicsBody(texture: coralUnder, size: coralUnder.size())
            under.physicsBody?.isDynamic = false
            under.physicsBody?.categoryBitMask = ColliderType.Coral
            under.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(under)
            
            //天井から伸びる珊瑚を作成
            let above = SKSpriteNode(texture: coralAbove)
            above.position = CGPoint(x: 0, y: y + under.size.height/2 + 160 + above.size.height/2)
            
            //珊瑚に物理シミュレーションを設定
            above.physicsBody = SKPhysicsBody(texture: coralAbove, size: above.size)
            above.physicsBody?.isDynamic = false
            above.physicsBody?.categoryBitMask = ColliderType.Coral
            above.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(above)
            
            //スコアをカウントアップするノードを作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: above.size.width/2 + 5, y: self.size.height/2)
            //スコアノードに物理シミュレーションを設定
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
            scoreNode.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(scoreNode)
            
            coral.run(coralAnime)
            self.coralNode.addChild(coral)
        })
        let delayAnime = SKAction.wait(forDuration: 2.5)
        let repeatForeverAnime = SKAction.repeatForever(SKAction.sequence([newCoralAnime,delayAnime]))
        
        self.coralNode.run(repeatForeverAnime)
    }
    
    //スコアラベルの設定
    func setupScoreLabel() {
        //フォント名"Arial Bold"でラベルを作成
        scoreLabelNode = SKLabelNode(fontNamed: "Arial Bold")
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.9)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = "\(score)"
        
        self.addChild(scoreLabelNode)
    }
}

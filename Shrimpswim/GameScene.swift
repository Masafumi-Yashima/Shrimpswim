//
//  GameScene.swift
//  Shrimpswim
//
//  Created by YashimaMasafumi on 2021/04/18.
//

import SpriteKit

class GameScene: SKScene {
    
    //衝突判定
    struct ColliderType {
        static let Player:UInt32 = 1<<0
        static let World:UInt32 = 1<<1
        static let Coral:UInt32 = 1<<2
        static let Score:UInt32 = 1<<3
        static let None:UInt32 = 1<<4
    }
    
    var baseNode:SKNode!
    var coralNode:SKNode!
    
    override func didMove(to view: SKView) {
        //全ノードの親となるノードを生成
        baseNode = SKNode()
//        baseNode?.speed = 1
        self.addChild(baseNode)
        
        //障害物を生成するノードを生成
        coralNode = SKNode()
        self.addChild(coralNode)
        
        //背景画像を構築
        setupBackgroundSea()
        //岩山画像を構築
        setupBackgroundRock()
        //地面天井画像を構築
        setupCeilingAndLand()
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
}

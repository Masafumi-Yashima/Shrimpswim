//
//  ViewController.swift
//  Shrimpswim
//
//  Created by YashimaMasafumi on 2021/04/18.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //Nodeの数を表示する
        skView.showsNodeCount = true
        
        //Viewと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ViewにSceneを表示する
        skView.presentScene(scene)
        // Do any additional setup after loading the view.
    }


}


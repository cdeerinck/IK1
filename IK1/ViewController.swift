//
//  ViewController.swift
//  IK1
//
//  Created by Chuck Deerinck on 7/25/19.
//  Copyright © 2019 Chuck Deerinck. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            let scene = GameScene()
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }


}


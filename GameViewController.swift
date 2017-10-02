//
//  GameViewController.swift
//  JigsawPuzzle
//
//  Created by Arturs Derkintis on 8/19/15.
//  Copyright (c) 2015 Starfly. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        let scene = SliddingPuzzle()
         let scene = JigsawPuzzle()
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = skView.frame.size

            skView.presentScene(scene)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

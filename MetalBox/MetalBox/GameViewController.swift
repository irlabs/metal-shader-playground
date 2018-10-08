//
//  GameViewController.swift
//  MetalBox
//
//  Created by Dirk van Oosterbosch on 08/10/2018.
//  Copyright © 2018 IRLabs. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = GameScene()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // set draw_normals SCNTechnique
        if let path = Bundle.main.url(forResource: "draw_normals", withExtension: "json") {
            let data = try? Data.init(contentsOf: path)
            let techDict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
            let technique = SCNTechnique.init(dictionary: techDict! as! [String : Any])
            scnView.technique = technique
        }

        // draw_highlight (blur)
        // Configure the Technique
        
//        if let path = Bundle.main.path(forResource: "draw_highlight", ofType: "plist") {
//            if let dict = NSDictionary(contentsOfFile: path)  {
//                let dict2 = dict as! [String : AnyObject]
//                let technique = SCNTechnique(dictionary: dict2)
//                scnView.technique = technique
//            }
//        }

    }
}

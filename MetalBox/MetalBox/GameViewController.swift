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

        
        /* Tests with shaders */
        
        // set draw_normals SCNTechnique
//        setTechnique(name: "draw_normals", in: scnView)

        // set draw_mask SCNTechnique
//        setTechnique(name: "draw_mask", in: scnView)
        
        // draw_highlight (blur)
        setTechnique(name: "draw_highlight", in: scnView)
        
//        if let path = Bundle.main.path(forResource: "draw_highlight", ofType: "plist") {
//            if let dict = NSDictionary(contentsOfFile: path)  {
//                let dict2 = dict as! [String : AnyObject]
//                let technique = SCNTechnique(dictionary: dict2)
//                scnView.technique = technique
//            }
//        }

    }
    
    // Configuring the Technique
    func setTechnique(name: String, in scnView: SCNView) {
        guard let path = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Definition file \(name).json not found in bundle")
        }
        guard let data = try? Data(contentsOf: path) else {
            fatalError("Could not read contents of definition file")
        }
        guard let techDict = try? JSONSerialization.jsonObject(with: data,
            options: JSONSerialization.ReadingOptions(rawValue: 0)) else {
                fatalError("Malformed JSON format")
        }
        guard let dictionary = techDict as? [String : Any] else {
            fatalError("Technique definition dict (JSON) no valid dictionary")
        }
        guard let technique = SCNTechnique(dictionary: dictionary ) else {
            fatalError("SCNTechnique Failed to initialize")
        }
        
        scnView.technique = technique
    }
}

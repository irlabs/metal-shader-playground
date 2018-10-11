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

        // set draw_masked_normals SCNTechnique
//        setTechnique(name: "draw_masked_normals", in: scnView)
        
        // set draw_masked_position SCNTechnique
//        setTechnique(name: "draw_masked_position", in: scnView)

        // draw_highlight (blur)
        setTechnique(name: "draw_highlight", in: scnView)


        
        /**
         #### Notes on Clearing of the color state:
         
         - There is a difference between the default state of the clear value between iOS and macOS:
             - Default `colorStates.clear` on iOS: `true`
             - Default `colorStates.clear` on macOS: `false`
         - Default `depthStates.clear` is `false` on both platforms.
         - Clearing means that each draw pass clear the buffer before rendering content to it.
         - If you don't clear that means the buffer value could be accumulated
            - This (not clearing) is useful if e.g. you need multiple blur passes on the same buffer.
         
         As an example on what happens if you don't clear the color buffer, when you're not drawing every
         pixel (e.g. when only some nodes are affected from their categoryBitMask)

         ```
             "colorStates" : {
                "clear" : 0
             },
         ```
         
         See screenshot `masked_position.png`
         
         
         So, to prevent that, in those cases make sure to set the clear state like so:
         
         ```
             "colorStates" : {
                "clear" : 1
             },
             "depthStates" : {
                "clear" : 1
             },
         ```
        */
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

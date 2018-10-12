//
//  GameController.swift
//  MetalBox Shared
//
//  Created by Dirk van Oosterbosch on 13/10/2018.
//  Copyright © 2018 IRLabs. All rights reserved.
//

import SceneKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif

#if os(macOS)
    typealias SCNVectorFloat = CGFloat
#else
    typealias SCNVectorFloat = Float
#endif


class GameController: NSObject, SCNSceneRendererDelegate {

    let scene: GameScene
    let sceneRenderer: SCNSceneRenderer
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = GameScene()
        
        super.init()
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
        
        if let scnView = sceneRenderer as? SCNView {
            scnView.backgroundColor = SCNColor.black
            
            /* Tests with shaders */
            
            // set draw_normals SCNTechnique
            //        setTechnique(name: "draw_normals", in: scnView)
            
            // set draw_masked_normals SCNTechnique
            //        setTechnique(name: "draw_masked_normals", in: scnView)
            
            // set draw_masked_position SCNTechnique
            //        setTechnique(name: "draw_masked_position", in: scnView)
            
            // draw_highlight (blur)
            setTechnique(name: "draw_highlight", in: scnView)
        }
    }
    
    
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

    
    /**
     Configuring the Technique
    */
    private func setTechnique(name: String, in scnView: SCNView) {
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

    
    func highlightNodes(atPoint point: CGPoint) {
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        for result in hitResults {
            // get its material
            guard let material = result.node.geometry?.firstMaterial else {
                return
            }
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = SCNColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = SCNColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }

}

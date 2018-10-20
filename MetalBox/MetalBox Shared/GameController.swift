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
    var technique: SCNTechnique?
    
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
            
            // set draw_highlight (blur) SCNTechnique
            //        setTechnique(name: "draw_highlight", in: scnView)
            
            // set draw_grow_border (bloom border) SCNTechnique
            setTechnique(name: "draw_grow_border", in: scnView)

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
        
    #if targetEnvironment(simulator)
        print("WARNING: Metal Shaders will be disabled on a Simulator")
    #else
        scnView.technique = technique
    #endif

        self.technique = technique

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
        if let technique = technique {
            
            if let symbols: [String : Any] = technique.dictionaryRepresentation["symbols"] as? [String : Any] {
                
                // Variables for:  draw_highlight
                if symbols.keys.contains("my_variable_symbol") {
                    // Saw tooth animation for 2 seconds
                    var t = time.truncatingRemainder(dividingBy: 2)
                    if t > 1 { t = 2 - t }
                    
                    technique.setObject(NSNumber(value: t), forKeyedSubscript: NSString(string: "my_variable_symbol"))
                }
                
                // Variables for:  draw_grow_border
                //  - bloom_grow
                //  - over_blur (Unsused. Found desired over blur value (1.5) and hard coded that in)
                if symbols.keys.contains("over_blur_symbol") {
                    // Saw tooth animation for 10 seconds
                    var t = time.truncatingRemainder(dividingBy: 20)
                    if t > 10 { t = 20 - t }

                    let over_blur: Float = 1.0 + Float(t * 0.05)
                    technique.setObject(NSNumber(value: over_blur), forKeyedSubscript: NSString(string: "over_blur_symbol"))
                }
                if symbols.keys.contains("bloom_grow_symbol") {
                    
                    // Clamped saw tooth animation for 4 seconds:
                    //  - ramp up 1 second, - hold on 1 for 1 second, - ramp down 1 second, hold on 0 for 1 second
                    var t = time.truncatingRemainder(dividingBy: 4)
                    if t > 1 && t < 2 { t = 1 }             // hold on 1
                    else if t >= 2 && t < 3 { t = 3 - t }   // ramp down
                    else if t >= 3 { t = 0 }                // hold on 0

                    technique.setObject(NSNumber(value: t), forKeyedSubscript: NSString(string: "bloom_grow_symbol"))
                }
            }
        }
    }

}

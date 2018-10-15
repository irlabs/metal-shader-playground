//
//  GameScene.swift
//  MetalBox
//
//  Created by Dirk van Oosterbosch on 08/10/2018.
//  Copyright © 2018 IRLabs. All rights reserved.
//

import SceneKit

class GameScene: SCNScene {
    
    override init() {
        
        super.init()
        
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        let ambientLight = SCNLight()
        let lightNode = SCNNode()
        let directLight = SCNLight()
        
        camera.xFov = 60
        camera.yFov = 60
        
        ambientLight.type = SCNLight.LightType.ambient
        let ambiTint: CGFloat = 0.45
        ambientLight.color = SCNColor(red: ambiTint, green: ambiTint, blue: ambiTint, alpha: 1.0)
        
        cameraNode.camera = camera
        cameraNode.light = ambientLight
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 45)
        
        /*
         // Camera constraints
         let cameraConstraint = SCNLookAtConstraint(target: field) // self.cubeNode
         cameraConstraint.isGimbalLockEnabled = true
         self.cameraNode.constraints = [cameraConstraint]
         */
        
        let directTint: CGFloat = 0.83
        directLight.type = SCNLight.LightType.directional // .spot // .omni // .directional
        directLight.color = SCNColor(red: directTint, green: directTint, blue: directTint, alpha: 1.0)
        directLight.castsShadow = true
        directLight.zNear = 0
        directLight.zFar = 40
        directLight.orthographicScale = 20
        
        lightNode.light = directLight
        lightNode.position = SCNVector3(x: 0, y: 0, z: 25)
        lightNode.orientation = SCNQuaternion(x: -0.32, y: 0.0, z: 1.0, w: 0.76)
        
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(lightNode)
        
        /////
        
        let back = SCNBox(width: 50, height: 50, length: 1, chamferRadius: 0)
        back.firstMaterial?.diffuse.contents = SCNColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        let backNode = SCNNode(geometry: back)
        backNode.position = SCNVector3(0,0,0)
        self.rootNode.addChildNode(backNode)
        
        /// Other elements
        let otherOffset = 16
        let geoA = SCNSphere(radius: 2)
        geoA.firstMaterial?.diffuse.contents = SCNColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0)
        let a = SCNNode(geometry: geoA)
        a.position = SCNVector3(-otherOffset, otherOffset, 0)
        a.categoryBitMask = 4
        self.rootNode.addChildNode(a)

        let geoB = SCNSphere(radius: 2)
        geoB.firstMaterial?.diffuse.contents = SCNColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
        let b = SCNNode(geometry: geoB)
        b.position = SCNVector3(otherOffset, otherOffset, 0)
        b.categoryBitMask = 8
        self.rootNode.addChildNode(b)

        let geoC = SCNSphere(radius: 2)
        geoC.firstMaterial?.diffuse.contents = SCNColor(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0)
        let c = SCNNode(geometry: geoC)
        c.position = SCNVector3(-otherOffset, -otherOffset, 0)
        c.categoryBitMask = 16
        self.rootNode.addChildNode(c)
        
        let geoD = SCNSphere(radius: 2)
        geoD.firstMaterial?.diffuse.contents = SCNColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
        let d = SCNNode(geometry: geoD)
        d.position = SCNVector3(otherOffset, -otherOffset, 0)
        d.categoryBitMask = 32
        self.rootNode.addChildNode(d)

        
        //// Object
        let object = SCNNode()
        
        let box = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = SCNColor(red: 0.8, green: 0.1, blue: 0.3, alpha: 1)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,15)
        
        let plate = SCNBox(width: 13, height: 13, length: 2, chamferRadius: 0)
        plate.firstMaterial?.diffuse.contents = SCNColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 1)
        let plateNode = SCNNode(geometry: plate)
        plateNode.position = SCNVector3(0,0,10)
        
        let stick = SCNBox(width: 2, height: 15, length: 2, chamferRadius: 0)
        stick.firstMaterial?.diffuse.contents = SCNColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1)
        let stickNode = SCNNode(geometry: stick)
        stickNode.position = SCNVector3(0,0,20)
        
        object.addChildNode(boxNode)
        object.addChildNode(plateNode)
        object.addChildNode(stickNode)

        // Add Glow
        
        
        /**
         #### Notes on categoryBitMask:
         
         - categoryBitMasks need to be applied to all the childNodes of compound / combined node. (see example below)
         - default categoryBitMask or nodes, lights and techniques is 1
         - bitMask of nodes and lights (or technique) are compared with bitwise AND (0 * 1 = 0). Any non-zero result is rendered.
         
         So don't use:
         object.categoryBitMask = 4
         
         But use:
         object.enumerateChildNodes { (node, stop) in
            node.categoryBitMask = 4
         }

         */
 
        object.enumerateChildNodes { (node, stop) in
            node.categoryBitMask = 2
        }

        self.rootNode.addChildNode(object)
        
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = SCNVector4(x: 0, y: 0, z: 1, w: 0)
        spin.toValue = SCNVector4(x: 0.3, y: 1, z: 1, w: SCNVectorFloat(2 * Double.pi))
        spin.duration = 3
        spin.repeatCount = .infinity
        object.addAnimation(spin, forKey: "spin around")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
}

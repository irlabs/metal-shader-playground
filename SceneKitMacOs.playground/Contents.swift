//: A SpriteKit based Playground

import PlaygroundSupport
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
        ambientLight.color = NSColor(red: ambiTint, green: ambiTint, blue: ambiTint, alpha: 1.0)
        
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
        directLight.color = NSColor(red: directTint, green: directTint, blue: directTint, alpha: 1.0)
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
        let backNode = SCNNode(geometry: back)
        backNode.position = SCNVector3(0,0,0)
        self.rootNode.addChildNode(backNode)
        
        
        let box = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = NSColor(calibratedRed: 0.8, green: 0.1, blue: 0.3, alpha: 1)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,15)
        
        self.rootNode.addChildNode(boxNode)
        
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = SCNVector4(x: 0, y: 0, z: 1, w: 0)
        spin.toValue = SCNVector4(x: 0.5, y: 0, z: 0.5, w: CGFloat(2 * M_PI))
        spin.duration = 3
        spin.repeatCount = .infinity
        boxNode.addAnimation(spin, forKey: "spin around")
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

// Load the SKScene from 'GameScene.sks'
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 320, height: 320))
sceneView.backgroundColor = NSColor.black
let scene = GameScene()
// Present the scene
sceneView.scene = scene

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

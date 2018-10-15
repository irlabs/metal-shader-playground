# metal-shader-playground

### Attempt to build a simple Xcode Playground to experiment with Metal shaders

Metal shaders in a playground do work, but are not so useful as we would hope. This is because the shader definition and shader code (`.metal`) have to be added to the _Resources_ in order to work. That means they will not be automatically / live be recompiled. ... At least that doesn't work as smooth as expected.

Another attempt to experiment with Metal shader is to make a simple _cross platform_ (iOS + macOS) app, **MetalBox**, and to run that in debugger mode. It needs to run on a real device, so the development machine on macOS, and an actual iPhone or iPad on iOS, because the iOS Simulator cannot simulate metal.

### MetalBox debugging

The usefulness of the iOS & macOS app, is that you can _Capture the GPU Frame_ while running in debug mode in Xcode.

## Notes


#### Notes on categoryBitMask:

- categoryBitMasks need to be applied to all the childNodes of compound / combined node. (see example below)
- default categoryBitMask or nodes, lights and techniques is 1
- bitMask of nodes and lights (or technique) are compared with bitwise AND (0 * 1 = 0). Any non-zero result is rendered.

So don't use:

```
object.categoryBitMask = 4
```

But use:

```
object.enumerateChildNodes { (node, stop) in
    node.categoryBitMask = 4
}
```


#### Notes on Clearing of the color state:
 
- There is a difference between the default state of the clear value between iOS and macOS:
    - Default `colorStates.clear` on iOS: `true`
    - Default `colorStates.clear` on macOS: `false`
- Default `depthStates.clear` is `false` on both platforms.
- Clearing means that each draw pass clear the buffer before rendering content to it.
- If you don't clear that means the buffer value could be accumulated
    - This (not clearing) is useful if e.g. you need multiple blur passes on the same buffer.
 
As an example on what happens if you don't clear the color buffer, when you're not drawing every pixel (e.g. when only some nodes are affected from their categoryBitMask)

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


#### Notes on making it work Cross Platform:

In order to make the same code compile and run on both macOS and iOS, we need to make some shared type definitions, because the frameworks do not 100% overlap:

##### Colors:

```
#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif
```

##### Floats to be used in a `SCNVector3`:

```
#if os(macOS)
    typealias SCNVectorFloat = CGFloat
#else
    typealias SCNVectorFloat = Float
#endif
```
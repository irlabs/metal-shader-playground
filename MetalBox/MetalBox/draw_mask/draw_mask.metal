//
//  common.metal
//  TechniqueTest
//
//  Created by Volodymyr Boichentsov on 08/04/2018.
//  Copyright © 2018 3D4Medical LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

constexpr sampler samp = sampler(coord::normalized,
                              filter::linear);


// ----------------------- normals ------------------------


struct VertexIn_t
{
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
    float4 normal  [[ attribute(SCNVertexSemanticNormal) ]];
    float4 color  [[ attribute(SCNVertexSemanticColor) ]];
};

struct VertexOut_t
{
    float4 position [[position]];
    float4 normal;
    float2 uv;
};


struct SceneNode {
    float4x4 modelViewProjectionTransform;
    float4x4 normalTransform;
};

vertex VertexOut_t normalsVertex2(VertexIn_t in [[stage_in]],
                                        constant SceneNode& scn_node [[buffer(0)]])
{
    VertexOut_t out;
    out.position = scn_node.modelViewProjectionTransform  * in.position;
    out.normal  = scn_node.normalTransform * in.normal; 
    return out;
}


fragment half4 normalsFragment2(VertexOut_t vert [[stage_in]])
{
    half3 normal = normalize(half3(vert.normal.xyz));
//    return half4(1.0,0.,0.,1.0);
    return half4(normal, 1.0);
}


// ---- result pass

vertex VertexOut_t resultVertex2(VertexIn_t in [[stage_in]],
                                        constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                                        constant SceneNode& scn_node [[buffer(1)]])
{
    VertexOut_t out;
    out.position = in.position;
    out.uv = in.position.xy*float2(.5,-.5) + .5;
    return out;
};


fragment half4 resultFragment2(VertexOut_t vert [[stage_in]],
                                    texture2d<float, access::sample> normalSampler [[texture(0)]])
{
    
    float4 FragmentColor = normalSampler.sample(samp, vert.uv);
//    return half4(1.0,0.0,0.0,1.0);
    return half4(FragmentColor);
}





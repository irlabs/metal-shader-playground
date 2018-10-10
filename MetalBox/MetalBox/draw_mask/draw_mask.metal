//
//  draw_mask.metal
//  MetalBox
//
//  Created by Dirk van Oosterbosch on 10/10/2018.
//  Copyright © 2018 IRLabs. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

constexpr sampler samp = sampler(coord::normalized,
                              filter::linear);


// -------- Experiment with Normals (masked normal colors) --------


struct VertexIn_t {
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
    float4 normal  [[ attribute(SCNVertexSemanticNormal) ]];
    float4 color  [[ attribute(SCNVertexSemanticColor) ]];
};

struct VertexOut_t {
    float4 position [[position]];
    float4 normal;
    float2 uv;
};


struct SceneNode {
    float4x4 modelViewProjectionTransform;
    float4x4 normalTransform;
};


// ---- draw normals pass

vertex VertexOut_t drawNormalsVertex(VertexIn_t in [[stage_in]],
                                        constant SceneNode& scn_node [[buffer(0)]]) {
    
    VertexOut_t out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.normal  = scn_node.normalTransform * in.normal; 
    return out;
}


fragment half4 drawNormalsFragment(VertexOut_t vert [[stage_in]]) {
    
    half3 normal = normalize(half3(vert.normal.xyz));
//    return half4(1.0,0.,0.,1.0);
    return half4(normal, 1.0);
}


// ---- compose pass

vertex VertexOut_t normalsComposeVertex(VertexIn_t in [[stage_in]],
                                        constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                                        constant SceneNode& scn_node [[buffer(1)]]) {
    
    VertexOut_t out;
    out.position = in.position;
    out.uv = in.position.xy * float2(.5,-.5) + .5;
    return out;
};


fragment half4 normalsComposeFragment(VertexOut_t vert [[stage_in]],
                                    texture2d<float, access::sample> normalSampler [[texture(0)]],
                                    texture2d<float, access::sample> colorSampler [[texture(1)]]) {
    
    float4 FragmentColor = colorSampler.sample(samp, vert.uv);
    float4 NormalColor = normalSampler.sample(samp, vert.uv);

    if ( (NormalColor.r + NormalColor.g + NormalColor.b) < 0.01 ) {
        return half4(FragmentColor);
    }
    
//    return half4(1.0,0.0,0.0,1.0);
    return half4(NormalColor);
}





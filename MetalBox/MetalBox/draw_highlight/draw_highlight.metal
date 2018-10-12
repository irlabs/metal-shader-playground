//
//  draw_highlight.metal
//  MetalBox
//
//  Created by Dirk van Oosterbosch on 10/10/2018.
//  Copyright © 2018 IRLabs. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

constexpr sampler s = sampler(coord::normalized,
                              r_address::clamp_to_edge,
                              t_address::repeat,
                              filter::linear);

// -------- Highlighting 3D objects  -  blurred outline --------

struct VertexIn_t {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
    float4 normal   [[attribute(SCNVertexSemanticNormal)]];
    float4 color    [[attribute(SCNVertexSemanticColor)]];
};

struct VertexOut_t {
    float4 position [[position]];
    float4 normal;
    float2 uv;
};

struct SceneNode {
    float4x4 modelViewProjectionTransform;
    float4x4 normalTransform;
//
//    float4x4 modelTransform;
//    float4x4 modelViewTransform;
//    float4x4 normalTransform;
//    float4x4 modelViewProjectionTransform;
};


// -------- pass_draw_masks

vertex VertexOut_t mask_vertex(VertexIn_t in [[stage_in]],
                                     constant SceneNode& scn_node [[buffer(0)]]) {
    
    VertexOut_t out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.normal = scn_node.normalTransform * in.normal;
    return out;
}


fragment half4 mask_fragment(VertexOut_t vert [[stage_in]]) {
    
    half3 normal = normalize(half3(vert.position.xyz));
//        return half4(1.0, 1.0, 1.0, 1.0);
    return half4(normal, 1.0);
}

/*
vertex VertexOut_t mask_vertex(VertexIn_t in [[stage_in]],
                                        constant SceneNode& scn_node [[buffer(0)]])
{
    VertexOut_t out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.normal = scn_node.normalTransform * in.normal;
    return out;

//
//    VertexOut_t out;
//    out.position = scn_node.modelViewProjectionTransform * float4(in.position.xyz, 1.0);
//    return out;
};

fragment half4 mask_fragment(VertexOut_t vert [[stage_in]])
//                                          texture2d<float, access::sample> colorSampler [[texture(0)]])
{
//    constexpr sampler sampler2d(coord::normalized, filter::linear, address::repeat);
//    return half4(1.0);
//    half3 pos = normalize(half3(vert.position.xyz));
//    half2 uv = normalize(half2(vert.uv));
//    return half4(1.0, 1.0, 1.0, 1.0);
    half3 normal = normalize(half3(vert.position.xyz));
    return half4(normal, 1.0);

};
*/


// -------- pass_combine

vertex VertexOut_t combine_vertex(VertexIn_t in [[stage_in]])
{
    VertexOut_t out;
    out.position = in.position;
    out.uv = in.position.xy * float2(.5,-.5) + .5;

//    out.uv = float2( (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5 );
    return out;
};


fragment half4 combine_fragment(VertexOut_t vert [[stage_in]],
                                            texture2d<float, access::sample> colorSampler [[texture(0)]],
                                            texture2d<float, access::sample> maskSampler [[texture(1)]],
                                            texture2d<float, access::sample> blurSampler [[texture(2)]])
{
    
    float4 FragmentColor = colorSampler.sample( s, vert.uv);
    float4 maskColor = maskSampler.sample(s, vert.uv);
    float4 blurColor = blurSampler.sample(s, vert.uv);
    
    // Don't render glow on top of the object itself
    if ( (blurColor.r + blurColor.g + blurColor.b) > 0.01) {
        if ( (maskColor.r + maskColor.g + maskColor.b) < 0.01 ) {
//            return half4(maskColor);
            
        float3 glowColor = float3(1.0, 1.0, 1.0); // White glow
            
        float alpha = blurColor.r;
        float3 out = FragmentColor.rgb * ( 1.0 - alpha ) + alpha * glowColor;
        return half4( float4(out.rgb, 1.0) );
        }
    }
    return half4(FragmentColor);
    
//    float3 glowColor = float3(1.0, 1.0, 0.0); // Yellow
//    
//    float alpha = maskColor.r;
//    float3 out = FragmentColor.rgb * ( 1.0 - alpha ) + alpha * glowColor;
//    return half4( float4(out.rgb, 1.0) );
    
}


// -------- Blur passes: pass_blur_h + pass_blur_v

vertex VertexOut_t blur_vertex(VertexIn_t in [[stage_in]])
{
    VertexOut_t out;
    out.position = in.position;
    out.uv = float2( (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5 );
    return out;
};

// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
constant float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };
constant float bufferSize = 512.0;

fragment half4 blur_fragment_h(VertexOut_t vert [[stage_in]],
                                          texture2d<float, access::sample> maskSampler [[texture(0)]])
{
    
    float4 FragmentColor = maskSampler.sample( s, vert.uv);
    float FragmentR = FragmentColor.r * weight[0];
    
    
    for (int i=1; i<5; i++) {
        FragmentR += maskSampler.sample( s, ( vert.uv + float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
        FragmentR += maskSampler.sample( s, ( vert.uv - float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
    }
    return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
}

fragment half4 blur_fragment_v(VertexOut_t vert [[stage_in]],
                               texture2d<float, access::sample> maskSampler [[texture(0)]])
{
    
    float4 FragmentColor = maskSampler.sample( s, vert.uv);
    float FragmentR = FragmentColor.r * weight[0];
    
    for (int i=1; i<5; i++) {
        FragmentR += maskSampler.sample( s, ( vert.uv + float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
        FragmentR += maskSampler.sample( s, ( vert.uv - float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
    }
    
    return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
    
};



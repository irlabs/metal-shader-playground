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

// -------- Highlighting 3D objects  --  blurred outline --------

struct VertexIn_t {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
    /*
     // Other possible input parameters:
    float4 normal   [[attribute(SCNVertexSemanticNormal)]];
    float4 color    [[attribute(SCNVertexSemanticColor)]];
     */
};

struct VertexOut_t {
    float4 position [[position]];
    float2 uv;
    /*
     // Other possible output parameters:
    float4 normal;
     */
};

struct SceneNode {
    float4x4 modelViewProjectionTransform;
    float4x4 normalTransform;
    /*
     // Other possible node properties:
    float4x4 modelTransform;
    float4x4 modelViewTransform;
     */
};

struct VariableInputs {
    float my_variable;
};


// -------- shared shaders

vertex VertexOut_t pass_through_vertex(VertexIn_t in [[stage_in]]) {
    
    VertexOut_t out;
    out.position = in.position;
    out.uv = in.position.xy * float2(0.5, -0.5) + 0.5;
    return out;
}


// -------- pass_draw_masks

vertex VertexOut_t mask_vertex(VertexIn_t in [[stage_in]],
                               constant SceneNode& scn_node [[buffer(0)]]) {
    
    VertexOut_t out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    return out;
}


fragment half4 mask_fragment() {
    
    return half4(1.0);
}


// -------- Blur passes: pass_blur_h + pass_blur_v

/* tap 9 (sigma 1.0) */
//constant int nSamples = 5;
//constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
//constant float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };

/* optimized tap 9 (as above, but with only 5 samples) */
//constant int nSamples = 3;
//constant float offset[] = { 0.0, 1.38461538, 3.23076923 };
//constant float weight[] = { 0.2270270270, 0.31621622, 0.07027027 };

/* tap 17 (sigma 3.0) */
//constant int nSamples = 9;
//constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 };
//constant float weight[] = { 0.13298, 0.125858, 0.106701, 0.081029, 0.055119, 0.033585, 0.018331, 0.008962, 0.003924 };

/* optimized tap 17 (as above, but with only 9 samples) */
constant int nSamples = 5;
constant float offset[] = { 0.0, 1.45881, 3.40485, 5.35309, 7.30452 };
constant float weight[] = { 0.13298, 0.23256, 0.13615, 0.05192, 0.01289 };


fragment half4 blur_fragment_h(VertexOut_t vert [[stage_in]],
                               texture2d<float, access::sample> maskSampler [[texture(0)]]) {
    
    float4 FragmentColor = maskSampler.sample( s, vert.uv);
    float FragmentR = FragmentColor.r * weight[0];
    uint bufferSize = maskSampler.get_width();
    
    for (int i = 1; i < nSamples; i++) {
        FragmentR += maskSampler.sample( s, ( vert.uv + float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
        FragmentR += maskSampler.sample( s, ( vert.uv - float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
    }
    return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
}


fragment half4 blur_fragment_v(VertexOut_t vert [[stage_in]],
                               texture2d<float, access::sample> maskSampler [[texture(0)]]) {
    
    float4 FragmentColor = maskSampler.sample( s, vert.uv);
    float FragmentR = FragmentColor.r * weight[0];
    uint bufferSize = maskSampler.get_height();

    for (int i = 1; i < nSamples; i++) {
        FragmentR += maskSampler.sample( s, ( vert.uv + float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
        FragmentR += maskSampler.sample( s, ( vert.uv - float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
    }
    
    return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
}


// -------- pass_combine

fragment half4 combine_fragment(VertexOut_t vert [[stage_in]],
                                            texture2d<float, access::sample> colorSampler [[texture(0)]],
                                            texture2d<float, access::sample> maskSampler [[texture(1)]],
                                            texture2d<float, access::sample> blurSampler [[texture(2)]],
                                            constant VariableInputs& variablesIn [[buffer(0)]])
{
    
    float4 FragmentColor = colorSampler.sample( s, vert.uv);
    float4 maskColor = maskSampler.sample(s, vert.uv);
    float4 blurColor = blurSampler.sample(s, vert.uv);
    
    // Don't render glow on top of the object itself (or the background)
    // (Only if blur is at least visible & not masked by object itself)
    if ( (blurColor.r + blurColor.g + blurColor.b) > 0.01) {
        if ( (maskColor.r + maskColor.g + maskColor.b) < 0.01 ) {

            // Create (semi-transparent) white glow
            float3 glowColor = float3(1.0, variablesIn.my_variable, variablesIn.my_variable);
            float alpha = blurColor.r;
            float3 out = FragmentColor.rgb * ( 1.0 - alpha ) + alpha * glowColor;
            return half4( float4(out.rgb, 1.0) );
        }
    }
    return half4(FragmentColor);
}


# TODO to create a better blur

- [ ] new technique for grow shrink
- [ ] external variable to grow and shrink the blur (subtract blur value ... )
    - [ ] test with min or fmin function (from <metal_math>)
- [ ] use perfect distribution and then add extra weight
- [ ] merge back to dev & master
- [ ] clean up todo
- [ ] publish

### Extra effect
- [ ] opacity + shadow
- [ ] 2 light sources shadow experiment


In combine

```
            // Create (semi-transparent) white glow
            float fade = 1.0 - variablesIn.my_variable;
            float3 glowColor = float3(1.0);
            float alpha = blurColor.r - fade;
            if (alpha < 0.0) { alpha = 0; }
            float3 out = FragmentColor.rgb * ( 1.0 - alpha ) + alpha * glowColor;
            return half4( float4(out.rgb, 1.0) );
```
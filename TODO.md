# TODO to create a better blur

- [x] merge working shader back to master
- [x] new feature/improve_blur
- [x] simply pass_vertex function (reuse)
- [x] extra pass: `pass_initial_blur_h`
- [x] 5 passes (10 total) to see effect
- [x] mask target as r8 or r16 (CAN'T GET THIS TO WORK)
- [x] blur function / 17tap
- [ ] calculate offset and weights with http://dev.theomader.com/gaussian-kernel-calculator/ or https://github.com/manuelbua/blur-ninja
- [ ] link to calculations
- [ ] fix copyright headers
- [x] number techniques
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


```
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 };
constant float weight[] = { 0.038973, 0.034483, 0.023884, 0.012949, 0.005495, 0.001825, 0.000474, 0.000097, 0.000015 };

```

```
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 };
constant float weight[] = { 0.12, 0.11, 0.10, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04 };

tap 11
0.0093	0.028002	0.065984	0.121703	0.175713	0.198596

tap 17 (sigma 3.0)
0.003924	0.008962	0.018331	0.033585	0.055119	0.081029	0.106701	0.125858	0.13298
```

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
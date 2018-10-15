# TODO to create a better blur

- [ ] merge working shader back to master
- [ ] new feature/improve_blur
- [ ] simply pass_vertex function (reuse)
- [ ] extra pass: `pass_initial_blur_h`
- [ ] 5 passes (10 total) to see effect
- [ ] mask target as r8 or r16
- [ ] blur function 17tap
- [ ] calculate offset and weights with http://dev.theomader.com/gaussian-kernel-calculator/ or https://github.com/manuelbua/blur-ninja
- [ ] external variable to grow and shrink the blur (subtract blur value ... )
- [ ] use perfect distribution and then add extra weight

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
class L{constructor(t,e="content",i=1,s=0){this.canvas=document.getElementById(t),this.role=e,this.reactivity=i,this.variant=s,this.contextOptions={alpha:!0,depth:!0,stencil:!1,antialias:!1,premultipliedAlpha:!0,preserveDrawingBuffer:!1,powerPreference:"high-performance",failIfMajorPerformanceCaveat:!1};let o=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl");if(o&&!o.isContextLost()?(console.log(`🔄 Reusing existing WebGL context for ${t}`),this.gl=o):this.gl=this.canvas.getContext("webgl2",this.contextOptions)||this.canvas.getContext("webgl",this.contextOptions)||this.canvas.getContext("experimental-webgl",this.contextOptions),!this.gl)throw console.error(`WebGL not supported for ${t}`),this.showWebGLError(),new Error(`WebGL not supported for ${t}`);this.variantParams=this.generateVariantParams(s),this.roleParams=this.generateRoleParams(e),this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0,this.clickIntensity=0,this.clickDecay=.95,this.touchX=.5,this.touchY=.5,this.touchActive=!1,this.touchMorph=0,this.touchChaos=0,this.scrollPosition=0,this.scrollVelocity=0,this.scrollDecay=.92,this.parallaxDepth=0,this.gridDensityShift=0,this.colorScrollShift=0,this.densityVariation=0,this.densityTarget=0,this.audioData={bass:0,mid:0,high:0},this.audioDensityBoost=0,this.audioMorphBoost=0,this.audioSpeedBoost=0,this.audioChaosBoost=0,this.audioColorShift=0,this.startTime=Date.now(),this.initShaders(),this.initBuffers(),this.resize()}generateVariantParams(t){const e=["TETRAHEDRON","HYPERCUBE","SPHERE","TORUS","KLEIN BOTTLE","FRACTAL","WAVE","CRYSTAL"],s=[0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,7][t]||0,o=t%4,h=e[s]+[" LATTICE"," FIELD"," MATRIX"," RESONANCE"][o],r={0:{density:.8+o*.2,speed:.3+o*.1,chaos:o*.1,morph:0+o*.2},1:{density:1+o*.3,speed:.5+o*.1,chaos:o*.15,morph:o*.2},2:{density:1.2+o*.4,speed:.4+o*.2,chaos:.1+o*.1,morph:.3+o*.2},3:{density:.9+o*.3,speed:.6+o*.2,chaos:.2+o*.2,morph:.5+o*.1},4:{density:1.4+o*.5,speed:.7+o*.1,chaos:.3+o*.2,morph:.7+o*.1},5:{density:1.8+o*.3,speed:.5+o*.3,chaos:.5+o*.2,morph:.8+o*.05},6:{density:.6+o*.4,speed:.8+o*.4,chaos:.4+o*.3,morph:.6+o*.2},7:{density:1.6+o*.2,speed:.2+o*.1,chaos:.1+o*.1,morph:.2+o*.2}}[s];return{geometryType:s,name:h,density:r.density,speed:r.speed,hue:t*12.27%360,saturation:.8+o*.05,intensity:.5+o*.1,chaos:r.chaos,morph:r.morph}}generateRoleParams(t){const e=this.variantParams;return{background:{densityMult:.4,speedMult:.2,colorShift:0,intensity:.2,mouseReactivity:.3,clickReactivity:.1},shadow:{densityMult:.8,speedMult:.3,colorShift:180,intensity:.4,mouseReactivity:.5,clickReactivity:.3},content:{densityMult:e.density,speedMult:e.speed,colorShift:e.hue,intensity:e.intensity,mouseReactivity:1,clickReactivity:.8},highlight:{densityMult:1.5+e.density*.3,speedMult:.8+e.speed*.2,colorShift:e.hue+60,intensity:.6+e.intensity*.2,mouseReactivity:1.2,clickReactivity:1},accent:{densityMult:2.5+e.density*.5,speedMult:.4+e.speed*.1,colorShift:e.hue+300,intensity:.3+e.intensity*.1,mouseReactivity:1.5,clickReactivity:1.2}}[t]||{densityMult:1,speedMult:.5,colorShift:0,intensity:.5,mouseReactivity:1,clickReactivity:.5}}initShaders(){const t=`
            attribute vec2 a_position;
            void main() {
                gl_Position = vec4(a_position, 0.0, 1.0);
            }
        `,e=`
            precision highp float;
            
            uniform vec2 u_resolution;
            uniform float u_time;
            uniform vec2 u_mouse;
            uniform float u_geometry;
            uniform float u_density;
            uniform float u_speed;
            uniform vec3 u_color;
            uniform float u_intensity;
            uniform float u_roleDensity;
            uniform float u_roleSpeed;
            uniform float u_colorShift;
            uniform float u_chaosIntensity;
            uniform float u_mouseIntensity;
            uniform float u_clickIntensity;
            uniform float u_densityVariation;
            uniform float u_geometryType;
            uniform float u_chaos;
            uniform float u_morph;
            uniform float u_touchMorph;
            uniform float u_touchChaos;
            uniform float u_scrollParallax;
            uniform float u_gridDensityShift;
            uniform float u_colorScrollShift;
            uniform float u_audioDensityBoost;
            uniform float u_audioMorphBoost;
            uniform float u_audioSpeedBoost;
            uniform float u_audioChaosBoost;
            uniform float u_audioColorShift;
            uniform float u_rot4dXY;
            uniform float u_rot4dXZ;
            uniform float u_rot4dYZ;
            uniform float u_rot4dXW;
            uniform float u_rot4dYW;
            uniform float u_rot4dZW;

            // 6D rotation matrices - 3D space rotations (XY, XZ, YZ)
            mat4 rotateXY(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(c, -s, 0, 0, s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
            }

            mat4 rotateXZ(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(c, 0, s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1);
            }

            mat4 rotateYZ(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
            }

            // 4D hyperspace rotations (XW, YW, ZW)
            mat4 rotateXW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(c, 0, 0, -s, 0, 1, 0, 0, 0, 0, 1, 0, s, 0, 0, c);
            }

            mat4 rotateYW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(1, 0, 0, 0, 0, c, 0, -s, 0, 0, 1, 0, 0, s, 0, c);
            }

            mat4 rotateZW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, c, -s, 0, 0, s, c);
            }
            
            // 4D to 3D projection
            vec3 project4Dto3D(vec4 p) {
                float w = 2.5 / (2.5 + p.w);
                return vec3(p.x * w, p.y * w, p.z * w);
            }

            // ========================================
            // POLYTOPE CORE WARP FUNCTIONS (24 Geometries)
            // ========================================
            vec3 warpHypersphereCore(vec3 p, int geometryIndex, vec2 mouseDelta) {
                float radius = length(p);
                float morphBlend = clamp(u_morph * 0.6 + 0.3, 0.0, 2.0);
                float w = sin(radius * (1.3 + float(geometryIndex) * 0.12) + u_time * 0.0008 * u_speed);
                w *= (0.4 + morphBlend * 0.45);

                vec4 p4d = vec4(p * (1.0 + morphBlend * 0.2), w);
                p4d = rotateXY(u_rot4dXY) * p4d;
                p4d = rotateXZ(u_rot4dXZ) * p4d;
                p4d = rotateYZ(u_rot4dYZ) * p4d;
                p4d = rotateXW(u_rot4dXW) * p4d;
                p4d = rotateYW(u_rot4dYW) * p4d;
                p4d = rotateZW(u_rot4dZW) * p4d;

                vec3 projected = project4Dto3D(p4d);
                return mix(p, projected, clamp(0.45 + morphBlend * 0.35, 0.0, 1.0));
            }

            vec3 warpHypertetraCore(vec3 p, int geometryIndex, vec2 mouseDelta) {
                vec3 c1 = normalize(vec3(1.0, 1.0, 1.0));
                vec3 c2 = normalize(vec3(-1.0, -1.0, 1.0));
                vec3 c3 = normalize(vec3(-1.0, 1.0, -1.0));
                vec3 c4 = normalize(vec3(1.0, -1.0, -1.0));

                float morphBlend = clamp(u_morph * 0.8 + 0.2, 0.0, 2.0);
                float basisMix = dot(p, c1) * 0.14 + dot(p, c2) * 0.1 + dot(p, c3) * 0.08;
                float w = sin(basisMix * 5.5 + u_time * 0.0009 * u_speed);
                w *= cos(dot(p, c4) * 4.2 - u_time * 0.0007 * u_speed);
                w *= (0.5 + morphBlend * 0.4);

                vec3 offset = vec3(dot(p, c1), dot(p, c2), dot(p, c3)) * 0.1 * morphBlend;
                vec4 p4d = vec4(p + offset, w);
                p4d = rotateXY(u_rot4dXY) * p4d;
                p4d = rotateXZ(u_rot4dXZ) * p4d;
                p4d = rotateYZ(u_rot4dYZ) * p4d;
                p4d = rotateXW(u_rot4dXW) * p4d;
                p4d = rotateYW(u_rot4dYW) * p4d;
                p4d = rotateZW(u_rot4dZW) * p4d;

                vec3 projected = project4Dto3D(p4d);

                float planeInfluence = min(min(abs(dot(p, c1)), abs(dot(p, c2))), min(abs(dot(p, c3)), abs(dot(p, c4))));
                vec3 blended = mix(p, projected, clamp(0.45 + morphBlend * 0.35, 0.0, 1.0));
                return mix(blended, blended * (1.0 - planeInfluence * 0.55), 0.2 + morphBlend * 0.2);
            }

            vec3 applyCoreWarp(vec3 p, float geometryType, vec2 mouseDelta) {
                float totalBase = 8.0;
                float coreFloat = floor(geometryType / totalBase);
                int coreIndex = int(clamp(coreFloat, 0.0, 2.0));
                float baseGeomFloat = geometryType - floor(geometryType / totalBase) * totalBase;
                int geometryIndex = int(clamp(floor(baseGeomFloat + 0.5), 0.0, totalBase - 1.0));

                if (coreIndex == 1) {
                    return warpHypersphereCore(p, geometryIndex, mouseDelta);
                }
                if (coreIndex == 2) {
                    return warpHypertetraCore(p, geometryIndex, mouseDelta);
                }
                return p;
            }
            // ========================================

            // Enhanced VIB3 Geometry Library - Higher Fidelity
            float tetrahedronLattice(vec3 p, float gridSize) {
                vec3 q = fract(p * gridSize) - 0.5;
                
                // Enhanced tetrahedron vertices with holographic shimmer
                float d1 = length(q);
                float d2 = length(q - vec3(0.35, 0.0, 0.0));
                float d3 = length(q - vec3(0.0, 0.35, 0.0));
                float d4 = length(q - vec3(0.0, 0.0, 0.35));
                float d5 = length(q - vec3(0.2, 0.2, 0.0));
                float d6 = length(q - vec3(0.2, 0.0, 0.2));
                float d7 = length(q - vec3(0.0, 0.2, 0.2));
                
                float vertices = 1.0 - smoothstep(0.0, 0.03, min(min(min(d1, d2), min(d3, d4)), min(min(d5, d6), d7)));
                
                // Enhanced edge network with interference patterns
                float edges = 0.0;
                float shimmer = sin(u_time * 0.002) * 0.02;
                edges = max(edges, 1.0 - smoothstep(0.0, 0.015, abs(length(q.xy) - (0.18 + shimmer))));
                edges = max(edges, 1.0 - smoothstep(0.0, 0.015, abs(length(q.yz) - (0.18 + shimmer * 0.8))));
                edges = max(edges, 1.0 - smoothstep(0.0, 0.015, abs(length(q.xz) - (0.18 + shimmer * 1.2))));
                
                // Add interference patterns between vertices
                float interference = sin(d1 * 25.0 + u_time * 0.003) * sin(d2 * 22.0 + u_time * 0.0025) * 0.1;
                
                // Volumetric density based on distance field
                float volume = exp(-length(q) * 3.0) * 0.15;
                
                return max(vertices, edges * 0.7) + interference + volume;
            }
            
            float hypercubeLattice(vec3 p, float gridSize) {
                vec3 grid = fract(p * gridSize);
                vec3 q = grid - 0.5;
                
                // Enhanced hypercube with 4D projection effects
                vec3 edges = 1.0 - smoothstep(0.0, 0.025, abs(q));
                float wireframe = max(max(edges.x, edges.y), edges.z);
                
                // Add 4D hypercube vertices (8 corners + 8 hypervertices)
                float vertices = 0.0;
                for(int i = 0; i < 8; i++) {
                    // WebGL 1.0 compatible modulus replacement
                    float iFloat = float(i);
                    vec3 corner = vec3(
                        floor(iFloat - floor(iFloat / 2.0) * 2.0) - 0.5,
                        floor((iFloat / 2.0) - floor((iFloat / 2.0) / 2.0) * 2.0) - 0.5,
                        float(i / 4) - 0.5
                    );
                    float dist = length(q - corner * 0.4);
                    vertices = max(vertices, 1.0 - smoothstep(0.0, 0.04, dist));
                }
                
                // Holographic interference patterns
                float interference = sin(length(q) * 20.0 + u_time * 0.002) * 0.08;
                
                // Cross-dimensional glow
                float glow = exp(-length(q) * 2.5) * 0.12;
                
                return wireframe * 0.8 + vertices + interference + glow;
            }
            
            float sphereLattice(vec3 p, float gridSize) {
                vec3 q = fract(p * gridSize) - 0.5;
                float r = length(q);
                return 1.0 - smoothstep(0.2, 0.5, r);
            }
            
            float torusLattice(vec3 p, float gridSize) {
                vec3 q = fract(p * gridSize) - 0.5;
                float r1 = sqrt(q.x*q.x + q.y*q.y);
                float r2 = sqrt((r1 - 0.3)*(r1 - 0.3) + q.z*q.z);
                return 1.0 - smoothstep(0.0, 0.1, r2);
            }
            
            float kleinLattice(vec3 p, float gridSize) {
                vec3 q = fract(p * gridSize);
                float u = q.x * 2.0 * 3.14159;
                float v = q.y * 2.0 * 3.14159;
                float x = cos(u) * (3.0 + cos(u/2.0) * sin(v) - sin(u/2.0) * sin(2.0*v));
                float klein = length(vec2(x, q.z)) - 0.1;
                return 1.0 - smoothstep(0.0, 0.05, abs(klein));
            }
            
            float fractalLattice(vec3 p, float gridSize) {
                vec3 q = p * gridSize;
                float scale = 1.0;
                float fractal = 0.0;
                for(int i = 0; i < 4; i++) {
                  q = fract(q) - 0.5;
                  fractal += abs(length(q)) / scale;
                  scale *= 2.0;
                  q *= 2.0;
                }
                return 1.0 - smoothstep(0.0, 1.0, fractal);
            }
            
            float waveLattice(vec3 p, float gridSize) {
                vec3 q = p * gridSize;
                float wave = sin(q.x * 2.0) * sin(q.y * 2.0) * sin(q.z * 2.0 + u_time);
                return smoothstep(-0.5, 0.5, wave);
            }
            
            float crystalLattice(vec3 p, float gridSize) {
                vec3 q = fract(p * gridSize) - 0.5;
                float d = max(max(abs(q.x), abs(q.y)), abs(q.z));
                return 1.0 - smoothstep(0.3, 0.5, d);
            }
            
            float getDynamicGeometry(vec3 p, float gridSize, float geometryType) {
                // Apply polytope core warp transformation (24-geometry system)
                vec3 warped = applyCoreWarp(p, geometryType, vec2(0.0, 0.0));

                // WebGL 1.0 compatible modulus replacement - decode base geometry
                float baseGeomFloat = geometryType - floor(geometryType / 8.0) * 8.0;
                int baseGeom = int(baseGeomFloat);
                float variation = floor(geometryType / 8.0) / 4.0;
                float variedGridSize = gridSize * (0.5 + variation * 1.5);

                // Call lattice functions with warped point (enables 24 geometry variants)
                if (baseGeom == 0) return tetrahedronLattice(warped, variedGridSize);
                else if (baseGeom == 1) return hypercubeLattice(warped, variedGridSize);
                else if (baseGeom == 2) return sphereLattice(warped, variedGridSize);
                else if (baseGeom == 3) return torusLattice(warped, variedGridSize);
                else if (baseGeom == 4) return kleinLattice(warped, variedGridSize);
                else if (baseGeom == 5) return fractalLattice(warped, variedGridSize);
                else if (baseGeom == 6) return waveLattice(warped, variedGridSize);
                else return crystalLattice(warped, variedGridSize);
            }
            
            vec3 hsv2rgb(vec3 c) {
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }
            
            vec3 rgbGlitch(vec3 color, vec2 uv, float intensity) {
                vec2 offset = vec2(intensity * 0.005, 0.0);
                float r = color.r + sin(uv.y * 30.0 + u_time * 0.001) * intensity * 0.06;
                float g = color.g + sin(uv.y * 28.0 + u_time * 0.0012) * intensity * 0.06;
                float b = color.b + sin(uv.y * 32.0 + u_time * 0.0008) * intensity * 0.06;
                return vec3(r, g, b);
            }
            
            float moirePattern(vec2 uv, float intensity) {
                float freq1 = 12.0 + intensity * 6.0 + u_densityVariation * 3.0;
                float freq2 = 14.0 + intensity * 8.0 + u_densityVariation * 4.0;
                float pattern1 = sin(uv.x * freq1) * sin(uv.y * freq1);
                float pattern2 = sin(uv.x * freq2) * sin(uv.y * freq2);
                return (pattern1 * pattern2) * intensity * 0.15;
            }
            
            float gridOverlay(vec2 uv, float intensity) {
                vec2 grid = fract(uv * (8.0 + u_densityVariation * 4.0));
                float lines = 0.0;
                lines = max(lines, 1.0 - smoothstep(0.0, 0.02, abs(grid.x - 0.5)));
                lines = max(lines, 1.0 - smoothstep(0.0, 0.02, abs(grid.y - 0.5)));
                return lines * intensity * 0.1;
            }
            
            void main() {
                vec2 uv = gl_FragCoord.xy / u_resolution.xy;
                float aspectRatio = u_resolution.x / u_resolution.y;
                uv.x *= aspectRatio;
                uv -= 0.5;
                
                float time = u_time * 0.0004 * u_speed * u_roleSpeed;
                
                float mouseInfluence = u_mouseIntensity * 0.25; // FIX: Reduce mouse jarring by 50%
                vec2 mouseOffset = (u_mouse - 0.5) * mouseInfluence;
                
                float parallaxOffset = u_scrollParallax * 0.2;
                vec2 scrollOffset = vec2(parallaxOffset * 0.1, parallaxOffset * 0.05);
                
                float morphOffset = u_touchMorph * 0.3;
                
                vec4 p4d = vec4(uv + mouseOffset * 0.1 + scrollOffset, 
                               sin(time * 0.1 + morphOffset) * 0.15, 
                               cos(time * 0.08 + morphOffset * 0.5) * 0.15);
                
                float scrollRotation = u_scrollParallax * 0.1;
                float touchRotation = u_touchMorph * 0.2;

                // Combine manual rotation with automatic/interactive rotation - 6D full rotation
                p4d = rotateXY(u_rot4dXY + time * 0.1) * p4d;
                p4d = rotateXZ(u_rot4dXZ + time * 0.12) * p4d;
                p4d = rotateYZ(u_rot4dYZ + time * 0.08) * p4d;
                p4d = rotateXW(u_rot4dXW + time * 0.2 + mouseOffset.y * 0.5 + scrollRotation) * p4d;
                p4d = rotateYW(u_rot4dYW + time * 0.15 + mouseOffset.x * 0.5 + touchRotation) * p4d;
                p4d = rotateZW(u_rot4dZW + time * 0.25 + u_clickIntensity * 0.3 + u_touchChaos * 0.4) * p4d;
                
                vec3 p = project4Dto3D(p4d);
                
                float scrollDensityMod = 1.0 + u_gridDensityShift * 0.3;
                float audioDensityMod = 1.0 + u_audioDensityBoost * 0.5;
                // FIX: Prevent density doubling by using base density with controlled variations
                float baseDensity = u_density * u_roleDensity;
                float densityVariations = (u_densityVariation * 0.3 + (scrollDensityMod - 1.0) * 0.4 + (audioDensityMod - 1.0) * 0.2);
                float roleDensity = baseDensity + densityVariations;
                
                float morphedGeometry = u_geometryType + u_morph * 3.0 + u_touchMorph * 2.0 + u_audioMorphBoost * 1.5;
                float lattice = getDynamicGeometry(p, roleDensity, morphedGeometry);
                
                // Enhanced holographic color processing
                vec3 baseColor = u_color;
                float latticeIntensity = lattice * u_intensity;
                
                // Multi-layer color composition for higher fidelity
                vec3 color = baseColor * (0.2 + latticeIntensity * 0.8);
                
                // Holographic shimmer layers
                vec3 shimmer1 = baseColor * lattice * 0.5;
                vec3 shimmer2 = baseColor * sin(lattice * 8.0 + u_time * 0.001) * 0.2;
                vec3 shimmer3 = baseColor * cos(lattice * 12.0 + u_time * 0.0008) * 0.15;
                
                color += shimmer1 + shimmer2 + shimmer3;
                
                // Enhanced brightness variations with interference
                color += vec3(lattice * 0.6) * baseColor;
                color += vec3(sin(lattice * 15.0) * 0.1) * baseColor;
                
                // Depth-based coloring for 3D effect
                float depth = 1.0 - length(p) * 0.3;
                color *= (0.7 + depth * 0.3);
                
                float enhancedChaos = u_chaos + u_chaosIntensity + u_touchChaos * 0.3 + u_audioChaosBoost * 0.4;
                color += vec3(moirePattern(uv + scrollOffset, enhancedChaos));
                color += vec3(gridOverlay(uv, u_mouseIntensity + u_scrollParallax * 0.1));
                color = rgbGlitch(color, uv, enhancedChaos);
                
                // Apply morph distortion to position
                vec2 morphDistortion = vec2(sin(uv.y * 10.0 + u_time * 0.001) * u_morph * 0.1, 
                                           cos(uv.x * 10.0 + u_time * 0.001) * u_morph * 0.1);
                color = mix(color, color * (1.0 + length(morphDistortion)), u_morph * 0.5);
                
                // Enhanced holographic interaction effects
                float mouseDist = length(uv - (u_mouse - 0.5) * vec2(aspectRatio, 1.0));
                
                // Multi-layer mouse glow with holographic ripples
                float mouseGlow = exp(-mouseDist * 1.2) * u_mouseIntensity * 0.25;
                float mouseRipple = sin(mouseDist * 15.0 - u_time * 0.003) * exp(-mouseDist * 2.0) * u_mouseIntensity * 0.1;
                color += vec3(mouseGlow + mouseRipple) * baseColor * 0.8;
                
                // Enhanced click pulse with interference
                float clickPulse = u_clickIntensity * exp(-mouseDist * 1.8) * 0.4;
                float clickRing = sin(mouseDist * 20.0 - u_clickIntensity * 5.0) * u_clickIntensity * 0.15;
                color += vec3(clickPulse + clickRing, (clickPulse + clickRing) * 0.6, (clickPulse + clickRing) * 1.2);
                
                // Holographic interference from interactions
                float interference = sin(mouseDist * 25.0 + u_time * 0.002) * u_mouseIntensity * 0.05;
                color += vec3(interference) * baseColor;
                
                gl_FragColor = vec4(color, 0.95);
            }
        `;this.program=this.createProgram(t,e),this.uniforms={resolution:this.gl.getUniformLocation(this.program,"u_resolution"),time:this.gl.getUniformLocation(this.program,"u_time"),mouse:this.gl.getUniformLocation(this.program,"u_mouse"),geometry:this.gl.getUniformLocation(this.program,"u_geometry"),density:this.gl.getUniformLocation(this.program,"u_density"),speed:this.gl.getUniformLocation(this.program,"u_speed"),color:this.gl.getUniformLocation(this.program,"u_color"),intensity:this.gl.getUniformLocation(this.program,"u_intensity"),roleDensity:this.gl.getUniformLocation(this.program,"u_roleDensity"),roleSpeed:this.gl.getUniformLocation(this.program,"u_roleSpeed"),colorShift:this.gl.getUniformLocation(this.program,"u_colorShift"),chaosIntensity:this.gl.getUniformLocation(this.program,"u_chaosIntensity"),mouseIntensity:this.gl.getUniformLocation(this.program,"u_mouseIntensity"),clickIntensity:this.gl.getUniformLocation(this.program,"u_clickIntensity"),densityVariation:this.gl.getUniformLocation(this.program,"u_densityVariation"),geometryType:this.gl.getUniformLocation(this.program,"u_geometryType"),chaos:this.gl.getUniformLocation(this.program,"u_chaos"),morph:this.gl.getUniformLocation(this.program,"u_morph"),touchMorph:this.gl.getUniformLocation(this.program,"u_touchMorph"),touchChaos:this.gl.getUniformLocation(this.program,"u_touchChaos"),scrollParallax:this.gl.getUniformLocation(this.program,"u_scrollParallax"),gridDensityShift:this.gl.getUniformLocation(this.program,"u_gridDensityShift"),colorScrollShift:this.gl.getUniformLocation(this.program,"u_colorScrollShift"),audioDensityBoost:this.gl.getUniformLocation(this.program,"u_audioDensityBoost"),audioMorphBoost:this.gl.getUniformLocation(this.program,"u_audioMorphBoost"),audioSpeedBoost:this.gl.getUniformLocation(this.program,"u_audioSpeedBoost"),audioChaosBoost:this.gl.getUniformLocation(this.program,"u_audioChaosBoost"),audioColorShift:this.gl.getUniformLocation(this.program,"u_audioColorShift"),rot4dXY:this.gl.getUniformLocation(this.program,"u_rot4dXY"),rot4dXZ:this.gl.getUniformLocation(this.program,"u_rot4dXZ"),rot4dYZ:this.gl.getUniformLocation(this.program,"u_rot4dYZ"),rot4dXW:this.gl.getUniformLocation(this.program,"u_rot4dXW"),rot4dYW:this.gl.getUniformLocation(this.program,"u_rot4dYW"),rot4dZW:this.gl.getUniformLocation(this.program,"u_rot4dZW")}}createProgram(t,e){const i=this.createShader(this.gl.VERTEX_SHADER,t),s=this.createShader(this.gl.FRAGMENT_SHADER,e),o=this.gl.createProgram();if(this.gl.attachShader(o,i),this.gl.attachShader(o,s),this.gl.linkProgram(o),!this.gl.getProgramParameter(o,this.gl.LINK_STATUS))throw new Error("Program linking failed: "+this.gl.getProgramInfoLog(o));return o}createShader(t,e){if(!this.gl)throw console.error("❌ Cannot create shader: WebGL context is null"),new Error("WebGL context is null");if(this.gl.isContextLost())throw console.error("❌ Cannot create shader: WebGL context is lost"),new Error("WebGL context is lost");try{const i=this.gl.createShader(t);if(!i)throw console.error("❌ Failed to create shader object - WebGL context may be invalid"),new Error("Failed to create shader object - WebGL context may be invalid");if(this.gl.shaderSource(i,e),this.gl.compileShader(i),!this.gl.getShaderParameter(i,this.gl.COMPILE_STATUS)){const s=this.gl.getShaderInfoLog(i),o=t===this.gl.VERTEX_SHADER?"vertex":"fragment";throw s?(console.error(`❌ ${o} shader compilation failed:`,s),new Error(`${o} shader compilation failed: ${s}`)):(console.error(`❌ ${o} shader compilation failed: WebGL returned no error info (context may be invalid)`),new Error(`${o} shader compilation failed: WebGL returned no error info (context may be invalid)`))}return i}catch(i){throw console.error("❌ Exception during shader creation:",i),i}}initBuffers(){const t=new Float32Array([-1,-1,1,-1,-1,1,1,1]);this.buffer=this.gl.createBuffer(),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.buffer),this.gl.bufferData(this.gl.ARRAY_BUFFER,t,this.gl.STATIC_DRAW);const e=this.gl.getAttribLocation(this.program,"a_position");this.gl.enableVertexAttribArray(e),this.gl.vertexAttribPointer(e,2,this.gl.FLOAT,!1,0,0)}resize(){const t=Math.min(window.devicePixelRatio||1,2),e=this.canvas.clientWidth,i=this.canvas.clientHeight;(this.canvas.width!==e*t||this.canvas.height!==i*t)&&(this.canvas.width=e*t,this.canvas.height=i*t,this.gl.viewport(0,0,this.canvas.width,this.canvas.height))}showWebGLError(){if(!this.canvas)return;const t=this.canvas.getContext("2d");t&&(t.fillStyle="#000",t.fillRect(0,0,this.canvas.width,this.canvas.height),t.fillStyle="#ff64ff",t.font="16px Orbitron, monospace",t.textAlign="center",t.fillText("WebGL Required",this.canvas.width/2,this.canvas.height/2),t.fillStyle="#888",t.font="12px Orbitron, monospace",t.fillText("Please enable WebGL in your browser",this.canvas.width/2,this.canvas.height/2+25))}updateInteraction(t,e,i){this.mouseX=t,this.mouseY=e,this.mouseIntensity=i*this.roleParams.mouseReactivity*this.reactivity}triggerClick(t,e){this.clickIntensity=Math.min(1,this.clickIntensity+this.roleParams.clickReactivity*this.reactivity)}updateDensity(t){this.densityTarget=t}updateTouch(t,e,i){this.touchX=t,this.touchY=e,this.touchActive=i,this.touchMorph=(t-.5)*2,this.touchChaos=Math.abs(e-.5)*2}updateScroll(t){this.scrollVelocity+=t*.001,this.scrollVelocity=Math.max(-2,Math.min(2,this.scrollVelocity))}updateAudio_DISABLED(){}updateScrollPhysics(){this.scrollPosition+=this.scrollVelocity,this.scrollVelocity*=this.scrollDecay,this.parallaxDepth=Math.sin(this.scrollPosition*.1)*.5,this.gridDensityShift=Math.sin(this.scrollPosition*.05)*.3,this.colorScrollShift=this.scrollPosition*.02%(Math.PI*2)}render(){if(!this.program)return;this.resize(),this.gl.useProgram(this.program),this.densityVariation+=(this.densityTarget-this.densityVariation)*.05,this.clickIntensity*=this.clickDecay,this.updateScrollPhysics();const t=Date.now()-this.startTime,e=(this.variantParams.hue||0)/360,i=this.variantParams.saturation||.8,s=Math.max(.2,Math.min(.8,this.variantParams.intensity||.5)),l=((v,p,m)=>{let b,S,w;if(p===0)b=S=w=m;else{const _=(f,E,d)=>(d<0&&(d+=1),d>1&&(d-=1),d<.16666666666666666?f+(E-f)*6*d:d<.5?E:d<.6666666666666666?f+(E-f)*(.6666666666666666-d)*6:f),g=m<.5?m*(1+p):m+p-m*p,x=2*m-g;b=_(x,g,v+1/3),S=_(x,g,v),w=_(x,g,v-1/3)}return[b,S,w]})(e,i,s);this.gl.uniform2f(this.uniforms.resolution,this.canvas.width,this.canvas.height),this.gl.uniform1f(this.uniforms.time,t),this.gl.uniform2f(this.uniforms.mouse,this.mouseX,this.mouseY),this.gl.uniform1f(this.uniforms.geometryType,this.variantParams.geometryType||0),this.gl.uniform1f(this.uniforms.density,this.variantParams.density||1);const a=(this.variantParams.speed||.5)*.2,h=(this.audioSpeedBoost||0)*.1;this.gl.uniform1f(this.uniforms.speed,a+h),this.gl.uniform3fv(this.uniforms.color,new Float32Array(l)),this.gl.uniform1f(this.uniforms.intensity,(this.variantParams.intensity||.5)*this.roleParams.intensity),this.gl.uniform1f(this.uniforms.roleDensity,this.roleParams.densityMult),this.gl.uniform1f(this.uniforms.roleSpeed,this.roleParams.speedMult),this.gl.uniform1f(this.uniforms.colorShift,this.roleParams.colorShift+(this.variantParams.hue||0)/360),this.gl.uniform1f(this.uniforms.chaosIntensity,this.variantParams.chaos||0),this.gl.uniform1f(this.uniforms.mouseIntensity,this.mouseIntensity),this.gl.uniform1f(this.uniforms.clickIntensity,this.clickIntensity),this.gl.uniform1f(this.uniforms.densityVariation,this.densityVariation),this.gl.uniform1f(this.uniforms.geometryType,this.variantParams.geometryType!==void 0?this.variantParams.geometryType:this.variant||0),this.gl.uniform1f(this.uniforms.chaos,this.variantParams.chaos||0),this.gl.uniform1f(this.uniforms.morph,this.variantParams.morph||0),this.gl.uniform1f(this.uniforms.touchMorph,this.touchMorph),this.gl.uniform1f(this.uniforms.touchChaos,this.touchChaos),this.gl.uniform1f(this.uniforms.scrollParallax,this.parallaxDepth),this.gl.uniform1f(this.uniforms.gridDensityShift,this.gridDensityShift),this.gl.uniform1f(this.uniforms.colorScrollShift,this.colorScrollShift);let c=0,r=0,u=0,n=0,y=0;window.audioEnabled&&window.audioReactive&&(c=window.audioReactive.bass*1.5,r=window.audioReactive.mid*1.2,u=window.audioReactive.high*.8,n=window.audioReactive.energy*.6,y=window.audioReactive.bass*45,Date.now()%1e4<16&&console.log(`✨ Holographic audio reactivity: Density+${c.toFixed(2)} Morph+${r.toFixed(2)} Speed+${u.toFixed(2)} Chaos+${n.toFixed(2)} Color+${y.toFixed(1)}`)),this.gl.uniform1f(this.uniforms.audioDensityBoost,c),this.gl.uniform1f(this.uniforms.audioMorphBoost,r),this.gl.uniform1f(this.uniforms.audioSpeedBoost,u),this.gl.uniform1f(this.uniforms.audioChaosBoost,n),this.gl.uniform1f(this.uniforms.audioColorShift,y),this.gl.uniform1f(this.uniforms.rot4dXY,this.variantParams.rot4dXY||0),this.gl.uniform1f(this.uniforms.rot4dXZ,this.variantParams.rot4dXZ||0),this.gl.uniform1f(this.uniforms.rot4dYZ,this.variantParams.rot4dYZ||0),this.gl.uniform1f(this.uniforms.rot4dXW,this.variantParams.rot4dXW||0),this.gl.uniform1f(this.uniforms.rot4dYW,this.variantParams.rot4dYW||0),this.gl.uniform1f(this.uniforms.rot4dZW,this.variantParams.rot4dZW||0),this.gl.drawArrays(this.gl.TRIANGLE_STRIP,0,4)}reinitializeContext(){var t,e,i,s,o;if(console.log(`🔄 Reinitializing WebGL context for ${(t=this.canvas)==null?void 0:t.id}`),this.program=null,this.buffer=null,this.uniforms=null,this.gl=null,this.gl=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl"),!this.gl)return console.error(`❌ No WebGL context available for ${(e=this.canvas)==null?void 0:e.id} - SmartCanvasPool should have created one`),!1;if(this.gl.isContextLost())return console.error(`❌ WebGL context is lost for ${(i=this.canvas)==null?void 0:i.id}`),!1;try{return this.initShaders(),this.initBuffers(),this.resize(),console.log(`✅ ${(s=this.canvas)==null?void 0:s.id}: Holographic context reinitialized successfully`),!0}catch(l){return console.error(`❌ Failed to reinitialize holographic WebGL resources for ${(o=this.canvas)==null?void 0:o.id}:`,l),!1}}updateParameters(t){this.variantParams&&Object.keys(t).forEach(e=>{const i=this.mapParameterName(e);if(i!==null){let s=t[e];e==="gridDensity"&&(s=.3+(parseFloat(t[e])-5)/95*2.2,console.log(`🔧 Density scaling: gridDensity=${t[e]} → density=${s.toFixed(3)} (normal range)`)),this.variantParams[i]=s,i==="geometryType"&&(this.roleParams=this.generateRoleParams(this.role))}})}mapParameterName(t){return{gridDensity:"density",morphFactor:"morph",rot4dXW:"rot4dXW",rot4dYW:"rot4dYW",rot4dZW:"rot4dZW",hue:"hue",intensity:"intensity",saturation:"saturation",chaos:"chaos",speed:"speed",geometry:"geometryType"}[t]||t}}class P{constructor(){this.visualizers=[],this.currentVariant=0,this.baseVariants=30,this.totalVariants=30,this.isActive=!1,this.useBuiltInReactivity=!window.reactivityManager,this.audioEnabled=!1,this.audioContext=null,this.analyser=null,this.frequencyData=null,this.audioData={bass:0,mid:0,high:0},this.variantNames=["TETRAHEDRON LATTICE","TETRAHEDRON FIELD","TETRAHEDRON MATRIX","TETRAHEDRON RESONANCE","HYPERCUBE LATTICE","HYPERCUBE FIELD","HYPERCUBE MATRIX","HYPERCUBE QUANTUM","SPHERE LATTICE","SPHERE FIELD","SPHERE MATRIX","SPHERE RESONANCE","TORUS LATTICE","TORUS FIELD","TORUS MATRIX","TORUS QUANTUM","KLEIN BOTTLE LATTICE","KLEIN BOTTLE FIELD","KLEIN BOTTLE MATRIX","KLEIN BOTTLE QUANTUM","FRACTAL LATTICE","FRACTAL FIELD","FRACTAL QUANTUM","WAVE LATTICE","WAVE FIELD","WAVE QUANTUM","CRYSTAL LATTICE","CRYSTAL FIELD","CRYSTAL MATRIX","CRYSTAL QUANTUM"],this.initialize()}initialize(){console.log("🎨 Initializing REAL Holographic System for Active Holograms tab..."),this.createVisualizers(),this.setupCenterDistanceReactivity(),this.updateVariantDisplay(),this.startRenderLoop()}createVisualizers(){const t=[{id:"holo-background-canvas",role:"background",reactivity:.5},{id:"holo-shadow-canvas",role:"shadow",reactivity:.7},{id:"holo-content-canvas",role:"content",reactivity:.9},{id:"holo-highlight-canvas",role:"highlight",reactivity:1.1},{id:"holo-accent-canvas",role:"accent",reactivity:1.5}];let e=0;t.forEach(i=>{try{if(!document.getElementById(i.id)){console.error(`❌ Canvas not found: ${i.id}`);return}console.log(`🔍 Creating holographic visualizer for: ${i.id}`);const o=new L(i.id,i.role,i.reactivity,this.currentVariant);o.gl?(this.visualizers.push(o),e++,console.log(`✅ Created REAL holographic layer: ${i.role} (${i.id})`)):console.error(`❌ No WebGL context for: ${i.id}`)}catch(s){console.error(`❌ Failed to create REAL holographic layer ${i.id}:`,s)}}),console.log(`✅ Created ${e}/5 REAL holographic layers`),e===0&&console.error("🚨 NO HOLOGRAPHIC VISUALIZERS CREATED! Check canvas elements and WebGL support.")}setActive(t){if(this.isActive=t,t){const e=document.getElementById("holographicLayers");e&&(e.style.display="block"),!this.audioEnabled&&window.audioEnabled===!0&&this.initAudio(),console.log("🌌 REAL Active Holograms ACTIVATED with audio reactivity")}else{const e=document.getElementById("holographicLayers");e&&(e.style.display="none"),console.log("🌌 REAL Active Holograms DEACTIVATED")}}updateVariantDisplay(){const t=this.variantNames[this.currentVariant];return{variant:this.currentVariant,name:t,geometryType:Math.floor(this.currentVariant/4)}}nextVariant(){this.updateVariant(this.currentVariant+1)}previousVariant(){this.updateVariant(this.currentVariant-1)}randomVariant(){const t=Math.floor(Math.random()*this.totalVariants);this.updateVariant(t)}setVariant(t){this.updateVariant(t)}updateParameter(t,e){this.customParams||(this.customParams={}),this.customParams[t]=e,console.log(`🌌 Updating holographic ${t}: ${e} (${this.visualizers.length} visualizers)`),this.visualizers.forEach((i,s)=>{try{if(i.updateParameters){const o={};o[t]=e,i.updateParameters(o),console.log(`✅ Updated holographic layer ${s} (${i.role}) with ${t}=${e}`)}else console.warn(`⚠️ Holographic layer ${s} missing updateParameters method, using fallback`),i.variantParams&&(i.variantParams[t]=e,t==="geometryType"&&(i.roleParams=i.generateRoleParams(i.role)),i.render&&i.render())}catch(o){console.error(`❌ Failed to update holographic layer ${s}:`,o)}}),console.log(`🔄 Holographic parameter update complete: ${t}=${e}`)}updateVariant(t){t<0&&(t=this.totalVariants-1),t>=this.totalVariants&&(t=0),this.currentVariant=t,this.visualizers.forEach(e=>{e.variant=this.currentVariant,e.variantParams=e.generateVariantParams(this.currentVariant),e.roleParams=e.generateRoleParams(e.role),this.customParams&&Object.keys(this.customParams).forEach(i=>{e.variantParams[i]=this.customParams[i]})}),this.updateVariantDisplay(),console.log(`🔄 REAL Holograms switched to variant ${this.currentVariant+1}: ${this.variantNames[this.currentVariant]}`)}getCurrentVariantInfo(){return{variant:this.currentVariant,name:this.variantNames[this.currentVariant],geometryType:Math.floor(this.currentVariant/4)}}getParameters(){var e,i,s,o,l,a,h,c,r,u;const t={geometry:Math.floor(this.currentVariant/4),gridDensity:parseFloat(((e=document.getElementById("gridDensity"))==null?void 0:e.value)||15),morphFactor:parseFloat(((i=document.getElementById("morphFactor"))==null?void 0:i.value)||1),chaos:parseFloat(((s=document.getElementById("chaos"))==null?void 0:s.value)||.2),speed:parseFloat(((o=document.getElementById("speed"))==null?void 0:o.value)||1),hue:parseFloat(((l=document.getElementById("hue"))==null?void 0:l.value)||320),intensity:parseFloat(((a=document.getElementById("intensity"))==null?void 0:a.value)||.6),saturation:parseFloat(((h=document.getElementById("saturation"))==null?void 0:h.value)||.8),rot4dXW:parseFloat(((c=document.getElementById("rot4dXW"))==null?void 0:c.value)||0),rot4dYW:parseFloat(((r=document.getElementById("rot4dYW"))==null?void 0:r.value)||0),rot4dZW:parseFloat(((u=document.getElementById("rot4dZW"))==null?void 0:u.value)||0),variant:this.currentVariant};return this.customParams&&Object.assign(t,this.customParams),console.log("🌌 Holographic system getParameters:",t),t}async initAudio(){try{this.audioContext=new(window.AudioContext||window.webkitAudioContext),this.audioContext.state==="suspended"&&await this.audioContext.resume(),this.analyser=this.audioContext.createAnalyser(),this.analyser.fftSize=256,this.frequencyData=new Uint8Array(this.analyser.frequencyBinCount);const t={audio:{echoCancellation:!1,noiseSuppression:!1,autoGainControl:!1,sampleRate:44100}},e=await navigator.mediaDevices.getUserMedia(t);this.audioContext.createMediaStreamSource(e).connect(this.analyser),this.audioEnabled=!0,console.log("🎵 REAL Holograms audio reactivity enabled")}catch(t){console.error("REAL Holograms audio initialization failed:",t)}}disableAudio(){this.audioEnabled&&(this.audioEnabled=!1,this.audioContext&&(this.audioContext.close(),this.audioContext=null),this.analyser=null,this.frequencyData=null,this.audioData={bass:0,mid:0,high:0},console.log("🎵 REAL Holograms audio reactivity disabled"))}updateAudio(){if(!this.audioEnabled||!this.analyser||!this.isActive||window.audioEnabled===!1)return;this.analyser.getByteFrequencyData(this.frequencyData);const t=Math.floor(this.frequencyData.length*.1),e=Math.floor(this.frequencyData.length*.4);let i=0,s=0,o=0;for(let a=0;a<t;a++)i+=this.frequencyData[a];i/=t*255;for(let a=t;a<e;a++)s+=this.frequencyData[a];s/=(e-t)*255;for(let a=e;a<this.frequencyData.length;a++)o+=this.frequencyData[a];o/=(this.frequencyData.length-e)*255;const l={bass:this.smoothAudioValue(i,"bass"),mid:this.smoothAudioValue(s,"mid"),high:this.smoothAudioValue(o,"high"),energy:(i+s+o)/3,rhythm:this.detectRhythm(i),melody:this.detectMelody(s,o)};this.audioData=l,window.audioReactivitySettings&&this.applyAudioReactivityGrid(l),this.visualizers.forEach(a=>{a.updateAudio(this.audioData)})}smoothAudioValue(t,e){this.audioSmoothing||(this.audioSmoothing={bass:0,mid:0,high:0});const i=.4;return this.audioSmoothing[e]=this.audioSmoothing[e]*i+t*(1-i),this.audioSmoothing[e]>.05?this.audioSmoothing[e]:0}detectRhythm(t){this.previousBass||(this.previousBass=0);const e=t>this.previousBass+.2;return this.previousBass=t,e?1:0}detectMelody(t,e){const i=(t+e)/2;return i>.3?i:0}applyAudioReactivityGrid(t){const e=window.audioReactivitySettings;if(!e||e.activeVisualModes.size===0)return;const i=e.sensitivity[e.activeSensitivity];e.activeVisualModes.forEach(s=>{const[o,l]=s.split("-"),a=e.visualModes[l];if(!a)return;const h=t.energy*i,c=t.bass*i,r=t.rhythm*i;a.forEach(u=>{let n=0;switch(u){case"hue":this.audioHueBase||(this.audioHueBase=320),this.audioHueBase+=h*5,n=this.audioHueBase%360;break;case"saturation":n=Math.min(1,.6+r*.4);break;case"intensity":n=Math.min(1,.4+h*.6);break;case"morphFactor":n=Math.min(2,1+c*1);break;case"gridDensity":n=Math.min(100,15+r*50);break;case"chaos":n=Math.min(1,h*.8);break;case"speed":n=Math.min(3,1+h*2);break;case"rot4dXW":this.audioRotationXW||(this.audioRotationXW=0),this.audioRotationXW+=c*.1,n=this.audioRotationXW%(Math.PI*2);break;case"rot4dYW":this.audioRotationYW||(this.audioRotationYW=0),this.audioRotationYW+=t.mid*i*.08,n=this.audioRotationYW%(Math.PI*2);break;case"rot4dZW":this.audioRotationZW||(this.audioRotationZW=0),this.audioRotationZW+=t.high*i*.06,n=this.audioRotationZW%(Math.PI*2);break}window.updateParameter&&n!==void 0&&window.updateParameter(u,n.toFixed(2))})})}setupCenterDistanceReactivity(){if(console.log("✨ Holographic system: AUDIO-ONLY mode (no mouse/touch reactivity)"),!this.useBuiltInReactivity){console.log("✨ Holographic built-in reactivity DISABLED - ReactivityManager active");return}console.log("🎵 Holographic system will respond to audio input only")}updateHolographicShimmer(t,e){const i=(t-.5)*Math.PI,s=(e-.5)*Math.PI,o=320,a=Math.sin(i*2)*Math.cos(s*2)*120,h=(o+a+360)%360,c=.4+.5*Math.abs(Math.sin(i)*Math.cos(s)),r=.7+.3*Math.abs(Math.cos(i*1.5)*Math.sin(s*1.5)),u=1+.15*Math.sin(i*.8)*Math.cos(s*.8);window.updateParameter&&(window.updateParameter("hue",Math.round(h)),window.updateParameter("intensity",c.toFixed(2)),window.updateParameter("saturation",r.toFixed(2)),window.updateParameter("morphFactor",u.toFixed(2))),console.log(`✨ Holographic shimmer: angle=(${i.toFixed(2)}, ${s.toFixed(2)}) → Hue=${Math.round(h)}, Intensity=${c.toFixed(2)}`)}triggerHolographicColorBurst(t,e){const o=Math.sqrt((t-.5)**2+(e-.5)**2);this.colorBurstIntensity=1,this.burstHueShift=180,this.burstIntensityBoost=.7,this.burstSaturationSpike=.8,this.burstChaosEffect=.6,this.burstSpeedBoost=1.8,console.log(`🌈💥 HOLOGRAPHIC COLOR BURST: position=(${t.toFixed(2)}, ${e.toFixed(2)}), distance=${o.toFixed(3)}`)}startHolographicColorBurstLoop(){const t=()=>{if(this.colorBurstIntensity>.01){const e=this.colorBurstIntensity;if(this.burstHueShift>1){const o=(320+this.burstHueShift*Math.sin(e*Math.PI*2))%360;window.updateParameter&&window.updateParameter("hue",Math.round(o)),this.burstHueShift*=.93}if(this.burstIntensityBoost>.01){const s=Math.min(1,.5+this.burstIntensityBoost*e);window.updateParameter&&window.updateParameter("intensity",s.toFixed(2)),this.burstIntensityBoost*=.92}if(this.burstSaturationSpike>.01){const s=Math.min(1,.8+this.burstSaturationSpike*e);window.updateParameter&&window.updateParameter("saturation",s.toFixed(2)),this.burstSaturationSpike*=.91}if(this.burstChaosEffect>.01){const s=.2+this.burstChaosEffect*e;window.updateParameter&&window.updateParameter("chaos",s.toFixed(2)),this.burstChaosEffect*=.9}if(this.burstSpeedBoost>.01){const s=1+this.burstSpeedBoost*e;window.updateParameter&&window.updateParameter("speed",s.toFixed(2)),this.burstSpeedBoost*=.89}this.colorBurstIntensity*=.94}this.isActive&&requestAnimationFrame(t)};t()}startRenderLoop(){const t=()=>{this.isActive&&(this.updateAudio(),this.visualizers.forEach(e=>{e.render()})),requestAnimationFrame(t)};t(),console.log("🎬 REAL Holographic render loop started")}getVariantName(t=this.currentVariant){return this.variantNames[t]||"UNKNOWN"}destroy(){this.visualizers.forEach(t=>{t.destroy&&t.destroy()}),this.visualizers=[],this.audioContext&&this.audioContext.close(),console.log("🧹 REAL Holographic System destroyed")}}export{P as RealHolographicSystem};

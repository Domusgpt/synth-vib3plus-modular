class p{constructor(){this.gravity4D=[0,0,0,-2.5],this.airResistance=.02,this.timeStep=1/60,this.bodies=[],this.enabled=!1,this.paused=!1,this.magneticField=[0,0,1,0],this.fluidFlow=[.5,0,0,0],console.log("🔮 Polychora4DPhysics initialized")}createRigidBody(t,i=[0,0,0,0],e={}){const s={id:this.generateBodyId(),polytopeType:t,position:[...i],velocity:[0,0,0,0],acceleration:[0,0,0,0],rotation:[0,0,0,0,0,0],angularVelocity:[0,0,0,0,0,0],angularAcceleration:[0,0,0,0,0,0],mass:e.mass||1,inertia4D:this.calculate4DInertia(t,e.mass||1),elasticity:e.elasticity||.8,friction:e.friction||.1,density:e.density||1,viscosity:e.viscosity||0,brownianMotion:e.brownianMotion||.1,magneticSusceptibility:e.magnetic||0,forces:[0,0,0,0],torques:[0,0,0,0,0,0],boundingRadius:this.calculateBoundingRadius(t),collisionGroup:e.group||0,targetPosition:null,flockingBehavior:e.flocking||!1,territorialRadius:e.territorial||2,active:!0,sleeping:!1,sleepThreshold:.01,physicsFeedback:{impactIntensity:0,velocityIntensity:0,accelerationGlow:0}};return this.bodies.push(s),console.log(`🔮 Created 4D rigid body for polytope ${t}, ID: ${s.id}`),s}step(t=this.timeStep){!this.enabled||this.paused||(this.bodies.forEach(i=>{!i.active||i.sleeping||(this.clearForces(i),this.applyGravity(i),this.applyDrag(i),this.applyMagneticForces(i),this.applyFluidForces(i),this.applyBrownianMotion(i),this.applyBehavioralForces(i))}),this.detectCollisions(),this.bodies.forEach(i=>{!i.active||i.sleeping||(this.integrate(i,t),this.updateVisualFeedback(i),this.checkSleeping(i))}),this.updateSpatialHash())}applyGravity(t){const i=[this.gravity4D[0]*t.mass,this.gravity4D[1]*t.mass,this.gravity4D[2]*t.mass,this.gravity4D[3]*t.mass];this.addForce(t,i)}applyDrag(t){const i=this.magnitude4D(t.velocity);if(i<.001)return;const e=this.airResistance*i*i,s=this.normalize4D(t.velocity),o=[-s[0]*e,-s[1]*e,-s[2]*e,-s[3]*e];this.addForce(t,o)}applyMagneticForces(t){if(t.magneticSusceptibility===0)return;this.cross4D(t.velocity,this.magneticField).forEach((e,s)=>{t.forces[s]+=e*t.magneticSusceptibility})}applyFluidForces(t){const i=[this.fluidFlow[0]-t.velocity[0],this.fluidFlow[1]-t.velocity[1],this.fluidFlow[2]-t.velocity[2],this.fluidFlow[3]-t.velocity[3]],e=this.magnitude4D(i);if(e<.001)return;const s=this.multiply4D(i,t.viscosity*e);this.addForce(t,s)}applyBrownianMotion(t){if(t.brownianMotion===0)return;const i=[(Math.random()-.5)*t.brownianMotion,(Math.random()-.5)*t.brownianMotion,(Math.random()-.5)*t.brownianMotion,(Math.random()-.5)*t.brownianMotion];this.addForce(t,i)}applyBehavioralForces(t){t.flockingBehavior&&this.applyFlockingForce(t),t.targetPosition&&this.applySeekingForce(t),this.applyTerritorialForce(t)}applyFlockingForce(t){let i=[0,0,0,0],e=[0,0,0,0],s=[0,0,0,0],o=0;const a=t.territorialRadius;if(this.bodies.forEach(n=>{if(n===t||!n.active)return;const r=this.distance4D(t.position,n.position);if(!(r>a)){if(o++,r<a*.3){const h=this.subtract4D(t.position,n.position),l=this.multiply4D(this.normalize4D(h),1/(r+.1));i=this.add4D(i,l)}e=this.add4D(e,n.velocity),s=this.add4D(s,n.position)}}),o>0){this.magnitude4D(i)>0&&(i=this.multiply4D(this.normalize4D(i),.5),this.addForce(t,i)),e=this.multiply4D(e,1/o);const n=this.multiply4D(this.subtract4D(e,t.velocity),.3);this.addForce(t,n),s=this.multiply4D(s,1/o);const r=this.multiply4D(this.subtract4D(s,t.position),.2);this.addForce(t,r)}}applySeekingForce(t){const i=this.subtract4D(t.targetPosition,t.position),e=this.magnitude4D(i);if(e<.1){t.targetPosition=null;return}const s=this.multiply4D(this.normalize4D(i),Math.min(e*.5,2));this.addForce(t,s)}applyTerritorialForce(t){this.bodies.forEach(i=>{if(i===t||!i.active)return;const e=this.distance4D(t.position,i.position),s=t.territorialRadius*.5;if(e<s){const o=this.subtract4D(t.position,i.position),a=this.multiply4D(this.normalize4D(o),(s-e)*2);this.addForce(t,a)}})}detectCollisions(){for(let t=0;t<this.bodies.length;t++)for(let i=t+1;i<this.bodies.length;i++){const e=this.bodies[t],s=this.bodies[i];if(!e.active||!s.active)continue;const o=this.distance4D(e.position,s.position),a=e.boundingRadius+s.boundingRadius;o<a&&this.resolveCollision(e,s,o)}}resolveCollision(t,i,e){const s=this.normalize4D(this.subtract4D(i.position,t.position)),o=t.boundingRadius+i.boundingRadius-e,a=this.multiply4D(s,o*.5);t.position=this.subtract4D(t.position,a),i.position=this.add4D(i.position,a);const n=this.subtract4D(t.velocity,i.velocity),r=this.dot4D(n,s);if(r>0)return;const l=-(1+Math.min(t.elasticity,i.elasticity))*r/(1/t.mass+1/i.mass),c=this.multiply4D(s,l);t.velocity=this.add4D(t.velocity,this.multiply4D(c,1/t.mass)),i.velocity=this.subtract4D(i.velocity,this.multiply4D(c,1/i.mass));const u=Math.abs(l)*.1;t.physicsFeedback.impactIntensity=Math.max(t.physicsFeedback.impactIntensity,u),i.physicsFeedback.impactIntensity=Math.max(i.physicsFeedback.impactIntensity,u),console.log(`🔮 4D collision resolved between bodies ${t.id} and ${i.id}, impulse: ${l.toFixed(3)}`)}integrate(t,i){t.acceleration=this.multiply4D(t.forces,1/t.mass),t.velocity=this.add4D(t.velocity,this.multiply4D(t.acceleration,i)),t.position=this.add4D(t.position,this.multiply4D(t.velocity,i));for(let e=0;e<6;e++)t.angularAcceleration[e]=t.torques[e]/t.inertia4D[e],t.angularVelocity[e]+=t.angularAcceleration[e]*i,t.rotation[e]+=t.angularVelocity[e]*i,t.rotation[e]=t.rotation[e]%(Math.PI*2)}updateVisualFeedback(t){const i=this.magnitude4D(t.velocity);t.physicsFeedback.velocityIntensity=Math.min(i*.5,2);const e=this.magnitude4D(t.acceleration);t.physicsFeedback.accelerationGlow=Math.min(e*.3,1),t.physicsFeedback.impactIntensity*=.95}add4D(t,i){return[t[0]+i[0],t[1]+i[1],t[2]+i[2],t[3]+i[3]]}subtract4D(t,i){return[t[0]-i[0],t[1]-i[1],t[2]-i[2],t[3]-i[3]]}multiply4D(t,i){return[t[0]*i,t[1]*i,t[2]*i,t[3]*i]}dot4D(t,i){return t[0]*i[0]+t[1]*i[1]+t[2]*i[2]+t[3]*i[3]}magnitude4D(t){return Math.sqrt(this.dot4D(t,t))}normalize4D(t){const i=this.magnitude4D(t);return i>.001?this.multiply4D(t,1/i):[0,0,0,0]}distance4D(t,i){return this.magnitude4D(this.subtract4D(t,i))}cross4D(t,i){return[t[1]*i[2]-t[2]*i[1],t[2]*i[0]-t[0]*i[2],t[0]*i[1]-t[1]*i[0],t[3]]}addForce(t,i){t.forces=this.add4D(t.forces,i)}clearForces(t){t.forces=[0,0,0,0],t.torques=[0,0,0,0,0,0]}generateBodyId(){return`body_${Date.now()}_${Math.random().toString(36).substr(2,9)}`}calculate4DInertia(t,i){const e=i*.4;return[e,e,e,e,e,e]}calculateBoundingRadius(t){return[1.2,1.5,1,1.3,.8,2][t]||1}checkSleeping(t){const i=this.magnitude4D(t.velocity)+this.magnitude4D(t.angularVelocity);i<t.sleepThreshold?t.sleeping=!0:i>t.sleepThreshold*2&&(t.sleeping=!1)}updateSpatialHash(){}enable(){this.enabled=!0,console.log("🔮 Polychora4DPhysics enabled")}disable(){this.enabled=!1,console.log("🔮 Polychora4DPhysics disabled")}pause(){this.paused=!0}resume(){this.paused=!1}setGravity(t){this.gravity4D=[...t]}setMagneticField(t){this.magneticField=[...t]}setFluidFlow(t){this.fluidFlow=[...t]}getAllBodies(){return this.bodies}getBodyById(t){return this.bodies.find(i=>i.id===t)}removeBody(t){this.bodies=this.bodies.filter(i=>i.id!==t)}clearAllBodies(){this.bodies=[]}getPhysicsFeedback(){return this.bodies.map(t=>({id:t.id,position:t.position,rotation:t.rotation,feedback:t.physicsFeedback,polytopeType:t.polytopeType}))}}class f{constructor(t,i,e){this.canvasId=t,this.role=i,this.config=e,this.canvas=null,this.gl=null,this.program=null,this.time=0,this.vertexBuffer=null}initialize(){return this.canvas=document.getElementById(this.canvasId),this.canvas?(this.gl=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl"),this.gl?(console.log(`🎮 WebGL context created for ${this.canvasId}: ${this.gl instanceof WebGL2RenderingContext?"WebGL2":"WebGL1"}`),this.createPolychoraShader()?(this.setupCanvasSize(),this.gl.enable(this.gl.BLEND),this.gl.blendFunc(this.gl.SRC_ALPHA,this.gl.ONE_MINUS_SRC_ALPHA),!0):(console.error(`❌ Failed to create shader for ${this.canvasId}`),!1)):(console.error(`❌ WebGL not supported for ${this.canvasId}`),!1)):(console.error(`❌ Canvas ${this.canvasId} not found`),!1)}setupCanvasSize(){const t=document.getElementById("polychoraLayers"),i=t?t.style.display:null;t&&i==="none"&&(t.style.display="block");const e=this.canvas.parentElement.getBoundingClientRect();t&&i==="none"&&(t.style.display=i),this.canvas.width=e.width>0?e.width:window.innerWidth-300,this.canvas.height=e.height>0?e.height:window.innerHeight-50,this.gl.viewport(0,0,this.canvas.width,this.canvas.height),console.log(`🎮 Canvas ${this.canvasId} WebGL viewport: ${this.canvas.width}x${this.canvas.height}`)}createPolychoraShader(){const t=`
            attribute vec2 a_position;
            void main() {
                gl_Position = vec4(a_position, 0.0, 1.0);
            }
        `,i=`
            precision highp float;
            uniform float u_time;
            uniform vec2 u_resolution;
            uniform float u_polytope;
            
            // COMPLETE 6D 4D rotation uniforms
            uniform float u_rot4dXW;
            uniform float u_rot4dYW;
            uniform float u_rot4dZW;
            uniform float u_rot4dXY;
            uniform float u_rot4dXZ;
            uniform float u_rot4dYZ;
            
            uniform float u_dimension;
            uniform float u_hue;
            uniform vec3 u_layerColor;
            uniform float u_layerScale;
            uniform float u_layerOpacity;
            uniform float u_lineWidth;
            uniform float u_blur;
            
            // ADVANCED: Glass effect uniforms
            uniform float u_refractionIndex;
            uniform float u_chromaticAberration;
            uniform float u_noiseAmplitude;
            uniform float u_flowDirection;
            uniform float u_faceTransparency;
            uniform float u_edgeThickness;
            uniform float u_projectionDistance;
            
            // COMPLETE 4D rotation matrices - All 6 possible rotations
            mat4 rotateXW(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    c, 0, 0, -s,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    s, 0, 0, c
                );
            }
            
            mat4 rotateYW(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    1, 0, 0, 0,
                    0, c, 0, -s,
                    0, 0, 1, 0,
                    0, s, 0, c
                );
            }
            
            mat4 rotateZW(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, c, -s,
                    0, 0, s, c
                );
            }
            
            // NEW: Missing 4D rotations for complete 6D rotational freedom
            mat4 rotateXY(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    c, -s, 0, 0,
                    s, c, 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1
                );
            }
            
            mat4 rotateXZ(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    c, 0, -s, 0,
                    0, 1, 0, 0,
                    s, 0, c, 0,
                    0, 0, 0, 1
                );
            }
            
            mat4 rotateYZ(float angle) {
                float c = cos(angle);
                float s = sin(angle);
                return mat4(
                    1, 0, 0, 0,
                    0, c, -s, 0,
                    0, s, c, 0,
                    0, 0, 0, 1
                );
            }
            
            // 4D polytope distance functions
            float polytope4D(vec4 p, float type) {
                if (type < 0.5) {
                    // 5-Cell (4-Simplex)
                    vec4 q = abs(p) - 0.8;
                    float d1 = length(max(q, 0.0)) + min(max(max(max(q.x, q.y), q.z), q.w), 0.0);
                    vec4 r = p - vec4(0.5, 0.5, 0.5, 0.5);
                    float d2 = length(r) - 0.3;
                    return min(d1, d2);
                } else if (type < 1.5) {
                    // Tesseract (8-Cell)
                    vec4 q = abs(p) - 1.0;
                    float outside = length(max(q, 0.0));
                    float inside = max(max(max(q.x, q.y), q.z), q.w);
                    return outside + min(inside, 0.0);
                } else if (type < 2.5) {
                    // 16-Cell (4-Orthoplex)
                    return abs(p.x) + abs(p.y) + abs(p.z) + abs(p.w) - 1.5;
                } else if (type < 3.5) {
                    // 24-Cell
                    vec4 q = abs(p);
                    float d = max(max(q.x + q.y, q.z + q.w), max(q.x + q.z, q.y + q.w)) - 1.2;
                    return d;
                } else if (type < 4.5) {
                    // 600-Cell
                    float phi = (1.0 + sqrt(5.0)) / 2.0;
                    vec4 q = abs(p);
                    float d = length(q) - 1.0;
                    float r = max(max(q.x, q.y/phi), max(q.z*phi, q.w)) - 0.8;
                    return min(d, r);
                } else {
                    // 120-Cell
                    vec4 q = abs(p);
                    float d = max(max(max(q.x, q.y), max(q.z, q.w)), length(q.xy) + length(q.zw)) - 1.1;
                    return d;
                }
            }
            
            // Perlin noise function for surface effects
            float noise(vec4 p) {
                return fract(sin(dot(p, vec4(127.1, 311.7, 269.5, 183.3))) * 43758.5);
            }
            
            // Advanced 4D rotation application - Complete 6D freedom
            vec4 apply6DRotation(vec4 pos) {
                // Apply all 6 possible 4D rotations in mathematically correct order
                pos = rotateXY(u_rot4dXY + u_time * 0.08) * pos;
                pos = rotateXZ(u_rot4dXZ + u_time * 0.09) * pos;
                pos = rotateYZ(u_rot4dYZ + u_time * 0.07) * pos;
                pos = rotateXW(u_rot4dXW + u_time * 0.10) * pos;
                pos = rotateYW(u_rot4dYW + u_time * 0.11) * pos;
                pos = rotateZW(u_rot4dZW + u_time * 0.12) * pos;
                return pos;
            }
            
            // Cinema-quality glass effects
            vec3 calculateGlassEffects(vec2 uv, float dist, vec3 baseColor) {
                vec3 color = baseColor;
                
                // Chromatic aberration effect
                if (u_chromaticAberration > 0.0) {
                    vec2 offset = normalize(uv) * u_chromaticAberration * 0.01;
                    color.r *= 1.0 + sin(dist * 10.0 + u_time) * u_chromaticAberration;
                    color.g *= 1.0 + sin(dist * 10.0 + u_time + 2.09) * u_chromaticAberration;
                    color.b *= 1.0 + sin(dist * 10.0 + u_time + 4.18) * u_chromaticAberration;
                }
                
                // Refraction distortion
                if (u_refractionIndex > 1.0) {
                    vec2 refract_uv = uv * (1.0 + (u_refractionIndex - 1.0) * 0.1 * sin(dist * 20.0));
                    float refraction_intensity = (u_refractionIndex - 1.0) * 0.3;
                    color = mix(color, color * 1.2, refraction_intensity);
                }
                
                return color;
            }
            
            void main() {
                vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
                uv *= u_layerScale;
                
                // Create 4D point with enhanced projection distance
                vec4 pos = vec4(uv, 
                    sin(u_time * 0.3) * 0.5, 
                    cos(u_time * 0.2) * 0.5 * u_projectionDistance * 0.1
                );
                
                // Apply complete 6D 4D rotation
                pos = apply6DRotation(pos);
                
                // Get polytope distance
                float dist = polytope4D(pos, u_polytope);
                
                // Enhanced glassmorphic line rendering
                float edgeCore = u_edgeThickness * 0.01;
                float faceAlpha = u_faceTransparency;
                
                // Multi-layer line effect for cinema quality
                float lineCore = smoothstep(0.0, edgeCore, abs(dist));
                float lineOutline = smoothstep(0.0, edgeCore * 1.5, abs(dist + 0.05));
                float lineFine = smoothstep(0.0, edgeCore * 0.5, abs(dist));
                
                // Combine multiple line effects
                float alpha = (1.0 - lineCore) * 0.6 + (1.0 - lineOutline) * 0.3 + (1.0 - lineFine) * 0.1;
                alpha *= u_layerOpacity;
                
                // Add face transparency effect
                if (abs(dist) > edgeCore * 2.0) {
                    alpha *= faceAlpha;
                }
                
                // Apply procedural surface noise
                if (u_noiseAmplitude > 0.0) {
                    float noise_val = noise(pos * 10.0 + u_time * 0.1);
                    alpha *= 1.0 + (noise_val - 0.5) * u_noiseAmplitude;
                }
                
                // Apply blur with flow direction
                vec2 flow = vec2(cos(u_flowDirection * 3.14159 / 180.0), sin(u_flowDirection * 3.14159 / 180.0));
                float blur_dist = length(uv - flow * u_time * 0.1);
                alpha *= exp(-blur_dist * u_blur * 0.5);
                
                // Base color from layer configuration and hue
                vec3 color = u_layerColor;
                color = mix(color, vec3(
                    sin(u_hue/360.0*6.28), 
                    cos(u_hue/360.0*6.28), 
                    0.8
                ), 0.4);
                
                // Apply cinema-quality glass effects
                color = calculateGlassEffects(uv, dist, color);
                
                // Add subtle iridescence based on viewing angle
                float iridescence = sin(length(uv) * 10.0 + u_time) * 0.1;
                color += iridescence * vec3(0.3, 0.5, 0.7);
                
                gl_FragColor = vec4(color, alpha);
            }
        `;return this.program=this.createShaderProgram(t,i),this.program!==null}createShaderProgram(t,i){const e=this.compileShader(this.gl.VERTEX_SHADER,t),s=this.compileShader(this.gl.FRAGMENT_SHADER,i);if(!e||!s)return null;const o=this.gl.createProgram();if(this.gl.attachShader(o,e),this.gl.attachShader(o,s),this.gl.linkProgram(o),!this.gl.getProgramParameter(o,this.gl.LINK_STATUS))return console.error("Shader program link error:",this.gl.getProgramInfoLog(o)),null;const a=new Float32Array([-1,-1,1,-1,-1,1,-1,1,1,-1,1,1]);return this.vertexBuffer=this.gl.createBuffer(),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.vertexBuffer),this.gl.bufferData(this.gl.ARRAY_BUFFER,a,this.gl.STATIC_DRAW),o}compileShader(t,i){const e=this.gl.createShader(t);return this.gl.shaderSource(e,i),this.gl.compileShader(e),this.gl.getShaderParameter(e,this.gl.COMPILE_STATUS)?e:(console.error("Shader compile error:",this.gl.getShaderInfoLog(e)),null)}render(t={}){if(!this.gl||!this.program||!this.vertexBuffer)return;this.time+=.016,this.gl.useProgram(this.program),this.gl.enable(this.gl.BLEND),this.gl.blendFunc(this.gl.SRC_ALPHA,this.gl.ONE_MINUS_SRC_ALPHA),this.gl.clearColor(0,0,0,0),this.gl.clear(this.gl.COLOR_BUFFER_BIT);let i=t.rot4dXW||0,e=t.rot4dYW||0,s=t.rot4dZW||0,o=t.dimension||3.8,a=t.hue||280;window.audioEnabled&&window.audioReactive&&(i+=window.audioReactive.bass*3,e+=window.audioReactive.mid*2.5,s+=window.audioReactive.high*2,o+=window.audioReactive.energy*.5,a+=window.audioReactive.bass*60);const n={u_time:this.time,u_resolution:[this.canvas.width,this.canvas.height],u_polytope:t.polytope!==void 0?t.polytope:0,u_rot4dXW:i,u_rot4dYW:e,u_rot4dZW:s,u_rot4dXY:t.rot4dXY||0,u_rot4dXZ:t.rot4dXZ||0,u_rot4dYZ:t.rot4dYZ||0,u_dimension:Math.min(4,o),u_hue:a%360,u_layerColor:this.config.color,u_layerScale:this.config.scale*(t.layerScale||1),u_layerOpacity:this.config.opacity*(t.translucency||1),u_lineWidth:this.config.lineWidth*(t.lineThickness||1),u_blur:this.config.blur*(t.glassBlur||1),u_refractionIndex:t.refractionIndex||1.5,u_chromaticAberration:t.chromaticAberration||.1,u_noiseAmplitude:t.noiseAmplitude||.3,u_flowDirection:t.flowDirection||180,u_faceTransparency:t.faceTransparency||.7,u_edgeThickness:t.edgeThickness||2,u_projectionDistance:t.projectionDistance||5};Object.entries(n).forEach(([h,l])=>{const c=this.gl.getUniformLocation(this.program,h);if(c!==null)try{Array.isArray(l)?l.length===2?this.gl.uniform2fv(c,new Float32Array(l)):l.length===3&&this.gl.uniform3fv(c,new Float32Array(l)):this.gl.uniform1f(c,l)}catch(u){console.warn(`Failed to set uniform ${h}:`,u)}});const r=this.gl.getAttribLocation(this.program,"a_position");r!==-1&&(this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.vertexBuffer),this.gl.enableVertexAttribArray(r),this.gl.vertexAttribPointer(r,2,this.gl.FLOAT,!1,0,0),this.gl.drawArrays(this.gl.TRIANGLES,0,6))}update4DMouse(t,i,e){this.mouseState={x:t,y:i,intensity:e,time:Date.now()},console.log(`🔮 ${this.canvasId}: 4D mouse update ${t.toFixed(2)}, ${i.toFixed(2)}, intensity: ${e.toFixed(2)}`)}trigger4DClick(t){this.clickState={intensity:t,time:Date.now()},console.log(`🔮 ${this.canvasId}: 4D click intensity: ${t.toFixed(2)}`)}updateCrossSection(t){var i;this.crossSectionState={velocity:t,position:(((i=this.crossSectionState)==null?void 0:i.position)||0)+t*.01,time:Date.now()},console.log(`🔮 ${this.canvasId}: Cross-section velocity: ${t}, position: ${this.crossSectionState.position.toFixed(3)}`)}updateParameters(t){this.cachedParameters={...t},console.log(`🔮 ${this.canvasId}: Parameters updated`)}}class g{constructor(){this.canvasContainer=null,this.visualizers=[],this.isActive=!1,this.animationId=null,this.physics=new p,this.physicsEnabled=!1,this.physicsBodies=[],this.polytopes=[{name:"5-Cell",description:"4-Simplex with 5 tetrahedral cells"},{name:"Tesseract",description:"8-Cell hypercube with 8 cubic cells"},{name:"16-Cell",description:"4-Orthoplex with 16 tetrahedral cells"},{name:"24-Cell",description:"Unique 4D polytope with 24 octahedral cells"},{name:"600-Cell",description:"Icosahedral symmetry with 600 tetrahedral cells"},{name:"120-Cell",description:"Largest regular 4D polytope with 120 dodecahedral cells"}],this.parameters={polytope:0,lineThickness:2.5,coreSize:1.2,outlineWidth:1.8,glassBlur:3,colorMagnetism:.7,layerScale:1,translucency:.8,rot4dXW:0,rot4dYW:0,rot4dZW:0,rot4dXY:0,rot4dXZ:0,rot4dYZ:0,dimension:3.8,speed:1.2,hue:280,refractionIndex:1.5,chromaticAberration:.1,noiseAmplitude:.3,flowDirection:180,faceTransparency:.7,edgeThickness:2,projectionDistance:5,physicsEnabled:!1,gravity4D:-2.5,mass:1,elasticity:.8,friction:.1,brownianMotion:.1,flocking:!1,territorial:2,magneticField:0,fluidFlow:.5},this.layerConfigs={background:{scale:1.5,opacity:.25,lineWidth:3,color:[.6,.3,.9],blur:4},shadow:{scale:1.2,opacity:.4,lineWidth:2.5,color:[.3,.3,.6],blur:2},content:{scale:1,opacity:.85,lineWidth:2,color:[0,.8,1],blur:.5},highlight:{scale:.8,opacity:.7,lineWidth:1.5,color:[1,.4,.8],blur:1.5},accent:{scale:.6,opacity:.4,lineWidth:1,color:[1,1,.6],blur:3}}}initialize(){if(console.log("🔮 Initializing Polychora System"),this.canvasContainer=document.getElementById("polychoraLayers"),!this.canvasContainer)return console.error("❌ Polychora canvas container not found"),!1;this.setupCanvasElements();const t=["background","shadow","content","highlight","accent"];let i=0;return t.forEach(e=>{const s=`polychora-${e}-canvas`;if(!document.getElementById(s)){console.error(`❌ Canvas ${s} not found in DOM`);return}try{const a=new f(s,e,this.layerConfigs[e]);a.initialize()?(this.visualizers.push(a),i++,console.log(`✅ Polychora ${e} layer initialized`)):console.error(`❌ Failed to initialize Polychora ${e} layer`)}catch(a){console.error(`❌ Error creating Polychora ${e} visualizer:`,a)}}),i===0?(console.error("❌ No Polychora visualizers initialized successfully"),!1):(console.log(`✅ Polychora System initialized with ${i}/${t.length} layers`),!0)}setupCanvasElements(){["background","shadow","content","highlight","accent"].forEach(i=>{const e=`polychora-${i}-canvas`,s=document.getElementById(e);if(s){const o=this.canvasContainer.style.display;this.canvasContainer.style.display="block";const a=this.canvasContainer.getBoundingClientRect();this.canvasContainer.style.display=o,s.width=a.width>0?a.width:window.innerWidth-300,s.height=a.height>0?a.height:window.innerHeight-50,s.style.width="100%",s.style.height="100%",console.log(`📐 Canvas ${e} sized to ${s.width}x${s.height}`)}})}start(){this.isActive||(console.log("🔮 Starting Polychora System"),this.isActive=!0,this.canvasContainer.style.display="block",this.resizeAllCanvases(),this.startRenderLoop())}resizeAllCanvases(){this.setupCanvasElements(),this.visualizers.forEach(t=>{t.setupCanvasSize()}),console.log("🔮 All Polychora canvases resized after becoming visible")}startRenderLoop(){const t=()=>{this.isActive&&(this.parameters.physicsEnabled&&this.physicsEnabled&&(this.physics.step(),this.updatePhysicsVisuals()),this.visualizers.forEach(i=>{i.render(this.parameters)}),this.animationId=requestAnimationFrame(t))};t()}enablePhysics(){this.physicsEnabled=!0,this.parameters.physicsEnabled=!0,this.physics.enable(),this.createPhysicsBodies(),console.log("🔮 Polychora physics simulation enabled")}disablePhysics(){this.physicsEnabled=!1,this.parameters.physicsEnabled=!1,this.physics.disable(),this.physics.clearAllBodies(),this.physicsBodies=[],console.log("🔮 Polychora physics simulation disabled")}createPhysicsBodies(){this.physics.clearAllBodies(),this.physicsBodies=[];for(let t=0;t<this.polytopes.length;t++){const i=this.physics.createRigidBody(t,[(Math.random()-.5)*4,(Math.random()-.5)*4,(Math.random()-.5)*4,(Math.random()-.5)*2],{mass:this.parameters.mass,elasticity:this.parameters.elasticity,friction:this.parameters.friction,brownianMotion:this.parameters.brownianMotion,flocking:this.parameters.flocking,territorial:this.parameters.territorial,magnetic:this.parameters.magneticField});this.physicsBodies.push(i)}this.physics.setGravity([0,0,0,this.parameters.gravity4D]),this.physics.setMagneticField([0,0,this.parameters.magneticField,0]),this.physics.setFluidFlow([this.parameters.fluidFlow,0,0,0])}updatePhysicsVisuals(){const t=this.physics.getPhysicsFeedback();if(t.length>0){const i=this.calculateAveragePhysicsFeedback(t);this.parameters.hue+=i.velocityIntensity*5,this.parameters.chromaticAberration=Math.max(.1,this.parameters.chromaticAberration+i.impactIntensity*.3),this.parameters.noiseAmplitude=Math.max(.1,this.parameters.noiseAmplitude+i.accelerationGlow*.5);const e=t[this.parameters.polytope]||t[0];e&&(this.parameters.rot4dXY=e.rotation[0],this.parameters.rot4dXZ=e.rotation[1],this.parameters.rot4dYZ=e.rotation[2],this.parameters.rot4dXW=e.rotation[3],this.parameters.rot4dYW=e.rotation[4],this.parameters.rot4dZW=e.rotation[5])}}calculateAveragePhysicsFeedback(t){const i={velocityIntensity:0,impactIntensity:0,accelerationGlow:0};if(t.length===0)return i;t.forEach(s=>{i.velocityIntensity+=s.feedback.velocityIntensity,i.impactIntensity+=s.feedback.impactIntensity,i.accelerationGlow+=s.feedback.accelerationGlow});const e=t.length;return i.velocityIntensity/=e,i.impactIntensity/=e,i.accelerationGlow/=e,i}addInteractiveForce(t,i){if(!this.physicsEnabled)return;let e=null,s=1/0;this.physicsBodies.forEach(o=>{const a=this.physics.distance4D(o.position,t);a<s&&(s=a,e=o)}),e&&s<2&&this.physics.addForce(e,i)}resetPhysics(){this.physicsEnabled&&(this.createPhysicsBodies(),console.log("🔮 Polychora physics simulation reset"))}stop(){this.isActive&&(console.log("🔮 Stopping Polychora System"),this.isActive=!1,this.canvasContainer.style.display="none",this.animationId&&(cancelAnimationFrame(this.animationId),this.animationId=null))}updateParameters(t){Object.assign(this.parameters,t),console.log("🔮 Updated Polychora parameters:",t)}setPolytope(t){if(t<0||t>=this.polytopes.length){console.warn("⚠️ Invalid polytope index:",t);return}this.parameters.polytope=t;const i=this.polytopes[t];return console.log(`🔮 Set polytope to ${i.name}: ${i.description}`),i}updateParameters(t){t.rot4dXW!==void 0&&(this.parameters.rot4dXW=t.rot4dXW),t.rot4dYW!==void 0&&(this.parameters.rot4dYW=t.rot4dYW),t.rot4dZW!==void 0&&(this.parameters.rot4dZW=t.rot4dZW),t.hue!==void 0&&(this.parameters.hue=t.hue),t.gridDensity!==void 0&&(this.parameters.lineThickness=t.gridDensity*.01),t.geometry!==void 0&&(this.parameters.polytope=Math.min(t.geometry,this.polytopes.length-1)),t.speed!==void 0&&(this.parameters.flowDirection=t.speed),t.intensity!==void 0&&(this.parameters.projectionDistance=1+t.intensity*4),this.visualizers.forEach(i=>{i.updateParameters&&i.updateParameters(this.parameters)}),console.log("🔮 Polychora parameters updated:",this.parameters)}updateInteraction(t,i,e=.5){this.visualizers.forEach(s=>{s.update4DMouse&&s.update4DMouse(t,i,e)}),console.log(`🔮 Polychora 4D interaction: ${t.toFixed(2)}, ${i.toFixed(2)}, intensity: ${e.toFixed(2)}`)}triggerClick(t=1){this.visualizers.forEach(i=>{i.trigger4DClick&&i.trigger4DClick(t)}),console.log(`🔮 Polychora 4D click: intensity ${t.toFixed(2)}`)}updateScroll(t){this.visualizers.forEach(i=>{i.updateCrossSection&&i.updateCrossSection(t)})}getCurrentPolytope(){return this.polytopes[this.parameters.polytope]}getPolytopeNames(){return this.polytopes.map(t=>t.name)}destroy(){this.stop(),this.visualizers.forEach(t=>{t.destroy&&t.destroy()}),this.visualizers=[],console.log("🔮 Polychora System destroyed")}}export{g as PolychoraSystem};

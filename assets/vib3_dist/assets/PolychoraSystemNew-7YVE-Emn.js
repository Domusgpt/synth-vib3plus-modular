import{P as n}from"./Parameters-DwxYeMJO.js";class l{constructor(t,e,r){this.canvasId=t,this.role=e,this.config=r,this.canvas=null,this.gl=null,this.program=null,this.time=0,this.vertexBuffer=null,this.layerIntensity=this.getLayerIntensity(e),this.layerScale=this.getLayerScale(e),this.layerColor=this.getLayerColor(e)}getLayerIntensity(t){return{background:.1,shadow:.3,content:1,highlight:.7,accent:.5}[t]||.5}getLayerScale(t){return{background:1,shadow:1.1,content:1,highlight:.9,accent:.8}[t]||1}getLayerColor(t){return{background:[.1,.1,.2],shadow:[0,0,.1],content:[.5,.3,.8],highlight:[.8,.6,1],accent:[.3,.8,.9]}[t]||[.5,.5,.5]}initialize(){return this.canvas=document.getElementById(this.canvasId),this.canvas?(this.gl=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl"),this.gl?(console.log(`🔮 4D Polytope WebGL context: ${this.canvasId} (${this.role})`),this.createTrue4DPolytopeShader()?(this.setupCanvasSize(),!0):(console.error(`❌ Failed to create 4D polytope shader for ${this.canvasId}`),!1)):(console.error(`❌ WebGL not supported for ${this.canvasId}`),!1)):(console.error(`❌ Canvas ${this.canvasId} not found`),!1)}createTrue4DPolytopeShader(){const t=`
            attribute vec2 a_position;
            varying vec2 v_uv;
            
            void main() {
                v_uv = a_position * 0.5 + 0.5;
                gl_Position = vec4(a_position, 0.0, 1.0);
            }
        `,e=`
            precision highp float;
            varying vec2 v_uv;
            
            // Standard VIB34D uniforms - following DNA pattern
            uniform float u_time;
            uniform float u_geometry;
            uniform float u_rot4dXW;
            uniform float u_rot4dYW; 
            uniform float u_rot4dZW;
            uniform float u_gridDensity;
            uniform float u_morphFactor;
            uniform float u_chaos;
            uniform float u_speed;
            uniform float u_hue;
            uniform float u_intensity;
            uniform float u_saturation;
            
            // Layer-specific uniforms
            uniform float u_layerIntensity;
            uniform float u_layerScale;
            uniform vec3 u_layerColor;
            
            // Audio reactivity uniforms - following DNA pattern
            uniform float u_bass;
            uniform float u_mid;
            uniform float u_high;
            
            // 4D rotation matrices - EXACT DNA from other systems
            mat4 rotateXW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(c, 0.0, 0.0, -s, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, s, 0.0, 0.0, c);
            }
            
            mat4 rotateYW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(1.0, 0.0, 0.0, 0.0, 0.0, c, 0.0, -s, 0.0, 0.0, 1.0, 0.0, 0.0, s, 0.0, c);
            }
            
            mat4 rotateZW(float theta) {
                float c = cos(theta);
                float s = sin(theta);
                return mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, c, -s, 0.0, 0.0, s, c);
            }
            
            // 4D to 3D projection - EXACT DNA from other systems
            vec3 project4Dto3D(vec4 p) {
                float w = 2.5 / (2.5 + p.w);
                return vec3(p.x * w, p.y * w, p.z * w);
            }
            
            // HSV to RGB conversion - EXACT DNA from other systems
            vec3 hsv2rgb(vec3 c) {
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }
            
            // TRUE 4D POLYTOPE DISTANCE FUNCTIONS
            
            // 5-Cell (4D Tetrahedron) - Simplest regular 4D polytope
            float polytope5Cell(vec4 p) {
                vec4 vertices[5];
                vertices[0] = vec4(1.0, 1.0, 1.0, 1.0);
                vertices[1] = vec4(1.0, -1.0, -1.0, 1.0);
                vertices[2] = vec4(-1.0, 1.0, -1.0, 1.0);
                vertices[3] = vec4(-1.0, -1.0, 1.0, 1.0);
                vertices[4] = vec4(0.0, 0.0, 0.0, -1.0);
                
                float minDist = 1000.0;
                for(int i = 0; i < 5; i++) {
                    minDist = min(minDist, distance(p, vertices[i]));
                }
                return minDist;
            }
            
            // Tesseract (4D Hypercube) - Most famous 4D polytope
            float polytopeTesseract(vec4 p) {
                vec4 q = abs(p) - vec4(1.0);
                return length(max(q, 0.0)) + min(max(max(max(q.x, q.y), q.z), q.w), 0.0);
            }
            
            // 16-Cell (4D Cross-polytope)
            float polytope16Cell(vec4 p) {
                return abs(p.x) + abs(p.y) + abs(p.z) + abs(p.w) - 2.0;
            }
            
            // 24-Cell (Unique to 4D)
            float polytope24Cell(vec4 p) {
                vec4 q = abs(p);
                vec4 sorted = q;
                
                // Sort coordinates for 24-cell symmetry
                if(sorted.x < sorted.y) { float temp = sorted.x; sorted.x = sorted.y; sorted.y = temp; }
                if(sorted.y < sorted.z) { float temp = sorted.y; sorted.y = sorted.z; sorted.z = temp; }
                if(sorted.z < sorted.w) { float temp = sorted.z; sorted.z = sorted.w; sorted.w = temp; }
                
                return sorted.x + sorted.y - 2.0;
            }
            
            // 600-Cell (4D Icosahedron analog)
            float polytope600Cell(vec4 p) {
                float phi = 1.618033988749895; // Golden ratio
                vec4 q = abs(p);
                
                float d1 = max(max(max(q.x, q.y), q.z), q.w) - phi;
                float d2 = (q.x + q.y + q.z + q.w) / phi - 2.0;
                
                return max(d1, d2);
            }
            
            // 120-Cell (Most complex regular 4D polytope)
            float polytope120Cell(vec4 p) {
                float phi = 1.618033988749895; // Golden ratio
                vec4 q = abs(p);
                
                // Approximate 120-cell using dodecahedral symmetry
                float d1 = length(q) - 2.0;
                float d2 = max(max(max(q.x/phi, q.y*phi), q.z/phi), q.w*phi) - 1.5;
                
                return max(d1, d2);
            }
            
            // Hypersphere (4D Sphere)
            float polytopeHypersphere(vec4 p) {
                return length(p) - 1.5;
            }
            
            // 4D Torus (Duocylinder) 
            float polytopeDuocylinder(vec4 p) {
                float r1 = length(p.xy) - 1.0;
                float r2 = length(p.zw) - 1.0;
                return sqrt(r1*r1 + r2*r2) - 0.5;
            }
            
            // TRUE 4D GEOMETRY FUNCTION - Following exact DNA pattern
            float true4DGeometryFunction(vec4 p) {
                int geomType = int(u_geometry);
                float gridSize = u_gridDensity * 0.1;
                
                // Apply 4D rotation - EXACT DNA pattern
                mat4 rotation = rotateXW(u_rot4dXW) * rotateYW(u_rot4dYW) * rotateZW(u_rot4dZW);
                vec4 rotatedP = rotation * p;
                
                // Apply grid tiling like other systems
                vec4 tiledP = fract(rotatedP * gridSize) - 0.5;
                
                float dist = 0.0;
                
                if (geomType == 0) {
                    // 5-CELL (4D Tetrahedron)
                    dist = polytope5Cell(tiledP);
                }
                else if (geomType == 1) {
                    // TESSERACT (4D Hypercube) 
                    dist = polytopeTesseract(tiledP);
                }
                else if (geomType == 2) {
                    // HYPERSPHERE (4D Sphere)
                    dist = polytopeHypersphere(tiledP);
                }
                else if (geomType == 3) {
                    // DUOCYLINDER (4D Torus)
                    dist = polytopeDuocylinder(tiledP);
                }
                else if (geomType == 4) {
                    // 16-CELL (4D Cross-polytope)
                    dist = polytope16Cell(tiledP);
                }
                else if (geomType == 5) {
                    // 24-CELL (Unique to 4D)
                    dist = polytope24Cell(tiledP);
                }
                else if (geomType == 6) {
                    // 600-CELL (4D Icosahedron)
                    dist = polytope600Cell(tiledP);
                }
                else if (geomType == 7) {
                    // 120-CELL (Most complex)
                    dist = polytope120Cell(tiledP);
                }
                
                // Apply morphing and chaos - EXACT DNA pattern
                dist *= u_morphFactor;
                if (u_chaos > 0.0) {
                    float noise = sin(rotatedP.x * 10.0) * sin(rotatedP.y * 10.0) * sin(rotatedP.z * 10.0) * sin(rotatedP.w * 10.0);
                    dist += noise * u_chaos * 0.1;
                }
                
                return dist;
            }
            
            void main() {
                vec2 uv = (v_uv - 0.5) * 2.0;
                float time = u_time * 0.001 * u_speed;
                
                // Create 4D coordinate from 2D screen space
                vec4 rayDir = vec4(uv * u_layerScale, 1.0, sin(time * 0.5));
                
                // Audio reactivity - EXACT DNA pattern
                vec4 audioOffset = vec4(u_bass * 0.3, u_mid * 0.2, u_high * 0.1, u_bass * 0.1);
                rayDir += audioOffset;
                
                // Calculate true 4D polytope distance
                float dist = true4DGeometryFunction(rayDir);
                
                // Layer-specific rendering
                float alpha = 0.0;
                
                if (dist < 0.1) {
                    // Inside polytope
                    alpha = 1.0 - (dist / 0.1);
                    alpha = pow(alpha, 2.0); // Sharp edges like other systems
                } else {
                    // Outside polytope - glow effect
                    alpha = exp(-dist * 5.0) * 0.3;
                }
                
                // Apply layer intensity
                alpha *= u_layerIntensity * u_intensity;
                
                // HSV color calculation - EXACT DNA pattern
                float hue = u_hue / 360.0;
                vec3 hsvColor = vec3(hue, u_saturation, 1.0);
                vec3 color = hsv2rgb(hsvColor);
                
                // Mix with layer color
                color = mix(color, u_layerColor, 0.3);
                
                // Audio-reactive color modulation
                color.r += u_high * 0.2;
                color.g += u_mid * 0.2;  
                color.b += u_bass * 0.2;
                
                // Final output
                gl_FragColor = vec4(color, alpha);
            }
        `;return this.program=this.createShaderProgram(t,e),this.program!==null}createShaderProgram(t,e){const r=this.compileShader(this.gl.VERTEX_SHADER,t),o=this.compileShader(this.gl.FRAGMENT_SHADER,e);if(!r||!o)return null;const i=this.gl.createProgram();if(this.gl.attachShader(i,r),this.gl.attachShader(i,o),this.gl.linkProgram(i),!this.gl.getProgramParameter(i,this.gl.LINK_STATUS))return console.error("4D Polytope shader link error:",this.gl.getProgramInfoLog(i)),null;const s=new Float32Array([-1,-1,1,-1,-1,1,-1,1,1,-1,1,1]);return this.vertexBuffer=this.gl.createBuffer(),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.vertexBuffer),this.gl.bufferData(this.gl.ARRAY_BUFFER,s,this.gl.STATIC_DRAW),i}compileShader(t,e){const r=this.gl.createShader(t);return this.gl.shaderSource(r,e),this.gl.compileShader(r),this.gl.getShaderParameter(r,this.gl.COMPILE_STATUS)?r:(console.error("4D Polytope shader compile error:",this.gl.getShaderInfoLog(r)),null)}setupCanvasSize(){const t=this.canvas.getBoundingClientRect();this.canvas.width=t.width*(window.devicePixelRatio||1),this.canvas.height=t.height*(window.devicePixelRatio||1),this.gl.viewport(0,0,this.canvas.width,this.canvas.height)}render(t={}){var r,o,i;if(!this.gl||!this.program||!this.vertexBuffer)return;this.time+=16,this.gl.useProgram(this.program),this.gl.enable(this.gl.BLEND),this.gl.blendFunc(this.gl.SRC_ALPHA,this.gl.ONE_MINUS_SRC_ALPHA),this.gl.clearColor(0,0,0,0),this.gl.clear(this.gl.COLOR_BUFFER_BIT),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.vertexBuffer);const e=this.gl.getAttribLocation(this.program,"a_position");this.gl.enableVertexAttribArray(e),this.gl.vertexAttribPointer(e,2,this.gl.FLOAT,!1,0,0),this.setUniform("u_time",this.time),this.setUniform("u_geometry",t.geometry||0),this.setUniform("u_rot4dXW",t.rot4dXW||0),this.setUniform("u_rot4dYW",t.rot4dYW||0),this.setUniform("u_rot4dZW",t.rot4dZW||0),this.setUniform("u_gridDensity",t.gridDensity||20),this.setUniform("u_morphFactor",t.morphFactor||1),this.setUniform("u_chaos",t.chaos||0),this.setUniform("u_speed",t.speed||1),this.setUniform("u_hue",t.hue||280),this.setUniform("u_intensity",t.intensity||.8),this.setUniform("u_saturation",t.saturation||.9),this.setUniform("u_layerIntensity",this.layerIntensity),this.setUniform("u_layerScale",this.layerScale),this.setUniform("u_layerColor",this.layerColor),this.setUniform("u_bass",((r=window.audioReactive)==null?void 0:r.bass)||0),this.setUniform("u_mid",((o=window.audioReactive)==null?void 0:o.mid)||0),this.setUniform("u_high",((i=window.audioReactive)==null?void 0:i.high)||0),this.gl.drawArrays(this.gl.TRIANGLES,0,6)}setUniform(t,e){const r=this.gl.getUniformLocation(this.program,t);r!==null&&(typeof e=="number"?this.gl.uniform1f(r,e):Array.isArray(e)&&(e.length===2?this.gl.uniform2f(r,e[0],e[1]):e.length===3?this.gl.uniform3f(r,e[0],e[1],e[2]):e.length===4&&this.gl.uniform4f(r,e[0],e[1],e[2],e[3])))}cleanup(){this.gl&&(this.program&&(this.gl.deleteProgram(this.program),this.program=null),this.vertexBuffer&&(this.gl.deleteBuffer(this.vertexBuffer),this.vertexBuffer=null))}}class h{constructor(){console.log("🔮 Initializing TRUE 4D Polychora Engine with VIB34D DNA..."),this.visualizers=[],this.parameters=new n,this.isActive=!1,this.useBuiltInReactivity=!window.reactivityManager,this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0,this.clickIntensity=0,this.time=0,this.animationId=null,this.rotation4DVelocity={XW:0,YW:0,ZW:0},this.lastRotation4D={XW:0,YW:0,ZW:0},this.parameters.setParameter("geometry",1),this.parameters.setParameter("hue",280),this.parameters.setParameter("intensity",.8),this.parameters.setParameter("saturation",.9),this.parameters.setParameter("gridDensity",25),this.parameters.setParameter("morphFactor",1),this.init()}init(){this.createVisualizers(),this.setupAudioReactivity(),this.setup4DInteractivity(),this.startRenderLoop(),console.log("✨ TRUE 4D Polychora Engine initialized with VIB34D DNA")}createVisualizers(){const t=[{id:"polychora-background-canvas",role:"background"},{id:"polychora-shadow-canvas",role:"shadow"},{id:"polychora-content-canvas",role:"content"},{id:"polychora-highlight-canvas",role:"highlight"},{id:"polychora-accent-canvas",role:"accent"}];this.visualizers=[];for(const e of t){const r=new l(e.id,e.role,{});r.initialize()?(this.visualizers.push(r),console.log(`✅ 4D Polytope layer initialized: ${e.role}`)):console.error(`❌ Failed to initialize 4D Polytope layer: ${e.role}`)}console.log(`🔮 True 4D Polychora: ${this.visualizers.length}/5 layers active`)}setupAudioReactivity(){window.audioContext&&window.analyser&&console.log("🎵 4D Polychora audio reactivity enabled")}setup4DInteractivity(){this.useBuiltInReactivity&&setInterval(()=>{const t={XW:this.parameters.getParameter("rot4dXW"),YW:this.parameters.getParameter("rot4dYW"),ZW:this.parameters.getParameter("rot4dZW")};this.rotation4DVelocity={XW:t.XW-this.lastRotation4D.XW,YW:t.YW-this.lastRotation4D.YW,ZW:t.ZW-this.lastRotation4D.ZW},this.lastRotation4D=t},100)}startRenderLoop(){this.animationId&&cancelAnimationFrame(this.animationId);const t=()=>{if(!this.isActive)return;this.time+=16;const e={geometry:this.parameters.getParameter("geometry"),rot4dXW:this.parameters.getParameter("rot4dXW"),rot4dYW:this.parameters.getParameter("rot4dYW"),rot4dZW:this.parameters.getParameter("rot4dZW"),gridDensity:this.parameters.getParameter("gridDensity"),morphFactor:this.parameters.getParameter("morphFactor"),chaos:this.parameters.getParameter("chaos"),speed:this.parameters.getParameter("speed"),hue:this.parameters.getParameter("hue"),intensity:this.parameters.getParameter("intensity"),saturation:this.parameters.getParameter("saturation")};window.audioReactive&&(e.rot4dXW+=window.audioReactive.bass*2,e.rot4dYW+=window.audioReactive.mid*1.5,e.rot4dZW+=window.audioReactive.high*1,e.morphFactor+=window.audioReactive.bass*.5,e.hue+=(window.audioReactive.mid+window.audioReactive.high)*30),this.visualizers.forEach(r=>{r.render(e)}),this.animationId=requestAnimationFrame(t)};t()}activate(){console.log("🔮 Activating TRUE 4D Polychora Engine..."),this.isActive=!0,document.querySelectorAll('canvas[id*="-canvas"]').forEach(e=>{e.style.display=e.id.includes("polychora")?"block":"none"}),this.startRenderLoop(),window.statusManager&&window.statusManager.updateStatus("TRUE 4D POLYCHORA ENGINE ACTIVE","system"),console.log("✅ True 4D Polychora Engine activated")}deactivate(){console.log("🔮 Deactivating 4D Polychora Engine..."),this.isActive=!1,this.animationId&&(cancelAnimationFrame(this.animationId),this.animationId=null),document.querySelectorAll('canvas[id*="polychora"]').forEach(e=>{e.style.display="none"}),console.log("✅ 4D Polychora Engine deactivated")}updateParameter(t,e){this.parameters.setParameter(t,e),t==="geometry"&&console.log(`🔮 4D Polytope changed to: ${["5-CELL","TESSERACT","HYPERSPHERE","DUOCYLINDER","16-CELL","24-CELL","600-CELL","120-CELL"][Math.floor(e)]||"UNKNOWN"}`)}getParameters(){if(this.parameters&&typeof this.parameters.getAllParameters=="function")return this.parameters.getAllParameters();const t={};return["geometry","rot4dXW","rot4dYW","rot4dZW","gridDensity","morphFactor","chaos","speed","hue","intensity","saturation"].forEach(r=>{this.parameters&&typeof this.parameters.getParameter=="function"&&(t[r]=this.parameters.getParameter(r))}),t}setParameters(t){t&&(Object.keys(t).forEach(e=>{this.parameters&&typeof this.parameters.setParameter=="function"&&this.parameters.setParameter(e,t[e])}),console.log("🔮 4D Polychora parameters updated from load"))}getParameterValue(t){return this.parameters.getParameter(t)}randomizeParameters(){this.parameters.randomize(),this.parameters.setParameter("gridDensity",15+Math.random()*20),this.parameters.setParameter("intensity",.6+Math.random()*.4),console.log("🎲 4D Polychora parameters randomized")}cleanup(){this.deactivate(),this.visualizers.forEach(t=>{t.cleanup()}),this.visualizers=[],console.log("🧹 4D Polychora Engine cleaned up")}}window.NewPolychoraEngine=h;export{h as NewPolychoraEngine};

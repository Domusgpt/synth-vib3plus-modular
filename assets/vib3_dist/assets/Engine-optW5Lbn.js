import{P as g}from"./Parameters-DwxYeMJO.js";class p{static getGeometryNames(){return["TETRAHEDRON","HYPERCUBE","SPHERE","TORUS","KLEIN BOTTLE","FRACTAL","WAVE","CRYSTAL"]}static getGeometryName(t){return this.getGeometryNames()[t]||"UNKNOWN"}static getVariationParameters(t,e){const i={gridDensity:8+e*4,morphFactor:.5+e*.3,chaos:e*.15,speed:.8+e*.2,hue:(t*45+e*15)%360};switch(t){case 0:i.gridDensity*=1.2;break;case 1:i.morphFactor*=.8;break;case 2:i.chaos*=1.5;break;case 3:i.speed*=1.3;break;case 4:i.gridDensity*=.7,i.morphFactor*=1.4;break;case 5:i.gridDensity*=.5,i.chaos*=2;break;case 6:i.speed*=1.8,i.chaos*=.5;break;case 7:i.gridDensity*=1.5,i.morphFactor*=.6;break}return i}}class f{constructor(t,e,i,a){if(this.canvas=document.getElementById(t),this.role=e,this.reactivity=i,this.variant=a,!this.canvas){console.error(`Canvas ${t} not found`);return}let s=this.canvas.getBoundingClientRect();const r=Math.min(window.devicePixelRatio||1,2);this.contextOptions={alpha:!0,depth:!0,stencil:!1,antialias:!1,premultipliedAlpha:!0,preserveDrawingBuffer:!1,powerPreference:"high-performance",failIfMajorPerformanceCaveat:!1},this.ensureCanvasSizedThenInitWebGL(s,r),this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0,this.clickIntensity=0,this.startTime=Date.now(),this.params={geometry:0,gridDensity:15,morphFactor:1,chaos:.2,speed:1,hue:200,intensity:.5,saturation:.8,dimension:3.5,rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0}}async ensureCanvasSizedThenInitWebGL(t,e){t.width===0||t.height===0?await new Promise(i=>{setTimeout(()=>{if(t=this.canvas.getBoundingClientRect(),t.width===0||t.height===0){const a=window.innerWidth,s=window.innerHeight;this.canvas.width=a*e,this.canvas.height=s*e,window.mobileDebug&&window.mobileDebug.log(`📐 Canvas ${this.canvas.id}: Using viewport fallback ${this.canvas.width}x${this.canvas.height}`)}else this.canvas.width=t.width*e,this.canvas.height=t.height*e,window.mobileDebug&&window.mobileDebug.log(`📐 Canvas ${this.canvas.id}: Layout ready ${this.canvas.width}x${this.canvas.height}`);i()},100)}):(this.canvas.width=t.width*e,this.canvas.height=t.height*e,window.mobileDebug&&window.mobileDebug.log(`📐 Canvas ${this.canvas.id}: ${this.canvas.width}x${this.canvas.height} (DPR: ${e})`)),this.createWebGLContext(),this.gl&&this.init()}createWebGLContext(){let t=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl");if(t&&!t.isContextLost()){console.log(`🔄 Reusing existing WebGL context for ${this.canvas.id}`),this.gl=t;return}if(this.gl=this.canvas.getContext("webgl2",this.contextOptions)||this.canvas.getContext("webgl",this.contextOptions)||this.canvas.getContext("experimental-webgl",this.contextOptions),this.gl){if(window.mobileDebug){const e=this.gl.getParameter(this.gl.VERSION);window.mobileDebug.log(`✅ WebGL context created for ${this.canvas.id}: ${e} (size: ${this.canvas.width}x${this.canvas.height})`)}}else{console.error(`WebGL not supported for ${this.canvas.id}`),window.mobileDebug&&window.mobileDebug.log(`❌ WebGL context failed for ${this.canvas.id} (size: ${this.canvas.width}x${this.canvas.height})`),this.showWebGLError();return}}init(){this.initShaders(),this.initBuffers(),this.resize()}initShaders(){const t=`attribute vec2 a_position;
void main() {
    gl_Position = vec4(a_position, 0.0, 1.0);
}`,e=`precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform float u_geometry;
uniform float u_gridDensity;
uniform float u_morphFactor;
uniform float u_chaos;
uniform float u_speed;
uniform float u_hue;
uniform float u_intensity;
uniform float u_saturation;
uniform float u_dimension;
uniform float u_rot4dXY;
uniform float u_rot4dXZ;
uniform float u_rot4dYZ;
uniform float u_rot4dXW;
uniform float u_rot4dYW;
uniform float u_rot4dZW;
uniform float u_mouseIntensity;
uniform float u_clickIntensity;
uniform float u_roleIntensity;

// 6D rotation matrices - 3D space rotations (XY, XZ, YZ)
mat4 rotateXY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(c, -s, 0.0, 0.0, s, c, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
}

mat4 rotateXZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(c, 0.0, s, 0.0, 0.0, 1.0, 0.0, 0.0, -s, 0.0, c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

mat4 rotateYZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(1.0, 0.0, 0.0, 0.0, 0.0, c, -s, 0.0, 0.0, s, c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

// 4D hyperspace rotations (XW, YW, ZW)
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

vec3 project4Dto3D(vec4 p) {
    float w = 2.5 / (2.5 + p.w);
    return vec3(p.x * w, p.y * w, p.z * w);
}

// ========================================
// POLYTOPE CORE WARP FUNCTIONS (24 Geometries)
// ========================================
// Wraps geometry through 4D hypersphere (geometries 8-15)
vec3 warpHypersphereCore(vec3 p, int geometryIndex, vec2 mouseDelta) {
    float radius = length(p);
    float morphBlend = clamp(u_morphFactor * 0.6 + (u_dimension - 3.0) * 0.25, 0.0, 2.0);
    float w = sin(radius * (1.3 + float(geometryIndex) * 0.12) + u_time * 0.0008 * u_speed);
    w *= (0.4 + morphBlend * 0.45);

    vec4 p4d = vec4(p * (1.0 + morphBlend * 0.2), w);

    // Apply 6D rotation in 4D space
    p4d = rotateXY(u_rot4dXY) * p4d;
    p4d = rotateXZ(u_rot4dXZ) * p4d;
    p4d = rotateYZ(u_rot4dYZ) * p4d;
    p4d = rotateXW(u_rot4dXW) * p4d;
    p4d = rotateYW(u_rot4dYW) * p4d;
    p4d = rotateZW(u_rot4dZW) * p4d;

    vec3 projected = project4Dto3D(p4d);
    return mix(p, projected, clamp(0.45 + morphBlend * 0.35, 0.0, 1.0));
}

// Wraps geometry through 4D hypertetrahedron (geometries 16-23)
vec3 warpHypertetraCore(vec3 p, int geometryIndex, vec2 mouseDelta) {
    vec3 c1 = normalize(vec3(1.0, 1.0, 1.0));
    vec3 c2 = normalize(vec3(-1.0, -1.0, 1.0));
    vec3 c3 = normalize(vec3(-1.0, 1.0, -1.0));
    vec3 c4 = normalize(vec3(1.0, -1.0, -1.0));

    float morphBlend = clamp(u_morphFactor * 0.8 + (u_dimension - 3.0) * 0.2, 0.0, 2.0);
    float basisMix = dot(p, c1) * 0.14 + dot(p, c2) * 0.1 + dot(p, c3) * 0.08;
    float w = sin(basisMix * 5.5 + u_time * 0.0009 * u_speed);
    w *= cos(dot(p, c4) * 4.2 - u_time * 0.0007 * u_speed);
    w *= (0.5 + morphBlend * 0.4);

    vec3 offset = vec3(dot(p, c1), dot(p, c2), dot(p, c3)) * 0.1 * morphBlend;
    vec4 p4d = vec4(p + offset, w);

    // Apply 6D rotation in 4D space
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

// Applies polytope core warp based on geometry index (0-23)
// 0-7: Base (no warp), 8-15: Hypersphere, 16-23: Hypertetrahedron
vec3 applyCoreWarp(vec3 p, float geometryType, vec2 mouseDelta) {
    float totalBase = 8.0;
    float coreFloat = floor(geometryType / totalBase);
    int coreIndex = int(clamp(coreFloat, 0.0, 2.0));
    float baseGeomFloat = mod(geometryType, totalBase);
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

// Simplified geometry functions for WebGL 1.0 compatibility (ORIGINAL FACETED)
// NOW SUPPORTS 24 GEOMETRIES: Decodes geometry index to base geometry (0-7)
float geometryFunction(vec4 p) {
    // Decode geometry: base = geometry % 8
    float totalBase = 8.0;
    float baseGeomFloat = mod(u_geometry, totalBase);
    int geomType = int(clamp(floor(baseGeomFloat + 0.5), 0.0, totalBase - 1.0));
    
    if (geomType == 0) {
        // Tetrahedron lattice - UNIFORM GRID DENSITY
        vec4 pos = fract(p * u_gridDensity * 0.08);
        vec4 dist = min(pos, 1.0 - pos);
        return min(min(dist.x, dist.y), min(dist.z, dist.w)) * u_morphFactor;
    }
    else if (geomType == 1) {
        // Hypercube lattice - UNIFORM GRID DENSITY
        vec4 pos = fract(p * u_gridDensity * 0.08);
        vec4 dist = min(pos, 1.0 - pos);
        float minDist = min(min(dist.x, dist.y), min(dist.z, dist.w));
        return minDist * u_morphFactor;
    }
    else if (geomType == 2) {
        // Sphere lattice - UNIFORM GRID DENSITY
        float r = length(p);
        float density = u_gridDensity * 0.08;
        float spheres = abs(fract(r * density) - 0.5) * 2.0;
        float theta = atan(p.y, p.x);
        float harmonics = sin(theta * 3.0) * 0.2;
        return (spheres + harmonics) * u_morphFactor;
    }
    else if (geomType == 3) {
        // Torus lattice - UNIFORM GRID DENSITY
        float r1 = length(p.xy) - 2.0;
        float torus = length(vec2(r1, p.z)) - 0.8;
        float lattice = sin(p.x * u_gridDensity * 0.08) * sin(p.y * u_gridDensity * 0.08);
        return (torus + lattice * 0.3) * u_morphFactor;
    }
    else if (geomType == 4) {
        // Klein bottle lattice - UNIFORM GRID DENSITY
        float u = atan(p.y, p.x);
        float v = atan(p.w, p.z);
        float dist = length(p) - 2.0;
        float lattice = sin(u * u_gridDensity * 0.08) * sin(v * u_gridDensity * 0.08);
        return (dist + lattice * 0.4) * u_morphFactor;
    }
    else if (geomType == 5) {
        // Fractal lattice - NOW WITH UNIFORM GRID DENSITY
        vec4 pos = fract(p * u_gridDensity * 0.08);
        pos = abs(pos * 2.0 - 1.0);
        float dist = length(max(abs(pos) - 1.0, 0.0));
        return dist * u_morphFactor;
    }
    else if (geomType == 6) {
        // Wave lattice - UNIFORM GRID DENSITY
        float freq = u_gridDensity * 0.08;
        float time = u_time * 0.001 * u_speed;
        float wave1 = sin(p.x * freq + time);
        float wave2 = sin(p.y * freq + time * 1.3);
        float wave3 = sin(p.z * freq * 0.8 + time * 0.7); // Add Z-dimension waves
        float interference = wave1 * wave2 * wave3;
        return interference * u_morphFactor;
    }
    else if (geomType == 7) {
        // Crystal lattice - UNIFORM GRID DENSITY
        vec4 pos = fract(p * u_gridDensity * 0.08) - 0.5;
        float cube = max(max(abs(pos.x), abs(pos.y)), max(abs(pos.z), abs(pos.w)));
        return cube * u_morphFactor;
    }
    else {
        // Default hypercube - UNIFORM GRID DENSITY
        vec4 pos = fract(p * u_gridDensity * 0.08);
        vec4 dist = min(pos, 1.0 - pos);
        return min(min(dist.x, dist.y), min(dist.z, dist.w)) * u_morphFactor;
    }
}

void main() {
    vec2 uv = (gl_FragCoord.xy - u_resolution.xy * 0.5) / min(u_resolution.x, u_resolution.y);

    // 4D position with mouse interaction - NOW USING SPEED PARAMETER
    float timeSpeed = u_time * 0.0001 * u_speed;
    vec4 pos = vec4(uv * 3.0, sin(timeSpeed * 3.0), cos(timeSpeed * 2.0));
    pos.xy += (u_mouse - 0.5) * u_mouseIntensity * 2.0;

    // Apply 6D rotations - 3D space rotations first, then 4D hyperspace
    pos = rotateXY(u_rot4dXY) * pos;
    pos = rotateXZ(u_rot4dXZ) * pos;
    pos = rotateYZ(u_rot4dYZ) * pos;
    pos = rotateXW(u_rot4dXW) * pos;
    pos = rotateYW(u_rot4dYW) * pos;
    pos = rotateZW(u_rot4dZW) * pos;

    // POLYTOPE WARP: Apply 4D polytope core transformation (24-geometry system)
    // Decode geometry: 0-7 Base, 8-15 Hypersphere, 16-23 Hypertetrahedron
    vec3 basePoint = project4Dto3D(pos);
    vec3 warpedPoint = applyCoreWarp(basePoint, u_geometry, u_mouse - 0.5);

    // Convert warped 3D back to 4D for geometry evaluation
    vec4 warpedPos = vec4(warpedPoint, pos.w);

    // Calculate geometry value using WARPED position
    float value = geometryFunction(warpedPos);
    
    // Apply chaos
    float noise = sin(pos.x * 7.0) * cos(pos.y * 11.0) * sin(pos.z * 13.0);
    value += noise * u_chaos;
    
    // Color based on geometry value and hue with user-controlled intensity/saturation
    float geometryIntensity = 1.0 - clamp(abs(value), 0.0, 1.0);
    geometryIntensity += u_clickIntensity * 0.3;
    
    // Apply user intensity control
    float finalIntensity = geometryIntensity * u_intensity;
    
    float hue = u_hue / 360.0 + value * 0.1;
    
    // Create color with saturation control
    vec3 baseColor = vec3(
        sin(hue * 6.28318 + 0.0) * 0.5 + 0.5,
        sin(hue * 6.28318 + 2.0943) * 0.5 + 0.5,
        sin(hue * 6.28318 + 4.1887) * 0.5 + 0.5
    );
    
    // Apply saturation (mix with grayscale)
    float gray = (baseColor.r + baseColor.g + baseColor.b) / 3.0;
    vec3 color = mix(vec3(gray), baseColor, u_saturation) * finalIntensity;
    
    gl_FragColor = vec4(color, finalIntensity * u_roleIntensity);
}`;this.program=this.createProgram(t,e),this.uniforms={resolution:this.gl.getUniformLocation(this.program,"u_resolution"),time:this.gl.getUniformLocation(this.program,"u_time"),mouse:this.gl.getUniformLocation(this.program,"u_mouse"),geometry:this.gl.getUniformLocation(this.program,"u_geometry"),gridDensity:this.gl.getUniformLocation(this.program,"u_gridDensity"),morphFactor:this.gl.getUniformLocation(this.program,"u_morphFactor"),chaos:this.gl.getUniformLocation(this.program,"u_chaos"),speed:this.gl.getUniformLocation(this.program,"u_speed"),hue:this.gl.getUniformLocation(this.program,"u_hue"),intensity:this.gl.getUniformLocation(this.program,"u_intensity"),saturation:this.gl.getUniformLocation(this.program,"u_saturation"),dimension:this.gl.getUniformLocation(this.program,"u_dimension"),rot4dXY:this.gl.getUniformLocation(this.program,"u_rot4dXY"),rot4dXZ:this.gl.getUniformLocation(this.program,"u_rot4dXZ"),rot4dYZ:this.gl.getUniformLocation(this.program,"u_rot4dYZ"),rot4dXW:this.gl.getUniformLocation(this.program,"u_rot4dXW"),rot4dYW:this.gl.getUniformLocation(this.program,"u_rot4dYW"),rot4dZW:this.gl.getUniformLocation(this.program,"u_rot4dZW"),mouseIntensity:this.gl.getUniformLocation(this.program,"u_mouseIntensity"),clickIntensity:this.gl.getUniformLocation(this.program,"u_clickIntensity"),roleIntensity:this.gl.getUniformLocation(this.program,"u_roleIntensity")}}createProgram(t,e){const i=this.createShader(this.gl.VERTEX_SHADER,t),a=this.createShader(this.gl.FRAGMENT_SHADER,e);if(!i||!a)return null;const s=this.gl.createProgram();return this.gl.attachShader(s,i),this.gl.attachShader(s,a),this.gl.linkProgram(s),this.gl.getProgramParameter(s,this.gl.LINK_STATUS)?s:(console.error("Program linking failed:",this.gl.getProgramInfoLog(s)),null)}createShader(t,e){if(!this.gl)return console.error("❌ Cannot create shader: WebGL context is null"),null;if(this.gl.isContextLost())return console.error("❌ Cannot create shader: WebGL context is lost"),null;try{const i=this.gl.createShader(t);if(!i)return console.error("❌ Failed to create shader object - WebGL context may be invalid"),null;if(this.gl.shaderSource(i,e),this.gl.compileShader(i),!this.gl.getShaderParameter(i,this.gl.COMPILE_STATUS)){const a=this.gl.getShaderInfoLog(i),s=t===this.gl.VERTEX_SHADER?"vertex":"fragment";return a?console.error(`❌ ${s} shader compilation failed:`,a):console.error(`❌ ${s} shader compilation failed: WebGL returned no error info (context may be invalid)`),console.error("Shader source:",e),this.gl.deleteShader(i),null}return i}catch(i){return console.error("❌ Exception during shader creation:",i),null}}initBuffers(){const t=new Float32Array([-1,-1,1,-1,-1,1,1,1]);this.buffer=this.gl.createBuffer(),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.buffer),this.gl.bufferData(this.gl.ARRAY_BUFFER,t,this.gl.STATIC_DRAW);const e=this.gl.getAttribLocation(this.program,"a_position");this.gl.enableVertexAttribArray(e),this.gl.vertexAttribPointer(e,2,this.gl.FLOAT,!1,0,0)}resize(){const t=Math.min(window.devicePixelRatio||1,2),e=this.canvas.clientWidth,i=this.canvas.clientHeight;(this.canvas.width!==e*t||this.canvas.height!==i*t)&&(this.canvas.width=e*t,this.canvas.height=i*t,this.gl.viewport(0,0,this.canvas.width,this.canvas.height))}showWebGLError(){if(!this.canvas)return;const t=this.canvas.getContext("2d");if(t)this.canvas.width=this.canvas.clientWidth,this.canvas.height=this.canvas.clientHeight,t.fillStyle="#1a0033",t.fillRect(0,0,this.canvas.width,this.canvas.height),t.fillStyle="#ff6b6b",t.font=`${Math.min(20,this.canvas.width/15)}px sans-serif`,t.textAlign="center",t.fillText("⚠️ WebGL Error",this.canvas.width/2,this.canvas.height/2-30),t.fillStyle="#ffd93d",t.font=`${Math.min(14,this.canvas.width/20)}px sans-serif`,/Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)?(t.fillText("Mobile device detected",this.canvas.width/2,this.canvas.height/2),t.fillText("Enable hardware acceleration",this.canvas.width/2,this.canvas.height/2+20),t.fillText("or try Chrome/Firefox",this.canvas.width/2,this.canvas.height/2+40)):(t.fillText("Please enable WebGL",this.canvas.width/2,this.canvas.height/2),t.fillText("in your browser settings",this.canvas.width/2,this.canvas.height/2+20)),window.mobileDebug&&window.mobileDebug.log(`📱 WebGL error fallback shown for canvas ${this.canvas.id}`);else{const e=document.createElement("div");e.innerHTML=`
                <div style="
                    position: absolute;
                    top: 0; left: 0; right: 0; bottom: 0;
                    background: #1a0033;
                    color: #ff6b6b;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    font-family: sans-serif;
                    text-align: center;
                    padding: 20px;
                ">
                    <div style="font-size: 24px; margin-bottom: 10px;">⚠️</div>
                    <div style="font-size: 18px; margin-bottom: 10px;">Graphics Error</div>
                    <div style="font-size: 14px; color: #ffd93d;">
                        Your device doesn't support<br>
                        the required graphics features
                    </div>
                </div>
            `,this.canvas.parentNode.insertBefore(e,this.canvas.nextSibling)}}updateParameters(t){this.params={...this.params,...t}}updateInteraction(t,e,i){if(window.interactivityEnabled===!1){this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0;return}this.mouseX=t,this.mouseY=e,this.mouseIntensity=i}render(){var r,o,n,l,h;if(!this.program){window.mobileDebug&&window.mobileDebug.log(`❌ ${(r=this.canvas)==null?void 0:r.id}: No WebGL program compiled`);return}if(!this.gl){window.mobileDebug&&window.mobileDebug.log(`❌ ${(o=this.canvas)==null?void 0:o.id}: No WebGL context`);return}try{this.resize(),this.gl.useProgram(this.program),this.gl.clearColor(0,0,0,0),this.gl.clear(this.gl.COLOR_BUFFER_BIT)}catch(d){window.mobileDebug&&window.mobileDebug.log(`❌ ${(n=this.canvas)==null?void 0:n.id}: WebGL render error: ${d.message}`);return}const t={background:.3,shadow:.5,content:.8,highlight:1,accent:1.2},e=Date.now()-this.startTime;this.gl.uniform2f(this.uniforms.resolution,this.canvas.width,this.canvas.height),this.gl.uniform1f(this.uniforms.time,e),this.gl.uniform2f(this.uniforms.mouse,this.mouseX,this.mouseY),this.gl.uniform1f(this.uniforms.geometry,this.params.geometry);let i=this.params.gridDensity,a=this.params.hue,s=this.params.intensity;window.audioEnabled&&window.audioReactive&&(i+=window.audioReactive.bass*30,a+=window.audioReactive.mid*60,s+=window.audioReactive.high*.4),this.gl.uniform1f(this.uniforms.gridDensity,Math.min(100,i)),this.gl.uniform1f(this.uniforms.morphFactor,this.params.morphFactor),this.gl.uniform1f(this.uniforms.chaos,this.params.chaos),this.gl.uniform1f(this.uniforms.speed,this.params.speed),this.gl.uniform1f(this.uniforms.hue,a%360),this.gl.uniform1f(this.uniforms.intensity,Math.min(1,s)),this.gl.uniform1f(this.uniforms.saturation,this.params.saturation),this.gl.uniform1f(this.uniforms.dimension,this.params.dimension),this.gl.uniform1f(this.uniforms.rot4dXY,this.params.rot4dXY||0),this.gl.uniform1f(this.uniforms.rot4dXZ,this.params.rot4dXZ||0),this.gl.uniform1f(this.uniforms.rot4dYZ,this.params.rot4dYZ||0),this.gl.uniform1f(this.uniforms.rot4dXW,this.params.rot4dXW||0),this.gl.uniform1f(this.uniforms.rot4dYW,this.params.rot4dYW||0),this.gl.uniform1f(this.uniforms.rot4dZW,this.params.rot4dZW||0),this.gl.uniform1f(this.uniforms.mouseIntensity,this.mouseIntensity),this.gl.uniform1f(this.uniforms.clickIntensity,this.clickIntensity),this.gl.uniform1f(this.uniforms.roleIntensity,t[this.role]||1);try{this.gl.drawArrays(this.gl.TRIANGLE_STRIP,0,4),window.mobileDebug&&!this._renderSuccessLogged&&(window.mobileDebug.log(`✅ ${(l=this.canvas)==null?void 0:l.id}: WebGL render successful`),this._renderSuccessLogged=!0)}catch(d){window.mobileDebug&&window.mobileDebug.log(`❌ ${(h=this.canvas)==null?void 0:h.id}: WebGL draw error: ${d.message}`)}}reinitializeContext(){var t,e,i,a,s;if(console.log(`🔄 Reinitializing WebGL context for ${(t=this.canvas)==null?void 0:t.id}`),this.program=null,this.buffer=null,this.uniforms=null,this.gl=null,this.gl=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl"),!this.gl)return console.error(`❌ No WebGL context available for ${(e=this.canvas)==null?void 0:e.id} - CanvasManager should have created one`),!1;if(this.gl.isContextLost())return console.error(`❌ WebGL context is lost for ${(i=this.canvas)==null?void 0:i.id}`),!1;try{return this.init(),console.log(`✅ ${(a=this.canvas)==null?void 0:a.id}: Context reinitialized successfully`),!0}catch(r){return console.error(`❌ Failed to reinitialize WebGL resources for ${(s=this.canvas)==null?void 0:s.id}:`,r),!1}}destroy(){this.gl&&this.program&&this.gl.deleteProgram(this.program),this.gl&&this.buffer&&this.gl.deleteBuffer(this.buffer)}}class v{constructor(t){this.engine=t,this.variationNames=["TETRAHEDRON LATTICE 1","TETRAHEDRON LATTICE 2","TETRAHEDRON LATTICE 3","TETRAHEDRON LATTICE 4","HYPERCUBE LATTICE 1","HYPERCUBE LATTICE 2","HYPERCUBE LATTICE 3","HYPERCUBE LATTICE 4","SPHERE LATTICE 1","SPHERE LATTICE 2","SPHERE LATTICE 3","SPHERE LATTICE 4","TORUS LATTICE 1","TORUS LATTICE 2","TORUS LATTICE 3","TORUS LATTICE 4","KLEIN BOTTLE LATTICE 1","KLEIN BOTTLE LATTICE 2","KLEIN BOTTLE LATTICE 3","KLEIN BOTTLE LATTICE 4","FRACTAL LATTICE 1","FRACTAL LATTICE 2","FRACTAL LATTICE 3","WAVE LATTICE 1","WAVE LATTICE 2","WAVE LATTICE 3","CRYSTAL LATTICE 1","CRYSTAL LATTICE 2","CRYSTAL LATTICE 3","CRYSTAL LATTICE 4"],this.customVariations=new Array(70).fill(null),this.totalVariations=100}getVariationName(t){if(t<30)return this.variationNames[t];{const e=t-30,i=this.customVariations[e];return i?i.name:`CUSTOM ${e+1}`}}generateDefaultVariation(t){if(t>=30)return null;const e=Math.floor(t/4),i=t%4;let a=e;return e===5&&i>2&&(a=5,i=2),e===6&&i>2&&(a=6,i=2),{variation:t,geometry:a,gridDensity:8+a*2+i*1.5,morphFactor:.2+i*.2,chaos:i*.2,speed:.8+i*.2,hue:t*12.27%360,rot4dXW:(i-1.5)*.3,rot4dYW:a%2*.2,rot4dZW:(a+i)%3*.15,dimension:3.2+i*.2}}applyVariation(t){if(t<0||t>=this.totalVariations)return!1;let e;if(t<30)e=this.generateDefaultVariation(t);else{const i=t-30,a=this.customVariations[i];a?e={...a.parameters,variation:t}:e={...this.engine.parameterManager.getAllParameters(),variation:t}}return e?(this.engine.parameterManager.setParameters(e),this.engine.currentVariation=t,!0):!1}saveCurrentAsCustom(){const t=this.customVariations.findIndex(s=>s===null);if(t===-1)return-1;const e=this.engine.parameterManager.getAllParameters(),a={name:`${p.getGeometryName(e.geometry)} CUSTOM ${t+1}`,timestamp:new Date().toISOString(),parameters:{...e},metadata:{basedOnVariation:this.engine.currentVariation,createdFrom:"current-state"}};return this.customVariations[t]=a,this.saveCustomVariations(),30+t}deleteCustomVariation(t){return t>=0&&t<70?(this.customVariations[t]=null,this.saveCustomVariations(),!0):!1}populateGrid(){const t=document.getElementById("variationGrid");if(!t)return;t.innerHTML="",[{name:"Tetrahedron",range:[0,3],class:"tetrahedron"},{name:"Hypercube",range:[4,7],class:"hypercube"},{name:"Sphere",range:[8,11],class:"sphere"},{name:"Torus",range:[12,15],class:"torus"},{name:"Klein Bottle",range:[16,19],class:"klein"},{name:"Fractal",range:[20,22],class:"fractal"},{name:"Wave",range:[23,25],class:"wave"},{name:"Crystal",range:[26,29],class:"crystal"}].forEach(s=>{const r=document.createElement("div");r.className="variation-section",r.innerHTML=`<h3>${s.name} Lattice</h3>`;const o=document.createElement("div");o.className="variation-buttons";for(let n=s.range[0];n<=s.range[1];n++)if(n<this.variationNames.length){const l=this.createVariationButton(n,!0,s.class);o.appendChild(l)}r.appendChild(o),t.appendChild(r)});const i=document.createElement("div");i.className="variation-section custom-section",i.innerHTML="<h3>Custom Variations</h3>";const a=document.createElement("div");a.className="variation-buttons custom-grid";for(let s=0;s<70;s++){const r=this.createVariationButton(30+s,!1,"custom");a.appendChild(r)}i.appendChild(a),t.appendChild(i)}createVariationButton(t,e,i){const a=document.createElement("button"),s=this.getVariationName(t);if(a.className=`preset-btn ${i} ${e?"default-variation":"custom-variation"}`,a.dataset.variation=t,a.title=`${t+1}. ${s}`,e)a.innerHTML=`
                <div class="variation-number">${(t+1).toString().padStart(2,"0")}</div>
                <div class="variation-level">Level ${t%4+1}</div>
            `;else{const r=t-30,o=this.customVariations[r]!==null;a.innerHTML=`
                <div class="variation-number">${(t+1).toString()}</div>
                <div class="variation-type">${o?"CUSTOM":"EMPTY"}</div>
            `,o||a.classList.add("empty-slot")}return a.addEventListener("click",()=>{(e||this.customVariations[t-30]!==null)&&(this.engine.setVariation(t),this.updateVariationGrid())}),e||a.addEventListener("contextmenu",r=>{r.preventDefault();const o=t-30;this.customVariations[o]!==null&&confirm(`Delete custom variation ${t+1}?`)&&(this.deleteCustomVariation(o),this.populateGrid())}),a}updateVariationGrid(){document.querySelectorAll(".preset-btn").forEach(e=>{e.classList.remove("active"),parseInt(e.dataset.variation)===this.engine.currentVariation&&e.classList.add("active")})}loadCustomVariations(){try{const t=localStorage.getItem("vib34d-custom-variations");if(t){const e=JSON.parse(t);Array.isArray(e)&&e.length===70&&(this.customVariations=e)}}catch(t){console.warn("Failed to load custom variations:",t)}}saveCustomVariations(){try{localStorage.setItem("vib34d-custom-variations",JSON.stringify(this.customVariations))}catch(t){console.warn("Failed to save custom variations:",t)}}exportCustomVariations(){const t={type:"vib34d-custom-variations",version:"1.0.0",timestamp:new Date().toISOString(),variations:this.customVariations.filter(r=>r!==null)},e=JSON.stringify(t,null,2),i=new Blob([e],{type:"application/json"}),a=URL.createObjectURL(i),s=document.createElement("a");s.href=a,s.download="vib34d-custom-variations.json",s.click(),URL.revokeObjectURL(a)}async importCustomVariations(t){try{const e=await t.text(),i=JSON.parse(e);if(i.type==="vib34d-custom-variations"&&Array.isArray(i.variations)){let a=0;return i.variations.forEach(s=>{const r=this.customVariations.findIndex(o=>o===null);r!==-1&&(this.customVariations[r]=s,a++)}),this.saveCustomVariations(),this.populateGrid(),a}}catch(e){console.error("Failed to import custom variations:",e)}return 0}getStatistics(){const t=this.customVariations.filter(e=>e!==null).length;return{totalVariations:this.totalVariations,defaultVariations:30,customVariations:t,emptySlots:70-t,currentVariation:this.engine.currentVariation,isCustom:this.engine.currentVariation>=30}}}class y{constructor(t){this.engine=t,this.galleryModal=null,this.previewCanvas=null,this.previewVisualizer=null,this.currentPreview=-1,this.previewTimeout=null,this.init()}init(){this.createGalleryModal(),this.setupEventHandlers()}createGalleryModal(){const t=document.createElement("div");t.id="galleryModal",t.className="modal gallery-modal",t.innerHTML=`
            <div class="modal-content gallery-content">
                <div class="gallery-header">
                    <h2>VIB34D Variation Gallery</h2>
                    <div class="gallery-controls">
                        <button class="preview-toggle" title="Toggle Live Preview">
                            <span class="icon">👁️</span> Live Preview
                        </button>
                        <button class="gallery-export" title="Export All Variations">
                            <span class="icon">📁</span> Export All
                        </button>
                        <button class="close-btn" title="Close Gallery">×</button>
                    </div>
                </div>
                
                <div class="gallery-body">
                    <div class="gallery-sidebar">
                        <div class="preview-container">
                            <canvas id="galleryPreviewCanvas" width="300" height="300"></canvas>
                            <div class="preview-info">
                                <div class="preview-title">Hover to preview</div>
                                <div class="preview-details"></div>
                            </div>
                        </div>
                        
                        <div class="gallery-stats">
                            <div class="stat-item">
                                <span class="stat-label">Total Variations:</span>
                                <span class="stat-value" id="totalVariationsCount">100</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Custom Variations:</span>
                                <span class="stat-value" id="customVariationsCount">0</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="gallery-grid-container">
                        <div class="gallery-sections">
                            <!-- Populated dynamically -->
                        </div>
                    </div>
                </div>
            </div>
        `,document.body.appendChild(t),this.galleryModal=t,this.previewCanvas=document.getElementById("galleryPreviewCanvas"),this.initPreviewSystem()}initPreviewSystem(){if(this.previewCanvas){this.previewVisualizer={canvas:this.previewCanvas,ctx:this.previewCanvas.getContext("2d"),params:{},updateParams(e){this.params={...e}},render(){const e=this.ctx,i=this.canvas;e.fillStyle="#000",e.fillRect(0,0,i.width,i.height);const a=i.width/2,s=i.height/2,r=Date.now()*.001;for(let o=0;o<this.params.gridDensity*5;o++){const n=o/(this.params.gridDensity*5)*Math.PI*2,l=Math.sin(r*this.params.speed+n*this.params.morphFactor)*80,h=a+Math.cos(n)*l,d=s+Math.sin(n)*l,u=(this.params.hue+n*57.2958+r*20)%360,m=.4+Math.sin(r*2+n)*.3;e.fillStyle=`hsla(${u}, 70%, 50%, ${m})`,e.beginPath(),e.arc(h,d,2+this.params.chaos*4,0,Math.PI*2),e.fill()}}};const t=()=>{this.currentPreview>=0&&this.previewVisualizer.render(),requestAnimationFrame(t)};t()}}setupEventHandlers(){this.galleryModal.querySelector(".close-btn").addEventListener("click",()=>this.closeGallery()),this.galleryModal.addEventListener("click",a=>{a.target===this.galleryModal&&this.closeGallery()}),this.galleryModal.querySelector(".preview-toggle").addEventListener("click",()=>{this.togglePreview()}),this.galleryModal.querySelector(".gallery-export").addEventListener("click",()=>{this.exportAllVariations()}),document.addEventListener("keydown",a=>{if(this.galleryModal.classList.contains("active"))switch(a.key){case"Escape":this.closeGallery();break;case"ArrowLeft":this.navigatePreview(-1);break;case"ArrowRight":this.navigatePreview(1);break}})}openGallery(){this.populateGallery(),this.updateGalleryStats(),this.galleryModal.classList.add("active")}closeGallery(){this.galleryModal.classList.remove("active"),this.currentPreview=-1,this.clearPreview()}populateGallery(){const t=this.galleryModal.querySelector(".gallery-sections");t.innerHTML="",[{name:"Tetrahedron Lattice",range:[0,3],class:"tetrahedron"},{name:"Hypercube Lattice",range:[4,7],class:"hypercube"},{name:"Sphere Lattice",range:[8,11],class:"sphere"},{name:"Torus Lattice",range:[12,15],class:"torus"},{name:"Klein Bottle Lattice",range:[16,19],class:"klein"},{name:"Fractal Lattice",range:[20,22],class:"fractal"},{name:"Wave Lattice",range:[23,25],class:"wave"},{name:"Crystal Lattice",range:[26,29],class:"crystal"}].forEach(a=>{const s=this.createGallerySection(a.name,a.range,a.class,!0);t.appendChild(s)});const i=this.createCustomGallerySection();t.appendChild(i)}createGallerySection(t,e,i,a){const s=document.createElement("div");s.className="gallery-section";const r=document.createElement("h3");r.textContent=t,r.className=`geometry-header ${i}`;const o=document.createElement("div");o.className="gallery-grid";for(let n=e[0];n<=e[1];n++)if(n<this.engine.variationManager.variationNames.length||!a){const l=this.createVariationThumbnail(n,a);o.appendChild(l)}return s.appendChild(r),s.appendChild(o),s}createCustomGallerySection(){const t=document.createElement("div");t.className="gallery-section custom-section";const e=document.createElement("h3");e.textContent="Custom Variations",e.className="geometry-header custom";const i=document.createElement("div");i.className="gallery-grid custom-grid";for(let a=0;a<70;a++)if(this.engine.variationManager.customVariations[a]){const r=this.createVariationThumbnail(30+a,!1);i.appendChild(r)}return t.appendChild(e),t.appendChild(i),t}createVariationThumbnail(t,e){const i=document.createElement("div");i.className=`gallery-thumbnail ${e?"default":"custom"}`,i.dataset.variation=t;const a=this.engine.variationManager.getVariationName(t);return t===this.engine.currentVariation&&i.classList.add("current"),i.innerHTML=`
            <div class="thumbnail-preview">
                <div class="variation-number">${t+1}</div>
                <div class="preview-placeholder"></div>
            </div>
            <div class="thumbnail-info">
                <div class="variation-name">${a}</div>
                <div class="variation-type">${e?"Default":"Custom"}</div>
            </div>
        `,i.addEventListener("mouseenter",()=>{this.showPreview(t)}),i.addEventListener("mouseleave",()=>{this.clearPreview()}),i.addEventListener("click",()=>{this.selectVariation(t)}),i}showPreview(t){this.currentPreview=t,this.previewTimeout&&clearTimeout(this.previewTimeout),this.previewTimeout=setTimeout(()=>{if(this.currentPreview===t){const e=this.getVariationParameters(t);this.previewVisualizer.updateParams(e);const i=this.galleryModal.querySelector(".preview-title"),a=this.galleryModal.querySelector(".preview-details");i.textContent=this.engine.variationManager.getVariationName(t),a.innerHTML=`
                    <div>Variation #${t+1}</div>
                    <div>Geometry: ${this.getGeometryName(e.geometry)}</div>
                    <div>Density: ${e.gridDensity.toFixed(1)}</div>
                    <div>Hue: ${e.hue}°</div>
                `}},100)}clearPreview(){this.currentPreview=-1,this.previewTimeout&&clearTimeout(this.previewTimeout);const t=this.galleryModal.querySelector(".preview-title"),e=this.galleryModal.querySelector(".preview-details");t.textContent="Hover to preview",e.innerHTML=""}selectVariation(t){this.engine.setVariation(t),this.closeGallery()}navigatePreview(t){let e=this.currentPreview+t;for(;e>=0&&e<100;){if(e<30||this.engine.variationManager.customVariations[e-30]!==null){this.showPreview(e);const i=this.galleryModal.querySelector(`[data-variation="${e}"]`);i&&i.scrollIntoView({behavior:"smooth",block:"nearest"});break}e+=t}}getVariationParameters(t){if(t<30)return this.engine.variationManager.generateDefaultVariation(t);{const e=this.engine.variationManager.customVariations[t-30];return e?e.parameters:this.engine.parameterManager.getAllParameters()}}getGeometryName(t){return["Tetrahedron","Hypercube","Sphere","Torus","Klein Bottle","Fractal","Wave","Crystal"][t]||"Unknown"}updateGalleryStats(){const t=this.engine.variationManager.getStatistics();document.getElementById("totalVariationsCount").textContent=t.totalVariations,document.getElementById("customVariationsCount").textContent=t.customVariations}togglePreview(){this.galleryModal.querySelector(".preview-container").classList.toggle("hidden")}exportAllVariations(){this.engine.statusManager.info("Exporting all variations..."),this.engine.variationManager.exportCustomVariations()}}class w{constructor(t){this.engine=t,this.setupFileInputs()}setupFileInputs(){const t=document.createElement("input");t.type="file",t.id="jsonFileInput",t.accept=".json",t.style.display="none",t.addEventListener("change",i=>this.handleJSONImport(i)),document.body.appendChild(t);const e=document.createElement("input");e.type="file",e.id="folderInput",e.webkitdirectory=!0,e.multiple=!0,e.style.display="none",e.addEventListener("change",i=>this.handleFolderImport(i)),document.body.appendChild(e)}exportJSON(){const t={version:"2.0",type:"vib34d-integrated-config",name:`${this.engine.variationManager.getVariationName(this.engine.currentVariation)} - ${new Date().toLocaleDateString()}`,variation:this.engine.currentVariation,parameters:this.engine.parameterManager.getAllParameters(),timestamp:Date.now(),metadata:{engine:"VIB34D Integrated",features:["5-layer holographic","100 variations","4D mathematics","agent-ready"],author:"Paul Phillips (domusgpt)",email:"phillips.paul.email@gmail.com"}},e=JSON.stringify(t,null,2);this.downloadFile(e,"vib34d-config.json","application/json"),this.engine.statusManager.success("Configuration exported as JSON")}saveToGallery(t=null){const e=this.engine.parameterManager.getAllParameters(),i=t||this.engine.variationManager.getVariationName(this.engine.currentVariation),a=new Date().toISOString(),s={name:`Custom Gallery Collection - ${new Date().toLocaleDateString()}`,description:`User-saved variation: ${i}`,version:"1.0",type:"holographic-collection",profileName:"VIB34D System",totalVariations:1,created:a,variations:[{id:0,name:i,isCustom:!0,globalId:Date.now(),system:"faceted",parameters:{geometryType:e.geometry||0,density:e.gridDensity||10,speed:e.speed||1,chaos:e.chaos||0,morph:e.morphFactor||0,hue:e.hue||200,saturation:.8,intensity:.5,rot4dXW:e.rot4dXW||0,rot4dYW:e.rot4dYW||0,rot4dZW:e.rot4dZW||0,dimension:e.dimension||3.8}}]},r=JSON.stringify(s,null,2),o=`custom-${Date.now()}.json`;return this.downloadFile(r,o,"application/json"),this.engine.statusManager.success(`🎯 Saved for Gallery!<br><br><strong>File:</strong> ${o}<br><strong>Next Steps:</strong><br>1. Find downloaded file in your Downloads folder<br>2. Move it to the <code>collections/</code> folder in your VIB34D directory<br>3. Refresh gallery to see your variation<br><br><small>The gallery only shows collections from the collections/ folder</small>`),console.log("🎯 Gallery collection saved:",o),o}exportCSS(){const t=this.engine.parameterManager.getAllParameters(),e=`/* VIB34D Integrated Holographic CSS Theme */
/* Generated: ${new Date().toISOString()} */
/* Variation: ${this.engine.currentVariation+1} - ${this.engine.variationManager.getVariationName(this.engine.currentVariation)} */

:root {
    /* VIB34D Parameters */
    --vib34d-variation: ${this.engine.currentVariation};
    --vib34d-geometry: ${t.geometry};
    --vib34d-grid-density: ${t.gridDensity};
    --vib34d-morph-factor: ${t.morphFactor};
    --vib34d-chaos: ${t.chaos};
    --vib34d-speed: ${t.speed};
    --vib34d-hue: ${t.hue}deg;
    --vib34d-rot-4d-xw: ${t.rot4dXW};
    --vib34d-rot-4d-yw: ${t.rot4dYW};
    --vib34d-rot-4d-zw: ${t.rot4dZW};
    --vib34d-dimension: ${t.dimension};
}

.vib34d-holographic {
    /* Base holographic background */
    background: linear-gradient(45deg, 
        hsl(${t.hue}, 70%, 30%) 0%,
        hsl(${(t.hue+60)%360}, 70%, 20%) 25%,
        hsl(${(t.hue+120)%360}, 70%, 25%) 50%,
        hsl(${(t.hue+180)%360}, 70%, 20%) 75%,
        hsl(${(t.hue+240)%360}, 70%, 30%) 100%);
    
    /* Animation based on parameters */
    animation: vib34d-holographic-pulse ${3/t.speed}s infinite;
    
    /* 4D transformation simulation */
    transform: perspective(1000px) 
               rotateX(${t.rot4dXW*5}deg) 
               rotateY(${t.rot4dYW*5}deg) 
               rotateZ(${t.rot4dZW*5}deg);
    
    /* Layer effects */
    position: relative;
    overflow: hidden;
}

.vib34d-holographic::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: radial-gradient(circle at 50% 50%, 
        hsla(${(t.hue+30)%360}, 80%, 50%, 0.3) 0%,
        hsla(${(t.hue+90)%360}, 70%, 40%, 0.2) 30%,
        transparent 60%);
    mix-blend-mode: screen;
    animation: vib34d-overlay-rotate ${6/t.speed}s linear infinite;
}

.vib34d-holographic::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: repeating-linear-gradient(
        ${t.rot4dXW*90}deg,
        transparent 0px,
        hsla(${t.hue}, 60%, 60%, ${.1+t.chaos*.2}) ${2+t.gridDensity*.5}px,
        transparent ${4+t.gridDensity}px
    );
    mix-blend-mode: overlay;
}

@keyframes vib34d-holographic-pulse {
    0% { 
        filter: hue-rotate(0deg) saturate(1) brightness(1);
        transform: perspective(1000px) 
                   rotateX(${t.rot4dXW*5}deg) 
                   rotateY(${t.rot4dYW*5}deg) 
                   rotateZ(${t.rot4dZW*5}deg) 
                   scale(1);
    }
    50% { 
        filter: hue-rotate(${t.chaos*180}deg) 
                saturate(${1+t.morphFactor}) 
                brightness(${1.1+t.morphFactor*.3});
        transform: perspective(1000px) 
                   rotateX(${t.rot4dXW*5+2}deg) 
                   rotateY(${t.rot4dYW*5+2}deg) 
                   rotateZ(${t.rot4dZW*5+2}deg) 
                   scale(${1+t.morphFactor*.1});
    }
    100% { 
        filter: hue-rotate(360deg) saturate(1) brightness(1);
        transform: perspective(1000px) 
                   rotateX(${t.rot4dXW*5}deg) 
                   rotateY(${t.rot4dYW*5}deg) 
                   rotateZ(${t.rot4dZW*5}deg) 
                   scale(1);
    }
}

@keyframes vib34d-overlay-rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

/* Interactive effects */
.vib34d-holographic:hover {
    animation-duration: ${1.5/t.speed}s;
    filter: saturate(${1.2+t.morphFactor*.3}) brightness(${1.1+t.chaos*.2});
}

.vib34d-holographic:active {
    transform: perspective(1000px) 
               rotateX(${t.rot4dXW*5+5}deg) 
               rotateY(${t.rot4dYW*5+5}deg) 
               rotateZ(${t.rot4dZW*5+3}deg) 
               scale(${.95+t.morphFactor*.05});
}

/* Configuration comment for reference */
/* VIB34D Configuration: ${JSON.stringify(t,null,2)} */`;this.downloadFile(e,"vib34d-holographic.css","text/css"),this.engine.statusManager.success("CSS theme exported")}exportHTML(){const t=this.engine.parameterManager.getAllParameters(),e=`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VIB34D Holographic Export - Variation ${this.engine.currentVariation+1}</title>
    <style>
        body { 
            margin: 0; 
            padding: 0;
            background: #000; 
            font-family: 'Orbitron', 'Courier New', monospace; 
            overflow: hidden;
        }
        #holographic-canvas { 
            width: 100vw; 
            height: 100vh; 
            display: block;
        }
        .info-overlay {
            position: fixed;
            top: 20px;
            left: 20px;
            color: #fff;
            background: rgba(0,0,0,0.7);
            padding: 15px;
            border-radius: 8px;
            font-size: 12px;
            z-index: 1000;
            max-width: 300px;
        }
        .info-overlay h3 {
            margin: 0 0 10px 0;
            color: hsl(${t.hue}, 70%, 70%);
        }
    </style>
</head>
<body>
    <canvas id="holographic-canvas"></canvas>
    
    <div class="info-overlay">
        <h3>VIB34D Holographic Export</h3>
        <div>Variation: ${this.engine.currentVariation+1} - ${this.engine.variationManager.getVariationName(this.engine.currentVariation)}</div>
        <div>Geometry: ${this.getGeometryName(t.geometry)}</div>
        <div>Generated: ${new Date().toLocaleString()}</div>
        <div style="margin-top: 10px; font-size: 10px; opacity: 0.7;">
            Click to interact • Double-click to randomize
        </div>
    </div>

    <script>
// VIB34D Configuration
const vib34dConfig = ${JSON.stringify(t,null,4)};

// Simplified renderer for exported HTML
class ExportedHolographicRenderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.config = vib34dConfig;
        this.time = 0;
        this.mouseX = 0.5;
        this.mouseY = 0.5;
        this.mouseIntensity = 0;
        this.clickIntensity = 0;
        
        this.setupInteraction();
        this.render();
    }
    
    setupInteraction() {
        this.canvas.addEventListener('mousemove', (e) => {
            const rect = this.canvas.getBoundingClientRect();
            this.mouseX = (e.clientX - rect.left) / rect.width;
            this.mouseY = (e.clientY - rect.top) / rect.height;
            this.mouseIntensity = 0.5;
        });
        
        this.canvas.addEventListener('click', () => {
            this.clickIntensity = 1.0;
        });
        
        this.canvas.addEventListener('dblclick', () => {
            this.randomizeConfig();
        });
    }
    
    randomizeConfig() {
        this.config.hue = Math.random() * 360;
        this.config.gridDensity = 4 + Math.random() * 26;
        this.config.morphFactor = Math.random() * 2;
        this.config.chaos = Math.random();
        this.config.speed = 0.1 + Math.random() * 2.9;
        this.clickIntensity = 1.5;
    }
    
    render() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        
        const ctx = this.ctx;
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Generate holographic pattern based on config
        const centerX = this.canvas.width / 2;
        const centerY = this.canvas.height / 2;
        const interactionX = centerX + (this.mouseX - 0.5) * this.canvas.width * 0.3;
        const interactionY = centerY + (this.mouseY - 0.5) * this.canvas.height * 0.3;
        
        // Multiple layers for depth
        const layers = [
            { alpha: 0.2, size: 1, offset: 0 },
            { alpha: 0.3, size: 1.5, offset: 0.3 },
            { alpha: 0.4, size: 2, offset: 0.6 },
            { alpha: 0.3, size: 1.2, offset: 0.9 },
            { alpha: 0.5, size: 2.5, offset: 1.2 }
        ];
        
        layers.forEach((layer, layerIndex) => {
            for (let i = 0; i < this.config.gridDensity * 8; i++) {
                const angle = (i / (this.config.gridDensity * 8)) * Math.PI * 2;
                const radius = Math.sin(this.time * 0.001 * this.config.speed + angle * this.config.morphFactor + layer.offset) * 
                              (100 + layerIndex * 30) * (1 + this.mouseIntensity * 0.5);
                
                const x = interactionX + Math.cos(angle) * radius;
                const y = interactionY + Math.sin(angle) * radius;
                
                const hue = (this.config.hue + angle * 57.2958 + this.time * 0.1 + layerIndex * 20) % 360;
                const alpha = (layer.alpha + Math.sin(this.time * 0.002 + angle) * 0.2) * 
                             (1 + this.clickIntensity * 0.5);
                
                ctx.fillStyle = \`hsla(\${hue}, 70%, \${50 + layerIndex * 10}%, \${alpha})\`;
                ctx.beginPath();
                ctx.arc(x, y, (2 + this.config.chaos * 3) * layer.size, 0, Math.PI * 2);
                ctx.fill();
            }
        });
        
        // Decay intensities
        this.mouseIntensity *= 0.95;
        this.clickIntensity *= 0.92;
        
        this.time += 16;
        requestAnimationFrame(() => this.render());
    }
}

// Initialize when page loads
window.addEventListener('load', () => {
    new ExportedHolographicRenderer(document.getElementById('holographic-canvas'));
});
    <\/script>
</body>
</html>`;this.downloadFile(e,"vib34d-holographic.html","text/html"),this.engine.statusManager.success("HTML file exported")}exportPNG(){try{const t=document.getElementById("content-canvas");if(!t)throw new Error("Content canvas not found");const e=document.createElement("a");e.download=`vib34d-variation-${this.engine.currentVariation+1}.png`,e.href=t.toDataURL("image/png"),e.click(),this.engine.statusManager.success("PNG image exported")}catch(t){this.engine.statusManager.error("PNG export failed: "+t.message)}}importJSON(){document.getElementById("jsonFileInput").click()}importFolder(){document.getElementById("folderInput").click()}async handleJSONImport(t){const e=t.target.files[0];if(e){try{const i=await e.text(),a=JSON.parse(i);this.validateConfiguration(a)?(this.loadConfiguration(a),this.engine.statusManager.success(`Configuration imported: ${a.name||"Unnamed"}`)):this.engine.statusManager.error("Invalid configuration file")}catch(i){this.engine.statusManager.error("Failed to import configuration: "+i.message)}t.target.value=""}}async handleFolderImport(t){const i=Array.from(t.target.files).filter(s=>s.name.toLowerCase().endsWith(".json")&&s.type==="application/json");if(i.length===0){this.engine.statusManager.warning("No JSON files found in folder");return}let a=0;for(const s of i)try{const r=await s.text(),o=JSON.parse(r);this.validateConfiguration(o)&&(this.saveAsCustomVariation(o),a++)}catch(r){console.warn(`Failed to load ${s.name}:`,r)}a>0?(this.engine.statusManager.success(`Imported ${a} configurations from folder`),this.engine.variationManager.populateGrid()):this.engine.statusManager.error("No valid configurations found in folder"),t.target.value=""}validateConfiguration(t){return t&&t.type==="vib34d-integrated-config"&&t.parameters&&typeof t.parameters=="object"}loadConfiguration(t){t.parameters&&(this.engine.parameterManager.setParameters(t.parameters),typeof t.variation=="number"&&this.engine.setVariation(t.variation),this.engine.updateDisplayValues(),this.engine.updateVisualizers())}saveAsCustomVariation(t){return this.engine.variationManager.saveCurrentAsCustom()}downloadFile(t,e,i){const a=new Blob([t],{type:i}),s=URL.createObjectURL(a),r=document.createElement("a");r.href=s,r.download=e,r.click(),URL.revokeObjectURL(s)}getGeometryName(t){return["Tetrahedron","Hypercube","Sphere","Torus","Klein Bottle","Fractal","Wave","Crystal"][t]||"Unknown"}}class b{constructor(){this.statusElement=null,this.timeout=null,this.init()}init(){this.statusElement=document.getElementById("status")}setStatus(t,e="info",i=3e3){if(!this.statusElement)return;this.statusElement.textContent=t,this.statusElement.className=`status ${e}`,this.timeout&&clearTimeout(this.timeout),e!=="error"&&i>0&&(this.timeout=setTimeout(()=>{this.clearStatus()},i)),console[e==="error"?"error":e==="warning"?"warn":"log"](`[${e.toUpperCase()}] ${t}`)}clearStatus(){this.statusElement&&(this.statusElement.textContent="",this.statusElement.className="status"),this.timeout&&(clearTimeout(this.timeout),this.timeout=null)}success(t,e=3e3){this.setStatus(t,"success",e)}error(t){this.setStatus(t,"error",0)}warning(t,e=4e3){this.setStatus(t,"warning",e)}info(t,e=3e3){this.setStatus(t,"info",e)}loading(t){this.setStatus(t,"loading",0)}}class C{constructor(){this.visualizers=[],this.parameterManager=new g,this.variationManager=new v(this),this.gallerySystem=new y(this),this.exportManager=new w(this),this.statusManager=new b,this.isActive=!1,this.useBuiltInReactivity=!window.reactivityManager,this.currentVariation=0,this.totalVariations=100,this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0,this.clickIntensity=0,this.time=0,this.animationId=null,this.init()}init(){console.log("🌌 Initializing VIB34D Integrated Holographic Engine...");try{this.createVisualizers(),this.setupControls(),this.setupInteractions(),this.loadCustomVariations(),this.populateVariationGrid(),this.startRenderLoop(),this.statusManager.setStatus("VIB34D Engine initialized successfully","success"),console.log("✅ VIB34D Engine ready")}catch(t){console.error("❌ Failed to initialize VIB34D Engine:",t),this.statusManager.setStatus("Initialization failed: "+t.message,"error")}}createVisualizers(){[{id:"background-canvas",role:"background",reactivity:.5},{id:"shadow-canvas",role:"shadow",reactivity:.7},{id:"content-canvas",role:"content",reactivity:.9},{id:"highlight-canvas",role:"highlight",reactivity:1.1},{id:"accent-canvas",role:"accent",reactivity:1.5}].forEach(e=>{const i=new f(e.id,e.role,e.reactivity,this.currentVariation);this.visualizers.push(i)}),console.log("✅ Created 5-layer integrated holographic system")}setupControls(){this.setupTabSystem(),this.setupParameterControls(),this.setupGeometryPresets(),this.updateDisplayValues()}setupTabSystem(){document.querySelectorAll(".tab-btn").forEach(t=>{t.addEventListener("click",()=>{document.querySelectorAll(".tab-btn").forEach(e=>e.classList.remove("active")),document.querySelectorAll(".tab-content").forEach(e=>e.classList.remove("active")),t.classList.add("active"),document.getElementById(t.dataset.tab+"-tab").classList.add("active")})})}setupParameterControls(){["variationSlider","rot4dXW","rot4dYW","rot4dZW","dimension","gridDensity","morphFactor","chaos","speed","hue"].forEach(e=>{const i=document.getElementById(e);i&&i.addEventListener("input",()=>this.updateFromControls())})}setupGeometryPresets(){document.querySelectorAll("[data-geometry]").forEach(t=>{t.addEventListener("click",()=>{document.querySelectorAll("[data-geometry]").forEach(e=>e.classList.remove("active")),t.classList.add("active"),this.parameterManager.setGeometry(parseInt(t.dataset.geometry)),this.updateVisualizers(),this.updateDisplayValues()})})}setupInteractions(){if(!this.useBuiltInReactivity){console.log("🔷 Faceted built-in reactivity DISABLED - ReactivityManager active");return}console.log("🔷 Setting up Faceted 4D rotation mouse reactivity"),this.setup4DRotationReactivity()}setup4DRotationReactivity(){console.log("🔷 Setting up Faceted: 4D rotations + click flash + scroll density"),this.colorFlashIntensity=0,this.flashDecay=.95,this.scrollDensity=15,["background-canvas","shadow-canvas","content-canvas","highlight-canvas","accent-canvas"].forEach(e=>{const i=document.getElementById(e);i&&(i.addEventListener("mousemove",a=>{if(!this.isActive)return;const s=i.getBoundingClientRect(),r=(a.clientX-s.left)/s.width,o=(a.clientY-s.top)/s.height;this.update4DRotationParameters(r,o)}),i.addEventListener("touchmove",a=>{if(this.isActive&&(a.preventDefault(),a.touches.length>0)){const s=a.touches[0],r=i.getBoundingClientRect(),o=(s.clientX-r.left)/r.width,n=(s.clientY-r.top)/r.height;this.update4DRotationParameters(o,n)}},{passive:!1}),i.addEventListener("click",a=>{this.isActive&&this.triggerColorFlash()}),i.addEventListener("touchend",a=>{this.isActive&&this.triggerColorFlash()}),i.addEventListener("wheel",a=>{this.isActive&&(a.preventDefault(),this.updateScrollDensity(a.deltaY))},{passive:!1}))}),this.startColorFlashLoop()}update4DRotationParameters(t,e){const a=(t-.5)*12.56,s=(t-.5)*12.56*.7,r=(e-.5)*12.56;this.mouseHue||(this.mouseHue=this.scrollHue||200);const o=(t-.5)*30,n=(this.mouseHue+o)%360;window.updateParameter&&(window.updateParameter("rot4dXW",a.toFixed(2)),window.updateParameter("rot4dYW",s.toFixed(2)),window.updateParameter("rot4dZW",r.toFixed(2)),window.updateParameter("hue",Math.round(n))),console.log(`🔷 Smooth 4D + Hue: XW=${a.toFixed(2)}, ZW=${r.toFixed(2)}, Hue=${Math.round(n)}`)}triggerColorFlash(){this.colorFlashIntensity=1,this.clickChaosBoost=.8,this.clickSpeedBoost=1.5,console.log("💥 Faceted dramatic click: color flash + chaos + speed boost")}updateScrollDensity(t){const i=t>0?1:-1;this.scrollDensity+=i*.8,this.scrollDensity=Math.max(5,Math.min(100,this.scrollDensity)),this.scrollHue||(this.scrollHue=200);const a=3;this.scrollHue+=i*a,this.scrollHue=(this.scrollHue%360+360)%360,window.updateParameter&&(window.updateParameter("gridDensity",Math.round(this.scrollDensity)),window.updateParameter("hue",Math.round(this.scrollHue))),console.log(`🌀 Smooth scroll: Density=${Math.round(this.scrollDensity)}, Hue=${Math.round(this.scrollHue)}`)}startColorFlashLoop(){const t=()=>{if(this.colorFlashIntensity>.01){const e=this.colorFlashIntensity;let i,a;if(e>.5){const l=(e-.5)*2;i=1-l*.7,a=1-l*.5}else{const l=(.5-e)*2;i=1+l*.5,a=1+l*.3}const s=.8,r=.5,o=Math.max(.1,Math.min(1,s*i)),n=Math.max(.1,Math.min(1,r*a));window.updateParameter&&(window.updateParameter("saturation",o.toFixed(2)),window.updateParameter("intensity",n.toFixed(2))),this.colorFlashIntensity*=.94}if(this.clickChaosBoost>.01){const i=.2+this.clickChaosBoost;window.updateParameter&&window.updateParameter("chaos",i.toFixed(2)),this.clickChaosBoost*=.92}if(this.clickSpeedBoost>.01){const i=1+this.clickSpeedBoost;window.updateParameter&&window.updateParameter("speed",i.toFixed(2)),this.clickSpeedBoost*=.91}this.isActive&&requestAnimationFrame(t)};t()}loadCustomVariations(){this.variationManager.loadCustomVariations()}populateVariationGrid(){this.variationManager.populateGrid()}startRenderLoop(){var e;window.mobileDebug&&window.mobileDebug.log(`🎬 VIB34D Faceted Engine: Starting render loop with ${(e=this.visualizers)==null?void 0:e.length} visualizers`);const t=()=>{this.time+=.016,this.updateVisualizers(),this.animationId=requestAnimationFrame(t)};t(),window.mobileDebug&&window.mobileDebug.log(`✅ VIB34D Faceted Engine: Render loop started, animationId=${!!this.animationId}`)}updateVisualizers(){const t=this.parameterManager.getAllParameters();t.mouseX=this.mouseX,t.mouseY=this.mouseY,t.mouseIntensity=this.mouseIntensity,t.clickIntensity=this.clickIntensity,t.time=this.time,this.visualizers.forEach(e=>{e.updateParameters(t),e.render()}),this.mouseIntensity*=.95,this.clickIntensity*=.92}updateFromControls(){this.parameterManager.updateFromControls(),this.updateDisplayValues()}updateDisplayValues(){this.parameterManager.updateDisplayValues()}setVariation(t){if(t>=0&&t<this.totalVariations){this.currentVariation=t,this.variationManager.applyVariation(t),this.updateDisplayValues(),this.updateVisualizers();const e=document.getElementById("variationSlider");e&&(e.value=t),this.statusManager.setStatus(`Variation ${t+1} loaded`,"info")}}nextVariation(){this.setVariation((this.currentVariation+1)%this.totalVariations)}previousVariation(){this.setVariation((this.currentVariation-1+this.totalVariations)%this.totalVariations)}randomVariation(){const t=Math.floor(Math.random()*this.totalVariations);this.setVariation(t)}randomizeAll(){this.parameterManager.randomizeAll(),this.updateDisplayValues(),this.updateVisualizers(),this.statusManager.setStatus("All parameters randomized","info")}resetToDefaults(){this.parameterManager.resetToDefaults(),this.updateDisplayValues(),this.updateVisualizers(),this.statusManager.setStatus("Reset to default parameters","info")}saveAsCustomVariation(){const t=this.variationManager.saveCurrentAsCustom();t!==-1?(this.statusManager.setStatus(`Saved as custom variation ${t+1}`,"success"),this.populateVariationGrid()):this.statusManager.setStatus("All custom slots are full","warning")}openGalleryView(){this.gallerySystem.openGallery()}exportJSON(){this.exportManager.exportJSON()}exportCSS(){this.exportManager.exportCSS()}exportHTML(){this.exportManager.exportHTML()}exportPNG(){this.exportManager.exportPNG()}importJSON(){this.exportManager.importJSON()}importFolder(){this.exportManager.importFolder()}setActive(t){console.log(`🔷 Faceted Engine setActive: ${t}`),this.isActive=t,t&&!this.animationId?(console.log("🎬 Faceted Engine: Starting animation loop"),this.startRenderLoop()):!t&&this.animationId&&(console.log("⏹️ Faceted Engine: Stopping animation loop"),cancelAnimationFrame(this.animationId),this.animationId=null)}updateInteraction(t,e,i=.5){this.mouseX=t,this.mouseY=e,this.mouseIntensity=i,this.visualizers.forEach(a=>{a.updateInteraction&&a.updateInteraction(t,e,i)})}triggerClick(t=1){this.clickIntensity=t}applyAudioReactivityGrid(t){const e=this.audioReactivitySettings||window.audioReactivitySettings;if(!e)return;const i=e.sensitivity[e.activeSensitivity];e.activeVisualModes.forEach(a=>{const[s,r]=a.split("-");if(r==="color"){const o=t.energy*i,n=t.bass*i;if(t.rhythm*i,t.mid>.2){const l=this.parameterManager.getParameter("hue")||180,h=t.mid*i*30;this.parameterManager.setParameter("hue",(l+h)%360)}o>.3&&this.parameterManager.setParameter("intensity",Math.min(1,.5+o*.8)),n>.4&&this.parameterManager.setParameter("saturation",Math.min(1,.7+n*.3))}else if(r==="geometry"){const o=t.bass*i,n=t.high*i;if(o>.3){const l=this.parameterManager.getParameter("gridDensity")||15;this.parameterManager.setParameter("gridDensity",Math.min(100,l+o*25))}if(t.mid>.2){const l=t.mid*i*.5;this.parameterManager.setParameter("morphFactor",Math.min(2,l))}n>.4&&this.parameterManager.setParameter("chaos",Math.min(1,n*.6))}else if(r==="movement"){const o=t.energy*i;if(o>.2&&this.parameterManager.setParameter("speed",Math.min(3,.5+o*1.5)),t.bass>.3){const n=this.parameterManager.getParameter("rot4dXW")||0;this.parameterManager.setParameter("rot4dXW",n+t.bass*i*.1)}if(t.mid>.3){const n=this.parameterManager.getParameter("rot4dYW")||0;this.parameterManager.setParameter("rot4dYW",n+t.mid*i*.08)}if(t.high>.3){const n=this.parameterManager.getParameter("rot4dZW")||0;this.parameterManager.setParameter("rot4dZW",n+t.high*i*.06)}}})}updateClick(t){this.clickIntensity=Math.min(1,this.clickIntensity+t),this.visualizers.forEach(e=>{e.triggerClick&&e.triggerClick(t)})}updateScroll(t){if(this.visualizers.forEach(i=>{i.updateScroll&&i.updateScroll(t)}),Math.abs(t)>.1){const i=this.parameterManager.getParameter("morphFactor")||1;this.parameterManager.setParameter("morphFactor",Math.max(.1,i+t*.5))}}destroy(){window.universalReactivity&&window.universalReactivity.disconnectSystem("faceted"),this.animationId&&cancelAnimationFrame(this.animationId),this.visualizers.forEach(t=>{t.destroy&&t.destroy()}),console.log("🔄 VIB34D Engine destroyed")}}export{C as VIB34DIntegratedEngine};

import{P as D}from"./Parameters-DwxYeMJO.js";class L{constructor(e,t,i,o){if(this.canvas=document.getElementById(e),this.role=t,this.reactivity=i,this.variant=o,this.contextOptions={alpha:!0,depth:!0,stencil:!1,antialias:!1,premultipliedAlpha:!0,preserveDrawingBuffer:!1,powerPreference:"high-performance",failIfMajorPerformanceCaveat:!1},this.gl=this.canvas.getContext("webgl2",this.contextOptions)||this.canvas.getContext("webgl",this.contextOptions)||this.canvas.getContext("experimental-webgl",this.contextOptions),this.gl){if(window.mobileDebug){const a=this.gl.getParameter(this.gl.VERSION);window.mobileDebug.log(`✅ ${e}: WebGL context created - ${a}`)}}else{console.error(`WebGL not supported for ${e}`),window.mobileDebug&&window.mobileDebug.log(`❌ ${e}: WebGL context creation failed`),this.showWebGLError();return}this.mouseX=.5,this.mouseY=.5,this.mouseIntensity=0,this.clickIntensity=0,this.startTime=Date.now(),this.params={geometry:0,gridDensity:15,morphFactor:1,chaos:.2,speed:1,hue:200,intensity:.5,saturation:.8,dimension:3.5,rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0},this.init()}async ensureCanvasSizedThenInitWebGL(){let e=this.canvas.getBoundingClientRect();const t=Math.min(window.devicePixelRatio||1,2);e.width===0||e.height===0?await new Promise(i=>{setTimeout(()=>{if(e=this.canvas.getBoundingClientRect(),e.width===0||e.height===0){const o=window.innerWidth,a=window.innerHeight;this.canvas.width=o*t,this.canvas.height=a*t,window.mobileDebug&&window.mobileDebug.log(`📐 Quantum Canvas ${this.canvas.id}: Using viewport fallback ${this.canvas.width}x${this.canvas.height}`)}else this.canvas.width=e.width*t,this.canvas.height=e.height*t,window.mobileDebug&&window.mobileDebug.log(`📐 Quantum Canvas ${this.canvas.id}: Layout ready ${this.canvas.width}x${this.canvas.height}`);i()},100)}):(this.canvas.width=e.width*t,this.canvas.height=e.height*t,window.mobileDebug&&window.mobileDebug.log(`📐 Quantum Canvas ${this.canvas.id}: ${this.canvas.width}x${this.canvas.height} (DPR: ${t})`)),this.createWebGLContext(),this.gl&&this.init()}createWebGLContext(){let e=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl");if(e&&!e.isContextLost()){console.log(`🔄 Reusing existing WebGL context for ${this.canvas.id}`),this.gl=e;return}if(this.gl=this.canvas.getContext("webgl2",this.contextOptions)||this.canvas.getContext("webgl",this.contextOptions)||this.canvas.getContext("experimental-webgl",this.contextOptions),this.gl){if(window.mobileDebug){const t=this.gl.getParameter(this.gl.VERSION);window.mobileDebug.log(`✅ Quantum ${this.canvas.id}: WebGL context created - ${t} (size: ${this.canvas.width}x${this.canvas.height})`)}}else{console.error(`WebGL not supported for ${this.canvas.id}`),window.mobileDebug&&window.mobileDebug.log(`❌ Quantum ${this.canvas.id}: WebGL context creation failed (size: ${this.canvas.width}x${this.canvas.height})`),this.showWebGLError();return}}init(){this.initShaders(),this.initBuffers(),this.resize()}reinitializeContext(){if(console.log(`🔄 Reinitializing WebGL context for ${this.canvas.id}`),this.program=null,this.buffer=null,this.uniforms=null,this.gl=null,this.gl=this.canvas.getContext("webgl2")||this.canvas.getContext("webgl")||this.canvas.getContext("experimental-webgl"),!this.gl)return console.error(`❌ No WebGL context available for ${this.canvas.id} - SmartCanvasPool should have created one`),!1;if(this.gl.isContextLost())return console.error(`❌ WebGL context is lost for ${this.canvas.id}`),!1;try{return this.initShaders(),this.initBuffers(),this.resize(),console.log(`✅ WebGL context reinitialized for ${this.canvas.id}`),!0}catch(e){return console.error(`❌ Failed to reinitialize WebGL resources for ${this.canvas.id}:`,e),!1}}initShaders(){const e=`attribute vec2 a_position;
void main() {
    gl_Position = vec4(a_position, 0.0, 1.0);
}`,t=`
#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif

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
vec3 warpHypersphereCore(vec3 p, int geometryIndex, vec2 mouseDelta) {
    float radius = length(p);
    float morphBlend = clamp(u_morphFactor * 0.6 + (u_dimension - 3.0) * 0.25, 0.0, 2.0);
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

    float morphBlend = clamp(u_morphFactor * 0.8 + (u_dimension - 3.0) * 0.2, 0.0, 2.0);
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

// Complex 3D Lattice Functions - Superior Quantum Shaders
float tetrahedronLattice(vec3 p, float gridSize) {
    vec3 q = fract(p * gridSize) - 0.5;
    float d1 = length(q);
    float d2 = length(q - vec3(0.4, 0.0, 0.0));
    float d3 = length(q - vec3(0.0, 0.4, 0.0));
    float d4 = length(q - vec3(0.0, 0.0, 0.4));
    float vertices = 1.0 - smoothstep(0.0, 0.04, min(min(d1, d2), min(d3, d4)));
    float edges = 0.0;
    edges = max(edges, 1.0 - smoothstep(0.0, 0.02, abs(length(q.xy) - 0.2)));
    edges = max(edges, 1.0 - smoothstep(0.0, 0.02, abs(length(q.yz) - 0.2)));
    edges = max(edges, 1.0 - smoothstep(0.0, 0.02, abs(length(q.xz) - 0.2)));
    return max(vertices, edges * 0.5);
}

float hypercubeLattice(vec3 p, float gridSize) {
    vec3 grid = fract(p * gridSize);
    vec3 edges = min(grid, 1.0 - grid);
    float minEdge = min(min(edges.x, edges.y), edges.z);
    float lattice = 1.0 - smoothstep(0.0, 0.03, minEdge);
    
    vec3 centers = abs(grid - 0.5);
    float maxCenter = max(max(centers.x, centers.y), centers.z);
    float vertices = 1.0 - smoothstep(0.45, 0.5, maxCenter);
    
    return max(lattice * 0.7, vertices);
}

float sphereLattice(vec3 p, float gridSize) {
    vec3 cell = fract(p * gridSize) - 0.5;
    float sphere = 1.0 - smoothstep(0.15, 0.25, length(cell));
    
    float rings = 0.0;
    float ringRadius = length(cell.xy);
    rings = max(rings, 1.0 - smoothstep(0.0, 0.02, abs(ringRadius - 0.3)));
    rings = max(rings, 1.0 - smoothstep(0.0, 0.02, abs(ringRadius - 0.2)));
    
    return max(sphere, rings * 0.6);
}

float torusLattice(vec3 p, float gridSize) {
    vec3 cell = fract(p * gridSize) - 0.5;
    float majorRadius = 0.3;
    float minorRadius = 0.1;
    
    float toroidalDist = length(vec2(length(cell.xy) - majorRadius, cell.z));
    float torus = 1.0 - smoothstep(minorRadius - 0.02, minorRadius + 0.02, toroidalDist);
    
    float rings = 0.0;
    float angle = atan(cell.y, cell.x);
    rings = sin(angle * 8.0) * 0.02;
    
    return max(torus, 0.0) + rings;
}

float kleinLattice(vec3 p, float gridSize) {
    vec3 cell = fract(p * gridSize) - 0.5;
    float u = atan(cell.y, cell.x) / 3.14159 + 1.0;
    float v = cell.z + 0.5;
    
    float x = (2.0 + cos(u * 0.5)) * cos(u);
    float y = (2.0 + cos(u * 0.5)) * sin(u);
    float z = sin(u * 0.5) + v;
    
    vec3 kleinPoint = vec3(x, y, z) * 0.1;
    float dist = length(cell - kleinPoint);
    
    return 1.0 - smoothstep(0.1, 0.15, dist);
}

float fractalLattice(vec3 p, float gridSize) {
    vec3 cell = fract(p * gridSize);
    cell = abs(cell * 2.0 - 1.0);
    
    float dist = length(max(abs(cell) - 0.3, 0.0));
    
    // Recursive subdivision
    for(int i = 0; i < 3; i++) {
        cell = abs(cell * 2.0 - 1.0);
        float subdist = length(max(abs(cell) - 0.3, 0.0)) / pow(2.0, float(i + 1));
        dist = min(dist, subdist);
    }
    
    return 1.0 - smoothstep(0.0, 0.05, dist);
}

float waveLattice(vec3 p, float gridSize) {
    float time = u_time * 0.001 * u_speed;
    vec3 cell = fract(p * gridSize) - 0.5;
    
    float wave1 = sin(p.x * gridSize * 2.0 + time * 2.0);
    float wave2 = sin(p.y * gridSize * 1.8 + time * 1.5);
    float wave3 = sin(p.z * gridSize * 2.2 + time * 1.8);
    
    float interference = (wave1 + wave2 + wave3) / 3.0;
    float amplitude = 1.0 - length(cell) * 2.0;
    
    return max(0.0, interference * amplitude);
}

float crystalLattice(vec3 p, float gridSize) {
    vec3 cell = fract(p * gridSize) - 0.5;
    
    // Octahedral crystal structure
    float crystal = max(max(abs(cell.x) + abs(cell.y), abs(cell.y) + abs(cell.z)), abs(cell.x) + abs(cell.z));
    crystal = 1.0 - smoothstep(0.3, 0.4, crystal);
    
    // Add crystalline faces
    float faces = 0.0;
    faces = max(faces, 1.0 - smoothstep(0.0, 0.02, abs(abs(cell.x) - 0.35)));
    faces = max(faces, 1.0 - smoothstep(0.0, 0.02, abs(abs(cell.y) - 0.35)));
    faces = max(faces, 1.0 - smoothstep(0.0, 0.02, abs(abs(cell.z) - 0.35)));
    
    return max(crystal, faces * 0.5);
}

// Enhanced geometry function with holographic effects (24 GEOMETRIES)
float geometryFunction(vec4 p) {
    // Decode geometry: base = geometry % 8 (supports 24 geometries)
    float totalBase = 8.0;
    float baseGeomFloat = mod(u_geometry, totalBase);
    int geomType = int(clamp(floor(baseGeomFloat + 0.5), 0.0, totalBase - 1.0));

    // Project to 3D and apply polytope warp
    vec3 p3d = project4Dto3D(p);
    vec3 warped = applyCoreWarp(p3d, u_geometry, vec2(0.0, 0.0));
    float gridSize = u_gridDensity * 0.08;
    
    if (geomType == 0) {
        return tetrahedronLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 1) {
        return hypercubeLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 2) {
        return sphereLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 3) {
        return torusLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 4) {
        return kleinLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 5) {
        return fractalLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 6) {
        return waveLattice(warped, gridSize) * u_morphFactor;
    }
    else if (geomType == 7) {
        return crystalLattice(warped, gridSize) * u_morphFactor;
    }
    else {
        return hypercubeLattice(warped, gridSize) * u_morphFactor;
    }
}

// EXTREME LAYER-BY-LAYER COLOR SYSTEM
// Each canvas layer gets completely different color behavior

// Layer-specific color palettes with extreme juxtapositions
vec3 getLayerColorPalette(int layerIndex, float t) {
    if (layerIndex == 0) {
        // BACKGROUND LAYER: Deep space colors - purple/black/deep blue
        vec3 color1 = vec3(0.05, 0.0, 0.2);   // Deep purple
        vec3 color2 = vec3(0.0, 0.0, 0.1);    // Near black
        vec3 color3 = vec3(0.0, 0.05, 0.3);   // Deep blue
        return mix(mix(color1, color2, sin(t * 3.0) * 0.5 + 0.5), color3, cos(t * 2.0) * 0.5 + 0.5);
    }
    else if (layerIndex == 1) {
        // SHADOW LAYER: Toxic greens and sickly yellows - high contrast
        vec3 color1 = vec3(0.0, 1.0, 0.0);    // Pure toxic green
        vec3 color2 = vec3(0.8, 1.0, 0.0);    // Sickly yellow-green
        vec3 color3 = vec3(0.0, 0.8, 0.3);    // Forest green
        return mix(mix(color1, color2, sin(t * 7.0) * 0.5 + 0.5), color3, cos(t * 5.0) * 0.5 + 0.5);
    }
    else if (layerIndex == 2) {
        // CONTENT LAYER: Blazing hot colors - red/orange/white hot
        vec3 color1 = vec3(1.0, 0.0, 0.0);    // Pure red
        vec3 color2 = vec3(1.0, 0.5, 0.0);    // Blazing orange
        vec3 color3 = vec3(1.0, 1.0, 1.0);    // White hot
        return mix(mix(color1, color2, sin(t * 11.0) * 0.5 + 0.5), color3, cos(t * 8.0) * 0.5 + 0.5);
    }
    else if (layerIndex == 3) {
        // HIGHLIGHT LAYER: Electric blues and cyans - crackling energy
        vec3 color1 = vec3(0.0, 1.0, 1.0);    // Electric cyan
        vec3 color2 = vec3(0.0, 0.5, 1.0);    // Electric blue
        vec3 color3 = vec3(0.5, 1.0, 1.0);    // Bright cyan
        return mix(mix(color1, color2, sin(t * 13.0) * 0.5 + 0.5), color3, cos(t * 9.0) * 0.5 + 0.5);
    }
    else {
        // ACCENT LAYER: Violent magentas and purples - chaotic
        vec3 color1 = vec3(1.0, 0.0, 1.0);    // Pure magenta
        vec3 color2 = vec3(0.8, 0.0, 1.0);    // Violet
        vec3 color3 = vec3(1.0, 0.3, 1.0);    // Hot pink
        return mix(mix(color1, color2, sin(t * 17.0) * 0.5 + 0.5), color3, cos(t * 12.0) * 0.5 + 0.5);
    }
}

// Extreme RGB separation and distortion for each layer
vec3 extremeRGBSeparation(vec3 baseColor, vec2 uv, float intensity, int layerIndex) {
    vec2 offset = vec2(0.01, 0.005) * intensity;
    
    // Different separation patterns per layer
    if (layerIndex == 0) {
        // Background: Minimal separation, smooth
        return baseColor + vec3(
            sin(uv.x * 10.0 + u_time * 0.001) * 0.02,
            cos(uv.y * 8.0 + u_time * 0.0015) * 0.02,
            sin(uv.x * uv.y * 6.0 + u_time * 0.0008) * 0.02
        ) * intensity;
    }
    else if (layerIndex == 1) {
        // Shadow: Heavy vertical separation
        float r = baseColor.r + sin(uv.y * 50.0 + u_time * 0.003) * intensity * 0.15;
        float g = baseColor.g + sin((uv.y + 0.1) * 45.0 + u_time * 0.0025) * intensity * 0.12;
        float b = baseColor.b + sin((uv.y - 0.1) * 55.0 + u_time * 0.0035) * intensity * 0.18;
        return vec3(r, g, b);
    }
    else if (layerIndex == 2) {
        // Content: Explosive radial separation
        float dist = length(uv);
        float angle = atan(uv.y, uv.x);
        float r = baseColor.r + sin(dist * 30.0 + angle * 10.0 + u_time * 0.004) * intensity * 0.2;
        float g = baseColor.g + cos(dist * 25.0 + angle * 8.0 + u_time * 0.0035) * intensity * 0.18;
        float b = baseColor.b + sin(dist * 35.0 + angle * 12.0 + u_time * 0.0045) * intensity * 0.22;
        return vec3(r, g, b);
    }
    else if (layerIndex == 3) {
        // Highlight: Lightning-like separation
        float lightning = sin(uv.x * 80.0 + u_time * 0.008) * cos(uv.y * 60.0 + u_time * 0.006);
        float r = baseColor.r + lightning * intensity * 0.25;
        float g = baseColor.g + sin(lightning * 40.0 + u_time * 0.005) * intensity * 0.2;
        float b = baseColor.b + cos(lightning * 30.0 + u_time * 0.007) * intensity * 0.3;
        return vec3(r, g, b);
    }
    else {
        // Accent: Chaotic multi-directional separation
        float chaos1 = sin(uv.x * 100.0 + uv.y * 80.0 + u_time * 0.01);
        float chaos2 = cos(uv.x * 70.0 - uv.y * 90.0 + u_time * 0.008);
        float chaos3 = sin(uv.x * uv.y * 150.0 + u_time * 0.012);
        return baseColor + vec3(chaos1, chaos2, chaos3) * intensity * 0.3;
    }
}

void main() {
    vec2 uv = (gl_FragCoord.xy - u_resolution.xy * 0.5) / min(u_resolution.x, u_resolution.y);
    
    // Enhanced 4D position with holographic depth
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
    
    // Calculate enhanced geometry value
    float value = geometryFunction(pos);
    
    // Enhanced chaos with holographic effects
    float noise = sin(pos.x * 7.0) * cos(pos.y * 11.0) * sin(pos.z * 13.0);
    value += noise * u_chaos;
    
    // Enhanced intensity calculation with holographic glow
    float geometryIntensity = 1.0 - clamp(abs(value * 0.8), 0.0, 1.0);
    geometryIntensity = pow(geometryIntensity, 1.5); // More dramatic falloff
    geometryIntensity += u_clickIntensity * 0.3;
    
    // Holographic shimmer effect
    float shimmer = sin(uv.x * 20.0 + timeSpeed * 5.0) * cos(uv.y * 15.0 + timeSpeed * 3.0) * 0.1;
    geometryIntensity += shimmer * geometryIntensity;
    
    // Apply user intensity control
    float finalIntensity = geometryIntensity * u_intensity;
    
    // Old hemispheric color system completely removed - now using extreme layer-by-layer system
    
    // EXTREME LAYER-BY-LAYER COLOR SYSTEM
    // Determine canvas layer from role/variant (0=background, 1=shadow, 2=content, 3=highlight, 4=accent)
    int layerIndex = 0;
    if (u_roleIntensity == 0.7) layerIndex = 1;      // shadow layer
    else if (u_roleIntensity == 1.0) layerIndex = 2; // content layer  
    else if (u_roleIntensity == 0.85) layerIndex = 3; // highlight layer
    else if (u_roleIntensity == 0.6) layerIndex = 4;  // accent layer
    
    // Get layer-specific base color with extreme dynamics
    // Use u_hue as global intensity modifier (0-1) affecting all layers
    float globalIntensity = u_hue; // Now 0-1 from JavaScript
    float colorTime = timeSpeed * 2.0 + value * 3.0 + globalIntensity * 5.0;
    vec3 layerColor = getLayerColorPalette(layerIndex, colorTime) * (0.5 + globalIntensity * 1.5);
    
    // Apply geometry-based intensity modulation per layer
    vec3 extremeBaseColor;
    if (layerIndex == 0) {
        // Background: Subtle, fills empty space
        extremeBaseColor = layerColor * (0.3 + geometryIntensity * 0.4);
    }
    else if (layerIndex == 1) {
        // Shadow: Aggressive, high contrast where geometry is weak
        float shadowIntensity = pow(1.0 - geometryIntensity, 2.0); // Inverted for shadows
        extremeBaseColor = layerColor * (shadowIntensity * 0.8 + 0.1);
    }
    else if (layerIndex == 2) {
        // Content: Dominant, follows geometry strongly
        extremeBaseColor = layerColor * (geometryIntensity * 1.2 + 0.2);
    }
    else if (layerIndex == 3) {
        // Highlight: Electric, peaks only
        float peakIntensity = pow(geometryIntensity, 3.0); // Cubic for sharp peaks
        extremeBaseColor = layerColor * (peakIntensity * 1.5 + 0.1);
    }
    else {
        // Accent: Chaotic, random bursts
        float randomBurst = sin(value * 50.0 + timeSpeed * 10.0) * 0.5 + 0.5;
        extremeBaseColor = layerColor * (randomBurst * geometryIntensity * 2.0 + 0.05);
    }
    
    // Apply extreme RGB separation per layer
    vec3 extremeColor = extremeRGBSeparation(extremeBaseColor, uv, finalIntensity, layerIndex);
    
    // Layer-specific particle systems with extreme colors
    float extremeParticles = 0.0;
    if (layerIndex == 2 || layerIndex == 3) {
        // Only content and highlight layers get particles
        vec2 particleUV = uv * (layerIndex == 2 ? 12.0 : 20.0);
        vec2 particleID = floor(particleUV);
        vec2 particlePos = fract(particleUV) - 0.5;
        float particleDist = length(particlePos);
        
        float particleTime = timeSpeed * (layerIndex == 2 ? 3.0 : 8.0) + dot(particleID, vec2(127.1, 311.7));
        float particleAlpha = sin(particleTime) * 0.5 + 0.5;
        float particleSize = layerIndex == 2 ? 0.2 : 0.1;
        extremeParticles = (1.0 - smoothstep(0.05, particleSize, particleDist)) * particleAlpha * 0.4;
    }
    
    // Combine extreme color with particles based on layer
    vec3 finalColor;
    if (layerIndex == 0) {
        // Background: Pure extreme color
        finalColor = extremeColor;
    }
    else if (layerIndex == 1) {
        // Shadow: Dark with toxic highlights
        finalColor = extremeColor * 0.8;
    }
    else if (layerIndex == 2) {
        // Content: Blazing with white-hot particles
        finalColor = extremeColor + extremeParticles * vec3(1.0, 1.0, 1.0);
    }
    else if (layerIndex == 3) {
        // Highlight: Electric with cyan particles
        finalColor = extremeColor + extremeParticles * vec3(0.0, 1.0, 1.0);
    }
    else {
        // Accent: Chaotic magenta madness
        finalColor = extremeColor * (1.0 + sin(timeSpeed * 20.0) * 0.3);
    }
    
    // Layer-specific alpha intensity with extreme contrast
    float layerAlpha;
    if (layerIndex == 0) layerAlpha = 0.6;        // Background: Medium
    else if (layerIndex == 1) layerAlpha = 0.4;   // Shadow: Lower
    else if (layerIndex == 2) layerAlpha = 1.0;   // Content: Full intensity
    else if (layerIndex == 3) layerAlpha = 0.8;   // Highlight: High
    else layerAlpha = 0.3;                        // Accent: Subtle bursts
    
    gl_FragColor = vec4(finalColor, finalIntensity * layerAlpha);
}`;this.program=this.createProgram(e,t),this.uniforms={resolution:this.gl.getUniformLocation(this.program,"u_resolution"),time:this.gl.getUniformLocation(this.program,"u_time"),mouse:this.gl.getUniformLocation(this.program,"u_mouse"),geometry:this.gl.getUniformLocation(this.program,"u_geometry"),gridDensity:this.gl.getUniformLocation(this.program,"u_gridDensity"),morphFactor:this.gl.getUniformLocation(this.program,"u_morphFactor"),chaos:this.gl.getUniformLocation(this.program,"u_chaos"),speed:this.gl.getUniformLocation(this.program,"u_speed"),hue:this.gl.getUniformLocation(this.program,"u_hue"),intensity:this.gl.getUniformLocation(this.program,"u_intensity"),saturation:this.gl.getUniformLocation(this.program,"u_saturation"),dimension:this.gl.getUniformLocation(this.program,"u_dimension"),rot4dXY:this.gl.getUniformLocation(this.program,"u_rot4dXY"),rot4dXZ:this.gl.getUniformLocation(this.program,"u_rot4dXZ"),rot4dYZ:this.gl.getUniformLocation(this.program,"u_rot4dYZ"),rot4dXW:this.gl.getUniformLocation(this.program,"u_rot4dXW"),rot4dYW:this.gl.getUniformLocation(this.program,"u_rot4dYW"),rot4dZW:this.gl.getUniformLocation(this.program,"u_rot4dZW"),mouseIntensity:this.gl.getUniformLocation(this.program,"u_mouseIntensity"),clickIntensity:this.gl.getUniformLocation(this.program,"u_mouseIntensity"),roleIntensity:this.gl.getUniformLocation(this.program,"u_roleIntensity")}}createProgram(e,t){var s,r;const i=this.createShader(this.gl.VERTEX_SHADER,e),o=this.createShader(this.gl.FRAGMENT_SHADER,t);if(!i||!o)return null;const a=this.gl.createProgram();if(this.gl.attachShader(a,i),this.gl.attachShader(a,o),this.gl.linkProgram(a),this.gl.getProgramParameter(a,this.gl.LINK_STATUS))window.mobileDebug&&window.mobileDebug.log(`✅ ${(r=this.canvas)==null?void 0:r.id}: Shader program linked successfully`);else{const n=this.gl.getProgramInfoLog(a);return console.error("Program linking failed:",n),window.mobileDebug&&window.mobileDebug.log(`❌ ${(s=this.canvas)==null?void 0:s.id}: Shader program link failed - ${n}`),null}return a}createShader(e,t){var i,o,a,s,r,n;if(!this.gl)return console.error("❌ Cannot create shader: WebGL context is null"),window.mobileDebug&&window.mobileDebug.log(`❌ ${(i=this.canvas)==null?void 0:i.id}: Cannot create shader - WebGL context is null`),null;if(this.gl.isContextLost())return console.error("❌ Cannot create shader: WebGL context is lost"),window.mobileDebug&&window.mobileDebug.log(`❌ ${(o=this.canvas)==null?void 0:o.id}: Cannot create shader - WebGL context is lost`),null;try{const l=this.gl.createShader(e);if(!l)return console.error("❌ Failed to create shader object - WebGL context may be invalid"),window.mobileDebug&&window.mobileDebug.log(`❌ ${(a=this.canvas)==null?void 0:a.id}: Failed to create shader object`),null;if(this.gl.shaderSource(l,t),this.gl.compileShader(l),this.gl.getShaderParameter(l,this.gl.COMPILE_STATUS)){if(window.mobileDebug){const c=e===this.gl.VERTEX_SHADER?"vertex":"fragment";window.mobileDebug.log(`✅ ${(r=this.canvas)==null?void 0:r.id}: ${c} shader compiled successfully`)}}else{const c=this.gl.getShaderInfoLog(l),h=e===this.gl.VERTEX_SHADER?"vertex":"fragment";if(c?console.error(`❌ ${h} shader compilation failed:`,c):console.error(`❌ ${h} shader compilation failed: WebGL returned no error info (context may be invalid)`),console.error("Shader source:",t),window.mobileDebug){const f=c||"No error info (context may be invalid)";window.mobileDebug.log(`❌ ${(s=this.canvas)==null?void 0:s.id}: ${h} shader compile failed - ${f}`);const p=t.split(`
`).slice(0,5).join("\\n");window.mobileDebug.log(`🔍 ${h} shader source start: ${p}...`)}return this.gl.deleteShader(l),null}return l}catch(l){return console.error("❌ Exception during shader creation:",l),window.mobileDebug&&window.mobileDebug.log(`❌ ${(n=this.canvas)==null?void 0:n.id}: Exception during shader creation - ${l.message}`),null}}initBuffers(){const e=new Float32Array([-1,-1,1,-1,-1,1,1,1]);this.buffer=this.gl.createBuffer(),this.gl.bindBuffer(this.gl.ARRAY_BUFFER,this.buffer),this.gl.bufferData(this.gl.ARRAY_BUFFER,e,this.gl.STATIC_DRAW);const t=this.gl.getAttribLocation(this.program,"a_position");this.gl.enableVertexAttribArray(t),this.gl.vertexAttribPointer(t,2,this.gl.FLOAT,!1,0,0)}resize(){var o,a;const e=Math.min(window.devicePixelRatio||1,2),t=this.canvas.clientWidth,i=this.canvas.clientHeight;window.mobileDebug&&(t===0||i===0)&&!this._zeroDimWarned&&(window.mobileDebug.log(`⚠️ ${(o=this.canvas)==null?void 0:o.id}: Canvas clientWidth=${t}, clientHeight=${i} - will be invisible`),this._zeroDimWarned=!0),(this.canvas.width!==t*e||this.canvas.height!==i*e)&&(this.canvas.width=t*e,this.canvas.height=i*e,this.gl.viewport(0,0,this.canvas.width,this.canvas.height),window.mobileDebug&&!this._finalSizeLogged&&(window.mobileDebug.log(`📐 ${(a=this.canvas)==null?void 0:a.id}: Final canvas buffer ${this.canvas.width}x${this.canvas.height} (DPR=${e})`),this._finalSizeLogged=!0))}showWebGLError(){if(!this.canvas)return;const e=this.canvas.getContext("2d");e&&(e.fillStyle="#000",e.fillRect(0,0,this.canvas.width,this.canvas.height),e.fillStyle="#64ff96",e.font="16px Orbitron, monospace",e.textAlign="center",e.fillText("WebGL Required",this.canvas.width/2,this.canvas.height/2),e.fillStyle="#888",e.font="12px Orbitron, monospace",e.fillText("Please enable WebGL in your browser",this.canvas.width/2,this.canvas.height/2+25))}updateParameters(e){this.params={...this.params,...e}}updateInteraction(e,t,i){this.mouseX=e,this.mouseY=t,this.mouseIntensity=i}render(){var r,n;if(!this.program){window.mobileDebug&&!this._noProgramWarned&&(window.mobileDebug.log(`❌ ${(r=this.canvas)==null?void 0:r.id}: No WebGL program for render`),this._noProgramWarned=!0);return}this.resize(),this.gl.useProgram(this.program),this.gl.clearColor(0,0,0,0),this.gl.clear(this.gl.COLOR_BUFFER_BIT),this._renderParamsLogged||(console.log(`[Mobile] ${(n=this.canvas)==null?void 0:n.id}: Render params - geometry=${this.params.geometry}, gridDensity=${this.params.gridDensity}, intensity=${this.params.intensity}`),this._renderParamsLogged=!0);const e={background:.4,shadow:.6,content:1,highlight:1.3,accent:1.6},t=Date.now()-this.startTime;this.gl.uniform2f(this.uniforms.resolution,this.canvas.width,this.canvas.height),this.gl.uniform1f(this.uniforms.time,t),this.gl.uniform2f(this.uniforms.mouse,this.mouseX,this.mouseY),this.gl.uniform1f(this.uniforms.geometry,this.params.geometry);let i=this.params.gridDensity,o=this.params.morphFactor,a=this.params.hue,s=this.params.chaos;window.audioEnabled&&window.audioReactive&&(i+=window.audioReactive.bass*40,o+=window.audioReactive.mid*1.2,a+=window.audioReactive.high*120,s+=window.audioReactive.energy*.6,Date.now()%1e4<16&&console.log(`🌌 Quantum audio reactivity: Density+${(window.audioReactive.bass*40).toFixed(1)} Morph+${(window.audioReactive.mid*1.2).toFixed(2)} Hue+${(window.audioReactive.high*120).toFixed(1)} Chaos+${(window.audioReactive.energy*.6).toFixed(2)}`)),this.gl.uniform1f(this.uniforms.gridDensity,Math.min(100,i)),this.gl.uniform1f(this.uniforms.morphFactor,Math.min(2,o)),this.gl.uniform1f(this.uniforms.chaos,Math.min(1,s)),this.gl.uniform1f(this.uniforms.speed,this.params.speed),this.gl.uniform1f(this.uniforms.hue,a%360/360),this.gl.uniform1f(this.uniforms.intensity,this.params.intensity),this.gl.uniform1f(this.uniforms.saturation,this.params.saturation),this.gl.uniform1f(this.uniforms.dimension,this.params.dimension),this.gl.uniform1f(this.uniforms.rot4dXY,this.params.rot4dXY||0),this.gl.uniform1f(this.uniforms.rot4dXZ,this.params.rot4dXZ||0),this.gl.uniform1f(this.uniforms.rot4dYZ,this.params.rot4dYZ||0),this.gl.uniform1f(this.uniforms.rot4dXW,this.params.rot4dXW||0),this.gl.uniform1f(this.uniforms.rot4dYW,this.params.rot4dYW||0),this.gl.uniform1f(this.uniforms.rot4dZW,this.params.rot4dZW||0),this.gl.uniform1f(this.uniforms.mouseIntensity,this.mouseIntensity),this.gl.uniform1f(this.uniforms.clickIntensity,this.clickIntensity),this.gl.uniform1f(this.uniforms.roleIntensity,e[this.role]||1),this.gl.drawArrays(this.gl.TRIANGLE_STRIP,0,4)}destroy(){this.gl&&this.program&&this.gl.deleteProgram(this.program),this.gl&&this.buffer&&this.gl.deleteBuffer(this.buffer)}}class P{constructor(){console.log("🔮 Initializing VIB34D Quantum Engine..."),this.visualizers=[],this.parameters=new D,this.isActive=!1,this.useBuiltInReactivity=!window.reactivityManager,this.lastMousePosition={x:.5,y:.5},this.mouseVelocity={x:0,y:0},this.velocityHistory=[],this.maxVelocityHistory=10,this.baseHue=280,this.baseMorphFactor=1,this.parameters.setParameter("hue",this.baseHue),this.parameters.setParameter("intensity",.7),this.parameters.setParameter("saturation",.9),this.parameters.setParameter("gridDensity",20),this.parameters.setParameter("morphFactor",this.baseMorphFactor),this.init()}init(){this.createVisualizers(),this.setupAudioReactivity(),this.setupGestureVelocityReactivity(),this.startRenderLoop(),console.log("✨ Quantum Engine initialized with audio + gesture velocity reactivity")}createVisualizers(){[{id:"quantum-background-canvas",role:"background",reactivity:.4},{id:"quantum-shadow-canvas",role:"shadow",reactivity:.6},{id:"quantum-content-canvas",role:"content",reactivity:1},{id:"quantum-highlight-canvas",role:"highlight",reactivity:1.3},{id:"quantum-accent-canvas",role:"accent",reactivity:1.6}].forEach(t=>{try{if(!document.getElementById(t.id)){console.warn(`⚠️ Canvas ${t.id} not found in DOM - skipping`);return}const o=new L(t.id,t.role,t.reactivity,0);o.gl?(this.visualizers.push(o),console.log(`🌌 Created quantum layer: ${t.role}`)):console.warn(`⚠️ No WebGL context for quantum layer ${t.id}`)}catch(i){console.warn(`Failed to create quantum layer ${t.id}:`,i)}}),console.log(`✅ Created ${this.visualizers.length} quantum visualizers with enhanced effects`)}setActive(e){if(this.isActive=e,e){const t=document.getElementById("quantumLayers");t&&(t.style.display="block"),window.audioEnabled&&!this.audioEnabled&&this.enableAudio(),console.log("🔮 Quantum System ACTIVATED - Audio frequency reactivity mode")}else{const t=document.getElementById("quantumLayers");t&&(t.style.display="none"),console.log("🔮 Quantum System DEACTIVATED")}}toggleAudio(e){e&&this.isActive&&!this.audioEnabled?this.enableAudio():!e&&this.audioEnabled&&(this.audioEnabled=!1,this.audioContext&&(this.audioContext.close(),this.audioContext=null),console.log("🔇 Quantum audio reactivity disabled"))}setupAudioReactivity(){console.log("🌌 Setting up Quantum audio frequency reactivity")}setupGestureVelocityReactivity(){if(!this.useBuiltInReactivity){console.log("🌌 Quantum built-in reactivity DISABLED - ReactivityManager active");return}console.log("🌌 Setting up Quantum: velocity + click + scroll + multi-parameter reactivity"),this.clickFlashIntensity=0,this.scrollMorph=1,this.velocitySmoothing=.8,["quantum-background-canvas","quantum-shadow-canvas","quantum-content-canvas","quantum-highlight-canvas","quantum-accent-canvas"].forEach(t=>{const i=document.getElementById(t);i&&(i.addEventListener("mousemove",o=>{if(!this.isActive)return;const a=i.getBoundingClientRect(),s=(o.clientX-a.left)/a.width,r=(o.clientY-a.top)/a.height;this.updateEnhancedQuantumParameters(s,r)}),i.addEventListener("touchmove",o=>{if(this.isActive&&(o.preventDefault(),o.touches.length>0)){const a=o.touches[0],s=i.getBoundingClientRect(),r=(a.clientX-s.left)/s.width,n=(a.clientY-s.top)/s.height;this.updateEnhancedQuantumParameters(r,n)}},{passive:!1}),i.addEventListener("click",o=>{this.isActive&&this.triggerQuantumClick()}),i.addEventListener("touchend",o=>{this.isActive&&this.triggerQuantumClick()}),i.addEventListener("wheel",o=>{this.isActive&&(o.preventDefault(),this.updateQuantumScroll(o.deltaY))},{passive:!1}))}),this.startQuantumEffectLoops()}updateEnhancedQuantumParameters(e,t){const i=e-this.lastMousePosition.x,o=t-this.lastMousePosition.y,a=Math.sqrt(i*i+o*o);this.velocityHistory.push(a),this.velocityHistory.length>5&&this.velocityHistory.shift();const s=this.velocityHistory.reduce((I,S)=>I+S,0)/this.velocityHistory.length,r=(e-.5)*Math.PI*2,n=r*.5,l=r*.3,c=r*.2,h=10+t*90,w=Math.sqrt(Math.pow(e-.5,2)+Math.pow(t-.5,2)),g=Math.min(1,w*Math.sqrt(2)),d=e<.5,m=t<.5;let u;d&&m?u=240:!d&&m?u=300:d&&!m?u=180:u=320;const b=g*60,y=(u+b)%360,x=Math.min(1,s*30),_=.5+Math.min(2.5,s*15),C=.3+g*.7;window.updateParameter&&(window.updateParameter("rot4dXW",n.toFixed(3)),window.updateParameter("rot4dYW",l.toFixed(3)),window.updateParameter("rot4dZW",c.toFixed(3)),window.updateParameter("chaos",x.toFixed(2)),window.updateParameter("speed",_.toFixed(2)),window.updateParameter("gridDensity",Math.round(h)),window.updateParameter("intensity",C.toFixed(2)),window.updateParameter("hue",Math.round(y))),this.lastMousePosition.x=e,this.lastMousePosition.y=t,console.log(`🌌 Quantum EXPERIMENTAL: X=${e.toFixed(2)}→Rot=${r.toFixed(2)}, Y=${t.toFixed(2)}→Density=${Math.round(h)}, Dist=${g.toFixed(2)}→Hue=${Math.round(y)}, Hemisphere=${d?"L":"R"}${m?"T":"B"}`)}triggerQuantumClick(){this.clickFlashIntensity=1,this.quantumChaosBlast=.7,this.quantumSpeedWave=2,this.quantumHueShift=60,console.log("💥 Quantum energy burst: flash + chaos + speed + hue explosion")}updateQuantumScroll(e){const i=e>0?1:-1;this.scrollMorph+=i*.02,this.scrollMorph=Math.max(.2,Math.min(2,this.scrollMorph)),window.updateParameter&&window.updateParameter("morphFactor",this.scrollMorph.toFixed(2)),console.log(`🌀 Quantum scroll morph: ${this.scrollMorph.toFixed(2)}`)}startQuantumEffectLoops(){const e=()=>{if(this.clickFlashIntensity>.01){const t=.9+this.clickFlashIntensity*.1,i=this.scrollMorph+this.clickFlashIntensity*.5;window.updateParameter&&(window.updateParameter("saturation",t.toFixed(2)),window.updateParameter("morphFactor",i.toFixed(2))),this.clickFlashIntensity*=.91}if(this.quantumChaosBlast>.01){const i=.3+this.quantumChaosBlast;window.updateParameter&&window.updateParameter("chaos",Math.min(1,i).toFixed(2)),this.quantumChaosBlast*=.88}if(this.quantumSpeedWave>.01){const i=1+this.quantumSpeedWave;window.updateParameter&&window.updateParameter("speed",Math.min(3,i).toFixed(2)),this.quantumSpeedWave*=.89}if(this.quantumHueShift>1){const i=(280+this.quantumHueShift)%360;window.updateParameter&&window.updateParameter("hue",Math.round(i)),this.quantumHueShift*=.9}this.isActive&&requestAnimationFrame(e)};e()}async enableAudio(){if(!this.audioEnabled)try{const e=await navigator.mediaDevices.getUserMedia({audio:!0});this.audioContext=new(window.AudioContext||window.webkitAudioContext),this.analyser=this.audioContext.createAnalyser(),this.analyser.fftSize=256,this.analyser.smoothingTimeConstant=.8,this.frequencyData=new Uint8Array(this.analyser.frequencyBinCount),this.audioContext.createMediaStreamSource(e).connect(this.analyser),this.audioEnabled=!0,console.log("🎵 Quantum audio reactivity enabled")}catch(e){console.error("❌ Failed to enable Quantum audio:",e),this.audioEnabled=!1}}updateParameter(e,t){this.parameters.setParameter(e,t),this.visualizers.forEach(i=>{if(i.updateParameters){const o={};o[e]=t,i.updateParameters(o)}else i.params&&(i.params[e]=t,i.render&&i.render())}),console.log(`🔮 Updated quantum ${e}: ${t}`)}updateParameters(e){Object.keys(e).forEach(t=>{this.updateParameter(t,e[t])})}updateInteraction(e,t,i){this.visualizers.forEach(o=>{o.updateInteraction&&o.updateInteraction(e,t,i)})}getParameters(){return this.parameters.getAllParameters()}setParameters(e){Object.keys(e).forEach(t=>{this.parameters.setParameter(t,e[t])}),this.updateParameters(e)}startRenderLoop(){var t;window.mobileDebug&&window.mobileDebug.log(`🎬 Quantum Engine: Starting render loop with ${(t=this.visualizers)==null?void 0:t.length} visualizers, isActive=${this.isActive}`);const e=()=>{var i;if(this.isActive){const o=this.parameters.getAllParameters();this.visualizers.forEach(a=>{a.updateParameters&&a.render&&(a.updateParameters(o),a.render())}),window.mobileDebug&&!this._renderActivityLogged&&(window.mobileDebug.log(`🎬 Quantum Engine: Actively rendering ${(i=this.visualizers)==null?void 0:i.length} visualizers`),this._renderActivityLogged=!0)}else window.mobileDebug&&!this._inactiveWarningLogged&&(window.mobileDebug.log("⚠️ Quantum Engine: Not rendering because isActive=false"),this._inactiveWarningLogged=!0);requestAnimationFrame(e)};e(),console.log("🎬 Quantum render loop started"),window.mobileDebug&&window.mobileDebug.log("✅ Quantum Engine: Render loop started, will render when isActive=true")}updateClick(e){this.visualizers.forEach(t=>{t.triggerClick&&t.triggerClick(.5,.5,e)})}updateScroll(e){this.visualizers.forEach(t=>{t.updateScroll&&t.updateScroll(e)})}destroy(){window.universalReactivity&&window.universalReactivity.disconnectSystem("quantum"),this.visualizers.forEach(e=>{e.destroy&&e.destroy()}),this.visualizers=[],console.log("🧹 Quantum Engine destroyed")}}export{P as QuantumEngine};

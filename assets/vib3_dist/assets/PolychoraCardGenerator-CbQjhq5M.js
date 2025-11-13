class l{constructor(e){this.systemName=e,this.canvasCount=0}async generateCard(e,o){try{const t=this.getSystemShaders(),r=this.getSystemStyles(),a=this.generateSystemContent(o),s=this.buildHTML({format:e,parameters:o,shaders:t,styles:r,content:a}),i=this.generateFilename(e,o);return this.downloadFile(i,s),{success:!0,filename:i,system:this.systemName}}catch(t){return console.error(`❌ ${this.systemName} card generation failed:`,t),{success:!1,error:t.message,system:this.systemName}}}buildHTML({format:e,parameters:o,shaders:t,styles:r,content:a}){const s=new Date().toISOString().replace(/[:.]/g,"-");return`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${this.systemName.toUpperCase()} Trading Card</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        ${this.getBaseStyles()}
        ${r}
    </style>
</head>
<body>
    <div class="card-container">
        <div class="card-header">
            <div class="system-badge ${this.systemName.toLowerCase()}">${this.systemName.toUpperCase()}</div>
            <div class="card-title">${this.getCardTitle(o)}</div>
        </div>
        
        <div class="visualization-area">
            ${a}
        </div>
        
        <div class="card-footer">
            <div class="parameters">
                ${this.formatParameters(o)}
            </div>
            <div class="signature">
                VIB34D Engine • ${s}
            </div>
        </div>
    </div>
    
    <script>
        ${t.vertex?`const vertexShaderSource = \`${t.vertex}\`;`:""}
        ${t.fragment?`const fragmentShaderSource = \`${t.fragment}\`;`:""}
        
        // System-specific initialization
        ${this.getSystemJavaScript()}
        
        // Start visualization
        window.addEventListener('load', () => {
            try {
                initializeCard(${JSON.stringify(o)});
            } catch (error) {
                console.error('Card initialization failed:', error);
                document.querySelector('.visualization-area').innerHTML = 
                    '<div style="color: #ff0000; text-align: center; padding: 50px;">Visualization failed to load</div>';
            }
        });
    <\/script>
</body>
</html>`}getBaseStyles(){return`
            * { margin: 0; padding: 0; box-sizing: border-box; }
            
            body {
                background: #000;
                color: #fff;
                font-family: 'Orbitron', monospace;
                overflow: hidden;
            }
            
            .card-container {
                width: 100vw;
                height: 100vh;
                display: flex;
                flex-direction: column;
                background: radial-gradient(ellipse at center, #1a0033 0%, #000000 70%);
            }
            
            .card-header {
                padding: 20px;
                background: rgba(0, 0, 0, 0.8);
                border-bottom: 2px solid rgba(0, 255, 255, 0.5);
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
            }
            
            .system-badge {
                padding: 8px 16px;
                border-radius: 12px;
                font-weight: 700;
                font-size: 0.9rem;
                text-shadow: 0 0 10px currentColor;
            }
            
            .system-badge.faceted {
                background: rgba(0, 255, 255, 0.2);
                border: 2px solid #00ffff;
                color: #00ffff;
            }
            
            .system-badge.quantum {
                background: rgba(0, 255, 255, 0.2);
                border: 2px solid #00ffff;
                color: #00ffff;
            }
            
            .system-badge.holographic {
                background: rgba(255, 100, 255, 0.2);
                border: 2px solid #ff64ff;
                color: #ff64ff;
            }
            
            .system-badge.polychora {
                background: rgba(255, 150, 0, 0.2);
                border: 2px solid #ff9600;
                color: #ff9600;
            }
            
            .card-title {
                font-size: 1.4rem;
                font-weight: 700;
                text-shadow: 0 0 15px rgba(255, 255, 255, 0.5);
            }
            
            .visualization-area {
                flex: 1;
                position: relative;
                overflow: hidden;
            }
            
            .card-footer {
                padding: 15px 20px;
                background: rgba(0, 0, 0, 0.9);
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-size: 0.8rem;
            }
            
            .parameters {
                color: rgba(255, 255, 255, 0.8);
                line-height: 1.4;
            }
            
            .signature {
                color: rgba(0, 255, 255, 0.7);
                font-weight: 400;
                font-size: 0.7rem;
            }
            
            canvas {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
            }
        `}generateFilename(e,o){const t=new Date().toISOString().replace(/[:.]/g,"-"),r=this.getGeometryName(o);return`vib34d-card-${this.systemName.toLowerCase()}-${r.toLowerCase().replace(/\s+/g,"-")}-${t}.html`}formatParameters(e){return Object.entries(e).filter(([t,r])=>!["system","hideui"].includes(t)).slice(0,4).map(([t,r])=>`${t}: ${typeof r=="number"?r.toFixed(1):r}`).join(" • ")||"Default parameters"}downloadFile(e,o){const t=new Blob([o],{type:"text/html"}),r=URL.createObjectURL(t),a=document.createElement("a");a.href=r,a.download=e,document.body.appendChild(a),a.click(),document.body.removeChild(a),URL.revokeObjectURL(r)}getSystemShaders(){throw new Error(`${this.systemName} must implement getSystemShaders()`)}getSystemStyles(){throw new Error(`${this.systemName} must implement getSystemStyles()`)}generateSystemContent(e){throw new Error(`${this.systemName} must implement generateSystemContent()`)}getSystemJavaScript(){throw new Error(`${this.systemName} must implement getSystemJavaScript()`)}getCardTitle(e){return`${this.systemName.toUpperCase()} ${this.getGeometryName(e)}`}getGeometryName(e){const o=["TETRAHEDRON","HYPERCUBE","SPHERE","TORUS","KLEIN BOTTLE","FRACTAL","WAVE","CRYSTAL"],t=e.geometry||e.geometryType||0;return o[t]||"GEOMETRY"}}class c extends l{constructor(){super("Polychora")}getSystemShaders(){return{vertex:`
                attribute vec2 a_position;
                void main() {
                    gl_Position = vec4(a_position, 0.0, 1.0);
                }
            `,fragment:`
                precision highp float;
                
                uniform vec2 u_resolution;
                uniform float u_time;
                uniform float u_geometry;
                uniform float u_gridDensity;
                uniform float u_hue;
                uniform float u_intensity;
                uniform float u_morphFactor;
                uniform float u_chaos;
                uniform float u_rot4dXW;
                uniform float u_rot4dYW;
                uniform float u_rot4dZW;
                
                // 4D rotation matrices for polytopes
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
                
                // 4D to 3D projection with perspective
                vec3 project4Dto3D(vec4 p) {
                    float perspective = 3.0 / (3.0 + p.w);
                    return vec3(p.x * perspective, p.y * perspective, p.z * perspective);
                }
                
                // 4D polytope distance functions
                float polytope5Cell(vec4 p) {
                    // 5-cell (4D tetrahedron)
                    vec4 a = vec4(1.0, 1.0, 1.0, -1.0/sqrt(5.0));
                    vec4 b = vec4(1.0, -1.0, -1.0, -1.0/sqrt(5.0));
                    vec4 c = vec4(-1.0, 1.0, -1.0, -1.0/sqrt(5.0));
                    vec4 d = vec4(-1.0, -1.0, 1.0, -1.0/sqrt(5.0));
                    vec4 e = vec4(0.0, 0.0, 0.0, sqrt(5.0)/sqrt(5.0));
                    
                    float d1 = length(p - a);
                    float d2 = length(p - b);
                    float d3 = length(p - c);
                    float d4 = length(p - d);
                    float d5 = length(p - e);
                    
                    return min(min(min(d1, d2), min(d3, d4)), d5);
                }
                
                float polytopeTesseract(vec4 p) {
                    // 8-cell (tesseract)
                    vec4 q = abs(p);
                    return max(max(q.x, q.y), max(q.z, q.w)) - 1.0;
                }
                
                float polytope16Cell(vec4 p) {
                    // 16-cell (hyperoctahedron)
                    return abs(p.x) + abs(p.y) + abs(p.z) + abs(p.w) - 1.0;
                }
                
                float getPolytope(vec4 p, float polytypeType) {
                    int polyType = int(mod(polytypeType, 6.0));
                    
                    if (polyType == 0) return polytope5Cell(p);
                    else if (polyType == 1) return polytopeTesseract(p);
                    else if (polyType == 2) return polytope16Cell(p);
                    else if (polyType == 3) return polytope5Cell(p * 1.2); // 24-cell approximation
                    else if (polyType == 4) return polytope16Cell(p * 0.8); // 600-cell approximation
                    else return polytopeTesseract(p * 0.6); // 120-cell approximation
                }
                
                vec3 hsv2rgb(vec3 c) {
                    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                }
                
                void main() {
                    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
                    float aspectRatio = u_resolution.x / u_resolution.y;
                    uv.x *= aspectRatio;
                    uv -= 0.5;
                    
                    float time = u_time * 0.0006;
                    
                    // 4D point in space
                    vec4 p4d = vec4(uv * u_gridDensity * 0.1, 
                                   sin(time * 0.7) * 0.3, 
                                   cos(time * 0.5) * 0.25);
                    
                    // Apply 4D rotations
                    p4d = rotateXW(u_rot4dXW + time * 0.3) * p4d;
                    p4d = rotateYW(u_rot4dYW + time * 0.4) * p4d;
                    p4d = rotateZW(u_rot4dZW + time * 0.5) * p4d;
                    
                    // Apply morphing
                    p4d += vec4(sin(p4d.yxz * 5.0 + time) * u_morphFactor * 0.1, 0.0);
                    
                    // Get polytope distance
                    float dist = getPolytope(p4d, u_geometry);
                    
                    // Create glassmorphic effect
                    float edge = 1.0 - smoothstep(0.0, 0.1, abs(dist));
                    float interior = 1.0 - smoothstep(0.0, 0.3, abs(dist + 0.2));
                    
                    // Project to 3D for additional effects
                    vec3 p3d = project4Dto3D(p4d);
                    
                    // Glass refraction simulation
                    vec2 refraction = uv + normalize(p3d.xy) * edge * 0.02;
                    
                    // Color composition
                    vec3 baseColor = hsv2rgb(vec3(u_hue / 360.0, 0.7, u_intensity));
                    vec3 glassColor = hsv2rgb(vec3((u_hue + 30.0) / 360.0, 0.4, u_intensity * 0.8));
                    
                    vec3 color = mix(glassColor * interior * 0.3, baseColor * edge, edge);
                    
                    // Add glassmorphic highlights
                    float highlight = pow(edge, 3.0) * u_intensity;
                    color += vec3(highlight) * 0.5;
                    
                    // Chaos as glass distortion
                    float distortion = sin(length(uv) * 20.0 + time * 2.0) * u_chaos * 0.1;
                    color += vec3(distortion) * baseColor * 0.3;
                    
                    // Depth fade for 4D effect
                    float depth = 1.0 - length(p4d) * 0.2;
                    color *= (0.5 + depth * 0.5);
                    
                    gl_FragColor = vec4(color, 0.9);
                }
            `}}getSystemStyles(){return`
            .visualization-area {
                border: 2px solid rgba(255, 150, 0, 0.4);
                box-shadow: 
                    0 0 30px rgba(255, 150, 0, 0.3),
                    inset 0 0 20px rgba(255, 150, 0, 0.1);
                background: rgba(255, 150, 0, 0.02);
                backdrop-filter: blur(5px);
            }
            
            .card-title {
                color: #ff9600;
                text-shadow: 0 0 20px rgba(255, 150, 0, 0.8);
            }
            
            .system-badge.polychora {
                box-shadow: 0 0 15px rgba(255, 150, 0, 0.5);
                animation: polytope-glow 3s ease-in-out infinite alternate;
            }
            
            @keyframes polytope-glow {
                from { 
                    box-shadow: 0 0 15px rgba(255, 150, 0, 0.5);
                    transform: rotateY(0deg);
                }
                to { 
                    box-shadow: 0 0 25px rgba(255, 150, 0, 0.8);
                    transform: rotateY(5deg);
                }
            }
        `}generateSystemContent(e){return'<canvas id="polychora-canvas"></canvas>'}getSystemJavaScript(){return`
            function initializeCard(params) {
                const canvas = document.getElementById('polychora-canvas');
                const gl = canvas.getContext('webgl');
                
                if (!gl) {
                    throw new Error('WebGL not supported');
                }
                
                // Resize canvas
                function resize() {
                    canvas.width = canvas.clientWidth;
                    canvas.height = canvas.clientHeight;
                    gl.viewport(0, 0, canvas.width, canvas.height);
                }
                window.addEventListener('resize', resize);
                resize();
                
                // Create shader program
                function createShader(type, source) {
                    const shader = gl.createShader(type);
                    gl.shaderSource(shader, source);
                    gl.compileShader(shader);
                    
                    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                        console.error('Shader compile error:', gl.getShaderInfoLog(shader));
                        gl.deleteShader(shader);
                        return null;
                    }
                    return shader;
                }
                
                const vertexShader = createShader(gl.VERTEX_SHADER, vertexShaderSource);
                const fragmentShader = createShader(gl.FRAGMENT_SHADER, fragmentShaderSource);
                
                const program = gl.createProgram();
                gl.attachShader(program, vertexShader);
                gl.attachShader(program, fragmentShader);
                gl.linkProgram(program);
                
                if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
                    console.error('Program link error:', gl.getProgramInfoLog(program));
                    return;
                }
                
                // Set up buffers
                const positions = new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]);
                const positionBuffer = gl.createBuffer();
                gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
                gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);
                
                const positionLocation = gl.getAttribLocation(program, 'a_position');
                gl.enableVertexAttribArray(positionLocation);
                gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);
                
                // Get uniform locations
                const uniforms = {
                    resolution: gl.getUniformLocation(program, 'u_resolution'),
                    time: gl.getUniformLocation(program, 'u_time'),
                    geometry: gl.getUniformLocation(program, 'u_geometry'),
                    gridDensity: gl.getUniformLocation(program, 'u_gridDensity'),
                    hue: gl.getUniformLocation(program, 'u_hue'),
                    intensity: gl.getUniformLocation(program, 'u_intensity'),
                    morphFactor: gl.getUniformLocation(program, 'u_morphFactor'),
                    chaos: gl.getUniformLocation(program, 'u_chaos'),
                    rot4dXW: gl.getUniformLocation(program, 'u_rot4dXW'),
                    rot4dYW: gl.getUniformLocation(program, 'u_rot4dYW'),
                    rot4dZW: gl.getUniformLocation(program, 'u_rot4dZW')
                };
                
                // Animation loop
                const startTime = Date.now();
                
                function render() {
                    const time = Date.now() - startTime;
                    
                    gl.useProgram(program);
                    
                    // Set uniforms (optimized for 4D polytopes)
                    gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);
                    gl.uniform1f(uniforms.time, time);
                    gl.uniform1f(uniforms.geometry, parseFloat(params.polytope) || parseFloat(params.geometry) || 0);
                    gl.uniform1f(uniforms.gridDensity, parseFloat(params.gridDensity) || 15);
                    gl.uniform1f(uniforms.hue, parseFloat(params.hue) || 30); // Default orange
                    gl.uniform1f(uniforms.intensity, parseFloat(params.intensity) || 0.6);
                    gl.uniform1f(uniforms.morphFactor, parseFloat(params.morphFactor) || 1.0);
                    gl.uniform1f(uniforms.chaos, parseFloat(params.chaos) || 0.1); // Lower chaos for mathematical precision
                    gl.uniform1f(uniforms.rot4dXW, parseFloat(params.rot4dXW) || 0);
                    gl.uniform1f(uniforms.rot4dYW, parseFloat(params.rot4dYW) || 0);
                    gl.uniform1f(uniforms.rot4dZW, parseFloat(params.rot4dZW) || 0);
                    
                    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
                    
                    requestAnimationFrame(render);
                }
                
                render();
                console.log('✅ Polychora trading card initialized');
            }
        `}getCardTitle(e){const o=["5-CELL","TESSERACT","16-CELL","24-CELL","600-CELL","120-CELL"],t=e.polytope||e.geometry||0;return`${o[t]||"4D-POLYTOPE"} GLASSMORPHIC`}getGeometryName(e){const o=["5-CELL","TESSERACT","16-CELL","24-CELL","600-CELL","120-CELL"],t=e.polytope||e.geometry||0;return o[t]||"4D-POLYTOPE"}}export{c as PolychoraCardGenerator,c as default};

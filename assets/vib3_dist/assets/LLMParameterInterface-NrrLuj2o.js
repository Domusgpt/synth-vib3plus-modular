class h{constructor(){this.useFirebase=!0,this.firebaseUrl="https://us-central1-vib34d-llm-engine.cloudfunctions.net/generateVIB34DParameters",this.apiKey=localStorage.getItem("vib34d-gemini-api-key")||null,this.baseApiUrl="https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",this.parameterCallback=null,this.systemPrompt=`You are a synesthetic AI that translates human experience into 4-dimensional holographic mathematics.

You control a VIB34D system with these parameters:
- geometry (0-7): Tetrahedron, Hypercube, Sphere, Torus, Klein Bottle, Fractal, Wave, Crystal
- hue (0-360), intensity (0-1), saturation (0-1)
- speed (0.1-3), chaos (0-1), morphFactor (0-2), gridDensity (5-100)
- rot4dXW, rot4dYW, rot4dZW (-6.28 to 6.28)

When given a description, use your understanding of:
- Visual aesthetics and emotional resonance
- Color theory and psychological associations
- Movement, rhythm, and temporal dynamics
- Mathematical beauty and complexity
- Human perception and synesthesia

Create a holographic experience that captures the essence of what they're describing.

Think beyond literal interpretation. If someone says "the sound of silence," you might create subtle, barely-there patterns with minimal chaos and low intensity. If they say "cosmic loneliness," you might use vast empty spaces with occasional fractal details.

Your goal is to create something that makes them say "YES, that's exactly what I meant, even though I couldn't have described it mathematically."

Return only JSON with the parameter names above.`}async initialize(){const e=localStorage.getItem("vib34d-gemini-api-key");return e?(this.apiKey=e,console.log("🔑 Gemini API key loaded from storage"),!0):(console.log("📝 Gemini API key will be requested on first use"),!1)}setApiKey(e){this.apiKey=e,localStorage.setItem("vib34d-gemini-api-key",e),console.log("🔑 Gemini API key saved")}setParameterCallback(e){this.parameterCallback=e}async generateParameters(e){if(this.useFirebase)try{return console.log("🔥 Trying Firebase Function first..."),await this.generateViaFirebase(e)}catch(a){console.warn("🔥 Firebase Function failed, falling back to direct API:",a.message),this.useFirebase=!1}console.log("🔍 Using direct API approach..."),console.log("🔍 Checking API key:",this.apiKey?`${this.apiKey.substring(0,10)}...`:"NOT SET");const r=this.apiKey&&this.apiKey.startsWith("AIza")&&this.apiKey.length>30;if(console.log("🔍 API key valid:",r),r)try{const a=`${this.baseApiUrl}?key=${this.apiKey}`;console.log("🤖 Making API request to:",a);const t=await fetch(a,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({contents:[{parts:[{text:`${this.systemPrompt}

User description: "${e}"

Generate JSON parameters:`}]}],generationConfig:{temperature:.7,maxOutputTokens:500,topP:.8,topK:40}})});if(console.log("🤖 API response status:",t.status),console.log("🤖 API response ok:",t.ok),t.ok){const s=await t.json();console.log("🤖 API response data:",s);const n=s.candidates[0].content.parts[0].text.match(/\{[\s\S]*\}/);if(n){const l=JSON.parse(n[0]),i=this.validateParameters(l);return console.log("🤖 Generated parameters via Gemini API:",i),this.parameterCallback&&this.parameterCallback(i),i}}else{const s=await t.text();throw console.error("🤖 API request failed:",t.status,s),new Error(`API request failed: ${t.status} - ${s}`)}}catch(a){throw console.error("🤖 API request error:",a),a}throw this.apiKey?new Error("API request failed. Please check your API key or network connection."):new Error("No API key set. Please enter your Gemini API key to use AI generation.")}async generateViaFirebase(e){const r=await fetch(this.firebaseUrl,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({description:e.trim()})});if(!r.ok){const s=await r.json().catch(()=>({}));throw new Error(s.error||`Firebase Function error: ${r.status}`)}const a=await r.json();if(!a.success||!a.parameters)throw new Error("Invalid response from Firebase Function");const t=a.parameters;return console.log("🔥 Generated parameters via Firebase:",t),this.parameterCallback&&this.parameterCallback(t),t}validateParameters(e){const r={};return Object.entries({geometry:{min:0,max:7,type:"int"},hue:{min:0,max:360,type:"int"},intensity:{min:0,max:1,type:"float"},saturation:{min:0,max:1,type:"float"},speed:{min:.1,max:3,type:"float"},chaos:{min:0,max:1,type:"float"},morphFactor:{min:0,max:2,type:"float"},gridDensity:{min:5,max:100,type:"int"},rot4dXW:{min:-6.28,max:6.28,type:"float"},rot4dYW:{min:-6.28,max:6.28,type:"float"},rot4dZW:{min:-6.28,max:6.28,type:"float"}}).forEach(([t,s])=>{if(e.hasOwnProperty(t)){let o=parseFloat(e[t]);o=Math.max(s.min,Math.min(s.max,o)),s.type==="int"&&(o=Math.round(o)),r[t]=o}}),r}}export{h as LLMParameterInterface};

const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["./Engine-optW5Lbn.js","./Parameters-DwxYeMJO.js","./QuantumEngine-CFfXzAcE.js","./PolychoraSystemNew-7YVE-Emn.js"])))=>i.map(i=>d[i]);
(function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const i of document.querySelectorAll('link[rel="modulepreload"]'))n(i);new MutationObserver(i=>{for(const a of i)if(a.type==="childList")for(const s of a.addedNodes)s.tagName==="LINK"&&s.rel==="modulepreload"&&n(s)}).observe(document,{childList:!0,subtree:!0});function o(i){const a={};return i.integrity&&(a.integrity=i.integrity),i.referrerPolicy&&(a.referrerPolicy=i.referrerPolicy),i.crossOrigin==="use-credentials"?a.credentials="include":i.crossOrigin==="anonymous"?a.credentials="omit":a.credentials="same-origin",a}function n(i){if(i.ep)return;i.ep=!0;const a=o(i);fetch(i.href,a)}})();class pt{constructor(){this.galleryPreviewData=null,this.isGalleryPreview=!1}parseURLParameters(){const t=new URLSearchParams(window.location.search);if(t.has("system")){const o=t.get("system"),n=t.get("hideui")==="true";n&&this.setupCleanPreview();const i={};t.forEach((m,l)=>{["system","hideui","alllayers","highquality"].includes(l)||(i[l]=parseFloat(m)||m)});const a=t.get("alllayers")==="true",s=t.get("highquality")==="true";(a||s)&&(window.forceAllLayers=!0,window.forceHighQuality=!0,console.log("🎨 Gallery preview: Forcing all 5 layers with high quality")),this.galleryPreviewData={system:o,parameters:i,hideUI:n},console.log("🎨 Gallery preview mode detected:",this.galleryPreviewData),console.log("🎨 URL that triggered this:",window.location.href),console.log("🎨 Parameters parsed:",i),console.log("🎨 System to switch to:",o),this.isGalleryPreview=!0;const r=window.currentSystem;window.currentSystem=o,console.log(`🎯 Gallery preview: currentSystem set to '${o}' (was '${r}')`),window.galleryPreviewData=this.galleryPreviewData,window.isGalleryPreview=this.isGalleryPreview}}setupCleanPreview(){const t=()=>{const o=document.querySelector(".top-bar"),n=document.querySelector(".control-panel"),i=document.querySelector(".canvas-container");o&&(o.style.display="none"),n&&(n.style.display="none"),i&&(i.style.cssText=`
                    position: fixed !important;
                    top: 0 !important;
                    left: 0 !important;
                    width: 100vw !important;
                    height: 100vh !important;
                    display: block !important;
                    background: #000 !important;
                `,i.querySelectorAll("canvas").forEach((s,r)=>{s.style.cssText=`
                        position: absolute !important;
                        top: 0 !important;
                        left: 0 !important;
                        width: 100% !important;
                        height: 100% !important;
                    `}))};document.readyState==="loading"?document.addEventListener("DOMContentLoaded",t):t()}showCorrectSystemLayers(t){const o=()=>{["faceted","quantum","holographic","polychora"].forEach(i=>{const a=i==="faceted"?"vib34dLayers":`${i}Layers`,s=document.getElementById(a);if(s){const r=i===t;s.style.display=r?"block":"none",console.log(`🎯 EARLY CANVAS CONTROL: ${i} layers → ${r?"VISIBLE":"HIDDEN"}`)}})};document.readyState==="loading"?document.addEventListener("DOMContentLoaded",o):o()}}const yt=new pt;yt.parseURLParameters();class wt{constructor(){this.initializationAttempts=0,this.maxAttempts=10,this.retryDelay=1e3}async initializeGalleryPreview(){if(!window.isGalleryPreview||!window.galleryPreviewData)return;console.log("🚀 FAST GALLERY PREVIEW: Initializing for",window.galleryPreviewData.system),await this.waitForCriticalSystems();const t=window.galleryPreviewData.system;console.log(`🚀 FAST GALLERY PREVIEW: Switching to ${t} (ONCE)`);try{await window.switchSystem(t),console.log(`✅ FAST: ${t} system ready`)}catch(o){if(console.warn(`❌ FAST: Switch to ${t} failed, using fallback:`,o.message),t!=="faceted")try{await window.switchSystem("faceted"),window.galleryPreviewData.system="faceted",console.log("✅ FAST: Fallback to faceted successful")}catch(n){console.error("❌ FAST: Even fallback failed:",n.message)}}await this.applyParametersFast()}async waitForCriticalSystems(){return new Promise(t=>{const o=()=>{const n=typeof window.switchSystem=="function",i=!!window.canvasManager,a=window.engineClasses&&Object.keys(window.engineClasses).length>0;n&&i&&a?(console.log("🚀 FAST GALLERY PREVIEW: Essential systems ready!"),t()):this.initializationAttempts<5?(this.initializationAttempts++,console.log(`🚀 FAST: Waiting for essentials... (${this.initializationAttempts}/5)`),console.log(`  - switchSystem: ${n?"✅":"❌"}`),console.log(`  - canvasManager: ${i?"✅":"❌"}`),console.log(`  - engineClasses: ${a?"✅":"❌"}`),setTimeout(o,500)):(console.warn("🚀 FAST: Timeout waiting for essentials - proceeding anyway"),t())};o()})}checkTargetSystemEngine(t){if(!t)return!1;const n=!!{faceted:window.engine,quantum:window.quantumEngine,holographic:window.holographicSystem,polychora:window.polychoraSystem}[t],i=typeof window.switchSystem=="function";return n||i}checkSystemAvailability(t){console.log(`🎨 GALLERY PREVIEW FIX: Checking ${t} system availability...`);const o={faceted:window.engine,quantum:window.quantumEngine,holographic:window.holographicSystem,polychora:window.polychoraSystem},n=!!o[t];return n?(console.log(`✅ ${t} available via engine instance`),!0):window.switchSystem&&t==="faceted"?(console.log(`✅ ${t} available via switchSystem (fallback)`),!0):window.isGalleryPreview&&t!=="faceted"?(console.warn(`⚠️ Gallery preview: ${t} not available, will fallback to faceted`),!1):(console.warn(`❌ ${t} system not available`,{engineInstance:n,switchSystemExists:!!window.switchSystem,isGalleryPreview:window.isGalleryPreview,availableInstances:Object.keys(o).filter(i=>o[i])}),!1)}async applyParametersFast(){const{parameters:t}=window.galleryPreviewData;console.log("🚀 ENHANCED GALLERY PREVIEW: Applying full parameter set"),console.log(`🚀 Parameters (${Object.keys(t).length}):`,t),await new Promise(o=>setTimeout(o,100));try{if(window.userParameterState){const s={variation:0,geometry:0,gridDensity:15,speed:.5,chaos:0,morphFactor:0,hue:0,saturation:.8,intensity:.5,rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0,dimension:3.2,...t};Object.assign(window.userParameterState,s),console.log(`🚀 ENHANCED: Global state updated with ${Object.keys(s).length} parameters`)}if(["rot4dXY","rot4dXZ","rot4dYZ"].forEach(s=>{if(t[s]!==void 0)try{window.updateParameter&&(window.updateParameter(s,t[s]),console.log(`🚀 3D ROTATION: ${s} = ${t[s].toFixed(4)}`))}catch(r){console.warn(`🚀 3D ROTATION ${s} failed:`,r.message)}}),["rot4dXW","rot4dYW","rot4dZW"].forEach(s=>{if(t[s]!==void 0)try{window.updateParameter&&(window.updateParameter(s,t[s]),console.log(`🚀 4D ROTATION: ${s} = ${t[s].toFixed(4)}`))}catch(r){console.warn(`🚀 4D ROTATION ${s} failed:`,r.message)}}),t.dimension!==void 0)try{window.updateParameter&&(window.updateParameter("dimension",t.dimension),console.log(`🚀 DIMENSION: dimension = ${t.dimension}`))}catch(s){console.warn("🚀 DIMENSION failed:",s.message)}if(["geometry","gridDensity","morphFactor","chaos","speed"].forEach(s=>{if(t[s]!==void 0)try{window.updateParameter&&(window.updateParameter(s,t[s]),console.log(`🚀 VISUAL: ${s} = ${t[s]}`))}catch(r){console.warn(`🚀 VISUAL ${s} failed:`,r.message)}}),["hue","saturation","intensity"].forEach(s=>{if(t[s]!==void 0)try{window.updateParameter&&(window.updateParameter(s,t[s]),console.log(`🚀 COLOR: ${s} = ${t[s]}`))}catch(r){console.warn(`🚀 COLOR ${s} failed:`,r.message)}}),t.variation!==void 0)try{window.updateParameter&&(window.updateParameter("variation",t.variation),console.log(`🚀 VARIATION: variation = ${t.variation}`))}catch(s){console.warn("🚀 VARIATION failed:",s.message)}console.log("🚀 ENHANCED GALLERY PREVIEW: All parameters applied successfully"),window.updateTiltBaseRotations&&(window.updateTiltBaseRotations(),console.log("🚀 ENHANCED: Updated device tilt base rotations"))}catch(o){console.error("🚀 ENHANCED: Parameter application error:",o)}}getCurrentEngine(){switch(window.currentSystem){case"faceted":return window.engine;case"quantum":return window.quantumEngine;case"holographic":return window.holographicSystem;default:return null}}suppressWarningSpam(){if(!window.originalConsoleWarn){window.originalConsoleWarn=console.warn;const t=new Map,o=3;console.warn=function(...n){const i=n.join(" ");if(i.includes("System")&&i.includes("not available")){const a=t.get(i)||0;a<o&&(t.set(i,a+1),window.originalConsoleWarn.apply(console,n),a===o-1&&window.originalConsoleWarn("🔇 Suppressing further identical warnings for this session"))}else window.originalConsoleWarn.apply(console,n)},console.log("🔇 Gallery preview warning spam suppression active")}}}if(typeof window<"u"&&window.location.search.includes("system=")){console.log("🎨 GALLERY PREVIEW FIX: Detected gallery preview mode");const e=new wt;e.suppressWarningSpam(),document.readyState==="loading"?document.addEventListener("DOMContentLoaded",()=>{setTimeout(()=>e.initializeGalleryPreview(),50)}):setTimeout(()=>e.initializeGalleryPreview(),50),window.galleryPreviewFix=e}console.log("🎨 Gallery Preview Fix: Loaded");window.audioEnabled=!1;class ht{constructor(){this.context=null,this.analyser=null,this.dataArray=null,this.isActive=!1,window.audioReactive={bass:0,mid:0,high:0,energy:0},console.log("🎵 Audio Engine: Initialized with default values")}async init(){if(this.isActive)return!0;try{console.log("🎵 Simple Audio Engine: Starting...");const t=await navigator.mediaDevices.getUserMedia({audio:!0});return this.context=new(window.AudioContext||window.webkitAudioContext),this.context.state==="suspended"&&await this.context.resume(),this.analyser=this.context.createAnalyser(),this.analyser.fftSize=256,this.analyser.smoothingTimeConstant=.8,this.context.createMediaStreamSource(t).connect(this.analyser),this.dataArray=new Uint8Array(this.analyser.frequencyBinCount),this.isActive=!0,window.audioEnabled=!0,this.startProcessing(),console.log("✅ Audio Engine: Active - window.audioEnabled = true"),!0}catch{return console.log("⚠️ Audio denied - silent mode"),window.audioEnabled=!1,!1}}startProcessing(){const t=()=>{if(!this.isActive||!this.analyser){requestAnimationFrame(t);return}this.analyser.getByteFrequencyData(this.dataArray);const o=this.dataArray.length,n=Math.floor(o*.1),i=Math.floor(o*.3);let a=0,s=0,r=0;for(let l=0;l<n;l++)a+=this.dataArray[l];for(let l=n;l<i;l++)s+=this.dataArray[l];for(let l=i;l<o;l++)r+=this.dataArray[l];a=a/n/255,s=s/(i-n)/255,r=r/(o-i)/255;const m=.7;window.audioReactive.bass=a*m+window.audioReactive.bass*(1-m),window.audioReactive.mid=s*m+window.audioReactive.mid*(1-m),window.audioReactive.high=r*m+window.audioReactive.high*(1-m),window.audioReactive.energy=(window.audioReactive.bass+window.audioReactive.mid+window.audioReactive.high)/3,Date.now()%5e3<16&&console.log(`🎵 Audio levels: Bass=${window.audioReactive.bass.toFixed(2)} Mid=${window.audioReactive.mid.toFixed(2)} High=${window.audioReactive.high.toFixed(2)} Energy=${window.audioReactive.energy.toFixed(2)}`),requestAnimationFrame(t)};t()}isAudioActive(){return this.isActive&&window.audioEnabled}getAudioLevels(){return window.audioReactive}stop(){this.isActive=!1,window.audioEnabled=!1,this.context&&(this.context.close(),this.context=null),console.log("🎵 Audio Engine: Stopped")}}function vt(){window.toggleAudio=function(){const e=document.querySelector('[onclick="toggleAudio()"]');if(!window.audioEngine.isActive)window.audioEngine.init().then(t=>{t?(e&&(e.style.background="linear-gradient(45deg, rgba(0, 255, 0, 0.3), rgba(0, 255, 0, 0.6))",e.style.borderColor="#00ff00",e.title="Audio Reactivity: ON"),console.log("🎵 Audio Reactivity: ON")):console.log("⚠️ Audio permission denied or not available")});else{let t=!window.audioEnabled;window.audioEnabled=t,e&&(e.style.background=t?"linear-gradient(45deg, rgba(0, 255, 0, 0.3), rgba(0, 255, 0, 0.6))":"linear-gradient(45deg, rgba(255, 0, 255, 0.1), rgba(255, 0, 255, 0.3))",e.style.borderColor=t?"#00ff00":"rgba(255, 0, 255, 0.3)",e.title=`Audio Reactivity: ${t?"ON":"OFF"}`),t&&navigator.mediaDevices.getUserMedia({audio:!0}).catch(o=>{t=!1,window.audioEnabled=!1,console.log("⚠️ Audio permission denied:",o.message)}),console.log(`🎵 Audio Reactivity: ${t?"ON":"OFF"}`)}}}const bt=new ht;window.audioEngine=bt;vt();console.log("🎵 Audio Engine Module: Loaded");let St=window.audioEnabled||!1,C=!1;window.updateParameter=function(e,t){window.userParameterState[e]=parseFloat(t),console.log(`💾 User parameter: ${e} = ${t}`);const o={rot4dXY:"rot4dXY-display",rot4dXZ:"rot4dXZ-display",rot4dYZ:"rot4dYZ-display",rot4dXW:"rot4dXW-display",rot4dYW:"rot4dYW-display",rot4dZW:"rot4dZW-display",gridDensity:"gridDensity-display",morphFactor:"morphFactor-display",chaos:"chaos-display",speed:"speed-display",hue:"hue-display",intensity:"intensity-display",saturation:"saturation-display"},n=document.getElementById(o[e]);n&&(e==="hue"?n.textContent=t+"°":e.startsWith("rot4d")?n.textContent=parseFloat(t).toFixed(2):n.textContent=parseFloat(t).toFixed(1));try{const i=window.currentSystem||"faceted",a={faceted:window.engine,quantum:window.quantumEngine,holographic:window.holographicSystem,polychora:window.polychoraSystem},s=a[i];if(!s){console.warn(`⚠️ System ${i} not available - engines:`,Object.keys(a).map(l=>`${l}:${!!a[l]}`).join(", ")),window.parameterRetryCount||(window.parameterRetryCount={});const r=`${e}_${t}_${i}`,m=window.parameterRetryCount[r]||0;m<1?(window.parameterRetryCount[r]=m+1,console.log(`🔄 Retrying parameter ${e} = ${t} for ${i} (attempt ${m+2})`),setTimeout(()=>{window.updateParameter(e,t)},100)):(console.warn(`❌ Parameter ${e} = ${t} failed for ${i} - system not available, giving up after 2 attempts`),delete window.parameterRetryCount[r]);return}i==="faceted"?(s.parameterManager.setParameter(e,parseFloat(t)),s.updateVisualizers()):i==="quantum"||i==="holographic"?s.updateParameter(e,parseFloat(t)):i==="polychora"&&s.updateParameters({[e]:parseFloat(t)}),console.log(`📊 ${i.toUpperCase()}: ${e} = ${t}`)}catch(i){console.error(`❌ Parameter update error in ${window.currentSystem||"unknown"} for ${e}:`,i)}};window.randomizeAll=function(){Ze()};window.randomizeEverything=function(){Ze(),setTimeout(()=>xt(),10)};function Ze(){const e=["hue"];document.querySelectorAll(".control-slider").forEach(t=>{const o=t.id;if(!e.includes(o)){const n=parseFloat(t.min),i=parseFloat(t.max),a=Math.random()*(i-n)+n;t.value=a,t.oninput()}}),console.log("🎲 Parameters randomized (NO hue, NO geometry)")}function xt(){var t,o;if(window.currentSystem!=="holographic"){const n=((o=(t=window.geometries)==null?void 0:t[window.currentSystem])==null?void 0:o.length)||8,i=Math.floor(Math.random()*n);window.selectGeometry&&window.selectGeometry(i)}const e=document.getElementById("hue");if(e){const n=Math.random()*360;e.value=n,e.oninput()}console.log("🎲 Stage 2: Randomized geometry and hue")}window.resetAll=function(){Object.entries({rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0,gridDensity:15,morphFactor:1,chaos:.2,speed:1,hue:200,intensity:.5,saturation:.8}).forEach(([t,o])=>{const n=document.getElementById(t);n&&(n.value=o,n.oninput())}),console.log("🔄 Reset all parameters")};window.openGallery=function(){if(console.log("🖼️ Navigating to gallery..."),window.location.href="./gallery.html",window.galleryWindow){const e=setInterval(()=>{window.galleryWindow.closed&&(window.galleryWindow=null,clearInterval(e),console.log("🖼️ Gallery window closed"))},1e3)}};window.toggleInteractivity=function(){C=!C;const e=document.querySelector('[onclick="toggleInteractivity()"]');e&&(e.style.background=C?"linear-gradient(45deg, rgba(0, 255, 255, 0.3), rgba(0, 255, 255, 0.6))":"linear-gradient(45deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.3))",e.style.borderColor=C?"#00ffff":"rgba(255, 255, 255, 0.5)",e.title=`Toggle Interactivity: ${C?"ON":"OFF"}`,e.textContent="I"),console.log(`🎛️ Mouse/Touch Interactions: ${C?"ENABLED":"DISABLED"}`),console.log("🔷 Faceted: Mouse tracking",C?"✅":"❌"),console.log("🌌 Quantum: Enhanced interactions",C?"✅":"❌"),console.log("✨ Holographic: Touch interactions",C?"✅":"❌"),console.log("🔮 Polychora: 4D precision tracking",C?"✅":"❌"),Et()};window.toggleSystemReactivity=function(e,t,o){var n,i,a,s,r,m,l,f,b;if(!window.reactivityManager){console.warn("⚠️ ReactivityManager not initialized");return}if(console.log(`🎛️ ${e.toUpperCase()} ${t.toUpperCase()}: ${o?"ON":"OFF"}`),`${e}${t.charAt(0).toUpperCase()}${t.slice(1)}`,t==="mouse")if(o)e==="faceted"?(window.reactivityManager.setMouseMode("rotations"),console.log("  🔷 Activating Faceted 4D rotation mouse tracking")):e==="quantum"?(window.reactivityManager.setMouseMode("velocity"),console.log("  🌌 Activating Quantum velocity mouse tracking")):e==="holographic"&&(window.reactivityManager.setMouseMode("distance"),console.log("  ✨ Activating Holographic shimmer mouse tracking")),window.reactivityManager.toggleMouse(!0);else{const w=((n=document.getElementById("facetedMouse"))==null?void 0:n.checked)||!1,p=((i=document.getElementById("quantumMouse"))==null?void 0:i.checked)||!1,c=((a=document.getElementById("holographicMouse"))==null?void 0:a.checked)||!1;!w&&!p&&!c&&(window.reactivityManager.toggleMouse(!1),console.log("  🖱️ All mouse reactivity disabled"))}else if(t==="click")if(o)e==="faceted"?(window.reactivityManager.setClickMode("burst"),console.log("  🔷 Activating Faceted burst clicks")):e==="quantum"?(window.reactivityManager.setClickMode("blast"),console.log("  🌌 Activating Quantum blast clicks")):e==="holographic"&&(window.reactivityManager.setClickMode("ripple"),console.log("  ✨ Activating Holographic ripple clicks")),window.reactivityManager.toggleClick(!0);else{const w=((s=document.getElementById("facetedClick"))==null?void 0:s.checked)||!1,p=((r=document.getElementById("quantumClick"))==null?void 0:r.checked)||!1,c=((m=document.getElementById("holographicClick"))==null?void 0:m.checked)||!1;!w&&!p&&!c&&(window.reactivityManager.toggleClick(!1),console.log("  👆 All click reactivity disabled"))}else if(t==="scroll")if(o)e==="faceted"?(window.reactivityManager.setScrollMode("cycle"),console.log("  🔷 Activating Faceted cycle scroll effects")):e==="quantum"?(window.reactivityManager.setScrollMode("wave"),console.log("  🌌 Activating Quantum wave scroll")):e==="holographic"&&(window.reactivityManager.setScrollMode("sweep"),console.log("  ✨ Activating Holographic sweep scroll effects")),window.reactivityManager.toggleScroll(!0);else{const w=((l=document.getElementById("facetedScroll"))==null?void 0:l.checked)||!1,p=((f=document.getElementById("quantumScroll"))==null?void 0:f.checked)||!1,c=((b=document.getElementById("holographicScroll"))==null?void 0:b.checked)||!1;!w&&!p&&!c&&(window.reactivityManager.toggleScroll(!1),console.log("  🌀 All scroll reactivity disabled"))}};window.toggleAudioReactivity=function(e,t,o){console.log(`🎵 ${e.toUpperCase()} ${t.toUpperCase()}: ${o?"ON":"OFF"}`),window.audioReactivitySettings||(window.audioReactivitySettings={sensitivity:{low:.3,medium:1,high:2},visualModes:{color:["hue","saturation","intensity"],geometry:["morphFactor","gridDensity","chaos"],movement:["speed","rot4dXW","rot4dYW","rot4dZW"]},activeSensitivity:"medium",activeVisualModes:new Set(["color"])});const n=window.audioReactivitySettings,i=`${e}-${t}`;o?(n.activeVisualModes.add(i),n.activeSensitivity=e,console.log(`  🎵 Activated: ${e} sensitivity with ${t} visual changes`),console.log(`  📊 Sensitivity multiplier: ${n.sensitivity[e]}x`),console.log("  🎨 Visual parameters:",n.visualModes[t])):(n.activeVisualModes.delete(i),console.log(`  🎵 Deactivated: ${e} ${t}`)),window.holographicSystem&&window.holographicSystem.audioEnabled&&(window.holographicSystem.audioReactivitySettings=n,console.log("  ✨ Updated holographic system audio settings")),window.quantumEngine&&window.quantumEngine.audioEnabled&&(window.quantumEngine.audioReactivitySettings=n,console.log("  🌌 Updated quantum engine audio settings")),Tt()};window.toggleAudioCell=function(e){const t=document.getElementById(e);if(t){t.checked=!t.checked;const o=e.replace(/Color|Geometry|Movement/,"").toLowerCase();let n="";e.includes("Color")?n="color":e.includes("Geometry")?n="geometry":e.includes("Movement")&&(n="movement"),toggleAudioReactivity(o,n,t.checked)}};function Et(){let e=document.getElementById("reactivity-status-overlay");e||(e=document.createElement("div"),e.id="reactivity-status-overlay",e.style.cssText=`
            position: fixed;
            top: 60px;
            right: 20px;
            background: rgba(0, 0, 0, 0.9);
            border: 2px solid #00ffff;
            padding: 15px;
            border-radius: 10px;
            color: #fff;
            font-family: 'Orbitron', monospace;
            font-size: 0.9rem;
            z-index: 2000;
            backdrop-filter: blur(10px);
            animation: fadeInOut 3s ease;
        `,document.body.appendChild(e)),e.innerHTML=`
        <div style="color: #00ffff; font-weight: bold; margin-bottom: 10px;">
            🎛️ REACTIVITY STATUS
        </div>
        <div>🎵 Audio: ${St?'<span style="color: #00ff00">ON</span>':'<span style="color: #ff4444">OFF</span>'}</div>
        <div>🖱️ Interactions: ${C?'<span style="color: #00ff00">ON</span>':'<span style="color: #ff4444">OFF</span>'}</div>
    `,setTimeout(()=>{e&&e.parentNode&&e.parentNode.removeChild(e)},3e3)}function Tt(){const e=window.audioReactivitySettings;if(!e)return;let t=document.getElementById("audio-reactivity-overlay");t||(t=document.createElement("div"),t.id="audio-reactivity-overlay",t.style.cssText=`
            position: fixed;
            top: 60px;
            left: 20px;
            background: rgba(40, 0, 40, 0.9);
            border: 2px solid #ff64ff;
            padding: 15px;
            border-radius: 10px;
            color: #fff;
            font-family: 'Orbitron', monospace;
            font-size: 0.8rem;
            z-index: 2000;
            backdrop-filter: blur(10px);
            animation: fadeInOut 4s ease;
            max-width: 300px;
        `,document.body.appendChild(t));const o=Array.from(e.activeVisualModes),n=o.length>0?o.map(i=>i.replace("-"," ")).join(", "):"None active";t.innerHTML=`
        <div style="color: #ff64ff; font-weight: bold; margin-bottom: 10px;">
            🎵 AUDIO REACTIVITY STATUS
        </div>
        <div>🔊 Sensitivity: <span style="color: #ff64ff">${e.activeSensitivity.toUpperCase()}</span></div>
        <div>🎨 Active Modes: <span style="color: #ff64ff">${n}</span></div>
        <div>📊 Multiplier: <span style="color: #ff64ff">${e.sensitivity[e.activeSensitivity]}x</span></div>
    `,setTimeout(()=>{t&&t.parentNode&&t.parentNode.removeChild(t)},4e3)}document.addEventListener("keydown",e=>{(e.key==="i"||e.key==="I")&&window.toggleInteractivity()});window.addEventListener("message",e=>{if(e.data&&e.data.type){if(e.data.type==="mouseMove"){const t=o=>{o&&o.visualizers&&o.visualizers.forEach(n=>{n&&(n.mouseX=e.data.x,n.mouseY=e.data.y,n.mouseIntensity=e.data.intensity||.5)})};window.currentSystem==="faceted"&&window.engine?t(window.engine):window.currentSystem==="quantum"&&window.quantumEngine?t(window.quantumEngine):window.currentSystem==="holographic"&&window.holographicSystem&&t(window.holographicSystem)}else if(e.data.type==="mouseClick"){const t=o=>{o&&o.visualizers&&o.visualizers.forEach(n=>{n&&(n.clickIntensity=e.data.intensity||1)})};window.currentSystem==="faceted"&&window.engine?t(window.engine):window.currentSystem==="quantum"&&window.quantumEngine?t(window.quantumEngine):window.currentSystem==="holographic"&&window.holographicSystem&&t(window.holographicSystem)}}});window.setupGeometry=function(e){var n,i;const t=document.getElementById("geometryGrid");if(!t)return;const o=((n=window.geometries)==null?void 0:n[e])||((i=window.geometries)==null?void 0:i.faceted)||["TETRAHEDRON","HYPERCUBE","SPHERE","TORUS","KLEIN BOTTLE","FRACTAL","WAVE","CRYSTAL"];t.innerHTML=o.map((a,s)=>`<button class="geom-btn ${s===0?"active":""}" 
                 data-index="${s}" onclick="selectGeometry(${s})">
            ${a}
        </button>`).join("")};window.toggleMobilePanel=function(){const e=document.getElementById("controlPanel"),t=document.querySelector(".mobile-collapse-btn");e&&t&&(e.classList.toggle("collapsed"),t.textContent=e.classList.contains("collapsed")?"▲":"▼",console.log("📱 Mobile panel toggled"))};console.log("🎛️ UI Handlers Module: Loaded");const Ct="modulepreload",$t=function(e,t){return new URL(e,t).href},Ee={},E=function(t,o,n){let i=Promise.resolve();if(o&&o.length>0){const s=document.getElementsByTagName("link"),r=document.querySelector("meta[property=csp-nonce]"),m=(r==null?void 0:r.nonce)||(r==null?void 0:r.getAttribute("nonce"));i=Promise.allSettled(o.map(l=>{if(l=$t(l,n),l in Ee)return;Ee[l]=!0;const f=l.endsWith(".css"),b=f?'[rel="stylesheet"]':"";if(!!n)for(let c=s.length-1;c>=0;c--){const S=s[c];if(S.href===l&&(!f||S.rel==="stylesheet"))return}else if(document.querySelector(`link[href="${l}"]${b}`))return;const p=document.createElement("link");if(p.rel=f?"stylesheet":Ct,f||(p.as="script"),p.crossOrigin="",p.href=l,m&&p.setAttribute("nonce",m),document.head.appendChild(p),f)return new Promise((c,S)=>{p.addEventListener("load",c),p.addEventListener("error",()=>S(new Error(`Unable to preload CSS for ${l}`)))})}))}function a(s){const r=new Event("vite:preloadError",{cancelable:!0});if(r.payload=s,window.dispatchEvent(r),!r.defaultPrevented)throw s}return i.then(s=>{for(const r of s||[])r.status==="rejected"&&a(r.reason);return t().catch(a)})};let ce=null;const ye=()=>{window.vib34dPreservedFunctions||(window.vib34dPreservedFunctions={switchSystem:window.switchSystem,updateParameter:window.updateParameter,currentSystem:window.currentSystem,reactivityManager:window.reactivityManager,engine:window.engine,userParameterState:window.userParameterState,selectGeometry:window.selectGeometry,quantumEngine:window.quantumEngine,holographicSystem:window.holographicSystem,polychoraSystem:window.polychoraSystem},console.log("🛡️ Critical VIB34D functions preserved"))},we=()=>{if(window.vib34dPreservedFunctions){let e=0;Object.entries(window.vib34dPreservedFunctions).forEach(([t,o])=>{!window[t]&&o&&(window[t]=o,e++,console.log(`🔧 Restored ${t}`))}),e>0&&console.log(`🛡️ Restored ${e} critical functions`)}};window.saveToGallery=async function(){console.log("🔵 Save to Gallery button clicked"),ye();try{if(!!!(window.engine||window.quantumEngine||window.holographicSystem))throw new Error("No engine system initialized yet - please wait a moment");if(console.log("🔍 Engine check passed:",{faceted:!!window.engine,quantum:!!window.quantumEngine,holographic:!!window.holographicSystem,currentSystem:window.currentSystem}),!ce){console.log("🔧 Initializing UnifiedSaveManager...");const{UnifiedSaveManager:o}=await E(async()=>{const{UnifiedSaveManager:i}=await import("./UnifiedSaveManager-DKc_BQk1.js");return{UnifiedSaveManager:i}},[],import.meta.url);let n=null;window.currentSystem==="faceted"&&window.engine?n=window.engine:window.currentSystem==="quantum"&&window.quantumEngine?n=window.quantumEngine:window.currentSystem==="holographic"&&window.holographicSystem&&(n=window.holographicSystem),console.log("🔧 Initializing UnifiedSaveManager with engine for:",window.currentSystem,!!n),ce=new o(n)}window.currentSystem||(window.currentSystem="faceted",console.log("🔧 Fixed window.currentSystem:",window.currentSystem)),console.log("🔵 Starting save process...");const t=await ce.save({target:"gallery"});if(console.log("🔵 Save result:",t),t&&t.success){console.log("✅ Saved to gallery:",t.id),Lt("Variation saved to gallery!",t.id);const o=new CustomEvent("gallery-refresh-needed");window.dispatchEvent(o);try{window.galleryWindow&&!window.galleryWindow.closed&&(window.galleryWindow.postMessage({type:"vib34d-variation-saved",variationId:t.id,timestamp:Date.now()},"*"),console.log("📤 Sent gallery update message to gallery window"))}catch{console.log("📤 No gallery window to notify")}localStorage.setItem("vib34d-gallery-update-trigger",Date.now().toString())}else throw new Error((t==null?void 0:t.error)||"Save failed - no result returned")}catch(e){console.error("❌ Failed to save to gallery:",e),Mt(e.message||"Gallery save failed")}finally{setTimeout(we,100)}};window.createTradingCard=async function(e="classic"){var t,o,n;console.log(`🎴 Creating ${e} trading card for ${window.currentSystem} system...`),ye();try{const{TradingCardManager:i}=await E(async()=>{const{TradingCardManager:r}=await import("./TradingCardManager-CILHPAPr.js");return{TradingCardManager:r}},[],import.meta.url),a={system:window.currentSystem||"faceted",geometry:It(),rot4dXY:parseFloat(((t=document.getElementById("rot4dXY"))==null?void 0:t.value)||0),rot4dXZ:parseFloat(((o=document.getElementById("rot4dXZ"))==null?void 0:o.value)||0),rot4dYZ:parseFloat(((n=document.getElementById("rot4dYZ"))==null?void 0:n.value)||0),rot4dXW:parseFloat(document.getElementById("rot4dXW").value),rot4dYW:parseFloat(document.getElementById("rot4dYW").value),rot4dZW:parseFloat(document.getElementById("rot4dZW").value),gridDensity:parseFloat(document.getElementById("gridDensity").value),morphFactor:parseFloat(document.getElementById("morphFactor").value),chaos:parseFloat(document.getElementById("chaos").value),speed:parseFloat(document.getElementById("speed").value),hue:parseFloat(document.getElementById("hue").value),intensity:parseFloat(document.getElementById("intensity").value),saturation:parseFloat(document.getElementById("saturation").value)},s=await i.createCard(window.currentSystem||"faceted",e,a);if(s.success){console.log(`✅ ${s.system} trading card created: ${s.filename}`);const r=document.createElement("div");r.style.cssText=`
                position: fixed;
                top: 70px;
                right: 20px;
                background: rgba(0, 255, 0, 0.9);
                color: black;
                padding: 15px 20px;
                border-radius: 10px;
                font-family: 'Orbitron', monospace;
                font-weight: bold;
                z-index: 10000;
                animation: slideIn 0.3s ease-out;
            `,r.innerHTML=`
                🎴 ${s.system.toUpperCase()} Trading Card Created!<br>
                <small style="opacity: 0.8;">${s.filename}</small>
            `,document.body.appendChild(r),setTimeout(()=>r.remove(),4e3)}else throw new Error(s.error||"Trading card generation failed")}catch(i){console.error("❌ Failed to create trading card:",i);const a=document.createElement("div");a.style.cssText=`
            position: fixed;
            top: 70px;
            right: 20px;
            background: rgba(255, 0, 0, 0.9);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            font-family: 'Orbitron', monospace;
            z-index: 10000;
        `,a.innerHTML=`❌ Trading Card Failed: ${i.message}`,document.body.appendChild(a),setTimeout(()=>a.remove(),3e3)}finally{setTimeout(we,100)}};window.showLLMInterface=async function(){console.log("🤖 Opening AI parameter interface"),ye();try{const{LLMParameterInterface:e}=await E(async()=>{const{LLMParameterInterface:o}=await import("./LLMParameterInterface-NrrLuj2o.js");return{LLMParameterInterface:o}},[],import.meta.url),{LLMParameterUI:t}=await E(async()=>{const{LLMParameterUI:o}=await import("./LLMParameterUI-CRwdupuW.js");return{LLMParameterUI:o}},[],import.meta.url);window.llmInterface||(window.llmInterface=new e,window.llmUI=new t(window.llmInterface),window.llmInterface.setParameterCallback(o=>{console.log("🤖 Applying AI-generated parameters:",o);let n=window.currentSystem||"faceted";o.chaos>.7&&o.speed>2?n="quantum":o.intensity>.8&&o.saturation>.8?n="holographic":o.chaos<.3&&o.gridDensity>60&&(n="faceted"),n!==window.currentSystem&&(console.log(`🎯 AI switching from ${window.currentSystem} to ${n} for optimal visual effect`),window.switchSystem&&window.switchSystem(n)),Object.entries(o).forEach(([i,a],s)=>{setTimeout(()=>{window.updateParameter?(console.log(`🤖 Applying ${i} = ${a} to ${n} system`),window.updateParameter(i,a)):console.error("❌ window.updateParameter not available")},s*50)})})),window.llmUI.show()}catch(e){console.error("❌ Error loading LLM interface:",e),alert("Error loading AI parameter interface. Please check console for details.")}finally{setTimeout(we,100)}};function It(){const e=document.querySelector(".geom-btn.active");return e&&parseInt(e.dataset.index)||0}function Lt(e,t){const o=document.createElement("div");o.style.cssText=`
        position: fixed;
        top: 70px;
        left: 20px;
        background: rgba(0, 255, 255, 0.9);
        color: black;
        padding: 15px 20px;
        border-radius: 10px;
        font-family: 'Orbitron', monospace;
        font-weight: bold;
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `,o.innerHTML=`
        ✅ ${e}<br>
        <small style="opacity: 0.8;">ID: ${t}</small>
    `,document.body.appendChild(o),setTimeout(()=>o.remove(),4e3)}function Mt(e){const t=document.createElement("div");t.style.cssText=`
        position: fixed;
        top: 70px;
        left: 20px;
        background: rgba(255, 0, 0, 0.9);
        color: white;
        padding: 15px 20px;
        border-radius: 10px;
        font-family: 'Orbitron', monospace;
        z-index: 10000;
    `,t.innerHTML=`❌ Save Error: ${e}`,document.body.appendChild(t),setTimeout(()=>t.remove(),3e3)}function Te(){const e=localStorage.getItem("vib34d-load-params");if(e)try{const t=JSON.parse(e);console.log("🔗 Received parameters from gallery:",t),localStorage.removeItem("vib34d-load-params"),t.system&&t.system!==window.currentSystem?(window.switchSystem(t.system),setTimeout(()=>Ce(t),20)):Ce(t)}catch(t){console.error("❌ Failed to parse gallery parameters:",t),localStorage.removeItem("vib34d-load-params")}}function Ce(e){const{system:t,parameters:o,globalId:n}=e;console.log(`🎯 Loading ${t} variation #${n} from gallery`),t==="faceted"&&window.engine?Object.entries(o).forEach(([i,a])=>{if(i==="geometry"&&typeof a=="number")window.selectGeometry&&window.selectGeometry(a);else{const s=document.getElementById(i);s&&(s.value=a,window.updateParameter(i,a))}}):t==="holographic"&&window.holographicSystem&&Object.entries(o).forEach(([i,a])=>{const s=document.getElementById(i);s&&(s.value=a,window.updateParameter(i,a))})}window.baseHue=200;window.baseDensity=15;window.baseMorph=1;let $e=0,ee=null,de=null;function At(){if(!ee||!window.updateParameter||!window.moduleReady)return;const{mouseX:e,mouseY:t,intensity:o}=ee,n=(e-.5)*60,i=(t-.5)*10,a=o*.3;window.updateParameter("hue",(window.baseHue||200)+n),window.updateParameter("gridDensity",Math.max(5,(window.baseDensity||15)+i)),window.updateParameter("morphFactor",Math.max(0,Math.min(2,(window.baseMorph||1)+a))),window.updateParameter("intensity",Math.max(0,Math.min(1,o))),ee=null}window.addEventListener("message",e=>{if(e.data&&e.data.type==="mouseMove"){const t=performance.now();t-$e>16&&(ee={mouseX:e.data.x||.5,mouseY:e.data.y||.5,intensity:e.data.intensity||.5},de&&cancelAnimationFrame(de),de=requestAnimationFrame(At),$e=t)}});typeof window<"u"&&(setTimeout(Te,100),window.addEventListener("storage",e=>{e.key==="vib34d-load-params"&&Te()}));console.log("🖼️ Gallery Manager Module: Loaded");window.openGallery=function(){console.log("🖼️ Opening inline gallery modal...");let e=document.getElementById("gallery-modal");e||(e=kt(),document.body.appendChild(e)),he(),e.style.display="flex",setTimeout(()=>{e.classList.add("visible")},10),document.body.style.overflow="hidden"};window.closeGallery=function(){const e=document.getElementById("gallery-modal");e&&(e.classList.remove("visible"),setTimeout(()=>{e.style.display="none",document.body.style.overflow=""},300))};function kt(){const e=document.createElement("div");return e.id="gallery-modal",e.className="gallery-modal",e.innerHTML=`
        <div class="gallery-overlay" onclick="closeGallery()"></div>
        <div class="gallery-container">
            <!-- Gallery Header -->
            <div class="gallery-header">
                <div class="gallery-title">
                    <span class="gallery-icon">🖼️</span>
                    <span>VIB34D GALLERY</span>
                </div>
                <div class="gallery-stats" id="galleryStats">
                    Loading...
                </div>
                <button class="gallery-close-btn" onclick="closeGallery()">×</button>
            </div>

            <!-- Gallery Filter/Sort -->
            <div class="gallery-controls">
                <div class="filter-tabs">
                    <button class="filter-tab active" onclick="filterGallery('all')">All</button>
                    <button class="filter-tab" onclick="filterGallery('faceted')">🔷 Faceted</button>
                    <button class="filter-tab" onclick="filterGallery('quantum')">🌌 Quantum</button>
                    <button class="filter-tab" onclick="filterGallery('holographic')">✨ Holographic</button>
                    <button class="filter-tab" onclick="filterGallery('polychora')">🔮 Polychora</button>
                </div>
                <select class="sort-select" onchange="sortGallery(this.value)">
                    <option value="newest">Newest First</option>
                    <option value="oldest">Oldest First</option>
                    <option value="system">By System</option>
                </select>
            </div>

            <!-- Gallery Grid -->
            <div class="gallery-grid" id="galleryGrid">
                <!-- Gallery items loaded dynamically -->
            </div>

            <!-- Empty State -->
            <div class="gallery-empty" id="galleryEmpty" style="display: none;">
                <div class="empty-icon">🎨</div>
                <div class="empty-title">No Variations Saved</div>
                <div class="empty-text">
                    Create your first variation by clicking "💾 Save to Gallery" in the control panel
                </div>
            </div>
        </div>
    `,e}function he(){console.log("📦 Loading gallery items...");try{const e=[];for(let t=0;t<localStorage.length;t++){const o=localStorage.key(t);if(o.startsWith("vib34d-variation-"))try{const n=JSON.parse(localStorage.getItem(o));e.push({key:o,id:o.replace("vib34d-variation-",""),...n})}catch(n){console.warn(`Failed to parse ${o}:`,n)}}return console.log(`✅ Loaded ${e.length} gallery items`),Rt(e),e.length===0?Ie():Ve(e),e}catch(e){return console.error("❌ Failed to load gallery items:",e),Ie(),[]}}function Rt(e){const t=document.getElementById("galleryStats");if(!t)return;const o=e.reduce((i,a)=>{const s=a.system||"unknown";return i[s]=(i[s]||0)+1,i},{}),n=Object.entries(o).map(([i,a])=>`${{faceted:"🔷",quantum:"🌌",holographic:"✨",polychora:"🔮"}[i]||""} ${a}`).join(" • ");t.innerHTML=`
        <span class="stat-total">${e.length} Variations</span>
        ${n?`<span class="stat-breakdown">${n}</span>`:""}
    `}function Ve(e){const t=document.getElementById("galleryGrid"),o=document.getElementById("galleryEmpty");t&&(t.style.display="grid",o&&(o.style.display="none"),e.sort((n,i)=>new Date(i.timestamp)-new Date(n.timestamp)),t.innerHTML=e.map(n=>Pt(n)).join(""))}function Pt(e){var r;const t={faceted:"🔷",quantum:"🌌",holographic:"✨",polychora:"🔮"},o={faceted:"#00ffff",quantum:"#ff00ff",holographic:"#ff64ff",polychora:"#ffff00"},n=t[e.system]||"🎨",i=o[e.system]||"#00ffff",a=Dt(e.system,((r=e.parameters)==null?void 0:r.geometry)||0),s=new Date(e.timestamp).toLocaleDateString();return`
        <div class="gallery-card" data-id="${e.id}" data-system="${e.system}">
            <div class="card-preview" style="border-color: ${i};">
                <div class="preview-icon" style="color: ${i};">${n}</div>
                <div class="preview-info">
                    <div class="preview-system">${e.system.toUpperCase()}</div>
                    <div class="preview-geometry">${a}</div>
                </div>
            </div>
            <div class="card-info">
                <div class="card-title">${e.name||`Variation #${e.id}`}</div>
                <div class="card-meta">
                    <span class="card-date">${s}</span>
                    <span class="card-id">#${e.id}</span>
                </div>
            </div>
            <div class="card-actions">
                <button class="card-btn load-btn" onclick="loadGalleryVariation('${e.id}')" title="Load Variation">
                    ▶️ Load
                </button>
                <button class="card-btn delete-btn" onclick="deleteGalleryVariation('${e.id}')" title="Delete Variation">
                    🗑️
                </button>
            </div>
        </div>
    `}function Dt(e,t){const o={faceted:["Tetrahedron","Hypercube","Sphere","Torus","Klein Bottle","Fractal","Wave","Crystal","🌀 Tetrahedron","🌀 Hypercube","🌀 Sphere","🌀 Torus","🌀 Klein","🌀 Fractal","🌀 Wave","🌀 Crystal","🔺 Tetrahedron","🔺 Hypercube","🔺 Sphere","🔺 Torus","🔺 Klein","🔺 Fractal","🔺 Wave","🔺 Crystal"],quantum:["Tetrahedron","Hypercube","Sphere","Torus","Klein Bottle","Fractal","Wave","Crystal","🌀 Tetrahedron","🌀 Hypercube","🌀 Sphere","🌀 Torus","🌀 Klein","🌀 Fractal","🌀 Wave","🌀 Crystal","🔺 Tetrahedron","🔺 Hypercube","🔺 Sphere","🔺 Torus","🔺 Klein","🔺 Fractal","🔺 Wave","🔺 Crystal"],holographic:["Holographic"],polychora:["5-Cell","Tesseract","16-Cell","24-Cell","600-Cell","120-Cell"]};return(o[e]||o.faceted)[t]||`Geometry #${t}`}window.loadGalleryVariation=async function(e){console.log(`📂 Loading variation ${e}...`);try{const t=`vib34d-variation-${e}`,o=JSON.parse(localStorage.getItem(t));if(!o)throw new Error(`Variation ${e} not found`);console.log("✅ Loaded variation:",o),closeGallery(),o.system&&o.system!==window.currentSystem&&(console.log(`🔄 Switching from ${window.currentSystem} to ${o.system}`),window.switchSystem&&(await window.switchSystem(o.system),await new Promise(n=>setTimeout(n,500)))),o.parameters&&Object.entries(o.parameters).forEach(([n,i])=>{if(n==="geometry"&&typeof i=="number")window.selectGeometry&&window.selectGeometry(i);else{const a=document.getElementById(n);a&&(a.value=i,window.updateParameter&&window.updateParameter(n,i))}}),ne(`✅ Loaded: ${o.name||`Variation #${e}`}`,"success")}catch(t){console.error("❌ Failed to load variation:",t),ne(`❌ Failed to load variation: ${t.message}`,"error")}};window.deleteGalleryVariation=function(e){if(confirm(`Delete variation #${e}?`))try{const t=`vib34d-variation-${e}`;localStorage.removeItem(t),console.log(`🗑️ Deleted variation ${e}`),he(),ne(`🗑️ Deleted variation #${e}`,"success")}catch(t){console.error("❌ Failed to delete variation:",t),ne(`❌ Failed to delete: ${t.message}`,"error")}};window.filterGallery=function(e){console.log(`🔍 Filtering by: ${e}`),document.querySelectorAll(".filter-tab").forEach(o=>{o.classList.remove("active")}),event.target.classList.add("active"),document.querySelectorAll(".gallery-card").forEach(o=>{e==="all"||o.dataset.system===e?o.style.display="block":o.style.display="none"})};window.sortGallery=function(e){console.log(`🔢 Sorting by: ${e}`);const t=he();e==="oldest"?t.sort((o,n)=>new Date(o.timestamp)-new Date(n.timestamp)):e==="system"?t.sort((o,n)=>o.system.localeCompare(n.system)):t.sort((o,n)=>new Date(n.timestamp)-new Date(o.timestamp)),Ve(t)};function Ie(){const e=document.getElementById("galleryGrid"),t=document.getElementById("galleryEmpty");e&&(e.style.display="none"),t&&(t.style.display="flex")}function ne(e,t="info"){const o=document.createElement("div");o.className=`gallery-notification ${t}`,o.textContent=e,o.style.cssText=`
        position: fixed;
        top: 80px;
        right: 20px;
        background: ${t==="success"?"rgba(0, 255, 0, 0.9)":"rgba(255, 0, 0, 0.9)"};
        color: ${t==="success"?"black":"white"};
        padding: 15px 20px;
        border-radius: 8px;
        font-family: 'Orbitron', monospace;
        font-weight: bold;
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `,document.body.appendChild(o),setTimeout(()=>o.remove(),3e3)}document.addEventListener("keydown",e=>{if(e.key==="Escape"){const t=document.getElementById("gallery-modal");t&&t.style.display!=="none"&&closeGallery()}});console.log("🖼️ Gallery Modal Module: Loaded");let Ue="controls",I=!1;window.switchBezelTab=function(e){console.log(`🔄 Switching to tab: ${e}`),Ue=e,document.querySelectorAll(".bezel-tab").forEach(t=>{t.dataset.tab===e?t.classList.add("active"):t.classList.remove("active")}),document.querySelectorAll(".bezel-content").forEach(t=>{t.id===`${e}-content`?t.classList.add("active"):t.classList.remove("active")}),I&&toggleBezelCollapse()};window.toggleBezelCollapse=function(){const e=document.getElementById("controlPanel"),t=document.querySelector(".bezel-collapse-btn");e&&(I=!I,e.classList.toggle("collapsed"),t&&(t.innerHTML=I?"▲":"▼",t.title=I?"Expand Controls":"Collapse Controls"),console.log(`🎛️ Bezel ${I?"collapsed":"expanded"}`),_e())};function _e(){const e=document.getElementById("canvasContainer");e&&(I?e.style.bottom="52px":e.style.bottom="65vh")}window.quickRandomize=function(){window.randomizeAll&&window.randomizeAll()};window.quickSave=function(){window.saveToGallery&&window.saveToGallery()};window.quickGallery=function(){window.openGallery&&window.openGallery()};document.addEventListener("keydown",e=>{if((e.ctrlKey||e.metaKey)&&e.key==="b"&&(e.preventDefault(),toggleBezelCollapse()),(e.ctrlKey||e.metaKey)&&e.key>="1"&&e.key<="5"){e.preventDefault();const t=["controls","color","geometry","reactivity","export"],o=parseInt(e.key)-1;t[o]&&switchBezelTab(t[o])}e.code==="Space"&&e.target.tagName!=="INPUT"&&e.target.tagName!=="TEXTAREA"&&(e.preventDefault(),toggleBezelCollapse())});let Le;const zt=8e3;function se(){clearTimeout(Le),window.innerWidth<=768&&!I&&(Le=setTimeout(()=>{console.log("📱 Auto-collapsing bezel due to inactivity"),toggleBezelCollapse()},zt))}document.addEventListener("mousemove",se);document.addEventListener("touchstart",se);document.addEventListener("keypress",se);window.addEventListener("resize",()=>{_e(),se()});window.addEventListener("DOMContentLoaded",()=>{switchBezelTab("controls"),window.innerWidth<=768&&setTimeout(()=>{toggleBezelCollapse()},2e3),console.log("🎛️ Bezel Tab System: Initialized"),console.log("⌨️ Keyboard Shortcuts:"),console.log("  - Ctrl/Cmd + B: Toggle collapse"),console.log("  - Ctrl/Cmd + 1-5: Switch tabs"),console.log("  - Space: Toggle collapse")});function Bt(){localStorage.setItem("vib34d-active-tab",Ue),localStorage.setItem("vib34d-bezel-collapsed",I)}function Ft(){const e=localStorage.getItem("vib34d-active-tab"),t=localStorage.getItem("vib34d-bezel-collapsed");e&&switchBezelTab(e),t==="true"&&!I&&toggleBezelCollapse()}window.addEventListener("beforeunload",Bt);setTimeout(Ft,500);console.log("🎛️ Bezel Tabs Module: Loaded");let $=0,M=0,B=0;const F={base:{index:0,name:"Base",icon:"🔷",color:"#00ffff",range:"0-7"},hypersphere:{index:1,name:"Hypersphere",icon:"🌀",color:"#ff00ff",range:"8-15"},hypertetra:{index:2,name:"Hypertetra",icon:"🔺",color:"#ff8800",range:"16-23"}},X=[{name:"Tetrahedron",icon:"🔺"},{name:"Hypercube",icon:"🟦"},{name:"Sphere",icon:"🔮"},{name:"Torus",icon:"🍩"},{name:"Klein Bottle",icon:"🫙"},{name:"Fractal",icon:"❄️"},{name:"Wave",icon:"🌊"},{name:"Crystal",icon:"💎"}];window.initGeometryTabs=function(){console.log("🎨 Initializing Geometry Tab System..."),Gt(),Ot(),switchCoreType("base"),selectGeometryButton(0),console.log("✅ Geometry Tab System initialized"),console.log("📐 24 geometries available: 8 base × 3 core types")};function Gt(){const e=document.getElementById("coreTabsContainer");if(!e){console.warn("⚠️ Core tabs container not found");return}e.className="core-tabs",e.innerHTML=Object.entries(F).map(([t,o])=>`
        <button
            class="core-tab"
            data-core="${t}"
            onclick="switchCoreType('${t}')"
            title="${o.name} Core (Geometries ${o.range})"
        >
            <div class="core-tab-icon">${o.icon}</div>
            <div class="core-tab-name">${o.name}</div>
            <div class="core-tab-range">${o.range}</div>
        </button>
    `).join("")}function Ot(){const e=document.getElementById("geometryGrid");if(!e){console.warn("⚠️ Geometry grid container not found");return}e.className="geometry-grid",e.innerHTML=X.map((t,o)=>`
        <button
            class="geom-btn"
            data-base-index="${o}"
            onclick="selectGeometryButton(${o})"
            title="${t.name}"
        >
            <div class="geom-icon">${t.icon}</div>
            <div class="geom-name">${t.name}</div>
        </button>
    `).join("")}window.switchCoreType=function(e){console.log(`🔄 Switching core type to: ${e}`);const t=F[e];if(!t){console.error(`❌ Unknown core type: ${e}`);return}$=t.index,document.querySelectorAll(".core-tab").forEach(n=>{n.dataset.core===e?n.classList.add("active"):n.classList.remove("active")});const o=document.querySelector(".geometry-container");o&&(o.dataset.activeCore=e),je(),console.log(`✅ Core type: ${t.name} (index ${$})`),console.log(`📐 Geometry range: ${t.range}`)};window.selectGeometryButton=function(e){if(e<0||e>7){console.error(`❌ Invalid base index: ${e} (must be 0-7)`);return}console.log(`🎯 Selected base geometry: ${X[e].name} (index ${e})`),M=e,document.querySelectorAll(".geom-btn").forEach(t=>{parseInt(t.dataset.baseIndex)===e?t.classList.add("active"):t.classList.remove("active")}),je()};function je(){var o,n;B=$*8+M;const e=(o=Object.values(F).find(i=>i.index===$))==null?void 0:o.name,t=(n=X[M])==null?void 0:n.name;console.log(`🧮 Calculated geometry index: ${B}`),console.log(`   = ${e} (${$}) × 8 + ${t} (${M})`),console.log(`   = ${$*8} + ${M} = ${B}`),window.selectGeometry?(window.selectGeometry(B),console.log(`✅ Applied geometry ${B} to engine`)):console.warn("⚠️ window.selectGeometry() not available yet"),Wt()}function Wt(){var i,a;const e=(i=Object.values(F).find(s=>s.index===$))==null?void 0:i.name,t=(a=X[M])==null?void 0:a.name,o=$===0?t:`${t} + ${e} Core`;document.querySelectorAll("[data-geometry-display]").forEach(s=>{s.textContent=o,s.dataset.geometryIndex=B})}window.loadGeometryFromIndex=function(e){var i;if(e<0||e>23){console.error(`❌ Invalid geometry index: ${e} (must be 0-23)`);return}console.log(`📂 Loading geometry from index: ${e}`);const t=Math.floor(e/8),o=e%8;console.log(`   Decoded: core=${t}, base=${o}`);const n=(i=Object.entries(F).find(([a,s])=>s.index===t))==null?void 0:i[0];if(!n){console.error(`❌ Failed to decode core index: ${t}`);return}switchCoreType(n),selectGeometryButton(o),console.log(`✅ Loaded geometry ${e}: ${X[o].name} + ${F[n].name}`)};window.getGeometryInfo=function(){var o,n;const e=(o=Object.values(F).find(i=>i.index===$))==null?void 0:o.name,t=(n=X[M])==null?void 0:n.name;return{index:B,coreIndex:$,baseIndex:M,coreName:e,baseName:t,fullName:$===0?t:`${t} + ${e} Core`}};document.addEventListener("keydown",e=>{if(e.altKey&&e.key>="1"&&e.key<="3"){e.preventDefault();const o=["base","hypersphere","hypertetra"][parseInt(e.key)-1];o&&switchCoreType(o)}if(e.altKey){const o={q:0,w:1,e:2,r:3,a:4,s:5,d:6,f:7}[e.key.toLowerCase()];o!==void 0&&(e.preventDefault(),selectGeometryButton(o))}});window.addEventListener("DOMContentLoaded",()=>{setTimeout(()=>{typeof initGeometryTabs=="function"&&initGeometryTabs()},100)});console.log("📐 Geometry Tabs Module: Loaded");console.log("⌨️ Keyboard Shortcuts:");console.log("  - Alt + 1-3: Switch core types");console.log("  - Alt + Q,W,E,R,A,S,D,F: Select geometries 0-7");class Ht{constructor(){this.isEnabled=!1,this.isSupported=!1,this.sensitivity=1,this.smoothing=.1,this.dramaticMode=!1,this.currentTilt={alpha:0,beta:0,gamma:0},this.tiltIntensity=0,this.extremeTilt=!1,this.smoothedRotation={rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0},this.baseRotation={rot4dXY:0,rot4dXZ:0,rot4dYZ:0,rot4dXW:0,rot4dYW:0,rot4dZW:0},this.mapping={normal:{alphaGammaToXY:{scale:.006,range:[-180,180],clamp:[-3.14,3.14]},alphaBetaToXZ:{scale:.008,range:[-90,90],clamp:[-1.57,1.57]},betaGammaToYZ:{scale:.008,range:[-90,90],clamp:[-1.57,1.57]},betaToXW:{scale:.01,range:[-45,45],clamp:[-1.5,1.5]},gammaToYW:{scale:.015,range:[-30,30],clamp:[-1.5,1.5]},alphaToZW:{scale:.008,range:[-180,180],clamp:[-2,2]}},dramatic:{alphaGammaToXY:{scale:.048,range:[-180,180],clamp:[-6.28,6.28]},alphaBetaToXZ:{scale:.064,range:[-120,120],clamp:[-6.28,6.28]},betaGammaToYZ:{scale:.064,range:[-120,120],clamp:[-6.28,6.28]},betaToXW:{scale:.08,range:[-120,120],clamp:[-6,6]},gammaToYW:{scale:.12,range:[-120,120],clamp:[-6,6]},alphaToZW:{scale:.064,range:[-180,180],clamp:[-6,6]}}},this.boundHandleDeviceOrientation=this.handleDeviceOrientation.bind(this)}checkSupport(){return this.isSupported="DeviceOrientationEvent"in window,this.isSupported?typeof DeviceOrientationEvent.requestPermission=="function"?(console.log("🎯 DEVICE TILT: iOS device detected - permission required"),"permission-required"):(console.log("🎯 DEVICE TILT: Supported and ready"),!0):(console.warn("🎯 DEVICE TILT: Not supported on this device/browser"),!1)}async requestPermission(){if(typeof DeviceOrientationEvent.requestPermission=="function")try{return await DeviceOrientationEvent.requestPermission()==="granted"?(console.log("🎯 DEVICE TILT: iOS permission granted"),!0):(console.warn("🎯 DEVICE TILT: iOS permission denied"),!1)}catch(t){return console.error("🎯 DEVICE TILT: Permission request failed:",t),!1}return!0}async enable(){return!this.checkSupport()||!await this.requestPermission()?!1:(window.userParameterState&&(this.baseRotation.rot4dXY=window.userParameterState.rot4dXY||0,this.baseRotation.rot4dXZ=window.userParameterState.rot4dXZ||0,this.baseRotation.rot4dYZ=window.userParameterState.rot4dYZ||0,this.baseRotation.rot4dXW=window.userParameterState.rot4dXW||0,this.baseRotation.rot4dYW=window.userParameterState.rot4dYW||0,this.baseRotation.rot4dZW=window.userParameterState.rot4dZW||0),this.smoothedRotation={...this.baseRotation},window.addEventListener("deviceorientation",this.boundHandleDeviceOrientation),this.isEnabled=!0,console.log("🎯 DEVICE TILT: Enabled - tilt your device to control 4D rotation!"),console.log("🎯 Base rotation values:",this.baseRotation),this.showTiltIndicator(!0),!0)}disable(){window.removeEventListener("deviceorientation",this.boundHandleDeviceOrientation),this.isEnabled=!1,window.updateParameter&&(window.updateParameter("rot4dXY",this.baseRotation.rot4dXY),window.updateParameter("rot4dXZ",this.baseRotation.rot4dXZ),window.updateParameter("rot4dYZ",this.baseRotation.rot4dYZ),window.updateParameter("rot4dXW",this.baseRotation.rot4dXW),window.updateParameter("rot4dYW",this.baseRotation.rot4dYW),window.updateParameter("rot4dZW",this.baseRotation.rot4dZW)),console.log("🎯 DEVICE TILT: Disabled - reset to base rotation"),this.showTiltIndicator(!1)}handleDeviceOrientation(t){if(!this.isEnabled)return;const o=(t.alpha||0)*Math.PI/180,n=(t.beta||0)*Math.PI/180,i=(t.gamma||0)*Math.PI/180;this.currentTilt={alpha:o,beta:n,gamma:i};const a=this.mapToRotation(t);this.smoothedRotation.rot4dXY=this.lerp(this.smoothedRotation.rot4dXY,a.rot4dXY,this.smoothing),this.smoothedRotation.rot4dXZ=this.lerp(this.smoothedRotation.rot4dXZ,a.rot4dXZ,this.smoothing),this.smoothedRotation.rot4dYZ=this.lerp(this.smoothedRotation.rot4dYZ,a.rot4dYZ,this.smoothing),this.smoothedRotation.rot4dXW=this.lerp(this.smoothedRotation.rot4dXW,a.rot4dXW,this.smoothing),this.smoothedRotation.rot4dYW=this.lerp(this.smoothedRotation.rot4dYW,a.rot4dYW,this.smoothing),this.smoothedRotation.rot4dZW=this.lerp(this.smoothedRotation.rot4dZW,a.rot4dZW,this.smoothing),window.updateParameter&&(window.updateParameter("rot4dXY",this.smoothedRotation.rot4dXY),window.updateParameter("rot4dXZ",this.smoothedRotation.rot4dXZ),window.updateParameter("rot4dYZ",this.smoothedRotation.rot4dYZ),window.updateParameter("rot4dXW",this.smoothedRotation.rot4dXW),window.updateParameter("rot4dYW",this.smoothedRotation.rot4dYW),window.updateParameter("rot4dZW",this.smoothedRotation.rot4dZW)),this.updateTiltDisplay()}mapToRotation(t){const o=t.beta||0,n=t.gamma||0,i=t.alpha||0,a=this.dramaticMode?this.mapping.dramatic:this.mapping.normal,s=Math.max(-120,Math.min(120,o)),r=Math.max(-120,Math.min(120,n));this.tiltIntensity=Math.sqrt(s*s+r*r)/90,this.extremeTilt=this.tiltIntensity>1;let m=i;m>180&&(m-=360);const l=Math.max(a.alphaGammaToXY.range[0],Math.min(a.alphaGammaToXY.range[1],m)),f=this.baseRotation.rot4dXY+l*a.alphaGammaToXY.scale*this.sensitivity,b=Math.max(a.alphaBetaToXZ.range[0],Math.min(a.alphaBetaToXZ.range[1],o)),w=this.baseRotation.rot4dXZ+b*a.alphaBetaToXZ.scale*this.sensitivity,p=Math.max(a.betaGammaToYZ.range[0],Math.min(a.betaGammaToYZ.range[1],n)),c=this.baseRotation.rot4dYZ+p*a.betaGammaToYZ.scale*this.sensitivity,S=Math.max(a.betaToXW.range[0],Math.min(a.betaToXW.range[1],o)),G=this.baseRotation.rot4dXW+S*a.betaToXW.scale*this.sensitivity,O=Math.max(a.gammaToYW.range[0],Math.min(a.gammaToYW.range[1],n)),W=this.baseRotation.rot4dYW+O*a.gammaToYW.scale*this.sensitivity,x=Math.max(a.alphaToZW.range[0],Math.min(a.alphaToZW.range[1],m)),xe=this.baseRotation.rot4dZW+x*a.alphaToZW.scale*this.sensitivity;return{rot4dXY:Math.max(a.alphaGammaToXY.clamp[0],Math.min(a.alphaGammaToXY.clamp[1],f)),rot4dXZ:Math.max(a.alphaBetaToXZ.clamp[0],Math.min(a.alphaBetaToXZ.clamp[1],w)),rot4dYZ:Math.max(a.betaGammaToYZ.clamp[0],Math.min(a.betaGammaToYZ.clamp[1],c)),rot4dXW:Math.max(a.betaToXW.clamp[0],Math.min(a.betaToXW.clamp[1],G)),rot4dYW:Math.max(a.gammaToYW.clamp[0],Math.min(a.gammaToYW.clamp[1],W)),rot4dZW:Math.max(a.alphaToZW.clamp[0],Math.min(a.alphaToZW.clamp[1],xe))}}lerp(t,o,n){return t+(o-t)*n}updateBaseRotation(t,o,n,i,a,s){this.baseRotation.rot4dXY=t||0,this.baseRotation.rot4dXZ=o||0,this.baseRotation.rot4dYZ=n||0,this.baseRotation.rot4dXW=i||0,this.baseRotation.rot4dYW=a||0,this.baseRotation.rot4dZW=s||0,console.log("🎯 DEVICE TILT: Base rotation updated (all 6 rotations):",this.baseRotation)}setSensitivity(t){this.sensitivity=Math.max(.1,Math.min(3,t)),console.log(`🎯 DEVICE TILT: Sensitivity set to ${this.sensitivity}`)}setSmoothing(t){this.smoothing=Math.max(.01,Math.min(1,t)),console.log(`🎯 DEVICE TILT: Smoothing set to ${this.smoothing}`)}setDramaticMode(t){this.dramaticMode=t,console.log(`🚀 DEVICE TILT: Dramatic mode ${t?"ENABLED - 8x more sensitive!":"disabled - normal sensitivity"}`),this.updateTiltModeDisplay(),t&&this.isEnabled&&console.log("⚠️ DRAMATIC TILTING ACTIVE: Tilt your device carefully - effects are 8x more intense!")}toggleDramaticMode(){return this.setDramaticMode(!this.dramaticMode),this.dramaticMode}showTiltIndicator(t){let o=document.getElementById("tilt-indicator");t&&!o?(o=document.createElement("div"),o.id="tilt-indicator",o.innerHTML=`
                <div class="tilt-status">
                    <div class="tilt-icon">📱</div>
                    <div class="tilt-text">6D Tilt Active</div>
                    <div class="tilt-mode" id="tilt-mode">NORMAL MODE</div>
                    <div class="tilt-values">
                        <div style="color: #0ff; font-weight: bold; margin-top: 4px;">3D Space:</div>
                        <span id="tilt-xy">XY: 0.00</span>
                        <span id="tilt-xz">XZ: 0.00</span>
                        <span id="tilt-yz">YZ: 0.00</span>
                        <div style="color: #0ff; font-weight: bold; margin-top: 4px;">4D Hyperspace:</div>
                        <span id="tilt-xw">XW: 0.00</span>
                        <span id="tilt-yw">YW: 0.00</span>
                        <span id="tilt-zw">ZW: 0.00</span>
                        <span id="tilt-intensity" style="margin-top: 4px;">Intensity: 0.00</span>
                    </div>
                </div>
            `,o.style.cssText=`
                position: fixed;
                top: 10px;
                right: 10px;
                background: rgba(0, 0, 0, 0.8);
                color: #0ff;
                padding: 8px 12px;
                border-radius: 8px;
                font-family: 'Orbitron', monospace;
                font-size: 11px;
                z-index: 10000;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(0, 255, 255, 0.3);
                box-shadow: 0 0 15px rgba(0, 255, 255, 0.2);
            `,document.body.appendChild(o)):!t&&o&&o.remove()}updateTiltDisplay(){const t=document.getElementById("tilt-xy"),o=document.getElementById("tilt-xz"),n=document.getElementById("tilt-yz"),i=document.getElementById("tilt-xw"),a=document.getElementById("tilt-yw"),s=document.getElementById("tilt-zw"),r=document.getElementById("tilt-intensity");t&&(t.textContent=`XY: ${this.smoothedRotation.rot4dXY.toFixed(2)}`),o&&(o.textContent=`XZ: ${this.smoothedRotation.rot4dXZ.toFixed(2)}`),n&&(n.textContent=`YZ: ${this.smoothedRotation.rot4dYZ.toFixed(2)}`),i&&(i.textContent=`XW: ${this.smoothedRotation.rot4dXW.toFixed(2)}`),a&&(a.textContent=`YW: ${this.smoothedRotation.rot4dYW.toFixed(2)}`),s&&(s.textContent=`ZW: ${this.smoothedRotation.rot4dZW.toFixed(2)}`),r&&(r.textContent=`Intensity: ${this.tiltIntensity.toFixed(2)}`,r.style.color=this.extremeTilt?"#ff4444":"#0ff")}updateTiltModeDisplay(){const t=document.getElementById("tilt-mode");t&&(t.textContent=this.dramaticMode?"🚀 DRAMATIC MODE":"NORMAL MODE",t.style.color=this.dramaticMode?"#ff4444":"#0ff",t.style.fontWeight=this.dramaticMode?"bold":"normal")}getStatus(){return{isSupported:this.isSupported,isEnabled:this.isEnabled,sensitivity:this.sensitivity,smoothing:this.smoothing,currentTilt:{...this.currentTilt},smoothedRotation:{...this.smoothedRotation},baseRotation:{...this.baseRotation}}}}typeof window<"u"&&(window.deviceTiltHandler=new Ht,window.enableDeviceTilt=async()=>await window.deviceTiltHandler.enable(),window.disableDeviceTilt=()=>{window.deviceTiltHandler.disable()},window.toggleDeviceTilt=async()=>{const e=document.getElementById("tiltBtn");if(window.deviceTiltHandler.isEnabled)return window.deviceTiltHandler.disable(),e&&(e.style.background="",e.style.color="",e.title="Device Tilt (4D Rotation)"),console.log("🎯 Device tilt disabled"),!1;if(await window.deviceTiltHandler.enable()){if(window.interactivityMenu&&window.interactivityMenu.engine&&(window.interactivityMenu.engine.setActiveInputMode("mouse/touch"),console.log("🎯 Forced interactivity to mouse/touch mode (matches tilt behavior)"),setTimeout(()=>{window.interactivityMenu.updateInputSources&&window.interactivityMenu.updateInputSources()},100)),window.interactivityEnabled!==void 0){window.interactivityEnabled=!0;const o=document.querySelector('[onclick="toggleInteractivity()"]');o&&(o.style.background="rgba(0, 255, 0, 0.3)",o.style.borderColor="#00ff00",o.title="Mouse/Touch Interactions: ON (Auto-enabled by tilt)")}return e&&(e.style.background="linear-gradient(45deg, #00ffff, #0099ff)",e.style.color="#000",e.title="Device Tilt Active + Mouse Movement Mode - Both work together!"),console.log("🎯 Device tilt enabled"),console.log("🖱️ Interactivity forced to mouse movement mode (compatible with tilt)"),!0}else return console.warn("🎯 Device tilt failed to enable - permission may be required"),e&&(e.style.background="rgba(255, 0, 0, 0.3)",e.title="Device Tilt (Permission Required - Click to try again)"),!1},window.setTiltSensitivity=e=>{window.deviceTiltHandler.setSensitivity(e)},window.setDramaticTilting=e=>{window.deviceTiltHandler.setDramaticMode(e)},window.toggleDramaticTilting=()=>window.deviceTiltHandler.toggleDramaticMode(),window.toggleDeviceTiltDramatic=async()=>{if(window.deviceTiltHandler.isEnabled){const e=window.deviceTiltHandler.toggleDramaticMode(),t=document.getElementById("tiltBtn");return t&&(e?(t.style.background="linear-gradient(45deg, #ff4444, #ff0080)",t.title="🚀 DRAMATIC 4D Tilt Active - 8x More Sensitive!"):(t.style.background="linear-gradient(45deg, #00ffff, #0099ff)",t.title="Device Tilt Active - Normal Sensitivity")),e}else{const e=await window.toggleDeviceTilt();if(e){window.deviceTiltHandler.setDramaticMode(!0),console.log("🚀 DRAMATIC TILTING ENABLED: 8x more sensitive! Tilt carefully!");const t=document.getElementById("tiltBtn");t&&(t.style.background="linear-gradient(45deg, #ff4444, #ff0080)",t.title="🚀 DRAMATIC 4D Tilt Active - 8x More Sensitive!")}return e}},console.log("🎯 DEVICE TILT: System loaded with DRAMATIC MODE support! 🚀"));let q=0;function qt(){console.log("🔧 Installing canvas resize fix...");const e=window.toggleBezelCollapse;window.toggleBezelCollapse=function(){e&&e(),setTimeout(()=>{ue()},100)};let t;window.addEventListener("resize",()=>{clearTimeout(t),t=setTimeout(ue,150)}),console.log("✅ Canvas resize fix installed")}function ue(){const e=document.getElementById("canvasContainer");if(!e)return;const t=e.getBoundingClientRect(),o=t.width,n=t.height;console.log(`📐 Resizing canvases to ${o}x${n}px`),e.querySelectorAll("canvas").forEach(a=>{a.style.display!=="none"&&(a.width=o,a.height=n,a.style.width=`${o}px`,a.style.height=`${n}px`)}),window.vib34dApp&&window.vib34dApp.currentEngine&&(window.vib34dApp.currentEngine.handleResize&&window.vib34dApp.currentEngine.handleResize(o,n),window.vib34dApp.currentEngine.render&&window.vib34dApp.currentEngine.render())}function Nt(){console.log("🔧 Installing geometry persistence fix...");const e=window.selectGeometry;window.selectGeometry=function(o){if(q=o,console.log(`💾 Stored geometry selection: ${o}`),ge(o),e)return e(o)};const t=window.switchSystem;window.switchSystem=async function(o){console.log(`🔄 Switching to ${o}, will apply geometry ${q}`);const n=await t(o);return setTimeout(()=>{console.log(`📐 Applying persistent geometry ${q} to ${o}`),window.loadGeometryFromIndex?window.loadGeometryFromIndex(q):window.selectGeometry&&window.selectGeometry(q),ge(q)},300),n},console.log("✅ Geometry persistence fix installed")}function ge(e){const t=Math.floor(e/8),o=e%8;console.log(`🎨 Highlighting button: core=${t}, base=${o}`),document.querySelectorAll(".core-tab").forEach(i=>{const a=i.dataset.core;({base:0,hypersphere:1,hypertetra:2})[a]===t?i.classList.add("active"):i.classList.remove("active")}),document.querySelectorAll(".geom-btn").forEach(i=>{parseInt(i.dataset.baseIndex)===o?i.classList.add("active"):i.classList.remove("active")});const n=document.querySelector(".geometry-container");if(n){const i=["base","hypersphere","hypertetra"][t];n.dataset.activeCore=i}}function Yt(){if(console.log("🔧 Enhancing 4D tilt mechanics..."),!window.deviceTiltHandler){console.warn("⚠️ Device tilt handler not available");return}window.deviceTiltHandler.setSensitivity(2.5),window.deviceTiltHandler.setSmoothing(.15);const e=window.deviceTiltHandler.enable.bind(window.deviceTiltHandler);if(window.deviceTiltHandler.enable=async function(){const t=await e();return t&&setTimeout(()=>{this.setDramaticMode(!0),console.log("🚀 Auto-enabled DRAMATIC tilting mode for better effect")},100),t},window.deviceTiltHandler.mapping&&window.deviceTiltHandler.mapping.dramatic){const t=window.deviceTiltHandler.mapping.dramatic;t.alphaGammaToXY.scale*=1.5,t.alphaBetaToXZ.scale*=1.5,t.betaGammaToYZ.scale*=1.5,t.betaToXW.scale*=1.5,t.gammaToYW.scale*=1.5,t.alphaToZW.scale*=1.5,console.log("🚀 Tilt mapping scales increased by 1.5x for more dramatic effect")}console.log("✅ Tilt mechanics enhanced: 2.5x sensitivity, 0.15 smoothing, dramatic mode auto-enabled")}function Xt(){console.log("🔧 Adding randomize buttons to tabs..."),document.querySelectorAll(".bezel-content").forEach((t,o)=>{const n=t.id;if(t.querySelector(".tab-randomize-buttons"))return;const i=document.createElement("div");i.className="tab-randomize-buttons",i.style.cssText=`
            position: sticky;
            top: 0;
            left: 0;
            right: 0;
            display: flex;
            gap: 8px;
            padding: 10px 0;
            margin-bottom: 15px;
            background: rgba(0, 0, 0, 0.8);
            border-bottom: 1px solid rgba(0, 255, 255, 0.15);
            z-index: 10;
            backdrop-filter: blur(10px);
        `;const a=document.createElement("button");a.className="tab-random-btn randomize-all",a.innerHTML="🎲 Randomize All",a.style.cssText=`
            flex: 1;
            padding: 8px 12px;
            background: linear-gradient(135deg, rgba(255, 0, 255, 0.15), rgba(200, 0, 255, 0.15));
            border: 1px solid rgba(255, 0, 255, 0.3);
            border-radius: 6px;
            color: #ff00ff;
            font-family: 'Orbitron', monospace;
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        `,a.onclick=()=>{window.randomizeEverything&&window.randomizeEverything()};const s=document.createElement("button");s.className="tab-random-btn randomize-tab",s.innerHTML="🎯 Random Tab",s.style.cssText=`
            flex: 1;
            padding: 8px 12px;
            background: linear-gradient(135deg, rgba(0, 255, 255, 0.15), rgba(0, 200, 255, 0.15));
            border: 1px solid rgba(0, 255, 255, 0.3);
            border-radius: 6px;
            color: #00ffff;
            font-family: 'Orbitron', monospace;
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        `,s.onclick=()=>{Ke(n)};const r=(l,f)=>{l.addEventListener("mouseenter",()=>{l.style.transform="scale(1.05)",l.style.boxShadow=`0 0 15px ${f}`}),l.addEventListener("mouseleave",()=>{l.style.transform="scale(1)",l.style.boxShadow="none"})};r(a,"rgba(255, 0, 255, 0.4)"),r(s,"rgba(0, 255, 255, 0.4)"),i.appendChild(a),i.appendChild(s);const m=t.querySelector(".tab-content-grid");m?t.insertBefore(i,m):t.insertBefore(i,t.firstChild)}),console.log("✅ Randomize buttons added to all tabs")}function Ke(e){console.log(`🎯 Randomizing tab: ${e}`);const t=(o,n)=>o+Math.random()*(n-o);switch(e){case"controls-content":window.updateParameter("rot4dXY",t(-6.28,6.28)),window.updateParameter("rot4dXZ",t(-6.28,6.28)),window.updateParameter("rot4dYZ",t(-6.28,6.28)),window.updateParameter("rot4dXW",t(-6.28,6.28)),window.updateParameter("rot4dYW",t(-6.28,6.28)),window.updateParameter("rot4dZW",t(-6.28,6.28)),window.updateParameter("gridDensity",Math.floor(t(5,100))),window.updateParameter("morphFactor",t(0,2)),window.updateParameter("chaos",t(0,1)),window.updateParameter("speed",t(.1,3)),console.log("✅ Randomized rotation & visual parameters");break;case"color-content":window.updateParameter("hue",Math.floor(t(0,360))),window.updateParameter("saturation",t(0,1)),window.updateParameter("intensity",t(0,1)),console.log("✅ Randomized color parameters");break;case"geometry-content":const o=Math.floor(t(0,24));window.loadGeometryFromIndex?window.loadGeometryFromIndex(o):window.selectGeometry&&window.selectGeometry(o),console.log(`✅ Randomized geometry to #${o}`);break;case"reactivity-content":const n=["faceted","quantum","holographic"],i=["mouse","click","scroll"];n.forEach(a=>{i.forEach(s=>{const r=document.getElementById(`${a}${s.charAt(0).toUpperCase()+s.slice(1)}`);r&&(r.checked=Math.random()>.5,r.dispatchEvent(new Event("change")))})}),console.log("✅ Randomized reactivity settings");break;default:console.log("⚠️ No randomization defined for this tab");break}}function Zt(){console.log("🚀 Initializing UI Fixes Module..."),document.readyState==="loading"?document.addEventListener("DOMContentLoaded",()=>{Me()}):Me()}function Me(){setTimeout(()=>qt(),100),setTimeout(()=>Nt(),200),setTimeout(()=>Yt(),300),setTimeout(()=>Xt(),500),console.log("✅ All UI fixes initialized successfully")}Zt();typeof window<"u"&&(window.resizeAllCanvases=ue,window.updateGeometryButtonHighlight=ge,window.randomizeCurrentTab=Ke);console.log("🔧 UI Fixes Module: Loaded");console.log("🎨 Geometric Icons Module: Loading...");const D={faceted:"#00ffff",quantum:"#ff00ff",holographic:"#ff64ff",polychora:"#ffff00",base:"#00ffff",hypersphere:"#ff00ff",hypertetra:"#ff8800"},Qe={faceted:(e=D.faceted)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2 L22 8 L22 16 L12 22 L2 16 L2 8 Z"
                  stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <path d="M12 2 L12 22 M2 8 L22 16 M22 8 L2 16"
                  stroke="${e}" stroke-width="1" opacity="0.4"/>
        </svg>
    `,quantum:(e=D.quantum)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="8" stroke="${e}" stroke-width="2" opacity="0.3"/>
            <circle cx="12" cy="12" r="5" stroke="${e}" stroke-width="2" opacity="0.5"/>
            <circle cx="12" cy="12" r="2" fill="${e}" opacity="0.8"/>
            <path d="M12 4 L12 20 M4 12 L20 12" stroke="${e}" stroke-width="1" opacity="0.4"/>
            <circle cx="12" cy="4" r="1.5" fill="${e}"/>
            <circle cx="20" cy="12" r="1.5" fill="${e}"/>
            <circle cx="12" cy="20" r="1.5" fill="${e}"/>
            <circle cx="4" cy="12" r="1.5" fill="${e}"/>
        </svg>
    `,holographic:(e=D.holographic)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M3 12 Q7 6, 12 12 T21 12" stroke="${e}" stroke-width="2" fill="none" opacity="0.6"/>
            <path d="M3 10 Q7 4, 12 10 T21 10" stroke="${e}" stroke-width="1.5" fill="none" opacity="0.4"/>
            <path d="M3 14 Q7 8, 12 14 T21 14" stroke="${e}" stroke-width="1.5" fill="none" opacity="0.4"/>
            <circle cx="12" cy="12" r="3" stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <circle cx="12" cy="12" r="1" fill="${e}" opacity="1"/>
        </svg>
    `,polychora:(e=D.polychora)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2 L20 7 L20 17 L12 22 L4 17 L4 7 Z"
                  stroke="${e}" stroke-width="2" fill="none" opacity="0.6"/>
            <path d="M8 9 L16 9 L16 15 L8 15 Z"
                  stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <path d="M12 2 L12 9 M12 15 L12 22 M4 7 L8 9 M20 7 L16 9 M4 17 L8 15 M20 17 L16 15"
                  stroke="${e}" stroke-width="1" opacity="0.4"/>
        </svg>
    `,save:(e="#00ff00")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"
                  stroke="${e}" stroke-width="2"/>
            <path d="M17 21v-8H7v8M7 3v5h8" stroke="${e}" stroke-width="2"/>
            <circle cx="12" cy="14" r="2" fill="${e}" opacity="0.8"/>
        </svg>
    `,gallery:(e="#ff00ff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="3" y="3" width="7" height="7" stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <rect x="14" y="3" width="7" height="7" stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <rect x="3" y="14" width="7" height="7" stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <rect x="14" y="14" width="7" height="7" stroke="${e}" stroke-width="2" fill="none" opacity="0.8"/>
            <circle cx="6.5" cy="6.5" r="1.5" fill="${e}"/>
            <circle cx="17.5" cy="6.5" r="1.5" fill="${e}"/>
            <circle cx="6.5" cy="17.5" r="1.5" fill="${e}"/>
            <circle cx="17.5" cy="17.5" r="1.5" fill="${e}"/>
        </svg>
    `,audio:(e="#ffff00")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M9 9v6l-3 2v-10l3 2z" fill="${e}" opacity="0.8"/>
            <path d="M15 5 Q18 8, 15 11" stroke="${e}" stroke-width="2" stroke-linecap="round" opacity="0.6"/>
            <path d="M15 9 Q19 12, 15 15" stroke="${e}" stroke-width="2" stroke-linecap="round" opacity="0.8"/>
            <path d="M15 13 Q21 12, 15 19" stroke="${e}" stroke-width="2" stroke-linecap="round" opacity="0.6"/>
        </svg>
    `,tilt:(e="#00ffff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="6" y="8" width="12" height="8" stroke="${e}" stroke-width="2" fill="none" opacity="0.6" transform="rotate(-15 12 12)"/>
            <circle cx="12" cy="12" r="2" fill="${e}" opacity="0.8"/>
            <path d="M12 2 L12 6 M12 18 L12 22 M2 12 L6 12 M18 12 L22 12"
                  stroke="${e}" stroke-width="2" stroke-linecap="round" opacity="0.4"/>
        </svg>
    `,ai:(e="#ff64ff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="9" stroke="${e}" stroke-width="2" fill="none" opacity="0.4"/>
            <circle cx="8" cy="10" r="1.5" fill="${e}"/>
            <circle cx="16" cy="10" r="1.5" fill="${e}"/>
            <path d="M8 15 Q12 17, 16 15" stroke="${e}" stroke-width="2" stroke-linecap="round" fill="none"/>
            <path d="M4 6 L8 4 M20 6 L16 4 M4 18 L8 20 M20 18 L16 20"
                  stroke="${e}" stroke-width="1.5" stroke-linecap="round" opacity="0.6"/>
        </svg>
    `,interactivity:(e="#00ffff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="8" stroke="${e}" stroke-width="2" fill="none" opacity="0.4"/>
            <text x="12" y="16" font-family="Orbitron" font-size="12" font-weight="bold"
                  fill="${e}" text-anchor="middle">I</text>
        </svg>
    `,base:(e=D.base)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="8" stroke="${e}" stroke-width="2" fill="none" opacity="0.6"/>
            <circle cx="12" cy="12" r="2" fill="${e}" opacity="0.8"/>
        </svg>
    `,hypersphere:(e=D.hypersphere)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="9" stroke="${e}" stroke-width="2" fill="none" opacity="0.3"/>
            <ellipse cx="12" cy="12" rx="9" ry="4" stroke="${e}" stroke-width="1.5" fill="none" opacity="0.5"/>
            <ellipse cx="12" cy="12" rx="4" ry="9" stroke="${e}" stroke-width="1.5" fill="none" opacity="0.5"/>
            <circle cx="12" cy="12" r="3" fill="${e}" opacity="0.8"/>
        </svg>
    `,hypertetra:(e=D.hypertetra)=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 3 L21 15 L12 21 L3 15 Z"
                  stroke="${e}" stroke-width="2" fill="none" opacity="0.6"/>
            <path d="M12 3 L12 21 M3 15 L21 15"
                  stroke="${e}" stroke-width="1" opacity="0.4"/>
            <circle cx="12" cy="12" r="2" fill="${e}" opacity="0.8"/>
        </svg>
    `,randomizeAll:(e="#ff00ff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="5" y="5" width="5" height="5" fill="${e}" opacity="0.8" transform="rotate(15 7.5 7.5)"/>
            <rect x="14" y="5" width="5" height="5" fill="${e}" opacity="0.6" transform="rotate(-15 16.5 7.5)"/>
            <rect x="5" y="14" width="5" height="5" fill="${e}" opacity="0.6" transform="rotate(-15 7.5 16.5)"/>
            <rect x="14" y="14" width="5" height="5" fill="${e}" opacity="0.8" transform="rotate(15 16.5 16.5)"/>
            <circle cx="12" cy="12" r="2" fill="${e}"/>
        </svg>
    `,randomizeTab:(e="#00ffff")=>`
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 3 L19 7 L19 17 L12 21 L5 17 L5 7 Z"
                  stroke="${e}" stroke-width="2" fill="none" opacity="0.6"/>
            <path d="M8 10 L16 10 M8 12 L16 12 M8 14 L16 14"
                  stroke="${e}" stroke-width="2" stroke-linecap="round" opacity="0.8"/>
            <circle cx="12" cy="12" r="1" fill="${e}"/>
        </svg>
    `};function U(e,t=24,o=null){const n=Qe[e];if(!n)return console.warn(`⚠️ Icon '${e}' not found`),null;const i=n(o),a=document.createElement("span");return a.className=`vib-icon vib-icon-${e}`,a.style.cssText=`
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: ${t}px;
        height: ${t}px;
    `,a.innerHTML=i,a}function Q(e,t){const o=e.textContent.trim();for(const[n,i]of Object.entries(t))if(o.includes(n)){const a=e.classList.contains("system-icon")?24:e.classList.contains("tab-icon")?20:18,s=U(i,a);if(s){e.innerHTML="",e.appendChild(s);const r=o.replace(n,"").trim();if(r){const m=document.createElement("span");m.textContent=r,e.appendChild(m)}}break}}function te(){console.log("🔄 Replacing all emojis with geometric SVG icons...");const e={"🔷":"faceted","🌌":"quantum","✨":"holographic","🔮":"polychora","💾":"save","🖼️":"gallery","🎵":"audio","📱":"tilt","🤖":"ai",I:"interactivity","🌀":"hypersphere","🔺":"hypertetra","🎲":"randomizeAll","🎯":"randomizeTab"};document.querySelectorAll(".system-icon").forEach(o=>{Q(o,e)}),document.querySelectorAll(".action-btn").forEach(o=>{o.textContent.trim().length<=2&&Q(o,e)});const t=document.querySelector(".save-btn");if(t){const o=t.textContent.trim().split(" ")[0];if(e[o]){const n=U(e[o],20,"#00ff00");if(n){t.innerHTML="",t.appendChild(n);const i=document.createElement("span");i.textContent=" SAVE",t.appendChild(i)}}}document.querySelectorAll(".tab-icon").forEach(o=>{Q(o,e)}),document.querySelectorAll(".core-tab-icon").forEach(o=>{Q(o,e)}),document.querySelectorAll(".tab-random-btn").forEach(o=>{const n=o.textContent;if(n.includes("🎲")){const i=U("randomizeAll",16,"#ff00ff");if(i){o.innerHTML="",o.appendChild(i);const a=document.createElement("span");a.textContent=" Randomize All",a.style.marginLeft="6px",o.appendChild(a)}}else if(n.includes("🎯")){const i=U("randomizeTab",16,"#00ffff");if(i){o.innerHTML="",o.appendChild(i);const a=document.createElement("span");a.textContent=" Random Tab",a.style.marginLeft="6px",o.appendChild(a)}}}),console.log("✅ All emojis replaced with geometric SVG icons")}function Vt(){document.readyState==="loading"?document.addEventListener("DOMContentLoaded",()=>{setTimeout(te,1e3)}):setTimeout(te,1e3);const e=new MutationObserver(t=>{t.forEach(o=>{o.addedNodes.forEach(n=>{n.classList&&n.classList.contains("tab-randomize-buttons")&&setTimeout(()=>{te()},100)})})});setTimeout(()=>{e.observe(document.body,{childList:!0,subtree:!0})},500)}Vt();typeof window<"u"&&(window.createIcon=U,window.replaceAllEmojisWithIcons=te,window.GEOMETRIC_ICONS=Qe);console.log("🎨 Geometric Icons Module: Loaded");console.log("🔧 Comprehensive Fixes Module: Loading...");let Ae=null;function ie(){const e=document.getElementById("canvasContainer"),t=document.getElementById("controlPanel");if(!e||!t)return;const o=t.classList.contains("collapsed"),n=60;let i;o?i=52:i=t.offsetHeight,console.log(`📐 Force canvas resize: ${o?"collapsed":"expanded"}, bottom=${i}px`),e.style.top=`${n}px`,e.style.bottom=`${i}px`,e.style.left="0",e.style.right="0",e.offsetHeight;const a=e.getBoundingClientRect(),s=a.width,r=a.height;console.log(`📐 Canvas container: ${s}x${r}px`),e.querySelectorAll("canvas").forEach(l=>{l.width=s,l.height=r,l.style.width=`${s}px`,l.style.height=`${r}px`}),window.vib34dApp&&window.vib34dApp.currentEngine&&setTimeout(()=>{window.vib34dApp.currentEngine.handleResize&&window.vib34dApp.currentEngine.handleResize(s,r),window.vib34dApp.currentEngine.render&&window.vib34dApp.currentEngine.render()},50)}function Ut(){const e=document.getElementById("controlPanel");if(!e){console.warn("⚠️ Control panel not found for resize observer");return}Ae=new MutationObserver(t=>{t.forEach(o=>{o.attributeName==="class"&&(console.log("🔄 Bezel class changed, forcing canvas resize..."),setTimeout(ie,100))})}),Ae.observe(e,{attributes:!0,attributeFilter:["class"]}),console.log("✅ Canvas resize observer installed"),setTimeout(ie,500)}let ke;window.addEventListener("resize",()=>{clearTimeout(ke),ke=setTimeout(ie,200)});function ve(e,t,o=500){const n=document.getElementById(e);if(!n)return;const i=parseFloat(n.value),a=parseFloat(t),s=performance.now();function r(m){const l=m-s,f=Math.min(l/o,1),b=1-Math.pow(1-f,3),w=i+(a-i)*b;n.value=w;const p=new Event("input",{bubbles:!0});n.dispatchEvent(p),f<1&&requestAnimationFrame(r)}requestAnimationFrame(r)}const Re=window.updateParameter;window.updateParameter=function(e,t,o=!1){o?ve(e,t):Re&&Re(e,t)};window.randomizeAll=function(){console.log("🎲 Randomizing with animations..."),["rot4dXY","rot4dXZ","rot4dYZ","rot4dXW","rot4dYW","rot4dZW","gridDensity","morphFactor","chaos","speed","hue","saturation","intensity"].forEach((t,o)=>{const n=document.getElementById(t);if(!n)return;const i=parseFloat(n.min),a=parseFloat(n.max),s=i+Math.random()*(a-i);setTimeout(()=>{ve(t,s,800)},o*50)}),console.log("✅ Animated randomization complete")};window.randomizeEverything=function(){console.log("🎯 Full randomize with animations...");const e=["faceted","quantum","holographic","polychora"],t=e[Math.floor(Math.random()*e.length)];window.switchSystem&&window.switchSystem(t);const o=Math.floor(Math.random()*24);setTimeout(()=>{window.loadGeometryFromIndex?window.loadGeometryFromIndex(o):window.selectGeometry&&window.selectGeometry(o)},300),setTimeout(()=>{window.randomizeAll()},600),console.log(`✅ Full randomization: ${t}, geometry ${o}`)};window.saveToGallery=function(){console.log("💾 Saving to gallery with fixes...");try{const e={system:window.currentSystem||"faceted",parameters:window.userParameterState||{},timestamp:new Date().toISOString(),name:`${window.currentSystem||"Unnamed"} - ${new Date().toLocaleString()}`};if(window.getGeometryInfo){const i=window.getGeometryInfo();e.parameters.geometry=i.index,e.geometryName=i.fullName}const t=Date.now().toString(36)+Math.random().toString(36).substr(2,5),o=`vib34d-variation-${t}`;return localStorage.setItem(o,JSON.stringify(e)),console.log(`✅ Saved variation ${t}:`,e),console.log(`📦 LocalStorage key: ${o}`),fe(`✅ Saved: ${e.name}`,"success"),localStorage.getItem(o)?console.log("✅ Save verified in localStorage"):console.error("❌ Save verification failed!"),t}catch(e){return console.error("❌ Save failed:",e),fe(`❌ Save failed: ${e.message}`,"error"),null}};function fe(e,t="success"){const o=document.createElement("div");o.style.cssText=`
        position: fixed;
        top: 80px;
        right: 20px;
        background: ${t==="success"?"linear-gradient(135deg, rgba(0, 255, 0, 0.95), rgba(0, 200, 100, 0.95))":"linear-gradient(135deg, rgba(255, 0, 0, 0.95), rgba(200, 0, 0, 0.95))"};
        color: ${t==="success"?"#000":"#fff"};
        padding: 15px 25px;
        border-radius: 10px;
        font-family: 'Orbitron', monospace;
        font-weight: bold;
        font-size: 0.9rem;
        z-index: 10001;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        animation: slideInRight 0.3s ease-out;
    `,o.textContent=e;const n=document.createElement("style");n.textContent=`
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `,document.head.appendChild(n),document.body.appendChild(o),setTimeout(()=>{o.style.animation="slideOutRight 0.3s ease-in",setTimeout(()=>o.remove(),300)},3e3)}function _t(){try{const e="vib34d-test";localStorage.setItem(e,"test");const t=localStorage.getItem(e);return localStorage.removeItem(e),t==="test"?(console.log("✅ LocalStorage is working"),!0):(console.error("❌ LocalStorage read/write mismatch"),!1)}catch(e){return console.error("❌ LocalStorage not available:",e),!1}}function jt(){console.log("🚀 Initializing Comprehensive Fixes..."),document.readyState==="loading"?document.addEventListener("DOMContentLoaded",Pe):Pe()}function Pe(){_t()||console.error("⚠️ LocalStorage is not working - save functionality will be limited"),setTimeout(()=>{Ut(),console.log("✅ Canvas resize observer initialized")},500),setTimeout(()=>{const t=Object.keys(localStorage).filter(o=>o.startsWith("vib34d-variation-"));console.log(`📦 Found ${t.length} saved variations:`,t)},1e3),console.log("✅ All comprehensive fixes applied")}jt();typeof window<"u"&&(window.forceCanvasResize=ie,window.animateSlider=ve,window.showSaveNotification=fe);console.log("🔧 Comprehensive Fixes Module: Loaded");console.log("⌨️ Global Shortcuts Module: Loading...");let be=!0,Z=!1,pe=null;const Kt={systems:{title:"System Switching",shortcuts:[{keys:["1"],action:"switchToFaceted",desc:"Switch to Faceted System"},{keys:["2"],action:"switchToQuantum",desc:"Switch to Quantum System"},{keys:["3"],action:"switchToHolographic",desc:"Switch to Holographic System"},{keys:["4"],action:"switchToPolychora",desc:"Switch to Polychora System"}]},tabs:{title:"Tab Navigation",shortcuts:[{keys:["Ctrl","B"],action:"toggleBezel",desc:"Toggle Bezel Collapse"},{keys:["Space"],action:"toggleBezel",desc:"Toggle Bezel (alt)"},{keys:["Ctrl","1"],action:"openControlsTab",desc:"Open Controls Tab"},{keys:["Ctrl","2"],action:"openColorTab",desc:"Open Color Tab"},{keys:["Ctrl","3"],action:"openGeometryTab",desc:"Open Geometry Tab"},{keys:["Ctrl","4"],action:"openReactivityTab",desc:"Open Reactivity Tab"},{keys:["Ctrl","5"],action:"openExportTab",desc:"Open Export Tab"}]},geometry:{title:"Geometry Selection",shortcuts:[{keys:["Alt","1"],action:"baseCore",desc:"Switch to Base Core"},{keys:["Alt","2"],action:"hypersphereCore",desc:"Switch to Hypersphere Core"},{keys:["Alt","3"],action:"hypertetraCore",desc:"Switch to Hypertetra Core"},{keys:["Alt","Q"],action:"tetrahedron",desc:"Select Tetrahedron"},{keys:["Alt","W"],action:"hypercube",desc:"Select Hypercube"},{keys:["Alt","E"],action:"sphere",desc:"Select Sphere"},{keys:["Alt","R"],action:"torus",desc:"Select Torus"},{keys:["Alt","A"],action:"kleinBottle",desc:"Select Klein Bottle"},{keys:["Alt","S"],action:"fractal",desc:"Select Fractal"},{keys:["Alt","D"],action:"wave",desc:"Select Wave"},{keys:["Alt","F"],action:"crystal",desc:"Select Crystal"}]},actions:{title:"Actions",shortcuts:[{keys:["Ctrl","S"],action:"saveToGallery",desc:"Save to Gallery"},{keys:["Ctrl","G"],action:"openGallery",desc:"Open Gallery"},{keys:["Ctrl","R"],action:"randomizeAll",desc:"Randomize All Parameters"},{keys:["Ctrl","Shift","R"],action:"randomizeEverything",desc:"Randomize Everything"},{keys:["Ctrl","Shift","Z"],action:"resetAll",desc:"Reset All Parameters"},{keys:["Ctrl","E"],action:"exportCard",desc:"Export Trading Card"}]},features:{title:"Feature Toggles",shortcuts:[{keys:["A"],action:"toggleAudio",desc:"Toggle Audio Reactivity"},{keys:["T"],action:"toggleTilt",desc:"Toggle Device Tilt"},{keys:["I"],action:"toggleInteractivity",desc:"Toggle Interactivity"},{keys:["F"],action:"toggleFullscreen",desc:"Toggle Fullscreen"},{keys:["H"],action:"toggleHelp",desc:"Toggle Shortcuts Help"}]},navigation:{title:"Navigation",shortcuts:[{keys:["←"],action:"previousGeometry",desc:"Previous Geometry"},{keys:["→"],action:"nextGeometry",desc:"Next Geometry"},{keys:["↑"],action:"nextSystem",desc:"Next System"},{keys:["↓"],action:"previousSystem",desc:"Previous System"}]}};function De(){console.log("🎹 Initializing global shortcuts..."),eo(),document.addEventListener("keydown",Qt),console.log("✅ Global shortcuts initialized"),console.log("📋 Press H to view all shortcuts")}function Qt(e){if(be&&!((e.target.tagName==="INPUT"||e.target.tagName==="TEXTAREA")&&!e.ctrlKey&&!e.metaKey)){if(!e.ctrlKey&&!e.altKey&&!e.shiftKey&&!e.metaKey){if(e.key==="1"&&window.switchSystem){e.preventDefault(),window.switchSystem("faceted");return}if(e.key==="2"&&window.switchSystem){e.preventDefault(),window.switchSystem("quantum");return}if(e.key==="3"&&window.switchSystem){e.preventDefault(),window.switchSystem("holographic");return}if(e.key==="4"&&window.switchSystem){e.preventDefault(),window.switchSystem("polychora");return}if(e.key.toLowerCase()==="a"&&window.toggleAudio){e.preventDefault(),window.toggleAudio();return}if(e.key.toLowerCase()==="t"&&window.toggleDeviceTilt){e.preventDefault(),window.toggleDeviceTilt();return}if(e.key.toLowerCase()==="i"&&window.toggleInteractivity){e.preventDefault(),window.toggleInteractivity();return}if(e.key.toLowerCase()==="f"){e.preventDefault(),Jt();return}if(e.key.toLowerCase()==="h"){e.preventDefault(),ae();return}}if(e.ctrlKey||e.metaKey){if(e.key==="s"&&window.saveToGallery){e.preventDefault(),window.saveToGallery();return}if(e.key==="g"&&window.openGallery){e.preventDefault(),window.openGallery();return}if(e.key==="r"){e.preventDefault(),e.shiftKey&&window.randomizeEverything?window.randomizeEverything():window.randomizeAll&&window.randomizeAll();return}if(e.key==="z"&&e.shiftKey&&window.resetAll){e.preventDefault(),window.resetAll();return}if(e.key==="e"&&window.createTradingCard){e.preventDefault(),window.createTradingCard();return}}if(!e.ctrlKey&&!e.altKey&&!e.shiftKey){if(e.key==="ArrowLeft"){e.preventDefault(),ze(-1);return}if(e.key==="ArrowRight"){e.preventDefault(),ze(1);return}if(e.key==="ArrowUp"){e.preventDefault(),Be(1);return}if(e.key==="ArrowDown"){e.preventDefault(),Be(-1);return}}}}function ze(e){const t=window.getGeometryInfo?window.getGeometryInfo().index:0;let o=t+e;o<0&&(o=23),o>23&&(o=0),console.log(`➡️ Navigating from geometry ${t} to ${o}`),window.loadGeometryFromIndex&&window.loadGeometryFromIndex(o)}function Be(e){const t=["faceted","quantum","holographic","polychora"],o=window.currentSystem||"faceted";let i=t.indexOf(o)+e;i<0&&(i=t.length-1),i>=t.length&&(i=0),console.log(`➡️ Navigating from ${o} to ${t[i]}`),window.switchSystem&&window.switchSystem(t[i])}function Jt(){document.fullscreenElement?document.exitFullscreen().then(()=>{console.log("🖥️ Exited fullscreen mode"),Fe("Fullscreen Mode Disabled","","info")}):document.documentElement.requestFullscreen().then(()=>{console.log("🖥️ Entered fullscreen mode"),Fe("Fullscreen Mode Enabled","Press F to exit","info")}).catch(e=>{console.error("❌ Failed to enter fullscreen:",e)})}function eo(){const e=document.createElement("div");e.id="shortcuts-help-modal",e.style.cssText=`
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0, 0, 0, 0.95);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 10000;
        font-family: 'Orbitron', monospace;
    `;const t=document.createElement("div");t.style.cssText=`
        background: linear-gradient(135deg, rgba(0, 30, 60, 0.95), rgba(0, 15, 30, 0.95));
        border: 2px solid #00ffff;
        border-radius: 15px;
        padding: 30px;
        max-width: 900px;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 0 40px rgba(0, 255, 255, 0.3);
    `;let o=`
        <h2 style="color: #00ffff; text-align: center; margin-bottom: 25px; font-size: 1.8rem;">
            ⌨️ VIB3+ KEYBOARD SHORTCUTS
        </h2>
        <p style="color: #888; text-align: center; margin-bottom: 30px; font-size: 0.85rem;">
            Master the VIB3+ Engine with comprehensive keyboard control
        </p>
    `;Object.entries(Kt).forEach(([n,i])=>{o+=`
            <div style="margin-bottom: 25px;">
                <h3 style="color: #ff00ff; font-size: 1.1rem; margin-bottom: 12px; border-bottom: 1px solid rgba(255, 0, 255, 0.3); padding-bottom: 5px;">
                    ${i.title}
                </h3>
                <div style="display: grid; grid-template-columns: 200px 1fr; gap: 8px; font-size: 0.85rem;">
        `,i.shortcuts.forEach(a=>{const s=a.keys.map(r=>`<kbd style="background: rgba(0, 255, 255, 0.15); border: 1px solid rgba(0, 255, 255, 0.3); padding: 2px 8px; border-radius: 3px; font-size: 0.75rem; color: #00ffff;">${r}</kbd>`).join(" + ");o+=`
                <div style="color: #fff;">${s}</div>
                <div style="color: #aaa;">${a.desc}</div>
            `}),o+=`
                </div>
            </div>
        `}),o+=`
        <div style="text-align: center; margin-top: 25px;">
            <button onclick="toggleShortcutsHelp()" style="
                background: linear-gradient(135deg, rgba(0, 255, 255, 0.2), rgba(0, 200, 255, 0.2));
                border: 1px solid #00ffff;
                color: #00ffff;
                padding: 10px 30px;
                border-radius: 8px;
                font-family: 'Orbitron', monospace;
                font-size: 0.9rem;
                cursor: pointer;
                font-weight: bold;
            ">CLOSE (H or ESC)</button>
        </div>
    `,t.innerHTML=o,e.appendChild(t),document.body.appendChild(e),e.addEventListener("click",n=>{n.target===e&&ae()}),document.addEventListener("keydown",n=>{n.key==="Escape"&&Z&&(n.preventDefault(),ae())}),pe=e}function ae(){pe&&(Z=!Z,pe.style.display=Z?"flex":"none",console.log(`⌨️ Shortcuts help ${Z?"shown":"hidden"}`))}function Fe(e,t,o="info"){const n={success:{bg:"#00ff00",border:"#00cc00"},error:{bg:"#ff0000",border:"#cc0000"},info:{bg:"#00ffff",border:"#00cccc"},warning:{bg:"#ffff00",border:"#cccc00"}},i=n[o]||n.info,a=document.createElement("div");a.style.cssText=`
        position: fixed;
        top: 80px;
        right: 20px;
        background: rgba(0, 0, 0, 0.95);
        border: 2px solid ${i.border};
        border-radius: 10px;
        padding: 15px 20px;
        color: ${i.bg};
        font-family: 'Orbitron', monospace;
        font-size: 0.85rem;
        z-index: 9999;
        box-shadow: 0 0 20px ${i.bg}40;
        animation: slideInRight 0.3s ease-out;
        max-width: 300px;
    `,a.innerHTML=`
        <div style="font-weight: bold; margin-bottom: 5px;">${e}</div>
        ${t?`<div style="font-size: 0.75rem; opacity: 0.8;">${t}</div>`:""}
    `,document.body.appendChild(a),setTimeout(()=>{a.style.animation="slideOutRight 0.3s ease-in",setTimeout(()=>a.remove(),300)},3e3)}window.enableShortcuts=function(){be=!0,console.log("✅ Keyboard shortcuts enabled")};window.disableShortcuts=function(){be=!1,console.log("⏸️ Keyboard shortcuts disabled")};window.toggleShortcutsHelp=ae;document.readyState==="loading"?document.addEventListener("DOMContentLoaded",De):De();console.log("⌨️ Global Shortcuts Module: Loaded");console.log("📋 Press H anytime to view all shortcuts");console.log("⚡ Performance Optimizer Module: Loading...");let g={fps:0,frameTime:0,drawCalls:0,triangles:0,memoryUsage:0,lastFrameTime:performance.now(),frameCount:0,sampleStartTime:performance.now()},N="auto",T=[],to=60,L=null,A=null,oe=!1;const k={lowFpsThreshold:30,mediumFpsThreshold:45,highFpsThreshold:55,memoryWarningThreshold:500*1024*1024,memoryDangerThreshold:1e3*1024*1024},Ge={low:{gridDensity:8,maxParticles:1e3,shadowQuality:0,antialiasing:!1,bloomEnabled:!1,particleLimit:500},medium:{gridDensity:15,maxParticles:2e3,shadowQuality:1,antialiasing:!0,bloomEnabled:!1,particleLimit:1500},high:{gridDensity:30,maxParticles:5e3,shadowQuality:2,antialiasing:!0,bloomEnabled:!0,particleLimit:3e3},ultra:{gridDensity:50,maxParticles:1e4,shadowQuality:3,antialiasing:!0,bloomEnabled:!0,particleLimit:5e3}};function Oe(){console.log("⚡ Initializing Performance Optimizer..."),oo(),no(),io(),document.addEventListener("keydown",e=>{e.key.toLowerCase()==="p"&&!e.ctrlKey&&!e.altKey&&(e.preventDefault(),Je())}),console.log("✅ Performance Optimizer initialized"),console.log("⌨️ Press P to toggle performance stats")}function oo(){L=document.createElement("div"),L.id="fps-display",L.style.cssText=`
        position: fixed;
        top: 70px;
        right: 10px;
        background: rgba(0, 0, 0, 0.8);
        border: 1px solid #00ffff;
        border-radius: 5px;
        padding: 5px 10px;
        font-family: 'Orbitron', monospace;
        font-size: 0.75rem;
        color: #00ffff;
        z-index: 9998;
        display: none;
        min-width: 80px;
        text-align: center;
    `,document.body.appendChild(L)}function no(){A=document.createElement("div"),A.id="performance-stats",A.style.cssText=`
        position: fixed;
        top: 100px;
        right: 10px;
        background: rgba(0, 0, 0, 0.9);
        border: 2px solid #00ffff;
        border-radius: 8px;
        padding: 15px;
        font-family: 'Orbitron', monospace;
        font-size: 0.7rem;
        color: #fff;
        z-index: 9998;
        display: none;
        min-width: 200px;
        line-height: 1.6;
    `,document.body.appendChild(A)}function io(){function e(){ao(),so(),N==="auto"&&lo(),requestAnimationFrame(e)}e()}function ao(){const e=performance.now(),t=e-g.lastFrameTime;g.lastFrameTime=e,g.frameCount++;const o=e-g.sampleStartTime;if(o>=1e3&&(g.fps=Math.round(g.frameCount/o*1e3),g.frameTime=t.toFixed(2),g.frameCount=0,g.sampleStartTime=e,T.push(g.fps),T.length>to&&T.shift()),performance.memory&&(g.memoryUsage=performance.memory.usedJSHeapSize),window.vib34dApp&&window.vib34dApp.currentEngine){const n=window.vib34dApp.currentEngine;if(n.getStats){const i=n.getStats();g.drawCalls=i.drawCalls||0,g.triangles=i.triangles||0}}}function so(){if(L){if(L.style.display!=="none"){const e=J(g.fps);L.innerHTML=`
            <div style="color: ${e}; font-weight: bold; font-size: 1.2em;">
                ${g.fps} FPS
            </div>
        `}if(A&&oe){const e=T.length>0?Math.round(T.reduce((a,s)=>a+s,0)/T.length):g.fps,t=T.length>0?Math.min(...T):g.fps,o=T.length>0?Math.max(...T):g.fps,n=(g.memoryUsage/(1024*1024)).toFixed(1),i=ro(g.memoryUsage);A.innerHTML=`
            <div style="color: #00ffff; font-weight: bold; margin-bottom: 10px; border-bottom: 1px solid #00ffff; padding-bottom: 5px;">
                ⚡ PERFORMANCE STATS
            </div>
            <div style="display: grid; grid-template-columns: 120px 1fr; gap: 5px;">
                <div style="color: #888;">FPS:</div>
                <div style="color: ${J(g.fps)}; font-weight: bold;">${g.fps}</div>

                <div style="color: #888;">Avg FPS:</div>
                <div style="color: ${J(e)};">${e}</div>

                <div style="color: #888;">Min/Max:</div>
                <div style="color: ${J(t)};">${t} / ${o}</div>

                <div style="color: #888;">Frame Time:</div>
                <div>${g.frameTime}ms</div>

                <div style="color: #888;">Memory:</div>
                <div style="color: ${i};">${n} MB</div>

                <div style="color: #888;">Draw Calls:</div>
                <div>${g.drawCalls}</div>

                <div style="color: #888;">Triangles:</div>
                <div>${g.triangles.toLocaleString()}</div>

                <div style="color: #888;">Mode:</div>
                <div style="color: #ff00ff; font-weight: bold;">${N.toUpperCase()}</div>
            </div>
            <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #333; font-size: 0.65rem; color: #666;">
                Press P to hide • Press M to cycle modes
            </div>
        `}}}function J(e){return e>=k.highFpsThreshold?"#00ff00":e>=k.mediumFpsThreshold?"#ffff00":e>=k.lowFpsThreshold?"#ff8800":"#ff0000"}function ro(e){return e>=k.memoryDangerThreshold?"#ff0000":e>=k.memoryWarningThreshold?"#ffff00":"#00ff00"}function lo(){if(T.length<30)return;const e=T.reduce((o,n)=>o+n,0)/T.length;let t="medium";e<k.lowFpsThreshold?t="low":e<k.mediumFpsThreshold?t="medium":e<k.highFpsThreshold?t="high":t="ultra",t!==N&&(console.log(`⚡ Auto-adjusting quality from ${N} to ${t} (avgFps: ${e.toFixed(1)})`),Se(t))}function Se(e){if(!Ge[e]){console.error(`❌ Invalid performance mode: ${e}`);return}N=e;const t=Ge[e];if(console.log(`⚡ Setting performance mode: ${e}`,t),window.updateParameter&&document.getElementById("gridDensity")&&window.updateParameter("gridDensity",t.gridDensity),window.vib34dApp&&window.vib34dApp.currentEngine){const n=window.vib34dApp.currentEngine;n.setPerformanceMode&&n.setPerformanceMode(e,t)}const o=document.createElement("div");o.style.cssText=`
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(0, 0, 0, 0.95);
        border: 2px solid #00ffff;
        border-radius: 10px;
        padding: 20px 40px;
        font-family: 'Orbitron', monospace;
        font-size: 1.2rem;
        color: #00ffff;
        z-index: 10001;
        text-align: center;
    `,o.innerHTML=`
        ⚡ PERFORMANCE MODE<br>
        <span style="font-size: 2rem; font-weight: bold;">${e.toUpperCase()}</span>
    `,document.body.appendChild(o),setTimeout(()=>o.remove(),1500)}function Je(){oe=!oe,oe?(L.style.display="block",A.style.display="block",console.log("📊 Performance stats enabled")):(L.style.display="none",A.style.display="none",console.log("📊 Performance stats disabled"))}function et(){const e=["auto","low","medium","high","ultra"],o=(e.indexOf(N)+1)%e.length;Se(e[o])}window.getPerformanceStats=function(){return{...g}};window.setPerformanceMode=Se;window.togglePerformanceStats=Je;window.cyclePerformanceMode=et;document.addEventListener("keydown",e=>{e.key.toLowerCase()==="m"&&!e.ctrlKey&&!e.altKey&&(e.preventDefault(),et())});document.readyState==="loading"?document.addEventListener("DOMContentLoaded",Oe):Oe();console.log("⚡ Performance Optimizer Module: Loaded");console.log("⌨️ Press P to toggle stats, M to cycle modes");console.log("💾 State Manager Module: Loading...");let h=[],v=-1,co=50,mo=2e3,We=null,tt={version:"1.0",timestamp:Date.now(),system:"faceted",geometry:0,parameters:{},ui:{},performance:{},reactivity:{}};function He(){console.log("💾 Initializing State Manager...");const e=vo();if(e)console.log("🔗 Restoring state from URL..."),j(e);else{const t=st();t?(console.log("📂 Restoring state from localStorage..."),j(t)):K()}bo(),So(),xo(),console.log("✅ State Manager initialized")}function K(){const e={version:"1.0",timestamp:Date.now(),system:window.currentSystem||"faceted",geometry:window.getGeometryInfo?window.getGeometryInfo().index:0,parameters:uo(),ui:{activeTab:fo(),bezelCollapsed:po(),performanceStatsVisible:yo()},performance:{mode:window.performanceMode||"auto"},reactivity:go()};return tt=e,e}function uo(){const e={};return["rot4dXY","rot4dXZ","rot4dYZ","rot4dXW","rot4dYW","rot4dZW"].forEach(i=>{const a=document.getElementById(i);a&&(e[i]=parseFloat(a.value))}),["gridDensity","morphFactor","chaos","speed"].forEach(i=>{const a=document.getElementById(i);a&&(e[i]=parseFloat(a.value))}),["hue","saturation","intensity"].forEach(i=>{const a=document.getElementById(i);a&&(e[i]=parseFloat(a.value))}),e}function go(){var n;const e={audio:window.audioEnabled||!1,deviceTilt:((n=window.deviceTiltHandler)==null?void 0:n.isEnabled)||!1,interactivity:window.interactivityEnabled!==!1},t=["faceted","quantum","holographic"],o=["Mouse","Click","Scroll"];return t.forEach(i=>{e[i]={},o.forEach(a=>{const s=document.getElementById(`${i}${a}`);s&&(e[i][a.toLowerCase()]=s.checked)})}),e}function fo(){const e=document.querySelector(".bezel-tab.active");return e?e.dataset.tab:"controls"}function po(){const e=document.getElementById("controlPanel");return e?e.classList.contains("collapsed"):!1}function yo(){const e=document.getElementById("performance-stats");return e?e.style.display!=="none":!1}function j(e){if(!e||!e.version)return console.error("❌ Invalid state object"),!1;console.log("📂 Restoring state:",e);try{return e.system&&window.switchSystem&&window.switchSystem(e.system),e.geometry!==void 0&&setTimeout(()=>{window.loadGeometryFromIndex&&window.loadGeometryFromIndex(e.geometry)},300),e.parameters&&Object.entries(e.parameters).forEach(([t,o])=>{setTimeout(()=>{window.updateParameter&&window.updateParameter(t,o)},500)}),e.ui&&setTimeout(()=>{if(e.ui.activeTab&&window.switchBezelTab&&window.switchBezelTab(e.ui.activeTab),e.ui.bezelCollapsed&&window.toggleBezelCollapse){const t=document.getElementById("controlPanel");t&&!t.classList.contains("collapsed")&&window.toggleBezelCollapse()}},700),e.performance&&e.performance.mode&&window.setPerformanceMode&&window.setPerformanceMode(e.performance.mode),e.reactivity&&setTimeout(()=>{wo(e.reactivity)},1e3),tt=e,console.log("✅ State restored successfully"),!0}catch(t){return console.error("❌ Failed to restore state:",t),!1}}function wo(e){if(!e)return;e.audio!==void 0&&e.audio!==window.audioEnabled&&window.toggleAudio&&window.toggleAudio();const t=["faceted","quantum","holographic"],o=["mouse","click","scroll"];t.forEach(n=>{e[n]&&o.forEach(i=>{const a=document.getElementById(`${n}${i.charAt(0).toUpperCase()+i.slice(1)}`);a&&e[n][i]!==void 0&&(a.checked=e[n][i],a.dispatchEvent(new Event("change")))})})}function ot(e=null){const t=e||K();v<h.length-1&&(h=h.slice(0,v+1)),h.push(JSON.parse(JSON.stringify(t))),v=h.length-1,h.length>co&&(h.shift(),v--),console.log(`📚 State saved to history (${v+1}/${h.length})`)}function nt(){if(v<=0)return console.log("⚠️ No more states to undo"),!1;v--;const e=h[v];return j(e),console.log(`↶ Undo to state ${v+1}/${h.length}`),_("Undo",`Step ${v+1}/${h.length}`,"info"),!0}function it(){if(v>=h.length-1)return console.log("⚠️ No more states to redo"),!1;v++;const e=h[v];return j(e),console.log(`↷ Redo to state ${v+1}/${h.length}`),_("Redo",`Step ${v+1}/${h.length}`,"info"),!0}function at(e="vib3-plus-app-state"){const t=K();try{return localStorage.setItem(e,JSON.stringify(t)),console.log(`💾 State saved to localStorage: ${e}`),!0}catch(o){return console.error("❌ Failed to save state to localStorage:",o),!1}}function st(e="vib3-plus-app-state"){try{const t=localStorage.getItem(e);if(!t)return null;const o=JSON.parse(t);return console.log(`📂 State loaded from localStorage: ${e}`),o}catch(t){return console.error("❌ Failed to load state from localStorage:",t),null}}function ho(e=null){const t=e||K();try{const o={v:t.version,s:t.system,g:t.geometry,p:t.parameters},n=JSON.stringify(o);return btoa(n)}catch(o){return console.error("❌ Failed to encode state:",o),null}}function vo(){const t=new URLSearchParams(window.location.search).get("state");if(!t)return null;try{const o=atob(t),n=JSON.parse(o),i={version:n.v||"1.0",timestamp:Date.now(),system:n.s||"faceted",geometry:n.g||0,parameters:n.p||{},ui:{},performance:{},reactivity:{}};return console.log("🔗 State decoded from URL"),i}catch(o){return console.error("❌ Failed to decode state from URL:",o),null}}function rt(){const e=ho();if(!e)return null;const o=`${window.location.origin+window.location.pathname}?state=${e}`;return console.log("🔗 Share link generated:",o),o}async function lt(){const e=rt();if(!e)return _("Error","Failed to generate share link","error"),!1;try{return await navigator.clipboard.writeText(e),_("Share Link Copied!","Link copied to clipboard","success"),console.log("✅ Share link copied to clipboard"),!0}catch(t){return console.error("❌ Failed to copy to clipboard:",t),_("Copy Failed","Could not copy to clipboard","error"),!1}}function bo(){document.addEventListener("input",e=>{e.target.classList.contains("control-slider")&&qe()}),["switchSystem","selectGeometry","switchBezelTab"].forEach(e=>{if(window[e]){const t=window[e];window[e]=function(...o){const n=t.apply(this,o);return qe(),n}}}),console.log("⏰ Auto-save enabled (delay: ${autoSaveDelay}ms)")}function qe(){clearTimeout(We),We=setTimeout(()=>{at(),console.log("💾 Auto-saved")},mo)}function So(){document.addEventListener("keydown",e=>{(e.ctrlKey||e.metaKey)&&e.key==="z"&&!e.shiftKey&&(e.preventDefault(),nt()),(e.ctrlKey||e.metaKey)&&(e.key==="y"||e.key==="z"&&e.shiftKey)&&(e.preventDefault(),it()),(e.ctrlKey||e.metaKey)&&e.key==="l"&&(e.preventDefault(),lt())}),console.log("⌨️ State management shortcuts enabled"),console.log("  - Ctrl+Z: Undo"),console.log("  - Ctrl+Y or Ctrl+Shift+Z: Redo"),console.log("  - Ctrl+L: Copy share link")}function xo(){setTimeout(()=>{ot()},2e3)}function _(e,t,o="info"){window.showSaveNotification?window.showSaveNotification(`${e}: ${t}`,o==="success"?"success":"error"):console.log(`[${o.toUpperCase()}] ${e}: ${t}`)}window.captureCurrentState=K;window.restoreState=j;window.saveToHistory=ot;window.undo=nt;window.redo=it;window.saveStateToStorage=at;window.loadStateFromStorage=st;window.generateShareLink=rt;window.copyShareLinkToClipboard=lt;document.readyState==="loading"?document.addEventListener("DOMContentLoaded",He):setTimeout(He,1e3);console.log("💾 State Manager Module: Loaded");console.log("⌨️ Ctrl+Z: Undo, Ctrl+Y: Redo, Ctrl+L: Copy share link");console.log("🎨 Layout Polish Module: Loading...");function Ne(){console.log("🎨 Initializing Simple Layout System..."),ct(),dt(),Eo(),console.log("✅ Simple Layout System initialized")}function ct(){console.log("🔧 Setting up angular RGB-split icons..."),setTimeout(()=>{document.querySelectorAll(".system-btn").forEach(i=>{const a=i.querySelector(".system-icon"),s=i.dataset.system;if(a){const m={faceted:"◆",quantum:"◉",holographic:"⬡",polychora:"■"}[s]||"◆";a.textContent=m,a.setAttribute("data-icon",m),a.setAttribute("data-system",s),a.style.display="inline-flex",a.style.position="relative",a.style.zIndex="10001"}i.addEventListener("click",()=>{i.classList.add("glitching"),setTimeout(()=>i.classList.remove("glitching"),400)})});const t=document.querySelector(".bezel-collapse-btn");if(t){const i=()=>{var r;const s=((r=document.getElementById("controlPanel"))==null?void 0:r.classList.contains("collapsed"))?"▲":"▼";t.textContent=s,t.setAttribute("data-icon",s)};i(),t.addEventListener("click",()=>{setTimeout(i,100)})}document.querySelectorAll(".action-btn").forEach(i=>{var r;const a=((r=i.getAttribute("title"))==null?void 0:r.toLowerCase())||"";let s="●";a.includes("gallery")?s="▦":a.includes("audio")?s="♪":a.includes("tilt")?s="⟲":a.includes("ai")?s="◉":a.includes("interactivity")&&(s="⚡"),i.textContent=s,i.setAttribute("data-icon",s)});const o=document.querySelector(".save-btn");o&&o.setAttribute("data-icon","💾");const n={controls:"⚙",color:"◐",geometry:"▲",reactivity:"⚡",export:"💾"};document.querySelectorAll(".bezel-tab").forEach(i=>{const a=i.dataset.tab,s=i.querySelector(".tab-icon");s&&n[a]&&(s.textContent=n[a],s.setAttribute("data-icon",n[a]))}),console.log("✅ All RGB-split icons initialized")},500)}function dt(){const e=document.getElementById("canvasContainer");if(!e){console.warn("⚠️ Canvas container not found");return}e.style.position="fixed",e.style.top="0",e.style.left="0",e.style.right="0",e.style.bottom="0",e.style.width="100vw",e.style.height="100vh",e.style.zIndex="1";const t=e.querySelectorAll("canvas"),o=window.innerWidth,n=window.innerHeight;t.forEach(a=>{a.width=o,a.height=n,a.style.width=`${o}px`,a.style.height=`${n}px`}),window.vib34dApp&&window.vib34dApp.currentEngine&&setTimeout(()=>{window.vib34dApp.currentEngine.handleResize&&window.vib34dApp.currentEngine.handleResize(o,n),window.vib34dApp.currentEngine.render&&window.vib34dApp.currentEngine.render()},100);let i;window.addEventListener("resize",()=>{clearTimeout(i),i=setTimeout(()=>{const a=window.innerWidth,s=window.innerHeight;t.forEach(r=>{r.width=a,r.height=s,r.style.width=`${a}px`,r.style.height=`${s}px`}),window.vib34dApp&&window.vib34dApp.currentEngine&&(window.vib34dApp.currentEngine.handleResize&&window.vib34dApp.currentEngine.handleResize(a,s),window.vib34dApp.currentEngine.render&&window.vib34dApp.currentEngine.render())},150)}),console.log(`🖼️ Canvas set to full-screen: ${o}x${n}px`)}function Eo(){window.addEventListener("orientationchange",()=>{setTimeout(()=>{me()},300)}),window.addEventListener("resize",()=>{me()}),setTimeout(()=>{me()},500)}function me(){const e=window.innerWidth>window.innerHeight,t=window.innerHeight<500;e&&t?(document.body.classList.add("projection-mode"),console.log("📽️ Projection mode: ON (landscape + short screen)")):document.body.classList.remove("projection-mode")}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",Ne):Ne();window.fixIconDisplay=ct;window.setupFullScreenCanvas=dt;console.log("🎨 Layout Polish Module: Loaded (SIMPLIFIED)");console.log("✅ Canvas is full-screen, UI overlays on top");console.log("📽️ Landscape mode auto-hides UI for projection");console.log("🔬 System Diagnostics Module: Loading...");let d={modules:{},layout:{},icons:{},performance:{},errors:[]},V=!1,z=null;function Ye(){console.log("🔬 Initializing System Diagnostics..."),Ao(),document.addEventListener("keydown",n=>{n.ctrlKey&&n.shiftKey&&n.key==="D"&&(n.preventDefault(),Y())});let e=0,t=null;const o=document.querySelector(".logo");o&&(o.addEventListener("click",n=>{e++,t&&clearTimeout(t),e===3&&(Y(),e=0),t=setTimeout(()=>{e=0},1e3)}),console.log("📱 Mobile: Triple-tap logo to open diagnostics")),ko(),console.log("✅ System Diagnostics initialized (auto-run disabled)"),console.log("⌨️ Desktop: Ctrl+Shift+D | Mobile: Triple-tap logo or use floating button")}function mt(){return console.log("🧪 Running complete diagnostic suite..."),d={modules:{},layout:{},icons:{},performance:{},errors:[],timestamp:new Date().toISOString()},To(),Co(),$o(),Io(),Lo(),Mo(),ut(),V&&gt(),console.log("✅ Diagnostic suite complete"),d}function To(){console.log("📦 Testing module integration...");const e={switchSystem:"System switching",selectGeometry:"Geometry selection",updateParameter:"Parameter updates",toggleBezelCollapse:"Bezel control",saveToGallery:"Gallery save",openGallery:"Gallery open",randomizeAll:"Randomize all",resetAll:"Reset all",togglePerformanceStats:"Performance stats",toggleShortcutsHelp:"Shortcuts help",copyShareLinkToClipboard:"Share links",captureCurrentState:"State capture",undo:"Undo",redo:"Redo",fixSystemButtonIcons:"Icon fixes",calculateLayout:"Layout calculation",applyLayout:"Layout application",loadGeometryFromIndex:"Geometry loading",getGeometryInfo:"Geometry info",switchCoreType:"Core type switching",createIcon:"Icon creation",replaceAllEmojisWithIcons:"Emoji replacement"};let t=0,o=0;Object.entries(e).forEach(([n,i])=>{typeof window[n]=="function"?(d.modules[n]={status:"OK",description:i},t++):(d.modules[n]={status:"MISSING",description:i},o++,d.errors.push(`Missing function: ${n} (${i})`))}),d.modules.summary={total:Object.keys(e).length,loaded:t,failed:o,percentage:(t/Object.keys(e).length*100).toFixed(1)},console.log(`✅ Modules: ${t}/${Object.keys(e).length} loaded (${d.modules.summary.percentage}%)`)}function Co(){console.log("📐 Testing layout system...");const e=document.querySelector(".top-bar"),t=document.getElementById("canvasContainer"),o=document.getElementById("controlPanel");if(d.layout={topBar:e?{exists:!0,height:e.offsetHeight,computed:window.getComputedStyle(e).height}:{exists:!1},canvasContainer:t?{exists:!0,position:window.getComputedStyle(t).position,top:window.getComputedStyle(t).top,bottom:window.getComputedStyle(t).bottom,width:t.offsetWidth,height:t.offsetHeight,rect:t.getBoundingClientRect()}:{exists:!1},controlPanel:o?{exists:!0,position:window.getComputedStyle(o).position,height:o.offsetHeight,isCollapsed:o.classList.contains("collapsed"),computed:window.getComputedStyle(o).height}:{exists:!1},viewport:{width:window.innerWidth,height:window.innerHeight,isMobile:window.innerWidth<=768,isLandscape:window.innerWidth>window.innerHeight}},t&&o){const n=t.getBoundingClientRect(),i=o.getBoundingClientRect(),a=window.innerHeight-n.bottom-i.height;if(d.layout.gap=a,Math.abs(a)>2&&d.errors.push(`Layout gap detected: ${a}px between canvas and bezel`),n.bottom>i.top){const s=n.bottom-i.top;d.layout.overlap=s,d.errors.push(`Layout overlap detected: ${s}px`)}}console.log("✅ Layout test complete")}function $o(){console.log("🎨 Testing icon system...");const e=document.querySelectorAll(".system-btn");let t=0,o=0,n=0;e.forEach((i,a)=>{const s=i.querySelector(".system-icon");if(s){const r=s.querySelector("svg")!==null,m=s.textContent.trim().length>0;r?t++:m?o++:n++}}),d.icons={systemButtons:{total:e.length,svgLoaded:t,fallbackUsed:o,missing:n}},n>0&&d.errors.push(`${n} system buttons missing icons`),console.log(`✅ Icons: ${t} SVG, ${o} fallback, ${n} missing`)}function Io(){console.log("⚡ Testing performance metrics..."),d.performance={memory:performance.memory?{used:(performance.memory.usedJSHeapSize/1024/1024).toFixed(2)+" MB",total:(performance.memory.totalJSHeapSize/1024/1024).toFixed(2)+" MB",limit:(performance.memory.jsHeapSizeLimit/1024/1024).toFixed(2)+" MB"}:"Not available",timing:performance.timing?{loadTime:performance.timing.loadEventEnd-performance.timing.navigationStart+" ms",domReady:performance.timing.domContentLoadedEventEnd-performance.timing.navigationStart+" ms"}:"Not available",fps:window.getPerformanceStats?window.getPerformanceStats().fps:"Not available"},console.log("✅ Performance metrics collected")}function Lo(){console.log("📱 Testing responsiveness...");const e=window.innerWidth<=768,t=document.body.classList.contains("mobile-layout");if(d.layout.responsiveness={isMobile:e,hasMobileClass:t,properlyConfigured:e===t,touchTargets:[]},e){const o=document.querySelectorAll(".system-btn, .action-btn, .geom-btn, .bezel-tab");let n=0;o.forEach(i=>{const a=i.getBoundingClientRect();Math.min(a.width,a.height)<44&&(n++,d.layout.responsiveness.touchTargets.push({element:i.className,width:a.width,height:a.height,tooSmall:!0}))}),n>0&&d.errors.push(`${n} touch targets smaller than 44px`)}console.log("✅ Responsiveness test complete")}function Mo(){console.log("🎯 Testing event listeners..."),d.events={bezelToggle:typeof window.toggleBezelCollapse=="function",systemSwitch:typeof window.switchSystem=="function",geometrySelect:typeof window.selectGeometry=="function",parameterUpdate:typeof window.updateParameter=="function"},console.log("✅ Event listener test complete")}function ut(){var t,o;const e={timestamp:d.timestamp,summary:{totalErrors:d.errors.length,modulesLoaded:((t=d.modules.summary)==null?void 0:t.percentage)||0,layoutStatus:d.layout.gap!==void 0?Math.abs(d.layout.gap)<=2?"OK":"WARNING":"UNKNOWN",iconsStatus:((o=d.icons.systemButtons)==null?void 0:o.missing)===0?"OK":"WARNING",performanceStatus:"OK"},details:d};return console.log(`
`+"=".repeat(50)),console.log("📊 DIAGNOSTIC REPORT"),console.log("=".repeat(50)),console.log(`Timestamp: ${e.timestamp}`),console.log(`Errors: ${e.summary.totalErrors}`),console.log(`Modules: ${e.summary.modulesLoaded}%`),console.log(`Layout: ${e.summary.layoutStatus}`),console.log(`Icons: ${e.summary.iconsStatus}`),console.log("=".repeat(50)+`
`),d.errors.length>0?(console.log("⚠️ ERRORS DETECTED:"),d.errors.forEach((n,i)=>{console.log(`  ${i+1}. ${n}`)}),console.log("")):console.log(`✅ NO ERRORS DETECTED
`),e}function Ao(){z=document.createElement("div"),z.id="system-diagnostics-overlay",z.style.cssText=`
        position: fixed;
        top: 70px;
        left: 10px;
        right: 10px;
        max-width: 600px;
        max-height: calc(100vh - 140px);
        background: rgba(0, 0, 0, 0.95);
        border: 2px solid #00ffff;
        border-radius: 10px;
        padding: 15px;
        font-family: 'Courier New', monospace;
        font-size: 0.7rem;
        color: #00ff00;
        z-index: 10002;
        display: none;
        overflow-y: auto;
        line-height: 1.4;
    `;const e=document.createElement("button");e.textContent="× Close",e.style.cssText=`
        position: absolute;
        top: 8px;
        right: 8px;
        background: rgba(255, 0, 0, 0.8);
        border: 1px solid #ff0000;
        color: #fff;
        padding: 6px 12px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 0.75rem;
        font-weight: bold;
    `,e.onclick=()=>Y(),z.appendChild(e);const t=document.createElement("div");t.id="debug-content",t.style.marginTop="35px",z.appendChild(t),document.body.appendChild(z)}function ko(){const e=document.createElement("button");e.id="floating-debug-btn",e.innerHTML="🔬",e.title="Open Diagnostics",e.style.cssText=`
        position: fixed;
        bottom: 80px;
        right: 20px;
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, rgba(0, 255, 255, 0.2), rgba(0, 200, 255, 0.3));
        border: 2px solid rgba(0, 255, 255, 0.5);
        border-radius: 50%;
        color: #00ffff;
        font-size: 1.5rem;
        cursor: pointer;
        z-index: 9999;
        box-shadow: 0 4px 20px rgba(0, 255, 255, 0.4);
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
        backdrop-filter: blur(10px);
    `,e.addEventListener("click",()=>{Y()}),e.addEventListener("touchstart",t=>{t.preventDefault(),e.style.transform="scale(0.9)"}),e.addEventListener("touchend",t=>{t.preventDefault(),e.style.transform="scale(1)",Y()}),document.body.appendChild(e),console.log("✅ Floating debug button added (bottom-right corner)")}function Y(){V=!V,z.style.display=V?"block":"none",V&&(mt(),gt())}function gt(){var n,i,a,s,r,m,l,f,b,w,p,c;const e=document.getElementById("debug-content");if(!e)return;const t=ut();let o=`
        <div style="color: #00ffff; font-weight: bold; margin-bottom: 15px; border-bottom: 1px solid #00ffff; padding-bottom: 5px;">
            🔬 SYSTEM DIAGNOSTICS
        </div>

        <div style="margin-bottom: 15px;">
            <div style="color: #ffff00;">⏱️ Timestamp:</div>
            <div style="margin-left: 15px;">${t.timestamp}</div>
        </div>

        <div style="margin-bottom: 15px;">
            <div style="color: #ffff00;">📊 Summary:</div>
            <div style="margin-left: 15px;">
                Errors: <span style="color: ${t.summary.totalErrors===0?"#00ff00":"#ff0000"}">${t.summary.totalErrors}</span><br>
                Modules: <span style="color: ${t.summary.modulesLoaded>=90?"#00ff00":"#ffff00"}">${t.summary.modulesLoaded}%</span><br>
                Layout: <span style="color: ${t.summary.layoutStatus==="OK"?"#00ff00":"#ffff00"}">${t.summary.layoutStatus}</span><br>
                Icons: <span style="color: ${t.summary.iconsStatus==="OK"?"#00ff00":"#ffff00"}">${t.summary.iconsStatus}</span>
            </div>
        </div>

        <div style="margin-bottom: 15px;">
            <div style="color: #ffff00;">📐 Layout:</div>
            <div style="margin-left: 15px; font-size: 0.7rem;">
                Viewport: ${(n=d.layout.viewport)==null?void 0:n.width}x${(i=d.layout.viewport)==null?void 0:i.height}<br>
                Mobile: ${(a=d.layout.viewport)!=null&&a.isMobile?"Yes":"No"}<br>
                Canvas: ${(s=d.layout.canvasContainer)==null?void 0:s.width}x${(r=d.layout.canvasContainer)==null?void 0:r.height}<br>
                Bezel: ${(m=d.layout.controlPanel)==null?void 0:m.height}px (${(l=d.layout.controlPanel)!=null&&l.isCollapsed?"Collapsed":"Expanded"})<br>
                Gap: <span style="color: ${Math.abs(d.layout.gap||0)<=2?"#00ff00":"#ff0000"}">${((f=d.layout.gap)==null?void 0:f.toFixed(2))||"N/A"}px</span>
            </div>
        </div>

        <div style="margin-bottom: 15px;">
            <div style="color: #ffff00;">🎨 Icons:</div>
            <div style="margin-left: 15px; font-size: 0.7rem;">
                SVG Loaded: ${((b=d.icons.systemButtons)==null?void 0:b.svgLoaded)||0}<br>
                Fallback: ${((w=d.icons.systemButtons)==null?void 0:w.fallbackUsed)||0}<br>
                Missing: <span style="color: ${((p=d.icons.systemButtons)==null?void 0:p.missing)===0?"#00ff00":"#ff0000"}">${((c=d.icons.systemButtons)==null?void 0:c.missing)||0}</span>
            </div>
        </div>

        <div style="margin-bottom: 15px;">
            <div style="color: #ffff00;">⚡ Performance:</div>
            <div style="margin-left: 15px; font-size: 0.7rem;">
                ${typeof d.performance.memory=="object"?`Memory: ${d.performance.memory.used} / ${d.performance.memory.total}`:"Memory: N/A"}<br>
                FPS: ${d.performance.fps||"N/A"}
            </div>
        </div>
    `;d.errors.length>0&&(o+=`
            <div style="margin-bottom: 15px;">
                <div style="color: #ff0000; font-weight: bold;">⚠️ ERRORS (${d.errors.length}):</div>
                <div style="margin-left: 15px; font-size: 0.7rem; color: #ff8888;">
                    ${d.errors.map((S,G)=>`${G+1}. ${S}`).join("<br>")}
                </div>
            </div>
        `),o+=`
        <div style="margin-top: 20px; padding-top: 10px; border-top: 1px solid #333; text-align: center; font-size: 0.65rem; color: #666;">
            Press Ctrl+Shift+D to close • Auto-refresh in diagnostics
        </div>
    `,e.innerHTML=o}window.runCompleteDiagnostics=mt;window.toggleDebugOverlay=Y;window.getDiagnosticResults=()=>d;document.readyState==="loading"?document.addEventListener("DOMContentLoaded",Ye):Ye();console.log("🔬 System Diagnostics Module: Loaded");console.log("⌨️ Press Ctrl+Shift+D to toggle debug overlay");console.log("⏳ Loading States Module: Loading...");let ft=!1;function Ro(){console.log("⏳ Initializing Loading States System..."),ft=!0,console.log("✅ Loading States System initialized (DISABLED FOR DEBUGGING)")}function Po(e,t){const o=document.getElementById("loading-progress-fill"),n=document.getElementById("loading-text");o&&(o.style.width=`${t}%`),n&&(n.textContent=e);const i=document.getElementById("loading-steps");if(i){const a=document.createElement("div");a.style.cssText=`
            padding: 4px 0;
            animation: fadeIn 0.3s ease-out;
            color: rgba(0, 255, 0, 0.7);
        `,a.innerHTML=`✓ ${e}`,i.appendChild(a);const s=i.children;s.length>5&&i.removeChild(s[0])}console.log(`⏳ Loading: ${t}% - ${e}`)}function Do(){}function zo(e){}window.updateLoadingProgress=Po;window.hideLoadingOverlay=Do;window.showErrorState=zo;window.isLoadingComplete=()=>ft;Ro();console.log("⏳ Loading States Module: Loaded");console.log("🧪 Visual Test Suite: Loading...");let y={passed:0,failed:0,warnings:0,tests:[]};function Xe(){console.log("🧪 Initializing Visual Test Suite..."),console.log("✅ Visual Test Suite initialized (auto-run disabled)"),console.log("💡 Run window.runAllVisualTests() manually when needed")}function Bo(){return console.log("🧪 Running visual tests..."),y={passed:0,failed:0,warnings:0,tests:[],timestamp:new Date().toISOString()},Fo(),Go(),Oo(),Wo(),Ho(),qo(),No(),Yo(),Xo(),console.log("✅ Visual tests complete"),y}function Fo(){const e=document.querySelector(".top-bar");if(!e){u("Header Layout",!1,"Top bar element not found");return}const t=e.getBoundingClientRect(),o=window.getComputedStyle(e);t.top===0?u("Header Position",!0):u("Header Position",!1,`Header not at top (${t.top}px)`);const n=t.height;n>=50&&n<=100?u("Header Height",!0):u("Header Height",!1,`Header height out of range: ${n}px`),o.position==="fixed"?u("Header Fixed Position",!0):u("Header Fixed Position",!1,`Header position is ${o.position}`);const i=e.querySelectorAll(".system-btn");i.length===4?u("System Buttons Count",!0):u("System Buttons Count",!1,`Found ${i.length} buttons, expected 4`)}function Go(){const e=document.getElementById("controlPanel");if(!e){u("Bezel Layout",!1,"Control panel not found");return}const t=e.getBoundingClientRect();window.getComputedStyle(e);const o=e.classList.contains("collapsed"),i=window.innerHeight-t.bottom;Math.abs(i)<=2?u("Bezel Bottom Position",!0):u("Bezel Bottom Position",!1,`Gap from bottom: ${i.toFixed(2)}px`),o&&(t.height>=48&&t.height<=56?u("Bezel Collapsed Height",!0):u("Bezel Collapsed Height",!1,`Height: ${t.height}px (expected 48-56px)`));const a=e.querySelectorAll(".bezel-tab");a.length===5?u("Bezel Tabs Count",!0):u("Bezel Tabs Count",!1,`Found ${a.length} tabs, expected 5`)}function Oo(){const e=document.getElementById("canvasContainer"),t=document.querySelector(".top-bar"),o=document.getElementById("controlPanel");if(!e||!t||!o){u("Canvas Layout",!1,"Required elements not found");return}const n=e.getBoundingClientRect(),i=t.getBoundingClientRect(),a=o.getBoundingClientRect(),s=i.bottom,r=a.top,m=Math.abs(n.top-s),l=Math.abs(n.bottom-r);if(m<=2&&l<=2?u("Canvas Fills Viewport",!0):u("Canvas Fills Viewport",!1,`Top gap: ${m.toFixed(2)}px, Bottom gap: ${l.toFixed(2)}px`),n.bottom<=a.top+2)u("No Canvas-Bezel Overlap",!0);else{const f=n.bottom-a.top;u("No Canvas-Bezel Overlap",!1,`Overlap: ${f.toFixed(2)}px`)}}function Wo(){const e=document.querySelectorAll(".system-btn");let t=0;e.forEach(o=>{const n=o.querySelector(".system-icon");if(n){const i=n.querySelector("svg")!==null,a=n.textContent.trim().length>0;i||a||t++}}),t===0?u("All Icons Rendered",!0):u("All Icons Rendered",!1,`${t} icons are empty`),e.forEach((o,n)=>{const i=o.querySelector(".system-icon");if(i){const a=window.getComputedStyle(i);a.display!=="none"&&a.visibility!=="hidden"?u(`Icon ${n+1} Visible`,!0):u(`Icon ${n+1} Visible`,!1,"Icon hidden by CSS")}})}function Ho(){if(window.innerWidth<=768){u("Mobile Layout Detection",!0,"Mobile viewport detected");const o=document.querySelectorAll(".system-btn, .action-btn, .bezel-tab");let n=0;o.forEach(i=>{const a=i.getBoundingClientRect();Math.min(a.width,a.height)<44&&n++}),n===0?u("Mobile Touch Targets",!0):u("Mobile Touch Targets",!1,`${n} buttons smaller than 44px`)}else u("Desktop Layout",!0,"Desktop viewport detected")}function qo(){const e=document.querySelectorAll('[style*="animation"], [class*="animate"]');e.length>0?u("Animations Present",!0,`${e.length} animated elements`):u("Animations Present",!1,"No animations detected",!0),e.forEach((t,o)=>{const n=window.getComputedStyle(t),i=parseFloat(n.animationDuration);i>0&&i<=5?u(`Animation ${o+1} Duration`,!0):i>5&&u(`Animation ${o+1} Duration`,!1,`Animation too long: ${i}s`,!0)})}function No(){const e=document.querySelectorAll("button");let t=0;e.forEach(n=>{const i=n.textContent.trim().length>0,a=n.hasAttribute("aria-label"),s=n.hasAttribute("title");!i&&!a&&!s&&t++}),t===0?u("Accessible Buttons",!0):u("Accessible Buttons",!1,`${t} buttons lack labels`,!0);const o=document.querySelectorAll("button, a, input, [tabindex]");u("Focusable Elements",!0,`${o.length} focusable elements`)}function Yo(){document.querySelectorAll(".logo, .section-title, .control-label").forEach(t=>{const o=window.getComputedStyle(t);o.color,o.backgroundColor}),u("Color Contrast",!0,"Manual review recommended",!0)}function u(e,t,o="",n=!1){const i={name:e,passed:t,message:o,isWarning:n};y.tests.push(i),n?y.warnings++:t?y.passed++:y.failed++;const a=t?"✅":n?"⚠️":"❌",s=o?` - ${o}`:"";console.log(`${a} ${e}${s}`)}function Xo(){const e=y.tests.length,t=e>0?(y.passed/e*100).toFixed(1):0;return console.log(`
`+"=".repeat(60)),console.log("🧪 VISUAL TEST REPORT"),console.log("=".repeat(60)),console.log(`Timestamp: ${y.timestamp}`),console.log(`Total Tests: ${e}`),console.log(`✅ Passed: ${y.passed}`),console.log(`❌ Failed: ${y.failed}`),console.log(`⚠️ Warnings: ${y.warnings}`),console.log(`Pass Rate: ${t}%`),console.log("=".repeat(60)),y.failed>0&&(console.log(`
❌ FAILED TESTS:`),y.tests.filter(o=>!o.passed&&!o.isWarning).forEach(o=>{console.log(`  • ${o.name}: ${o.message||"Failed"}`)})),y.warnings>0&&(console.log(`
⚠️ WARNINGS:`),y.tests.filter(o=>o.isWarning).forEach(o=>{console.log(`  • ${o.name}: ${o.message||"Warning"}`)})),console.log(`
`+"=".repeat(60)+`
`),y}window.runAllVisualTests=Bo;window.getVisualTestResults=()=>y;document.readyState==="loading"?document.addEventListener("DOMContentLoaded",Xe):Xe();console.log("🧪 Visual Test Suite: Loaded");(async function(){try{console.log("📦 Starting system imports...");const e=(await E(async()=>{const{default:c}=await import("./app-By9NSdyn.js");return{default:c}},[],import.meta.url)).default;console.log("✅ VIB34DApp imported");let t,o,n,i,a,s,r,m,l,f;try{t=(await E(()=>import("./Engine-optW5Lbn.js"),__vite__mapDeps([0,1]),import.meta.url)).VIB34DIntegratedEngine,console.log("✅ VIB34DIntegratedEngine imported")}catch(c){console.warn("⚠️ VIB34DIntegratedEngine not available:",c.message)}try{o=(await E(()=>import("./QuantumEngine-CFfXzAcE.js"),__vite__mapDeps([2,1]),import.meta.url)).QuantumEngine,console.log("✅ QuantumEngine imported")}catch(c){console.warn("⚠️ QuantumEngine not available:",c.message)}try{n=(await E(()=>import("./RealHolographicSystem-D9xiJMyx.js"),[],import.meta.url)).RealHolographicSystem,console.log("✅ RealHolographicSystem imported")}catch(c){console.warn("⚠️ RealHolographicSystem not available:",c.message)}try{const c=await E(()=>import("./PolychoraSystemNew-7YVE-Emn.js"),__vite__mapDeps([3,1]),import.meta.url);NewPolychoraEngine=c.NewPolychoraEngine,console.log("✅ NEW 4D Polychora Engine imported with VIB34D DNA")}catch(c){console.warn("⚠️ New Polychora Engine not available:",c.message);try{const S=await E(()=>import("./PolychoraSystem-BGw1Yu8l.js"),[],import.meta.url);NewPolychoraEngine=S.PolychoraSystem,console.log("✅ Fallback to old PolychoraSystem")}catch(S){console.warn("⚠️ No Polychora system available:",S.message)}}try{m=(await E(()=>import("./CanvasManager-BT4ruED8.js"),[],import.meta.url)).CanvasManager}catch{console.warn("⚠️ CanvasManager not available - using stub")}try{const c=await E(()=>import("./UnifiedReactivityManager-DsWWdpit.js"),[],import.meta.url);UnifiedReactivityManager=c.UnifiedReactivityManager,console.log("✅ UnifiedReactivityManager imported")}catch{console.warn("⚠️ UnifiedReactivityManager not available")}try{f=(await E(()=>import("./ReactivityManager-CQHKZe5v.js"),[],import.meta.url)).ReactivityManager}catch{console.warn("⚠️ ReactivityManager not available - using stub")}if(window.engineClasses={VIB34DIntegratedEngine:t,QuantumEngine:o,RealHolographicSystem:n,NewPolychoraEngine},console.log("📦 Engine classes stored:",Object.keys(window.engineClasses).filter(c=>window.engineClasses[c])),UnifiedReactivityManager){const c=new UnifiedReactivityManager;console.log("✅ UnifiedReactivityManager initialized")}else window.getCurrentReactivityState=function(){var c;return{system:window.currentSystem||"faceted",mouse:{faceted:!0,quantum:!1,holographic:!1,polychora:!1,mixed:!1},click:{faceted:!0,quantum:!1,holographic:!1,polychora:!1,mixed:!1},scroll:{faceted:!0,quantum:!1,holographic:!1,polychora:!1,mixed:!1},audio:window.audioEnabled||!1,interactivity:window.interactivityEnabled!==!1,deviceTilt:((c=window.deviceTiltHandler)==null?void 0:c.isEnabled)||!1}},console.log("⚠️ Using fallback getCurrentReactivityState");const b=new e;window.vib34dApp=b,await b.initialize(),window.syncVisualizerToUI?console.log("✅ Essential functions available globally"):console.error("🚨 CRITICAL: syncVisualizerToUI not available globally after app init");const w=window.currentSystem||"faceted";if(window.switchSystem&&await window.switchSystem(w),window.setupGeometry&&window.setupGeometry(w),window.moduleReady=!0,document.body.classList.remove("loading"),console.log("🚀 VIB34D Clean Architecture System Loaded"),new URLSearchParams(window.location.search).has("testing-mode")){let S=function(){const G=document.getElementById("test-results");let O=0,W=0;function x(R,P){W++,P&&O++;const le=document.createElement("div");le.style.cssText=`color: ${P?"#00ff00":"#ff4444"}; margin: 2px 0;`,le.innerHTML=`${P?"✅":"❌"} ${R}`,G.appendChild(le)}x("window.switchSystem available",typeof window.switchSystem=="function"),x("window.selectGeometry available",typeof window.selectGeometry=="function"),x("window.updateParameter available",typeof window.updateParameter=="function"),x("window.randomizeAll available",typeof window.randomizeAll=="function"),x("window.resetAll available",typeof window.resetAll=="function"),x("Canvas Container exists",!!document.getElementById("canvasContainer")),x("Control Panel exists",!!document.getElementById("controlPanel")),x("Panel Header exists",!!document.getElementById("panelHeader")),x("Faceted Layers exist",!!document.getElementById("vib34dLayers")),["rot4dXW","rot4dYW","rot4dZW","gridDensity","morphFactor","chaos","speed","hue","intensity","saturation"].forEach(R=>{const P=document.getElementById(R);x(`${R} slider exists`,!!P)}),["faceted","quantum","holographic","polychora"].forEach(R=>{const P=document.querySelector(`[data-system="${R}"]`);x(`${R} button exists`,!!P)});const H=(O/W*100).toFixed(1),re=document.createElement("div");re.style.cssText=`
                        color: ${H>=90?"#00ff00":H>=70?"#ffff00":"#ff4444"};
                        font-weight: bold;
                        margin-top: 10px;
                        padding: 10px;
                        border-top: 1px solid #333;
                    `,re.innerHTML=`
                        <div>📊 RESULT: ${O}/${W} (${H}%)</div>
                        <div>${H>=90?"✅ ARCHITECTURE READY":H>=70?"⚠️ NEEDS FIXES":"❌ CRITICAL ISSUES"}</div>
                    `,G.appendChild(re),console.log(`🧪 Architecture test complete: ${O}/${W} passed (${H}%)`)};console.log("🧪 TESTING MODE: Running architecture validation...");const c=document.createElement("div");c.id="test-overlay",c.style.cssText=`
                        position: fixed;
                        top: 60px;
                        left: 20px;
                        width: 400px;
                        max-height: 80vh;
                        overflow-y: auto;
                        background: rgba(0, 0, 0, 0.95);
                        border: 2px solid #00ffff;
                        border-radius: 10px;
                        padding: 15px;
                        font-family: 'Orbitron', monospace;
                        font-size: 0.8rem;
                        color: #fff;
                        z-index: 9999;
                    `,c.innerHTML=`
                        <h3 style="color: #00ffff; margin-bottom: 10px;">🧪 ARCHITECTURE TEST</h3>
                        <div id="test-results"></div>
                    `,document.body.appendChild(c),setTimeout(S,1e3)}}catch(e){console.error("❌ Failed to initialize VIB34D system:",e),document.body.classList.remove("loading");const t=document.createElement("div");t.style.cssText=`
                    position: fixed;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    background: rgba(255, 0, 0, 0.9);
                    color: white;
                    padding: 20px;
                    border-radius: 10px;
                    font-family: 'Orbitron', monospace;
                    z-index: 10000;
                    max-width: 80vw;
                `,t.innerHTML=`
                    <h3>❌ VIB34D Initialization Failed</h3>
                    <p>${e.message}</p>
                    <small>Check console for details</small>
                `,document.body.appendChild(t)}})();export{E as _};

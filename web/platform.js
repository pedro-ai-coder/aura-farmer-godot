/* Browser lifecycle adapter: native gesture fullscreen and bounded mobile raster.
 * It never advances simulation or modifies gameplay input. */
(function () {
  if (window.__auraPlatform) return;
  const media = query => typeof matchMedia === 'function' && matchMedia(query).matches;
  const standalone = () => navigator.standalone === true || media('(display-mode: standalone)');
  const state = { fullscreen: 'idle', orientation: 'idle', touch: navigator.maxTouchPoints > 0, safe: [0,0,0,0], mode: 'menu' };
  let automaticAttempted = false, cachedMetrics = '{}';
  const canvas = document.getElementById('canvas');
  const root = document.documentElement;
  const probe = document.createElement('div');
  probe.style.cssText = 'position:fixed;visibility:hidden;pointer-events:none;padding:env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left)';
  document.body.appendChild(probe);
  const launcher = document.createElement('button');
  launcher.type = 'button'; launcher.id = 'aura-fullscreen'; launcher.textContent = 'FULLSCREEN';
  launcher.style.cssText = 'position:fixed;right:max(12px,env(safe-area-inset-right));bottom:max(10px,env(safe-area-inset-bottom));z-index:20;min-height:44px;padding:8px 16px;border:2px solid #f8c45f;border-radius:6px;background:#13233a;color:#fff9e9;font:700 14px system-ui,sans-serif;cursor:pointer';
  document.body.appendChild(launcher);
  const hint = document.createElement('div'); hint.id = 'aura-fullscreen-help';
  hint.setAttribute('role','status');
  hint.style.cssText = 'position:fixed;right:12px;bottom:62px;z-index:20;max-width:min(330px,85vw);padding:12px;background:#13233a;color:#fff9e9;border:1px solid #f8c45f;font:500 15px system-ui,sans-serif;pointer-events:none';
  hint.hidden = true; document.body.appendChild(hint);
  function active() { return !!(document.fullscreenElement || document.webkitFullscreenElement); }
  function requestMethod() { return root.requestFullscreen || root.webkitRequestFullscreen; }
  function supported() { return root.requestFullscreen ? document.fullscreenEnabled !== false : !!root.webkitRequestFullscreen && document.webkitFullscreenEnabled !== false; }
  function controls() {
    launcher.hidden = !['menu','options','paused'].includes(state.mode) || active() || standalone();
    launcher.textContent = supported() ? 'FULLSCREEN' : 'FULLSCREEN HELP';
    if (launcher.hidden) hint.hidden = true;
  }
  function refresh() {
    const css = getComputedStyle(probe);
    state.safe = ['paddingLeft','paddingTop','paddingRight','paddingBottom'].map(k => parseFloat(css[k]) || 0);
    state.width = innerWidth; state.height = innerHeight;
    const dpr = window.devicePixelRatio || 1;
    const compactTouch = state.touch && Math.min(innerWidth,innerHeight) < 900;
    state.pixelRatio = compactTouch ? Math.min(dpr,1.5) : dpr;
    // The Web preset uses resize policy None: exactly one owner writes raster
    // dimensions. CSS coordinates remain independent of Retina pixel density.
    if (canvas) {
      const width = Math.max(1,Math.round(innerWidth*state.pixelRatio));
      const height = Math.max(1,Math.round(innerHeight*state.pixelRatio));
      if (canvas.width !== width) canvas.width = width;
      if (canvas.height !== height) canvas.height = height;
      canvas.style.width = innerWidth+'px'; canvas.style.height = innerHeight+'px';
    }
    state.fullscreen = standalone() ? 'standalone' : active() ? 'active' : state.fullscreen;
    controls();
    cachedMetrics = JSON.stringify({touch:state.touch,safe:state.safe,width:state.width,height:state.height,pixelRatio:state.pixelRatio,fullscreen:state.fullscreen,orientation:state.orientation});
  }
  function explain() {
    hint.textContent = 'standalone' in navigator
      ? 'For fullscreen, add Aura Farmer to your Home Screen, then open it there.'
      : 'Fullscreen is unavailable here. Open the game directly in your browser.';
    hint.hidden = false;
  }
  async function enter(event, explicit) {
    if (!event.isTrusted || state.fullscreen === 'pending') return;
    if (navigator.userActivation && !navigator.userActivation.isActive) return;
    if (standalone() || active()) { refresh(); return; }
    if (!supported()) { state.fullscreen='unavailable'; refresh(); if (explicit) explain(); return; }
    state.fullscreen='pending';
    try {
      // Request is invoked synchronously in the trusted input callback, before
      // any await, timer or Godot frame. Fullscreen root retains utility UI.
      const result = requestMethod().call(root, {navigationUI:'hide'});
      if (result && typeof result.then === 'function') await result;
      state.fullscreen = active() ? 'active' : 'pending';
      if (active()) {
        if (screen.orientation && typeof screen.orientation.lock === 'function') {
          try { await screen.orientation.lock('landscape'); state.orientation='locked'; }
          catch (_) { state.orientation='denied'; }
        } else state.orientation='unavailable';
      }
    } catch (_) {
      state.fullscreen='denied';
      if (explicit) { hint.textContent='Fullscreen was blocked. Tap FULLSCREEN to try again.'; hint.hidden=false; }
    }
    refresh();
  }
  function gesture(event) {
    const touch = event.type === 'touchend' || event.pointerType === 'touch';
    if (!touch || !event.isTrusted || automaticAttempted || event.target !== canvas) return;
    if (navigator.userActivation && !navigator.userActivation.isActive) return;
    automaticAttempted = true;
    state.touch = true;
    return enter(event,false);
  }
  // Capture survives engine stopPropagation; touchend supports TouchEvent-only
  // browsers. Neither handler cancels gameplay's tap/release.
  document.addEventListener('pointerup',gesture,{passive:true,capture:true});
  document.addEventListener('touchend',gesture,{passive:true,capture:true});
  launcher.addEventListener('click',event => enter(event,true));
  function changed() {
    state.fullscreen = standalone() ? 'standalone' : active() ? 'active' : supported() ? 'idle' : 'unavailable';
    refresh();
  }
  document.addEventListener('fullscreenchange',changed);
  document.addEventListener('webkitfullscreenchange',changed);
  document.addEventListener('fullscreenerror',() => { state.fullscreen='denied';refresh(); });
  addEventListener('resize',refresh); addEventListener('pageshow',changed);
  if (window.visualViewport) window.visualViewport.addEventListener('resize',refresh);
  const viewport = document.querySelector('meta[name="viewport"]');
  if (viewport) viewport.setAttribute('content','width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover');
  root.style.overscrollBehavior='none'; document.body.style.overscrollBehavior='none';
  document.body.style.margin='0';
  if (canvas) canvas.style.touchAction='none';
  state.metrics = () => cachedMetrics;
  state.setMode = mode => { state.mode=mode;controls(); };
  state.enter = event => enter(event,true);
  window.__auraPlatform = state; changed();
  if (state.touch && !supported() && !standalone()) explain();
})();

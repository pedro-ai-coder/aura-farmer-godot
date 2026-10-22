/* Browser lifecycle adapter. Called only by Godot Web; never advances simulation. */
(function () {
  if (window.__auraPlatform) return;
  const state = { fullscreen: 'idle', orientation: 'idle', touch: navigator.maxTouchPoints > 0, safe: [0,0,0,0] };
  const probe = document.createElement('div');
  probe.style.cssText = 'position:fixed;visibility:hidden;pointer-events:none;padding:env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left)';
  document.body.appendChild(probe);
  function refresh() {
    const css = getComputedStyle(probe);
    state.safe = ['paddingLeft','paddingTop','paddingRight','paddingBottom'].map(k => parseFloat(css[k]) || 0);
    state.width = innerWidth; state.height = innerHeight;
  }
  state.metrics = function () { refresh(); return JSON.stringify({touch:state.touch,safe:state.safe,width:state.width,height:state.height,fullscreen:state.fullscreen,orientation:state.orientation}); };
  async function gesture(event) {
    if (event.pointerType !== 'touch' || !event.isTrusted || state.fullscreen !== 'idle') return;
    state.touch = true;
    const canvas = document.getElementById('canvas');
    if (!canvas || !document.fullscreenEnabled || typeof canvas.requestFullscreen !== 'function') { state.fullscreen='unavailable';return; }
    if (navigator.userActivation && !navigator.userActivation.isActive) return;
    state.fullscreen='pending';
    try {
      if (!document.fullscreenElement) await canvas.requestFullscreen();
      state.fullscreen='active';
      if (screen.orientation && typeof screen.orientation.lock === 'function') {
        try { await screen.orientation.lock('landscape'); state.orientation='locked'; } catch (_) { state.orientation='denied'; }
      } else state.orientation='unavailable';
    } catch (_) { state.fullscreen='denied'; }
  }
  document.addEventListener('pointerup',gesture,{passive:true});
  document.addEventListener('fullscreenchange',refresh);
  addEventListener('resize',refresh);
  const viewport = document.querySelector('meta[name="viewport"]');
  if (viewport) viewport.setAttribute('content','width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover');
  document.documentElement.style.overscrollBehavior='none';
  document.body.style.overscrollBehavior='none';
  const canvas=document.getElementById('canvas');if(canvas)canvas.style.touchAction='none';
  window.__auraPlatform = state; refresh();
})();

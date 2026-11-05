/* Experimental Level Zero browser capability hint. Not a gameplay test. */
(function () {
  'use strict';
  if (new URLSearchParams(window.location.search).get('level_zero') !== '1') return;
  if (window.__clutchpunksLevelZeroPreflight) return;

  // NEVER probe the engine canvas: getContext() would claim its rendering context.
  const probe = document.createElement('canvas');
  let gl = null;
  try {
    gl = probe.getContext('webgl2');
  } catch (_) {
    // A blocked/disabled WebGL2 implementation can throw instead of returning null.
  }
  const supported = gl !== null;
  if (gl && typeof gl.getExtension === 'function') {
    const extension = gl.getExtension('WEBGL_lose_context');
    if (extension) extension.loseContext();
  }
  window.__clutchpunksLevelZeroPreflight = Object.freeze({
    version: 1,
    webgl2_available: supported,
    note: 'Capability probe only; does not verify that Godot booted or gameplay works.'
  });
  if (supported) return;

  const notice = document.createElement('div');
  notice.id = 'clutchpunks-level-zero-webgl2-warning';
  notice.setAttribute('role', 'alert');
  notice.style.cssText = 'position:fixed;inset:auto 16px 16px;z-index:10000;' +
    'max-width:640px;margin:auto;padding:16px 20px;' +
    'background:#101723;color:#fff9e9;border:2px solid #f8c45f;' +
    'font:500 16px/1.5 system-ui,sans-serif;box-sizing:border-box';
  notice.textContent = 'Level Zero cannot start here: WebGL2 is unavailable. ' +
    'Try a WebGL2-capable browser with hardware acceleration enabled. ' +
    'This is a browser capability check, not a gameplay test.';

  const attach = () => {
    if (document.body && !document.getElementById(notice.id)) document.body.appendChild(notice);
  };
  if (document.body) attach();
  else document.addEventListener('DOMContentLoaded', attach, { once: true });
})();

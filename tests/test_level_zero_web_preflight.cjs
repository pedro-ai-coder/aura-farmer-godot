'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const source = fs.readFileSync(path.join(__dirname, '../web/level_zero_preflight.js'), 'utf8');

function scenario({url = '?level_zero=1', capability = true, throws = false, bodyReady = true} = {}) {
  const elements = new Map(), listeners = new Map();
  let probed = 0, released = 0, canvasCount = 0;
  const body = {appendChild(node) {elements.set(node.id, node);}};
  const document = {
    body: bodyReady ? body : null,
    createElement(tag) {
      if (tag === 'canvas') {
        canvasCount++;
        return {getContext(kind) {
          assert.equal(kind, 'webgl2');
          probed++;
          if (throws) throw new Error('blocked');
          return capability ? {getExtension(name) {
            assert.equal(name, 'WEBGL_lose_context');
            return {loseContext() {released++;}};
          }} : null;
        }};
      }
      return {id:'', style:{}, setAttribute(name, value) {this[name] = value;}};
    },
    getElementById(id) {return elements.get(id) || null;},
    addEventListener(name, fn, options) {listeners.set(name, {fn, options});}
  };
  const context = {URLSearchParams, document, window:{location:{search:url}}};
  function execute() {vm.runInNewContext(source, context);}
  execute();
  return {
    context, document, elements, listeners, execute,
    ready() {document.body = body;listeners.get('DOMContentLoaded').fn();},
    get probed() {return probed;},
    get released() {return released;},
    get canvasCount() {return canvasCount;}
  };
}
const normal = scenario({url:''});
assert.equal(normal.probed,0);
assert.equal(normal.context.window.__clutchpunksLevelZeroPreflight,undefined);
const supported = scenario();
assert.equal(supported.probed,1);
assert.equal(supported.released,1);
assert.equal(supported.context.window.__clutchpunksLevelZeroPreflight.webgl2_available,true);
assert.equal(supported.elements.size,0);
supported.execute();
assert.equal(supported.probed,1,'Repeated execution must not probe again');
const blocked = scenario({capability:false});
assert.equal(blocked.context.window.__clutchpunksLevelZeroPreflight.webgl2_available,false);
assert.match(blocked.elements.get('clutchpunks-level-zero-webgl2-warning').textContent,/WebGL2 is unavailable/);
assert.equal(blocked.elements.get('clutchpunks-level-zero-webgl2-warning').role,'alert');
const thrown = scenario({throws:true,bodyReady:false});
assert.equal(thrown.elements.size,0);
assert.equal(thrown.listeners.get('DOMContentLoaded').options.once,true);
thrown.ready();
assert.equal(thrown.elements.size,1);
assert.equal(thrown.context.window.__clutchpunksLevelZeroPreflight.webgl2_available,false);
console.log('PASS: opt-in URL scope, isolated canvas probe, capability notice and idempotent startup');

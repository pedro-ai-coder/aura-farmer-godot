import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { setTimeout as wait } from 'node:timers/promises';

const [url, commit, directory] = process.argv.slice(2);
assert(url && /^[a-f0-9]{40}$/.test(commit) && directory && process.env.CHROME_BIN,
  'Set CHROME_BIN and pass Web URL, full build commit, and evidence directory.');
const accessFile = process.env.WAVE_AUDIO_PREVIEW_ACCESS_FILE;
const navigationUrl = accessFile ? (await readFile(accessFile, 'utf8')).trim() : url;
assert.equal(new URL(navigationUrl).origin, new URL(url).origin);
const fixture = process.env.WAVE_AUDIO_FIXTURE === '1';
const throughWave2 = process.env.WAVE_AUDIO_REPRO === '1';
const choices = (process.env.WAVE_AUDIO_CHOICES ?? '').split(',').filter(Boolean).map(Number);
assert(choices.every(slot => Number.isInteger(slot) && slot >= 1 && slot <= 3), 'Upgrade slots must be 1, 2, or 3');

await mkdir(directory, { recursive: true });
const profile = await mkdtemp(join(tmpdir(), 'cpk-wave-audio-'));
const chrome = spawn(process.env.CHROME_BIN, [
  '--headless=new', '--remote-debugging-port=0', '--no-first-run',
  '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
  '--user-data-dir=' + profile, 'about:blank',
], { stdio: 'ignore' });
let socket;
const evidence = { url, fixture, journal: [], frames: [], errors: [] };
try {
  let port;
  for (let attempt = 0; attempt < 100 && !port; attempt++) {
    port = (await readFile(join(profile, 'DevToolsActivePort'), 'utf8').catch(() => '')).split('\n')[0];
    if (!port) await wait(100);
  }
  assert(port, 'Chrome did not start');
  const [tab] = await fetch('http://127.0.0.1:' + port + '/json/list').then(r => r.json());
  socket = new WebSocket(tab.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
  const pending = new Map();
  let sequence = 0;
  socket.onmessage = ({ data }) => {
    const message = JSON.parse(data);
    if (message.method === 'Runtime.exceptionThrown') evidence.errors.push(message.params.exceptionDetails);
    if (!message.id) return;
    const { resolve, reject } = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message));
    else resolve(message.result);
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++sequence;
    pending.set(id, { resolve, reject });
    socket.send(JSON.stringify({ id, method, params }));
  });
  const read = async expression => {
    const { result, exceptionDetails } = await send('Runtime.evaluate', {
      expression, returnByValue: true, awaitPromise: true,
    });
    assert(!exceptionDetails, JSON.stringify(exceptionDetails));
    return result.value;
  };
  const until = async (check, description, limit = 30000) => {
    const deadline = Date.now() + limit;
    while (Date.now() < deadline) {
      const value = await check();
      if (value) return value;
      await wait(120);
    }
    throw new Error('Timed out: ' + description);
  };
  const note = (action, data = {}) => {
    const entry = { action, ...data };
    evidence.journal.push(entry);
    console.log(JSON.stringify(entry));
  };
  const key = (type, code, key, windowsVirtualKeyCode) =>
    send('Input.dispatchKeyEvent', { type, code, key, windowsVirtualKeyCode });
  const tap = async (code, value, number) => {
    await key('keyDown', code, value, number);
    await key('keyUp', code, value, number);
  };
  const click = async (x, y) => {
    for (const type of ['mousePressed', 'mouseReleased']) {
      await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 });
    }
  };
  const shot = async name => {
    const { data } = await send('Page.captureScreenshot', { format: 'png' });
    await writeFile(join(directory, name + '.png'), Buffer.from(data, 'base64'));
  };
  const probe = () => read('waveAudio.read()');
  const mode = () => read('window.__auraPlatform?.mode');
  await send('Runtime.enable');
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 1280, height: 720, mobile: false, deviceScaleFactor: 1 });
  await send('Page.addScriptToEvaluateOnNewDocument', {
    source: await readFile(new URL('./web_audio_probe.js', import.meta.url), 'utf8'),
  });
  await send('Page.navigate', { url: navigationUrl });
  await until(() => read('document.readyState === "complete" && location.origin === ' + JSON.stringify(new URL(url).origin)), 'Web export');
  evidence.build = await read('fetch("/build.json").then(response => response.json())');
  assert.equal(evidence.build.commit, commit);
  assert.equal(Boolean(evidence.build.fixture), fixture);
  assert(!evidence.build.review, 'Expected the standard Web preset');

  const sample = async () => {
    const frame = await probe();
    evidence.frames.push(frame);
    return frame;
  };
  const see = async name => until(async () => (await probe()).mode === name, name);
  const recordFor = async milliseconds => {
    const deadline = Date.now() + milliseconds;
    do {
      await sample();
      await wait(125);
    } while (Date.now() < deadline);
  };
  const scoreTracks = frame => frame.tracks.filter(track => Math.abs(track.duration - 9.6) < .02);
  const setMuteInSettings = async () => {
    await tap('KeyP', 'p', 80);
    await see('paused');
    await click(640, 438);
    await see('options');
    await shot('settings');
    await click(460, 390);
    await tap('Escape', 'Escape', 27);
    await see('paused');
    await tap('KeyP', 'p', 80);
    await see('playing');
  };

  if (fixture) {
    await see('waiting');
  } else {
    await until(() => read('waveAudio.read().time !== undefined && window.__auraPlatform?.mode === "menu" && (!document.getElementById("status") || getComputedStyle(document.getElementById("status")).display === "none")'), 'Garage');
    await shot('garage');
  }
  await read('waveAudio.record(' + !fixture + ')');
  try {
    if (fixture) {
      await tap('Enter', 'Enter', 13);
      await until(async () => (await sample()).mode === 'wave-2', 'Wave 2 audio fixture');
      await recordFor(1700);
      await tap('KeyP', 'p', 80);
      await see('paused');
      await wait(300);
      await recordFor(650);
      await tap('KeyP', 'p', 80);
      await until(async () => (await sample()).mode === 'wave-2', 'Wave 2 audio fixture');
      await recordFor(900);
      await tap('KeyM', 'm', 77);
      await see('muted');
      await wait(300);
      await recordFor(650);
      await tap('KeyM', 'm', 77);
      const timeout = Date.now() + 100000;
      while ((await probe()).mode !== 'done') {
        assert(Date.now() < timeout, 'Synthetic fixture exceeded test limit');
        const frame = await sample();
        if (frame.mode !== evidence.journal.at(-1)?.mode) note('fixture-stage', { mode: frame.mode, time: frame.time });
        await wait(125);
      }
    } else {
      await click(210, 280);
      await until(async () => await mode() === 'maps', 'map selection');
      await click(420, 522);
      await click(860, 596);
      await until(async () => await mode() === 'playing', 'first wave');
      await shot('run-start');
      note('start');
      let lastMode;
      let active = 0;
      let previous = Date.now();
      let held = '';
      let flexAt = 0;
      let paused = false;
      let muted = false;
      let choiceIndex = 0;
      const move = async direction => {
        if (held === direction) return;
        if (held) await key('keyUp', 'Key' + held.toUpperCase(), held, held.toUpperCase().charCodeAt(0));
        if (direction) await key('keyDown', 'Key' + direction.toUpperCase(), direction, direction.toUpperCase().charCodeAt(0));
        held = direction;
      };
      for (;;) {
        const frame = await sample();
        const now = Date.now();
        if (lastMode === 'playing' && frame.mode === 'playing') active += (now - previous) / 1000;
        previous = now;
        if (frame.mode !== lastMode) note('mode', { mode: frame.mode, active, time: frame.time });
        lastMode = frame.mode;
        if (frame.mode === 'playing') {
          const music = scoreTracks(frame);
          if (music.length > (evidence.waveIds?.length ?? 0)) {
            evidence.waveIds = music.map(track => track.id);
            note('new score', { count: music.length, time: frame.time, id: music.at(-1).id });
            await shot('score-' + music.length);
          }
          if (active > 10 && !paused) {
            paused = true;
            await move('');
            await tap('KeyP', 'p', 80);
            await see('paused');
            await wait(300);
            await recordFor(600);
            await shot('paused');
            await tap('KeyP', 'p', 80);
            await see('playing');
            await recordFor(750);
          } else if (active > 15 && !muted && !throughWave2) {
            muted = true;
            await move('');
            await setMuteInSettings();
            await wait(400);
            const mutedFrame = await sample();
            note('muted', mutedFrame);
            assert(mutedFrame.mix < 0.0001, 'Mute must silence the final browser mix');
            await setMuteInSettings();
            await recordFor(750);
            assert((await probe()).mix > 0.001, 'Unmute must restore the final browser mix');
          }
          let step = active % 7.68;
          for (const [direction, duration] of [['d', .9], ['s', .62], ['a', 1.8], ['w', 1.26], ['d', 1.82], ['s', 1.26]]) {
            if (step < duration) { await move(direction); break; }
            step -= duration;
          }
          if (active - flexAt > 4.5) {
            await tap('Space', ' ', 32);
            flexAt = active;
          }
        } else if (['choice', 'legendary', 'replace'].includes(frame.mode)) {
          await move('');
          await wait(400);
          await sample();
          const slot = choices[choiceIndex++] ?? 1;
          await tap('Digit' + slot, String(slot), 48 + slot);
          await tap('Enter', 'Enter', 13);
        } else if (['won', 'lost', 'result'].includes(frame.mode)) {
          await move('');
          await recordFor(2500);
          await shot('result');
          if (!throughWave2) {
            await click(1080, 670);
            await see('playing');
            const retryTime = (await probe()).time;
            await recordFor(2200);
            const retry = evidence.frames.filter(frame => frame.time >= retryTime);
            assert(retry.some(frame => frame.tracks.find(track => track.id === evidence.waveIds[0])?.rms > .004),
              'Retry must restore Wave 1 in the browser mix');
            note('retry', { time: retryTime });
          }
          break;
        }
        if (throughWave2 && evidence.waveIds?.length >= 2) {
          const starts = await read('waveAudio.starts');
          const initial = starts.find(start => start.id === evidence.waveIds[1]);
          if (frame.time - initial.time > 12) break;
        }
        assert(active < 1000, 'Run exceeded test limit');
        await wait(125);
      }
    }
    evidence.starts = await read('waveAudio.starts');
    note('last sample', await probe());
    verify(evidence, throughWave2);
  } finally {
    await read('waveAudio.recording().recorder.stop()');
    const length = await until(() => read('waveAudio.recording().blob?.size'), 'recorded browser output');
    const chunks = [];
    for (let offset = 0; offset < length; offset += 512000) {
      const encoded = await read('new Promise(resolve => { const reader = new FileReader(); reader.onload = () => resolve(reader.result.split(",")[1]); reader.readAsDataURL(waveAudio.recording().blob.slice(' + offset + ',' + (offset + 512000) + ')); })');
      chunks.push(Buffer.from(encoded, 'base64'));
    }
    await writeFile(join(directory, fixture ? 'synthetic-fixture.webm' : 'ordinary-web.webm'), Buffer.concat(chunks));
  }
} finally {
  await writeFile(join(directory, 'measurements.json'), JSON.stringify(evidence, null, 2));
  socket?.close();
  chrome.kill();
}


function verify(evidence, throughWave2) {
  const audible = .004;
  const firstStarts = evidence.starts.filter((start, index, starts) =>
    starts.findIndex(sample => sample.id === start.id) === index);
  const scores = firstStarts.filter(start => Math.abs(start.duration - 9.6) < .02);
  const rms = (frame, id) => frame.tracks.find(track => track.id === id)?.rms ?? 0;
  const tone = (duration, mode) => {
    const start = firstStarts.find(sample => Math.abs(sample.duration - duration) < .015);
    assert(start, 'Missing cue, duration ' + duration);
    assert(evidence.frames.some(frame => frame.mode === mode && rms(frame, start.id) > .0015),
      'Cue did not reach the browser mix, duration ' + duration);
  };
  const expected = throughWave2 ? 2 : 6;
  for (const [index, score] of scores.slice(0, expected).entries()) {
    const nextTime = scores[index + 1]?.time ?? Infinity;
    const frames = evidence.frames.filter(frame => frame.time > score.time + 1
      && frame.time < nextTime && (evidence.fixture
        ? frame.mode === (index === 5 ? 'boss' : 'wave-' + (index + 1))
        : frame.mode === 'playing')
      && !evidence.journal.some(entry => entry.action === 'retry' && frame.time >= entry.time));
    const peak = Math.max(0, ...frames.map(frame => rms(frame, score.id)));
    const loops = evidence.starts.filter(start => start.id === score.id && start.time < nextTime);
    const transition = evidence.frames.filter(frame => frame.time >= score.time && frame.time < score.time + .85);
    console.log(JSON.stringify({ score: index + 1, offset: score.offset, peak, frames: frames.length, starts: loops.length }));
    assert(peak >= audible, 'Silent browser score ' + (index + 1));
    if (index > 0 && index < 5) {
      assert(transition.some(frame => rms(frame, scores[index - 1].id) >= .001 && rms(frame, score.id) >= .001),
        'No browser output overlap during crossfade into Wave ' + (index + 1));
    }
    assert(score.offset < score.duration, 'Out-of-range browser start offset');
    let lastSound = null;
    let previous = null;
    for (const frame of frames) {
      // Input, UI transitions and screenshot capture can leave gaps in sampling.
      if (previous === null || frame.time - previous > .5) lastSound = frame.time;
      if (rms(frame, score.id) >= .001) lastSound = frame.time;
      assert(frame.time - lastSound < 1, 'Sustained score dropout in score ' + (index + 1));
      previous = frame.time;
    }
  }
  const paused = evidence.frames.filter(frame => frame.mode === 'paused');
  assert(paused.length && paused.every(frame => frame.mix < .0001), 'Pause must silence the actual browser mix');
  if (evidence.fixture) {
    const muted = evidence.frames.filter(frame => frame.mode === 'muted');
    assert(muted.length && muted.every(frame => frame.mix < .0001), 'Mute must silence the actual browser mix');
    tone(.84, 'boss');
    tone(2.05, 'victory');
    tone(1.2, 'defeat');
    assert(evidence.frames.some(frame => frame.mode === 'retry' && rms(frame, scores[0].id) >= audible),
      'Retry must restore Wave 1');
  } else if (!throughWave2) {
    const outcome = evidence.frames.find(frame => ['won', 'lost'].includes(frame.mode))?.mode;
    assert(outcome, 'Missing ordinary run result');
    const choices = evidence.frames.filter(frame => ['choice', 'legendary', 'replace'].includes(frame.mode));
    assert(choices.some(frame => frame.mix < .0001), 'An ordinary upgrade must pause the browser mix');
    tone(outcome === 'won' ? 2.05 : 1.2, outcome);
  }
  assert.equal(evidence.errors.length, 0, 'Unhandled browser errors');
  assert(scores.length >= expected, 'Run reached only ' + scores.length + ' of ' + expected + ' expected score tracks');
  console.log('PASS: rendered browser audio, modal lifecycle, and requested score coverage');
}

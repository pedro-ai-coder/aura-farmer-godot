(() => {
  const graph = new WeakMap();
  const tracks = new Map();
  const starts = [];
  const connect = AudioNode.prototype.connect;
  const start = AudioBufferSourceNode.prototype.start;
  let output;
  let capture;

  AudioNode.prototype.connect = function (target, ...ports) {
    const result = connect.call(this, target, ...ports);
    if (target === this.context.destination) {
      // A parallel tap of the same final mix, after the Master gain.
      if (!output) {
        output = { mix: this.context.createAnalyser(), media: this.context.createMediaStreamDestination() };
        connect.call(this, output.mix);
        connect.call(this, output.media);
      }
    } else if (target instanceof AudioNode) {
      if (!graph.has(this)) graph.set(this, new Set());
      graph.get(this).add(target);
    }
    return result;
  };

  AudioBufferSourceNode.prototype.start = function (when, offset = 0, ...args) {
    const duration = this.buffer?.duration;
    if (duration >= .83) {
      // Godot gives each loop restart a fresh copy of the same buffer.
      const pcm = this.buffer.getChannelData(0);
      const signature = [pcm.length, ...Array.from({ length: 16 }, (_, i) => pcm[Math.floor(pcm.length * (i + 1) / 17)])].join(",");
      if (!tracks.has(signature)) tracks.set(signature, { id: tracks.size + 1, duration });
      const track = tracks.get(signature);
      starts.push({ id: track.id, time: this.context.currentTime, duration, offset });
      for (const target of graph.get(this) ?? []) {
        if (!(target instanceof ChannelSplitterNode)) continue;
        // Godot Web sample path: source → splitter → player gains → merger.
        const gain = [...(graph.get(target) ?? [])].find(node => node instanceof GainNode);
        const merger = [...(graph.get(gain) ?? [])].find(node => node instanceof ChannelMergerNode);
        if (merger && track.merger !== merger) {
          const analyser = this.context.createAnalyser();
          connect.call(merger, analyser);
          track.merger = merger;
          track.analyser = analyser;
        }
      }
    }
    return start.call(this, when, offset, ...args);
  };

  const samples = new Float32Array(2048);
  const rms = analyser => {
    if (!analyser) return 0;
    analyser.getFloatTimeDomainData(samples);
    return Math.sqrt(samples.reduce((sum, sample) => sum + sample * sample, 0) / samples.length);
  };

  window.waveAudio = {
    starts,
    read: () => ({
      time: output?.mix.context.currentTime,
      state: output?.mix.context.state,
      mode: window.waveAudioStage ?? window.__auraPlatform?.mode,
      mix: rms(output?.mix),
      tracks: [...tracks.values()].map(({ id, duration, analyser }) => ({ id, duration, rms: rms(analyser) })),
    }),
    record: (video = false) => {
      const chunks = [];
      const stream = new MediaStream(output.media.stream.getAudioTracks());
      if (video) stream.addTrack(document.querySelector('canvas').captureStream(20).getVideoTracks()[0]);
      const recorder = new MediaRecorder(stream);
      capture = { recorder };
      recorder.ondataavailable = event => chunks.push(event.data);
      recorder.onstop = () => { capture.blob = new Blob(chunks, { type: recorder.mimeType }); };
      recorder.start(1000);
    },
    recording: () => capture,
  };
})();

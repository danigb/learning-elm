(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Snare = require('snare')
var Kick = require('kick-eight')

function eightoeight (ac) {
  return {
    snare: Snare(ac),
    kick: Kick(ac)
  }
}

if (typeof module === 'object' && module.exports) module.exports = eightoeight
if (typeof window !== 'undefined') window.eightoeight = eightoeight

},{"kick-eight":2,"snare":4}],2:[function(require,module,exports){
var NoiseBuffer = require('noise-buffer');
var noiseBuffer = NoiseBuffer(1);

module.exports = function(context, parameters) {

  parameters = parameters || {};
  parameters.tone = typeof parameters.tone === 'number' ? parameters.tone : 64;
  parameters.decay = typeof parameters.decay === 'number' ? parameters.decay : 64;
  parameters.level = typeof parameters.level === 'number' ? parameters.level : 100;

  var playingNodes = [];

  return function() {

    var osc = context.createOscillator();
    osc.frequency.value = 54;
    var gain = context.createGain();
    var oscGain = context.createGain();
    osc.connect(oscGain);

    gain.decay = parameters.decay;
    gain.tone = parameters.tone;

    var choke = context.createGain();
    choke.gain.value = 0;

    oscGain.connect(choke);
    choke.connect(gain);


    gain.start = function(when) {
      if (typeof when !== 'number') {
        when = context.currentTime;
      }

      while (playingNodes.length) {
        playingNodes.pop().stop(when);
      }
      playingNodes.push(gain);

      choke.gain.setValueAtTime(0, when + 0.0001);
      choke.gain.linearRampToValueAtTime(1, when + 0.0002);

      max = 2.2;
      min = 0.09;
      duration = (max - min) * (gain.decay / 127) + min;

      var noise = context.createBufferSource();
      noise.buffer = noiseBuffer;
      noise.loop = true;
      var noiseGain = context.createGain();
      var noiseFilter = context.createBiquadFilter();
      noiseFilter.type = "bandpass";
      noiseFilter.frequency.value = 1380 * 2;
      noiseFilter.Q.value = 20;
      noise.connect(noiseFilter);
      noiseFilter.connect(noiseGain);
      noiseGain.connect(choke);


      noiseGain.gain.setValueAtTime(2 * Math.max((gain.tone / 127), 0.0001), when);
      noiseGain.gain.exponentialRampToValueAtTime(0.0001, when + 0.01);
      noise.start(when);
      noise.stop(when + duration);

      osc.start(when);
      osc.stop(when + duration);
      osc.onended = function() {
        gain.disconnect();
      }

      oscGain.gain.setValueAtTime(0.0001, when);
      oscGain.gain.exponentialRampToValueAtTime(1, when + 0.004);
      oscGain.gain.exponentialRampToValueAtTime(0.0001, when + duration);
    };

    gain.stop = function(when) {
      if (typeof when !== 'number') {
        when = context.currentTime;
      }

      choke.gain.setValueAtTime(1, when);
      choke.gain.linearRampToValueAtTime(0, when + 0.0001);
    };

    return gain;
  };
};

},{"noise-buffer":3}],3:[function(require,module,exports){
// courtesy of http://noisehack.com/generate-noise-web-audio-api/
module.exports = function(length, type) {
  type = type || 'white';

  var sampleRate = 44100;
  var samples = length * sampleRate;
  var context = new (window.OfflineAudioContext || window.webkitOfflineAudioContext)(1, samples, sampleRate);
  var noiseBuffer = context.createBuffer(1, samples, sampleRate);
  var output = noiseBuffer.getChannelData(0);

  switch(type) {
    case 'white':
      // http://noisehack.com/generate-noise-web-audio-api/
      for (var i = 0; i < samples; i++) {
        output[i] = Math.random() * 2 - 1;
      }
      break;
    case 'pink':
      // just completely http://noisehack.com/generate-noise-web-audio-api/
      var b0, b1, b2, b3, b4, b5, b6;
      b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
      for (var i = 0; i < samples; i++) {
        var white = Math.random() * 2 - 1;
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
        output[i] *= 0.11; // (roughly) compensate for gain
        b6 = white * 0.115926;
      }
      break;
    case 'brown':
      // just completely http://noisehack.com/generate-noise-web-audio-api/
      var lastOut = 0.0;
      for (var i = 0; i < samples; i++) {
        var white = Math.random() * 2 - 1;
        output[i] = (lastOut + (0.02 * white)) / 1.02;
        lastOut = output[i];
        output[i] *= 3.5; // (roughly) compensate for gain
      }
      break;
  }

  return noiseBuffer;
};

},{}],4:[function(require,module,exports){
var NoiseBuffer = require('noise-buffer');
var augmentedOnEnded = require('./lib/augmented-on-ended');
var getVoltage = require('./lib/get-voltage');


module.exports = function(context, parameters) {

  var playingNodes = [];

  parameters = parameters || {};
  parameters.tone = typeof parameters.tone === 'number' ? parameters.tone : 64;
  parameters.snappy = typeof parameters.snappy === 'number' ? parameters.snappy : 64;

  var noiseBuffer = NoiseBuffer(1);

  return function() {

    var masterHighBump = context.createBiquadFilter();
    masterHighBump.frequency.value = 4000;
    masterHighBump.gain.value = 6;
    masterHighBump.type = "peaking";
    var masterLowBump = context.createBiquadFilter();
    masterLowBump.frequency.value = 200;
    masterLowBump.gain.value = 12;
    masterLowBump.type = "peaking";
    masterHighBump.connect(masterLowBump);


    var masterBus = context.createGain();
    masterBus.gain.value = 0.4;
    masterBus.connect(masterHighBump);


    var noiseHighpass = context.createBiquadFilter();
    noiseHighpass.type = "highpass";
    noiseHighpass.frequency.value = 1200;
    noiseHighpass.connect(masterBus);


    var oscsHighpass = context.createBiquadFilter();
    oscsHighpass.type = "highpass";
    oscsHighpass.frequency.value = 400;
    oscsHighpass.connect(masterBus);

    var audioNode = context.createGain();


    var noise = context.createBufferSource();
    noise.buffer = noiseBuffer;
    noise.loop = true;


    var snappyGainNode = context.createGain();
    snappyGainNode.gain.value = 1;
    audioNode.snappy = snappyGainNode.gain;

    var oscsPreChoke = context.createGain();
    oscsPreChoke.gain.value = 0;
    var noisePreChoke = context.createGain();
    noisePreChoke.gain.value = 0;


    var noiseGain = context.createGain();
    noise.connect(snappyGainNode);
    snappyGainNode.connect(noiseGain);
    noiseGain.connect(noisePreChoke);
    noisePreChoke.connect(noiseHighpass);



    var oscsGain = context.createGain();
    oscsGain.connect(oscsPreChoke);
    oscsPreChoke.connect(oscsHighpass);

    var voltage = getVoltage(context);
    var detuneGainNode = context.createGain();
    detuneGainNode.gain.value = 0;
    audioNode.detune = detuneGainNode.gain;
    voltage.connect(detuneGainNode);

    var postChoke = context.createGain();
    postChoke.gain.value = 0;


    var oscs = [87.307, 329.628].map(function(frequency) {
      var osc = context.createOscillator();
      osc.frequency.value = frequency;
      detuneGainNode.connect(osc.detune);
      return osc;
    });

    var toneNode = context.createGain();
    toneNode.gain.value = 0.5;
    voltage.connect(toneNode);

    audioNode.tone = toneNode.gain;

    var oscAGainNode = context.createGain();
    var oscBGainNode = context.createGain();

    oscAGainNode.gain.value = -1;
    oscBGainNode.gain.value = 0;

    oscs[0].connect(oscAGainNode);
    oscs[1].connect(oscBGainNode);

    toneNode.connect(oscAGainNode.gain);
    toneNode.connect(oscBGainNode.gain);

    oscAGainNode.connect(oscsGain);
    oscBGainNode.connect(oscsGain);


    masterLowBump.connect(postChoke);
    postChoke.connect(audioNode);


    augmentedOnEnded(noise, function() {
      masterLowBump.disconnect(postChoke);
    });


    audioNode.duration = 0.3;

    audioNode.start = function(when) {

      oscsPreChoke.gain.setValueAtTime(0, when + 0.0001);
      oscsPreChoke.gain.linearRampToValueAtTime(1, when + 0.0002);
      noisePreChoke.gain.setValueAtTime(0, when + 0.0001);
      noisePreChoke.gain.linearRampToValueAtTime(1, when + 0.0002);
      postChoke.gain.setValueAtTime(0, when + 0.0001);
      postChoke.gain.linearRampToValueAtTime(1, when + 0.0002);

      // each Snare instance is monophonic
      while (playingNodes.length) {
        playingNodes.pop().stop(when);
      }
      playingNodes.push(audioNode);

      if (typeof when !== "number") {
        when = context.currentTime;
      }

      noiseGain.gain.setValueAtTime(0.0001, when);
      noiseGain.gain.exponentialRampToValueAtTime(Math.max(0.0001, 1),
                                                  when + Math.min(audioNode.duration * (0.01 / 0.3), 0.01));
      noiseGain.gain.exponentialRampToValueAtTime(0.0001,
                                                  when + audioNode.duration);

      oscsGain.gain.setValueAtTime(0.0001, when);
      oscsGain.gain.exponentialRampToValueAtTime(1,
                                                 when + Math.min(0.01, audioNode.duration * (0.01 / 0.3)));
      oscsGain.gain.exponentialRampToValueAtTime(0.00001,
                                                 when + audioNode.duration * 2/3);

      oscs.forEach(function(osc) {
        osc.start(when);
        osc.stop(when + audioNode.duration);
      });

      noise.start(when);
      noise.stop(when + audioNode.duration);

      voltage.start(when);
      voltage.stop(when + audioNode.duration);


    };
    audioNode.stop = function(when) {

      oscsPreChoke.gain.setValueAtTime(1, when);
      oscsPreChoke.gain.linearRampToValueAtTime(0, when + 0.0001);
      noisePreChoke.gain.setValueAtTime(1, when);
      noisePreChoke.gain.linearRampToValueAtTime(0, when + 0.0001);
      postChoke.gain.setValueAtTime(1, when);
      postChoke.gain.linearRampToValueAtTime(0, when + 0.0001);

      // Do not stop twice
      audioNode.stop = function() {};
      audioNode.gain.setValueAtTime(1, when);
      audioNode.gain.linearRampToValueAtTime(0, when + 0.01);
      try {
        oscs.forEach(function(osc) {
          osc.stop(when + 0.01);
        });
        noise.stop(when + 0.01);
        voltage.stop(when + 0.01);
      } catch (e) {
        // likely already stopped
      }
    };
    return audioNode;
  };
};

},{"./lib/augmented-on-ended":5,"./lib/get-voltage":6,"noise-buffer":7}],5:[function(require,module,exports){
module.exports = function augmentedOnEnded(triggerNode, fn) {
  var context = triggerNode.context;
  if (context instanceof (window.OfflineAudioContext || window.webkitOfflineAudioContext)) {
    context.suspend().then(function() {
      fn();
      context.resume();
    });
  } else if (context instanceof (window.AudioContext || window.webkitAudioContext)) {
    triggerNode.onended = fn;
  }
}

},{}],6:[function(require,module,exports){
module.exports = function getVoltage(context) {
  var buffer = context.createBuffer(1, 2, 44100);
  var data = buffer.getChannelData(0);
  data[0] = 1;
  data[1] = 1;
  var source = context.createBufferSource();
  source.buffer = buffer;
  source.loop = true;
  return source;
}

},{}],7:[function(require,module,exports){
arguments[4][3][0].apply(exports,arguments)
},{"dup":3}]},{},[1]);

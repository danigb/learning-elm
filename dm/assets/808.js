(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict'
var NAMES = ['kick', 'snare', 'rimshot', 'hihat']
var vols = [1, 0.2, 0.5, 0.5]
var libs = [
  require('kick-eight'),
  require('snare'),
  require('rim-shot'),
  require('hi-hat')
]
function id (name) { return NAMES.indexOf(name) }

function eightoeight (ac) {
  var output = ac.createGain()
  var dm = { output: output }
  var gains = vols.map(function (val) {
    var g = ac.createGain()
    g.gain.value = val
    g.connect(output)
    return g
  })
  var insts = libs.map(function (lib) {
    return lib(ac)
  })
  dm.names = function () { return NAMES.slice() }
  dm.connect = function (dest) {
    output.connect(dest)
    return dm
  }
  dm.gain = function (name, val) {
    var g = gains[id(name)]
    if (g && val) g.gain.value = val
    return g
  }
  dm.node = function (name, options) {
    var inst = insts[id(name)]
    if (!inst) return null
    var node = inst()
    console.log('node', name, node, dm.gain(name))
    node.connect(dm.gain(name))
    return node
  }
  dm.start = function (name, when, options) {
    var node = dm.node(name, options)
    console.log('start', name, when, options, node)
    if (node) node.start(when)
  }
  return dm
}

if (typeof module === 'object' && module.exports) module.exports = eightoeight
if (typeof window !== 'undefined') window.eightoeight = eightoeight

},{"hi-hat":2,"kick-eight":4,"rim-shot":6,"snare":8}],2:[function(require,module,exports){
var Envelope = require('envelope-generator');

module.exports = function(context) {

  var playingNodes = [];
  var fundamental = 80;
  var ratios = [1, 1.5, 2.08, 2.715, 3.395, 4.105];

  return function(open) {

    // Highpass
    var highpass = context.createBiquadFilter();
    highpass.type = "highpass";
    highpass.frequency.value = 7000;


    // Bandpass
    var bandpass = context.createBiquadFilter();
    bandpass.type = "bandpass";
    bandpass.frequency.value = 10000;
    bandpass.connect(highpass);

    var audioNode = context.createGain();
    var preChoke = context.createGain();
    preChoke.gain.value = 0;
    var postChoke = context.createGain();
    postChoke.gain.value = 0;

    var volume = context.createGain();
    volume.gain.value = 0.4;


    if (open) {
      audioNode.duration = 1.3;
    } else {
      audioNode.duration = 0.1;
    }


    var gainNode = context.createGain();
    gainNode.gain.value = 0;


    gainNode.connect(bandpass);
    highpass.connect(postChoke);
    postChoke.connect(volume);
    volume.connect(audioNode);


    // Create the oscillators
    var oscs = ratios.map(function(ratio) {
      var osc = context.createOscillator();
      osc.type = "square";
      // Frequency is the fundamental * this oscillator's ratio
      osc.frequency.value = fundamental * ratio;
      osc.connect(preChoke);
      return osc;
    });

    preChoke.connect(gainNode);

    audioNode.start = function(when) {

      while (playingNodes.length) {
        playingNodes.pop().stop(when);
      }
      playingNodes.push(audioNode);


      preChoke.gain.setValueAtTime(0, when + 0.0001);
      preChoke.gain.linearRampToValueAtTime(1, when + 0.0002);
      postChoke.gain.setValueAtTime(0, when + 0.0001);
      postChoke.gain.linearRampToValueAtTime(1, when + 0.0002);


      var envSettings = {
        curve: 'exponential',
        attackTime: 0.0001,
        attackCurve: 'linear',
        sustainLevel: 0.3,
        decayTime: 0.02,
      };
      envSettings.releaseTime = audioNode.duration - envSettings.attackTime - envSettings.decayTime;
      var env = new Envelope(context, envSettings);
      env.connect(gainNode.gain);


      env.start(when);
      env.release(when + envSettings.attackTime + envSettings.decayTime);
      var stopAt = env.getReleaseCompleteTime()
      env.stop(stopAt);
      oscs.forEach(function(osc) {
        osc.start(when);
        osc.stop(stopAt);
      });


      // Disconnect audioNode when convenient to ensure its cleanup
      oscs[0].onended = function() {
        highpass.disconnect(postChoke);
        audioNode.disconnect();
      };
    };

    audioNode.stop = function(when) {
      preChoke.gain
        .setValueAtTime(1, when);
      preChoke.gain
        .linearRampToValueAtTime(0, when + 0.0001);
      postChoke.gain
        .setValueAtTime(1, when);
      postChoke.gain
        .linearRampToValueAtTime(0, when + 0.0001);
      audioNode.gain
        .setValueAtTime(1, when);
      audioNode.gain
        .linearRampToValueAtTime(0, when + 0.0001);
    };

    return audioNode;
  };
};

},{"envelope-generator":3}],3:[function(require,module,exports){
'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/**
 * Create an envelope generator that
 * can be attached to an AudioParam
 */

var Envelope = function () {
  function Envelope(context, settings) {
    _classCallCheck(this, Envelope);

    // Hold on to these
    this.context = context;
    this.settings = settings;

    this._setDefaults();

    // Create nodes
    this.source = this._getOnesBufferSource();
    this.attackDecayNode = context.createGain();
    this.releaseNode = context.createGain();
    this.ampNode = context.createGain();
    this.outputNode = context.createGain();

    this.outputNode.gain.value = this.settings.startLevel;
    this.ampNode.gain.value = this.settings.maxLevel - this.settings.startLevel;

    // Set up graph
    this.source.connect(this.attackDecayNode);
    this.source.connect(this.outputNode);
    this.attackDecayNode.connect(this.releaseNode);
    this.releaseNode.connect(this.ampNode);
    this.ampNode.connect(this.outputNode.gain);
  }

  /**
   * Deal w/ settings object
   */


  _createClass(Envelope, [{
    key: '_setDefaults',
    value: function _setDefaults() {

      // curve
      if (typeof this.settings.curve !== 'string') {
        this.settings.curve = 'linear';
      }

      // delayTime
      if (typeof this.settings.delayTime !== 'number') {
        this.settings.delayTime = 0;
      }

      // startLevel
      if (typeof this.settings.startLevel !== 'number') {
        this.settings.startLevel = 0;
      }
      // maxLevel
      if (typeof this.settings.maxLevel !== 'number') {
        this.settings.maxLevel = 1;
      }

      // sustainLevel
      if (typeof this.settings.sustainLevel !== 'number') {
        this.settings.sustainLevel = 1;
      }

      // attackTime
      if (typeof this.settings.attackTime !== 'number') {
        this.settings.attackTime = 0;
      }

      // holdTime
      if (typeof this.settings.holdTime !== 'number') {
        this.settings.holdTime = 0;
      }

      // decayTime
      if (typeof this.settings.decayTime !== 'number') {
        this.settings.decayTime = 0;
      }

      // releaseTime
      if (typeof this.settings.releaseTime !== 'number') {
        this.settings.releaseTime = 0;
      }

      // startLevel must not be zero if attack curve is exponential
      if (this.settings.startLevel === 0 && this._getRampMethodName('attack') === 'exponentialRampToValueAtTime') {
        if (this.settings.maxLevel < 0) {
          this.settings.startLevel = -0.001;
        } else {
          this.settings.startLevel = 0.001;
        }
      }

      // maxLevel must not be zero if attack, decay, or release curve is exponential
      if (this.settings.maxLevel === 0 && (this._getRampMethodName('attack') === 'exponentialRampToValueAtTime' || this._getRampMethodName('decay') === 'exponentialRampToValueAtTime' || this._getRampMethodName('release') === 'exponentialRampToValueAtTime')) {
        if (this.settings.startLevel < 0) {
          this.settings.maxLevel = -0.001;
        } else {
          this.settings.maxLevel = 0.001;
        }
      }

      // sustainLevel must not be zero if decay or release curve is exponential
      if (this.settings.sustainLevel === 0 && (this._getRampMethodName('decay') === 'exponentialRampToValueAtTime' || this._getRampMethodName('release') === 'exponentialRampToValueAtTime')) {
        // No need to be negative here as it's a multiplier
        this.settings.sustainLevel = 0.001;
      }

      // decayTime must not be zero to avoid colliding with attack curve events
      if (this.settings.decayTime === 0) {

        this.settings.decayTime = 0.001;
      }
    }

    /**
     * Get an audio source that will be pegged at 1,
     * providing a signal through our path that can
     * drive the AudioParam this is attached to.
     * TODO: Can we always cache this?
     */

  }, {
    key: '_getOnesBufferSource',
    value: function _getOnesBufferSource() {
      var context = this.context;

      // Generate buffer, setting its samples to 1
      // Needs to be 2 for safari!
      // Hat tip to https://github.com/mmckegg/adsr
      var onesBuffer = context.createBuffer(1, 2, context.sampleRate);
      var data = onesBuffer.getChannelData(0);
      data[0] = 1;
      data[1] = 1;

      // Create a source for the buffer, looping it
      var source = context.createBufferSource();
      source.buffer = onesBuffer;
      source.loop = true;

      return source;
    }

    /**
     * Connect the end of the path to the
     * targetParam.
     *
     * TODO: Throw error when not an AudioParam target?
     */

  }, {
    key: 'connect',
    value: function connect(targetParam) {
      this.outputNode.connect(targetParam);
    }

    /**
     * Begin the envelope, scheduling everything we know
     * (attack time, decay time, sustain level).
     */

  }, {
    key: 'start',
    value: function start(when) {

      var attackRampMethodName = this._getRampMethodName('attack');
      var decayRampMethodName = this._getRampMethodName('decay');

      var attackStartsAt = when + this.settings.delayTime;
      var attackEndsAt = attackStartsAt + this.settings.attackTime;
      var decayStartsAt = attackEndsAt + this.settings.holdTime;
      var decayEndsAt = decayStartsAt + this.settings.decayTime;

      var attackStartLevel = 0;
      if (attackRampMethodName === "exponentialRampToValueAtTime") {
        attackStartLevel = 0.001;
      }

      this.attackDecayNode.gain.setValueAtTime(attackStartLevel, when);
      this.attackDecayNode.gain.setValueAtTime(attackStartLevel, attackStartsAt);
      this.attackDecayNode.gain[attackRampMethodName](1, attackEndsAt);
      this.attackDecayNode.gain.setValueAtTime(1, decayStartsAt);
      this.attackDecayNode.gain[decayRampMethodName](this.settings.sustainLevel, decayEndsAt);

      this.source.start(when);
    }

    /**
     * Return  either linear or exponential
     * ramp method names based on a general
     * 'curve' setting, which is overridden
     * on a per-stage basis by 'attackCurve',
     * 'decayCurve', and 'releaseCurve',
     * all of which can be set to values of
     * either 'linear' or 'exponential'.
     */

  }, {
    key: '_getRampMethodName',
    value: function _getRampMethodName(stage) {
      var exponential = 'exponentialRampToValueAtTime';
      var linear = 'linearRampToValueAtTime';

      // Handle general case
      var generalRampMethodName = linear;
      if (this.settings.curve === 'exponential') {
        generalRampMethodName = exponential;
      }

      switch (stage) {
        case 'attack':
          if (this.settings.attackCurve) {
            if (this.settings.attackCurve === 'exponential') {
              return exponential;
            } else if (this.settings.attackCurve === 'linear') {
              return linear;
            }
          }
          break;
        case 'decay':
          if (this.settings.decayCurve) {
            if (this.settings.decayCurve === 'exponential') {
              return exponential;
            } else if (this.settings.decayCurve === 'linear') {
              return linear;
            }
          }
          break;
        case 'release':
          if (this.settings.releaseCurve) {
            if (this.settings.releaseCurve === 'exponential') {
              return exponential;
            } else if (this.settings.releaseCurve === 'linear') {
              return linear;
            }
          }
          break;
        default:
          break;
      }
      return generalRampMethodName;
    }

    /**
     * End the envelope, scheduling what we didn't know before
     * (release time)
     */

  }, {
    key: 'release',
    value: function release(when) {
      this.releasedAt = when;
      var releaseEndsAt = this.releasedAt + this.settings.releaseTime;

      var rampMethodName = this._getRampMethodName('release');

      var releaseTargetLevel = 0;

      if (rampMethodName === "exponentialRampToValueAtTime") {
        releaseTargetLevel = 0.001;
      }

      this.releaseNode.gain.setValueAtTime(1, when);
      this.releaseNode.gain[rampMethodName](releaseTargetLevel, releaseEndsAt);
    }
  }, {
    key: 'stop',
    value: function stop(when) {
      this.source.stop(when);
    }

    /**
     * Provide a helper for consumers to
     * know when the release is finished,
     * so that a source can be stopped.
     */

  }, {
    key: 'getReleaseCompleteTime',
    value: function getReleaseCompleteTime() {
      if (typeof this.releasedAt !== 'number') {
        throw new Error("Release has not been called.");
      }
      return this.releasedAt + this.settings.releaseTime;
    }
  }]);

  return Envelope;
}();

module.exports = Envelope;


},{}],4:[function(require,module,exports){
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

},{"noise-buffer":5}],5:[function(require,module,exports){
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

},{}],6:[function(require,module,exports){
var makeDistortionCurve = require('make-distortion-curve');
var curve = makeDistortionCurve(1024);


// partially informed by the rather odd http://www.kvraudio.com/forum/viewtopic.php?t=383536
module.exports = function(context) {

  var playingNodes = [];



  return function() {

    var distortion = context.createWaveShaper();
    distortion.curve = curve;

    var highpass = context.createBiquadFilter();
    highpass.type = "highpass";
    highpass.frequency.value = 700;

    distortion.connect(highpass);


    var preChoke = context.createGain();
    preChoke.gain.value = 0;
    var postChoke = context.createGain();
    postChoke.gain.value = 0;

    var duration = 0.05;

    var gain = context.createGain();

    gain.start = function(when) {

      while (playingNodes.length) {
        playingNodes.pop().stop(when);
      }
      playingNodes.push(gain);

      preChoke.gain.setValueAtTime(0, when + 0.0001);
      preChoke.gain.linearRampToValueAtTime(1, when + 0.0002);
      postChoke.gain.setValueAtTime(0, when + 0.0001);
      postChoke.gain.linearRampToValueAtTime(1, when + 0.0002);

      preChoke.connect(distortion);
      highpass.connect(postChoke);
      postChoke.connect(gain);

      var oscs = [
        context.createOscillator(),
        context.createOscillator(),
        ];
      oscs.forEach(function(osc, i) {
        osc.type = "triangle";
        osc.connect(preChoke);
        osc.start(when);
        osc.stop(when + duration);
        switch (i) {
          case 0:
            osc.frequency.value = 500;
            break;
          case 1:
            osc.frequency.value = 1720;
            break;
        }
      });
      oscs[0].onended = function() {
        highpass.disconnect(postChoke);
      };

      gain.gain.setValueAtTime(0.8, when);
      gain.gain.exponentialRampToValueAtTime(0.00001, when + duration);
    };

    gain.stop = function(when) {
      preChoke.gain.setValueAtTime(1, when);
      preChoke.gain.linearRampToValueAtTime(0, when + 0.0001);
      postChoke.gain.setValueAtTime(1, when);
      postChoke.gain.linearRampToValueAtTime(0, when + 0.0001);
    };
    return gain;
  };
};


},{"make-distortion-curve":7}],7:[function(require,module,exports){
module.exports = function(amount) {
  var k = typeof amount === 'number' ? amount : 50,
    n_samples = 44100,
    curve = new Float32Array(n_samples),
    deg = Math.PI / 180,
    i = 0,
    x;
  for ( ; i < n_samples; ++i ) {
    x = i * 2 / n_samples - 1;
    curve[i] = ( 3 + k ) * x * 20 * deg / ( Math.PI + k * Math.abs(x) );
  }
  return curve;
}

},{}],8:[function(require,module,exports){
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

},{"./lib/augmented-on-ended":9,"./lib/get-voltage":10,"noise-buffer":11}],9:[function(require,module,exports){
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

},{}],10:[function(require,module,exports){
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

},{}],11:[function(require,module,exports){
arguments[4][5][0].apply(exports,arguments)
},{"dup":5}]},{},[1]);

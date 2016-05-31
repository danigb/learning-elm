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
  var insts = libs.map(function (lib) { return lib(ac) })

  // API
  dm.names = function () { return NAMES.slice() }
  dm.connect = function (dest) { output.connect(dest); return dm }
  dm.gain = function (name, val) {
    var g = gains[id(name)]
    if (g && val) g.gain.value = val
    return g
  }
  dm.node = function (name, options) {
    var inst = insts[id(name)]
    if (!inst) return null
    var node = inst()
    node.connect(dm.gain(name))
    return node
  }
  dm.start = function (name, when, options) {
    var node = dm.node(name, options)
    if (!node) return null
    node.start(when)
    return node
  }
  return dm
}

if (typeof module === 'object' && module.exports) module.exports = eightoeight
if (typeof window !== 'undefined') window.eightoeight = eightoeight

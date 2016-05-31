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

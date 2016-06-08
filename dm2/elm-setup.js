/* global Elm AudioContext tiny808 */
var app = Elm.DrumMachine.fullscreen()
var ac = new AudioContext()
var tiny = tiny808(ac).connect(ac.destination)

app.ports.play.subscribe(function (evt) {
  console.log('Ports PLAY', evt)
  tiny.start(evt[1], evt[0])
})

app.ports.getAudioTime.subscribe(function () {
  app.ports.currentAudioTime.send(ac.currentTime)
})

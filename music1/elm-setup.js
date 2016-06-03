console.log('Init', Soundfont)
var ac = new AudioContext()
var piano = null

var app = Elm.Music.fullscreen()
app.ports.play.subscribe(function (note) {
  piano.play(note)
})

var instrument = Soundfont.instrument(ac, 'acoustic_grand_piano').then(function (inst) {
  console.log('Loaded')
  piano = inst
  app.ports.loaded.send('acoustic_grand_piano')
})


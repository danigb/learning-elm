console.log('Init', Soundfont)
var ac = new AudioContext()
var piano = null

var app = Elm.Music.fullscreen()
app.ports.play.subscribe(function (note) {
  piano.play(note)
})

app.ports.schedule.subscribe(function (events) {
  piano.schedule(0, events)
})

var instrument = Soundfont.instrument(ac, 'acoustic_grand_piano').then(function (inst) {
  console.log('Loaded')
  piano = inst
  piano.on('event', function (a, b, c) { console.log('event', a, b, c) })
  app.ports.loaded.send('acoustic_grand_piano')
})

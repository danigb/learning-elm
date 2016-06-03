console.log('Init', Soundfont)
var ac = new AudioContext()
var piano = null

var app = Elm.Music.fullscreen()
app.ports.play.subscribe(function (note) {
  piano.play(note)
})

app.ports.schedule.subscribe(function (events) {
  console.log('schedule', events, piano.schedule)
  piano.schedule(events, null, 0)
})

var instrument = Soundfont.instrument(ac, 'acoustic_grand_piano').then(function (inst) {
  console.log('Loaded')
  piano = inst
  piano.on('event', function (a, b, c) { console.log('event', a, b, c) })
  app.ports.loaded.send('acoustic_grand_piano')
})


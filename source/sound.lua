local synth = playdate.sound.synth.new(playdate.sound.kWaveSine)

-- Plays the specified note in the kWaveSine synth
function PlaySFX(note)
  if Settings.playSFX then
    synth:playMIDINote(note, 0.5, 0.08)
  end
end

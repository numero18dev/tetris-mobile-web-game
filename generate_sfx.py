import wave, math, struct
def make_sound(name, freq_start, freq_end, duration, vol=0.5):
    sample_rate = 44100
    n_samples = int(sample_rate * duration)
    with wave.open(name, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        for i in range(n_samples):
            t = float(i) / sample_rate
            # square wave
            freq = freq_start + (freq_end - freq_start) * (t / duration)
            val = math.sin(2 * math.pi * freq * t)
            sample = int(vol * 32767.0 * (1 if val > 0 else -1))
            f.writeframesraw(struct.pack('<h', sample))
make_sound('/home/alvaro/.openclaw/workspace/tetris-krilin-claw/rotate.wav', 800, 800, 0.05)
make_sound('/home/alvaro/.openclaw/workspace/tetris-krilin-claw/harddrop.wav', 100, 50, 0.1)
make_sound('/home/alvaro/.openclaw/workspace/tetris-krilin-claw/lock.wav', 200, 200, 0.1)
make_sound('/home/alvaro/.openclaw/workspace/tetris-krilin-claw/clear.wav', 400, 800, 0.3)

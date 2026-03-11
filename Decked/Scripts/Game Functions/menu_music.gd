extends AudioStreamPlayer2D

const menu_music = preload("res://Decked/Assests/Sound/OST/MenuOST.wav")

func _play_music(music: AudioStream, volume := 0.0):
	if stream == music and playing:
		return
	stream = music
	volume_db = volume
	play()

func play_music_menu():
	_play_music(menu_music)

func stop_music():
	if playing:
		stop()
		stream = null

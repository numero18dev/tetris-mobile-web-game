extends Node2D

@onready var board = $Board
@onready var main_menu = $CanvasLayer/MainMenu
@onready var game_over_menu = $CanvasLayer/GameOverMenu
@onready var score_label = $CanvasLayer/ScoreLabel

@onready var bgm_player = $Audio/BGMPlayer
@onready var sfx_rotate = $Audio/SFXRotate
@onready var sfx_harddrop = $Audio/SFXHardDrop
@onready var sfx_lock = $Audio/SFXLock
@onready var sfx_clear = $Audio/SFXClear

func _ready():
    # Load audio streams dynamically
    if FileAccess.file_exists("res://rotate.wav"):
        sfx_rotate.stream = load("res://rotate.wav")
    if FileAccess.file_exists("res://harddrop.wav"):
        sfx_harddrop.stream = load("res://harddrop.wav")
    if FileAccess.file_exists("res://lock.wav"):
        sfx_lock.stream = load("res://lock.wav")
    if FileAccess.file_exists("res://clear.wav"):
        sfx_clear.stream = load("res://clear.wav")

    main_menu.show()
    game_over_menu.hide()
    score_label.hide()
    board.hide()
    
    board.game_over.connect(_on_game_over)
    board.piece_rotated.connect(_on_piece_rotated)
    board.hard_dropped.connect(_on_hard_dropped)
    board.piece_locked.connect(_on_piece_locked)
    board.lines_cleared.connect(_on_lines_cleared)
    
    if bgm_player.stream:
        bgm_player.play()

func _process(delta):
    if board.is_game_active:
        score_label.text = "Score: %d\nLines: %d\nLevel: %d" % [board.score, board.lines_cleared_total, board.level]

func _on_play_button_pressed():
    main_menu.hide()
    game_over_menu.hide()
    score_label.show()
    board.show()
    board.start_game()

func _on_retry_button_pressed():
    _on_play_button_pressed()

func _on_game_over():
    game_over_menu.show()
    score_label.hide()

func _on_piece_rotated():
    if sfx_rotate.stream: sfx_rotate.play()

func _on_hard_dropped():
    if sfx_harddrop.stream: sfx_harddrop.play()

func _on_piece_locked():
    if sfx_lock.stream: sfx_lock.play()

func _on_lines_cleared(count):
    if sfx_clear.stream: sfx_clear.play()
    
    # Simple visual effect for line clear
    var flash = ColorRect.new()
    flash.color = Color(1, 1, 1, 0.5)
    flash.set_anchors_preset(PRESET_FULL_RECT)
    $CanvasLayer.add_child(flash)
    var tween = create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, 0.2)
    tween.tween_callback(flash.queue_free)


extends Node2D

signal game_over
signal piece_rotated
signal hard_dropped
signal piece_locked
signal lines_cleared(count)

const COLS = 10
const ROWS = 20
const CELL_SIZE = 32

# 7 classic pieces (I, J, L, O, S, T, Z)
const SHAPES = [
    [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
    [Vector2(-1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
    [Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
    [Vector2(0, -1), Vector2(1, -1), Vector2(0, 0), Vector2(1, 0)],
    [Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0)],
    [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
    [Vector2(-1, -1), Vector2(0, -1), Vector2(0, 0), Vector2(1, 0)]
]

const COLORS = [
    Color(0.0, 1.0, 1.0),
    Color(0.0, 0.0, 1.0),
    Color(1.0, 0.5, 0.0),
    Color(1.0, 1.0, 0.0),
    Color(0.0, 1.0, 0.0),
    Color(0.5, 0.0, 0.5),
    Color(1.0, 0.0, 0.0)
]

var grid = []
var current_piece_type = -1
var current_piece_shape = []
var current_piece_pos = Vector2()
var current_piece_color = Color()
var fall_timer = 0.0
var fall_delay = 0.5

var next_piece_type = -1
var held_piece_type = -1
var can_hold = true

var score = 0
var lines_cleared_total = 0
var level = 1
var is_game_active = false

func _ready():
    position = Vector2(400 - (COLS * CELL_SIZE) / 2, 800 - (ROWS * CELL_SIZE) - 50)
    reset_board()

func reset_board():
    grid.clear()
    for y in range(ROWS):
        var row = []
        for x in range(COLS):
            row.append(0)
        grid.append(row)
    
    current_piece_type = -1
    current_piece_shape = []
    next_piece_type = randi() % SHAPES.size()
    held_piece_type = -1
    can_hold = true
    score = 0
    lines_cleared_total = 0
    level = 1
    fall_delay = 0.5
    is_game_active = false
    queue_redraw()

func start_game():
    reset_board()
    is_game_active = true
    spawn_piece()

func spawn_piece():
    current_piece_type = next_piece_type
    next_piece_type = randi() % SHAPES.size()
    current_piece_shape = SHAPES[current_piece_type].duplicate()
    current_piece_color = COLORS[current_piece_type]
    current_piece_pos = Vector2(COLS / 2, 1)
    fall_timer = 0.0
    can_hold = true
    
    if not is_valid_position(current_piece_shape, current_piece_pos):
        # Game Over: Collision on spawn
        is_game_active = false
        game_over.emit()
        
    queue_redraw()

func _process(delta):
    if not is_game_active or current_piece_shape.is_empty(): return
    
    fall_timer += delta
    
    if Input.is_action_just_pressed("ui_up"):
        rotate_piece()
    
    if Input.is_action_just_pressed("ui_left"):
        move_piece(Vector2(-1, 0))
    elif Input.is_action_just_pressed("ui_right"):
        move_piece(Vector2(1, 0))
        
    if Input.is_action_pressed("ui_down"):
        fall_timer += delta * 10
        
    if Input.is_action_just_pressed("ui_accept"):
        hard_drop()
        return
        
    if (Input.is_key_pressed(KEY_C) or Input.is_key_pressed(KEY_SHIFT)) and can_hold:
        hold_piece()
        return
        
    if fall_timer >= fall_delay:
        fall_timer = 0.0
        if not move_piece(Vector2(0, 1)):
            lock_piece()
            
    queue_redraw()

func move_piece(offset: Vector2) -> bool:
    if is_valid_position(current_piece_shape, current_piece_pos + offset):
        current_piece_pos += offset
        queue_redraw()
        return true
    return false

func is_valid_position(shape: Array, pos: Vector2) -> bool:
    for cell in shape:
        var nx = int(pos.x + cell.x)
        var ny = int(pos.y + cell.y)
        if nx < 0 or nx >= COLS or ny >= ROWS:
            return false
        if ny >= 0 and typeof(grid[ny][nx]) != TYPE_INT:
            return false
    return true

func rotate_piece():
    if current_piece_type == 3: # O shape doesn't rotate
        return
        
    var new_shape = []
    for cell in current_piece_shape:
        new_shape.append(Vector2(-cell.y, cell.x))
        
    if is_valid_position(new_shape, current_piece_pos):
        current_piece_shape = new_shape
        piece_rotated.emit()
        queue_redraw()

func lock_piece():
    for cell in current_piece_shape:
        var nx = int(current_piece_pos.x + cell.x)
        var ny = int(current_piece_pos.y + cell.y)
        if ny >= 0 and ny < ROWS and nx >= 0 and nx < COLS:
            grid[ny][nx] = current_piece_color
    
    piece_locked.emit()
    check_lines()
    if is_game_active:
        spawn_piece()
    queue_redraw()

func hard_drop():
    var dropped = false
    while is_valid_position(current_piece_shape, current_piece_pos + Vector2(0, 1)):
        current_piece_pos += Vector2(0, 1)
        dropped = true
    if dropped:
        hard_dropped.emit()
    lock_piece()

func hold_piece():
    can_hold = false
    if held_piece_type == -1:
        held_piece_type = current_piece_type
        spawn_piece()
    else:
        var temp = held_piece_type
        held_piece_type = current_piece_type
        current_piece_type = temp
        current_piece_shape = SHAPES[current_piece_type].duplicate()
        current_piece_color = COLORS[current_piece_type]
        current_piece_pos = Vector2(COLS / 2, 1)
        fall_timer = 0.0
    queue_redraw()

func check_lines():
    var lines_removed = 0
    var y = ROWS - 1
    while y >= 0:
        var is_full = true
        for x in range(COLS):
            if typeof(grid[y][x]) == TYPE_INT and grid[y][x] == 0:
                is_full = false
                break
        
        if is_full:
            lines_removed += 1
            grid.remove_at(y)
            var new_row = []
            for i in range(COLS):
                new_row.append(0)
            grid.push_front(new_row)
        else:
            y -= 1
            
    if lines_removed > 0:
        lines_cleared.emit(lines_removed)
        update_score(lines_removed)

func update_score(lines: int):
    var points = 0
    match lines:
        1: points = 100 * level
        2: points = 300 * level
        3: points = 500 * level
        4: points = 800 * level
        _: points = 1000 * level
    
    score += points
    lines_cleared_total += lines
    
    var new_level = 1 + int(lines_cleared_total / 10)
    if new_level > level:
        level = new_level
        fall_delay = max(0.1, 0.5 - (level - 1) * 0.05)

func get_ghost_pos() -> Vector2:
    var ghost_pos = current_piece_pos
    while is_valid_position(current_piece_shape, ghost_pos + Vector2(0, 1)):
        ghost_pos += Vector2(0, 1)
    return ghost_pos

func _draw_cell(rect: Rect2, color: Color, is_ghost: bool = false):
    # Pulido visual: Dibujar con margen interno
    var margin = 2.0
    var inner_rect = rect.grow(-margin)
    
    if is_ghost:
        var c = color
        c.a = 0.3
        draw_rect(inner_rect, c, true)
        draw_rect(inner_rect, color, false, 1.0)
    else:
        # Main color fill
        draw_rect(inner_rect, color, true)
        # Lighter highlight on top-left
        var highlight_color = color.lightened(0.4)
        var shadow_color = color.darkened(0.4)
        
        # Border effect
        draw_line(inner_rect.position, inner_rect.position + Vector2(inner_rect.size.x, 0), highlight_color, margin)
        draw_line(inner_rect.position, inner_rect.position + Vector2(0, inner_rect.size.y), highlight_color, margin)
        draw_line(inner_rect.position + Vector2(0, inner_rect.size.y), inner_rect.position + inner_rect.size, shadow_color, margin)
        draw_line(inner_rect.position + Vector2(inner_rect.size.x, 0), inner_rect.position + inner_rect.size, shadow_color, margin)

func _draw():
    var board_rect = Rect2(0, 0, COLS * CELL_SIZE, ROWS * CELL_SIZE)
    draw_rect(board_rect, Color(0.1, 0.1, 0.1), true)
    draw_rect(board_rect, Color(0.8, 0.8, 0.8), false, 2.0)
    
    for y in range(ROWS):
        for x in range(COLS):
            var cell_rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
            draw_rect(cell_rect, Color(0.15, 0.15, 0.15), false, 1.0)
            
            if typeof(grid[y][x]) == TYPE_COLOR:
                _draw_cell(cell_rect, grid[y][x])
                
    if not current_piece_shape.is_empty() and is_game_active:
        var ghost_pos = get_ghost_pos()
        for cell in current_piece_shape:
            var px = (ghost_pos.x + cell.x) * CELL_SIZE
            var py = (ghost_pos.y + cell.y) * CELL_SIZE
            _draw_cell(Rect2(px, py, CELL_SIZE, CELL_SIZE), current_piece_color, true)
            
        for cell in current_piece_shape:
            var px = (current_piece_pos.x + cell.x) * CELL_SIZE
            var py = (current_piece_pos.y + cell.y) * CELL_SIZE
            _draw_cell(Rect2(px, py, CELL_SIZE, CELL_SIZE), current_piece_color)

    if next_piece_type != -1:
        var next_shape = SHAPES[next_piece_type]
        var next_color = COLORS[next_piece_type]
        var next_offset = Vector2(COLS * CELL_SIZE + 50, 50)
        for cell in next_shape:
            var px = next_offset.x + cell.x * CELL_SIZE
            var py = next_offset.y + cell.y * CELL_SIZE
            _draw_cell(Rect2(px, py, CELL_SIZE, CELL_SIZE), next_color)

    if held_piece_type != -1:
        var held_shape = SHAPES[held_piece_type]
        var held_color = COLORS[held_piece_type]
        var held_offset = Vector2(-150, 50)
        for cell in held_shape:
            var px = held_offset.x + cell.x * CELL_SIZE
            var py = held_offset.y + cell.y * CELL_SIZE
            var draw_color = held_color if can_hold else Color(0.5, 0.5, 0.5)
            _draw_cell(Rect2(px, py, CELL_SIZE, CELL_SIZE), draw_color)

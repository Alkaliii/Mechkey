extends Control

var kfv : Vector2 = Vector2.ZERO
var dragsnapp : float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_click_pressed()
	mGSB.timeline_zoom_changed.connect(setds)
	mGSB.length_changed.connect(maintain_position)
	dragsnapp = dragsnapp * mGSB.tzl
	
	$Options/VBoxContainer/Value/valueset.value = 0
	
	await get_tree().process_frame
	if mGSB.snappoints: #+ mGSB.ths
		kfv.x = snapped(((position.x) / mGSB.snappoints[mGSB.snappoints.size() - 1]) * mGSB.tll,0.01)
		$Options/VBoxContainer/position.text = str("t",snapped(kfv.x,0.01))

func maintain_position(_v = null):
	await get_tree().process_frame
	position.x = mGSB.getsnap((kfv.x / mGSB.tll) * mGSB.snappoints[mGSB.snappoints.size() - 1])

func setds(nzl):
	dragsnapp = dragsnapp * nzl
	maintain_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("create_keyframe") and shown:
		_on_click_pressed()
	if Input.is_action_just_pressed("paste") and shown:
		_on_click_pressed()
	if shown: $Options.position = global_position + Vector2(20,0)
	
	var inopti = $Options.get_rect().has_point(get_viewport().get_mouse_position())
	if Input.is_action_just_pressed("ui_left") and inopti and shown:
		_on_left_pressed()
	if Input.is_action_just_pressed("ui_right") and inopti and shown:
		_on_right_pressed()
	
	process_drag()
	process_playing()

func process_playing():
	if mGSB.playing and dragging: _on_click_button_up()
	if mGSB.playing and shown: _on_click_pressed()
	click.disabled = mGSB.playing

@onready var click = $Click
var dragging_dis
var dir
var dragging : bool = false
var newposition : Vector2
func process_drag():
	if dragging: 
		if mGSB.snappoints:#+ mGSB.ths
			create_tween().tween_property(self,"position:x",mGSB.getsnap(newposition.x),0.1)
			kfv.x = snapped(((position.x ) / mGSB.snappoints[mGSB.snappoints.size() - 1]) * mGSB.tll,0.01)
			$Options/VBoxContainer/position.text = str("t",snapped(kfv.x,0.01))
		else:
			create_tween().tween_property(self,"position:x",snapped(newposition.x,dragsnapp),0.1)

var shown := false
func _on_click_pressed():
	$Options/VBoxContainer/position.text = str("t",snapped(kfv.x,0.01))
	click.release_focus()
	shown = !shown
	match shown:
		true: create_tween().tween_property($Panel,"self_modulate",Color.ORANGE_RED,0.15)
		false: create_tween().tween_property($Panel,"self_modulate",Color("#1b1b1b"),0.15)
	$Options.position = global_position + Vector2(20,0)
	$Options.visible = shown

func _on_delete_pressed():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if shown and !dragging: _on_click_pressed()

func _on_click_button_down():
	#if !shown:
	dragging = true
	dragging_dis = position.distance_to(get_viewport().get_mouse_position())
	dir = (get_viewport().get_mouse_position() - position).normalized()
	newposition = get_viewport().get_mouse_position() - dragging_dis * dir

func _input(event):
	if event is InputEventMouseMotion and dragging:
		newposition = get_viewport().get_mouse_position() - dragging_dis * dir
	
	if event is InputEventMouseButton and event.is_pressed() and shown:
		var inpoint = get_rect().has_point(get_viewport().get_mouse_position())
		var inopti = $Options.get_rect().has_point(get_viewport().get_mouse_position())
		if !inpoint and !inopti:
			_on_click_pressed()

func _on_click_button_up():
	$Options/VBoxContainer/MoveOptions/Move.release_focus()
	dragging = false
	if mGSB.snappoints: #+ mGSB.ths
		kfv.x = snapped(((position.x) / mGSB.snappoints[mGSB.snappoints.size() - 1]) * mGSB.tll,0.01)
	#print(kfv)

func _on_copy_pressed(type := "CPY"):
	#Store data
	$Options/VBoxContainer/HBoxContainer/Copy.release_focus()
	var cpy = str(type,"KEY@",kfv)
	print(cpy)
	DisplayServer.clipboard_set(cpy)
	_on_click_pressed()

func _on_cut_pressed():
	#Store data and remove
	$Options/VBoxContainer/HBoxContainer/Cut.release_focus()
	_on_copy_pressed("CUT")
	_on_delete_pressed()
	_on_click_pressed()

func _on_valueset_value_changed(value):
	kfv.y = value

func _on_left_pressed():
	$Options/VBoxContainer/MoveOptions/Left.release_focus()
	kfv.x -= 0.01 #step value
	maintain_position()
	$Options/VBoxContainer/position.text = str("t",snapped(kfv.x,0.01))


func _on_right_pressed():
	$Options/VBoxContainer/MoveOptions/Right.release_focus()
	kfv.x += 0.01
	maintain_position()
	$Options/VBoxContainer/position.text = str("t",snapped(kfv.x,0.01))

extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("play_pause"):
		mGSB.playing = !mGSB.playing
		print("Playing: ",mGSB.playing)
	
	if mGSB.playing:
		if mGSB.reverse_playing:
			reverse_play(delta)
		else:
			play(delta)
	else:
		process_drag()

var dragging_dis
var dir
var dragging : bool = false
var newposition : Vector2
func process_drag():
	if dragging: 
		if mGSB.snappoints:#+ mGSB.ths
			create_tween().tween_property(self,"position:x",mGSB.getsnap(newposition.x),0.1)
		else:
			create_tween().tween_property(self,"position:x",snapped(newposition.x,3),0.1)

func _on_grabber_button_down():
	dragging = true
	dragging_dis = position.distance_to(get_viewport().get_mouse_position())
	dir = (get_viewport().get_mouse_position() - position).normalized()
	newposition = get_viewport().get_mouse_position() - dragging_dis * dir

func _input(event):
	if event is InputEventMouseMotion and dragging:
		newposition = get_viewport().get_mouse_position() - dragging_dis * dir

func _on_grabber_button_up():
	$grabber.release_focus()
	dragging = false

func resizee(sz):
	custom_minimum_size.y = sz - 30
	size = Vector2.ZERO

var speed = 1024.0/1.0
func play(delta : float):
	var len = get_parent().get_length()
	speed = len/((mGSB.tll) / mGSB.tzl)
	var aspd = (speed * delta)
	if position.x > len: 
		#restart or push scroll
		get_parent().scroll()
		position.x = 0
	position.x += aspd

func reverse_play(delta : float):
	var len = get_parent().get_length()
	speed = len/((mGSB.tll) / mGSB.tzl)
	var aspd = (speed * delta)
	if position.x < 0: 
		#restart or push scroll
		get_parent().scroll(true)
		position.x = len
	position.x -= aspd

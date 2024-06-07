extends PanelContainer

var hovered := false
@onready var keyframes = $keyframes

var placesnapp : float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate = Color("#b6b6b6")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("create_keyframe") and hovered:
		create_keyframe()
	if Input.is_action_just_pressed("paste") and hovered:
		paste_keyframe()
	if mGSB.playing and hovered: _on_mouse_exited()

const keyframe_tscn = preload("res://Application/Elements/keyframe.tscn")
func create_keyframe(pos = null):
	var mpos = get_local_mouse_position()
	var kf = keyframe_tscn.instantiate()
	keyframes.add_child(kf)
	if pos and mGSB.snappoints:
		kf.position.x = mGSB.getsnap((pos / mGSB.tll) * mGSB.snappoints[mGSB.snappoints.size() - 1])
		#snapped(((position.x) / mGSB.snappoints[mGSB.snappoints.size() - 1]) * mGSB.tll,0.01)
	elif mGSB.snappoints:
		kf.position.x = mGSB.getsnap(mpos.x)
	else:
		kf.position.x = snapped(mpos.x,5)
	kf.position.y = (size.y / 2.0) - 7
	
	#ColorRect.new()
	#kf.color = Color.ORANGE_RED
	#kf.size = Vector2(15,15)
	##kf.pivot_offset = kf.size / 2.0
	#keyframes.add_child(kf)
	#kf.position.x = mpos.x
	#kf.position.y = (size.y / 2.0) - 7.5

func paste_keyframe():
	var cli : String = DisplayServer.clipboard_get()
	if cli.contains("CPYKEY") or cli.contains("CUTKEY"):
		var newpos = str_to_var(str("Vector2",cli.split("@")[1]))
		print(newpos)
		create_keyframe(newpos.x)

func _on_mouse_entered():
	if mGSB.playing: 
		hovered = false
		return
	hovered = true
	create_tween().tween_property(self,"self_modulate",Color("#828282"),0.15).set_ease(Tween.EASE_IN_OUT)

func _on_mouse_exited():
	hovered = false
	create_tween().tween_property(self,"self_modulate",Color("#b6b6b6"),0.15).set_ease(Tween.EASE_IN_OUT)

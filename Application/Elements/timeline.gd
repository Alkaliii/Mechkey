extends Control

const sdv := 5 #subdivide value
const sps := 7 #snap point step

var zoom_lvl : float = 1.0
var tlength : float = 1.0

@onready var tline = $VBoxContainer/tlsc/Line
@onready var tptlist = $VBoxContainer/tlsc/Line/timepointlist
@onready var tlist = $VBoxContainer/ScrollContainer/List

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	#set_timepoints()
	await get_tree().process_frame
	set_timeline()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var mainsc = $VBoxContainer/ScrollContainer
@onready var tlsc = $VBoxContainer/tlsc
func _process(delta):
	mGSB.sync_scroll.emit(mainsc.scroll_vertical)
	tlsc.scroll_horizontal = mainsc.scroll_horizontal
	mGSB.ths = mainsc.scroll_horizontal
	if track:
		set_tracker()

const TRACKTRACK = preload("res://Application/Elements/tracktrack.tscn")
func add_track(trackID := "NOID"):
	var t = TRACKTRACK.instantiate()
	tlist.add_child(t)
	await tlist.resized
	tlist.custom_minimum_size.y = tlist.size.y + 100

func set_timeline(length : float = 1.0): 
	#I set the timeline to a specific length
	tline.custom_minimum_size.x = (size.x * zoom_lvl)
	tptlist.custom_minimum_size.x = (size.x * zoom_lvl)
	tlist.custom_minimum_size.x = (size.x * zoom_lvl)
	#print((size.x * zoom_lvl))
	set_timepoints(length)
	mGSB.tll = length
	mGSB.tzl = zoom_lvl
	pass

func set_timepoints(length : float = 1.0):
	destory_timepoints(0)
	var tpta = range((sdv * zoom_lvl) if zoom_lvl > 1 else float(sdv))
	#tpta.reverse()
	
	#create 0
	create_timepoint(1.0,-1,(sdv * zoom_lvl) if zoom_lvl > 1 else float(sdv))
	for i in tpta:
		create_timepoint(length,i,(sdv * zoom_lvl) if zoom_lvl > 1 else float(sdv))
		#print(i)
	#destory_timepoints(sdv * zoom_lvl)
	await get_tree().process_frame
	var lasttpt = tptlist.get_children()[tptlist.get_child_count() - 1]
	var snappts = range(0, (size.x * zoom_lvl) - lasttpt.size.x,((sps * zoom_lvl) if zoom_lvl > 1 else float(sps)))
	mGSB.snappoints = snappts
	#print(snappts)

func create_timepoint(length : float, pt : int, maxu : float):
	var ptv = str(snapped((length*(float(pt + 1) / maxu)),0.01))
	#print(ptv)
	var tpt = RichTextLabel.new()
	tpt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tpt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tptlist.add_child(tpt)
	tpt.fit_content = true
	tpt.scroll_active = false
	tpt.autowrap_mode = TextServer.AUTOWRAP_OFF
	tpt.text = ptv
	tpt.add_theme_color_override("default_color",Color("b6b6b6"))

func destory_timepoints(after : int):
	var dlist = tptlist.get_children().slice(after)
	for x in dlist:
		x.queue_free()

@onready var zoom_label = $VBoxContainer/TimelineOptions/Zoom/zoomLabel
func zoom(state:bool):
	match state:
		true: #UP
			if zoom_lvl > 1:
				zoom_lvl += 1
			else:
				zoom_lvl = zoom_lvl * 2.0
			set_timeline(tlength)
		false: #DOWN
			if zoom_lvl > 1:
				zoom_lvl -= 1
			else:
				zoom_lvl = zoom_lvl / 2.0
			set_timeline(tlength)
	#print("Zoom: ",zoom_lvl)
	mGSB.timeline_zoom_changed.emit(zoom_lvl)
	zoom_label.text = str(zoom_lvl,"x")

@onready var zoom_in = $VBoxContainer/TimelineOptions/Zoom/ZoomIN
func _on_zoom_in_pressed():
	zoom_in.release_focus()
	zoom(true)

@onready var zoom_out = $VBoxContainer/TimelineOptions/Zoom/ZoomOUT
func _on_zoom_out_pressed():
	zoom_out.release_focus()
	zoom(false)

@onready var background = $Background
func _on_resized():
	if !background: return
	background.material.set_shader_parameter("resolution",size)
	#await get_tree().process_frame
	tracker.custom_minimum_size.y = size.y - 30
	tracker.size = Vector2.ZERO
	$Playhead.resizee(size.y)

@onready var length_set = $VBoxContainer/TimelineOptions/AnimLength/LengthSet
func _on_length_set_value_changed(value):
	length_set.release_focus()
	tlength = value
	mGSB.length_changed.emit(tlength)
	set_timeline(tlength)

var track : bool
func _on_mouse_entered():
	track = true

func _on_mouse_exited():
	track = false

@onready var tracker = $Tracker
@onready var tracker_timepoint = $Tracker/pc/timepoint

func set_tracker():
	var lasttpt = tptlist.get_children()[tptlist.get_child_count() - 1]
	tracker.position.x = get_local_mouse_position().x
	var point = snapped(((get_local_mouse_position().x + mainsc.scroll_horizontal) / ((size.x * zoom_lvl) - lasttpt.size.x)) * tlength,0.01)
	tracker_timepoint.text = str(point)

func get_length() -> float:
	var lasttpt = tptlist.get_children()[tptlist.get_child_count() - 1]
	return tline.size.x - lasttpt.size.x

func scroll(back := false):
	var add = mainsc.get_h_scroll_bar().max_value / zoom_lvl
	if mainsc.scroll_horizontal + add >= mainsc.get_h_scroll_bar().max_value:
		#restart
		#create_tween().tween_property(mainsc,"scroll_horizontal",0,0.05).set_ease(Tween.EASE_IN_OUT)
		if back: mainsc.scroll_horizontal = mainsc.get_h_scroll_bar().max_value
		else: mainsc.scroll_horizontal = 0
	elif back:
		#create_tween().tween_property(mainsc,"scroll_horizontal",mainsc.scroll_horizontal + get_length(),0.05).set_ease(Tween.EASE_IN_OUT)
		mainsc.scroll_horizontal -= add
	else:
		mainsc.scroll_horizontal += add

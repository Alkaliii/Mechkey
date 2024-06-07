extends Control

@onready var tracks = $VSplitContainer/PanelContainer2/HSplitContainer/TrackLabels/VBoxContainer/ScrollContainer/Tracks
@onready var timeline = $VSplitContainer/PanelContainer2/HSplitContainer/Timeline


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	await get_tree().process_frame
	load_tracks_into_timeline()
	mGSB.sync_scroll.connect(sync_track_scroll)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_tracks_into_timeline():
	for t in tracks.get_children():
		timeline.add_track()
		#put ID through lol
	tracks.custom_minimum_size.y = tracks.size.y + 100

@onready var tracksc = $VSplitContainer/PanelContainer2/HSplitContainer/TrackLabels/VBoxContainer/ScrollContainer
func sync_track_scroll(ns):
	tracksc.scroll_vertical = ns

@onready var reversebtn = $VSplitContainer/PanelContainer2/HSplitContainer/TrackLabels/VBoxContainer/PlaybackControls/Reverse
@onready var pausebtn = $VSplitContainer/PanelContainer2/HSplitContainer/TrackLabels/VBoxContainer/PlaybackControls/Pause
@onready var playbtn = $VSplitContainer/PanelContainer2/HSplitContainer/TrackLabels/VBoxContainer/PlaybackControls/Play

func _on_reverse_pressed():
	reversebtn.release_focus()
	mGSB.playing = !mGSB.playing
	mGSB.reverse_playing = mGSB.playing

func _on_pause_pressed():
	pausebtn.release_focus()
	mGSB.playing = false
	mGSB.reverse_playing = false

func _on_play_pressed():
	playbtn.release_focus()
	mGSB.playing = !mGSB.playing
	mGSB.reverse_playing = false

extends Node
#Mechkey Global Signal Bus

signal timeline_zoom_changed #new zoom
signal length_changed #new length

signal sync_scroll #new scroll value

var tll : float #timeline length
var tzl : float #timeline zoom level
var ths : float #timeline horizontal scroll
var snappoints : Array
var playing := false
var reverse_playing := false

# Called when the node enters the scene tree for the first time.
func _ready():
	timeline_zoom_changed.connect(setzl)
	length_changed.connect(settll)

func settll(nl):
	tll = nl

func setzl(nzl):
	tzl = nzl

func getsnap(v) -> int:
	var ns : Array = snappoints.duplicate()
	ns.append(v)
	ns.sort()
	return snappoints[clamp(ns.find(v) - 1,0,snappoints.size() - 1)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

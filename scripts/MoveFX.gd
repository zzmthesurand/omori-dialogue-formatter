extends OptionButton


var options = [
"Move FX",
"Vertical Shake", 
"Vertical Shake Strong", 
"Horizontal Shake",
"Earthquake Strong",
"Earthquake"
]

func _ready():
	get_child(0).focus_mode = Control.FOCUS_NONE
	# disables focus so you cant accidentally press it with enter or spacebar
	for i in options: add_item(i)
	set_item_disabled(0, true)
	# adds options to dropdown menu and disables "Move FX"


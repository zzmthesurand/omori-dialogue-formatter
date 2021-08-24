extends OptionButton

var options = [
"Color",
"White", 
"Blue",
"Light Red",
"Light Green",
"Light Yellow",
"Orange",
"NOT IN OMORI",
"Gray",
"Red",
"Red Again?",
"Red Again??",
"Light Blue",
"Calm Dark Blue",
"Light Purple",
"Calm Dark Blue Again?"
]

var iconfiles = [
	preload("res://fonts/colors/0.png"),
	preload("res://fonts/colors/1.png"),
	preload("res://fonts/colors/2.png"),
	preload("res://fonts/colors/3.png"),
	preload("res://fonts/colors/4.png"),
	preload("res://fonts/colors/5.png"),
	"",
	preload("res://fonts/colors/7.png"),
	preload("res://fonts/colors/8.png"),
	preload("res://fonts/colors/9.png"),
	preload("res://fonts/colors/10.png"),
	preload("res://fonts/colors/11.png"),
	preload("res://fonts/colors/12.png"),
	preload("res://fonts/colors/13.png"),
	preload("res://fonts/colors/14.png"),
]

# i have to preload all the colors individually because load() is broken or
# something. anyways this is the only way i got it to work on export so just
# make sure it's preloaded

func _ready():
	get_child(0).focus_mode = Control.FOCUS_NONE
	# make sure you cant accidentally press the button again by pressing z if
	# it's in focus
	for i in options: add_item(i)
	# add the color names to the dropdown menu
	for i in range(iconfiles.size()):
		if iconfiles[i]: set_item_icon(i + 1, iconfiles[i])
	# set the icon for each color (the + 1 is since the text "Color" counts as 
	# an option
	set_item_disabled(0, true)
	set_item_disabled(7, true)
	# disable 0 and 7 (files, and the color which isnt in omori i think)


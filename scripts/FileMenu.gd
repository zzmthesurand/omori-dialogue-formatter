extends OptionButton

var options = ["File", "New File","Open File", "Save File", "Save File As"]
func _ready():
	# adds options to dropdown and disables "File" so you cant select it
	for i in options: add_item(i)
	set_item_disabled(0, true)



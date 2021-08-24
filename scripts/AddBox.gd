extends MarginContainer


func _ready():
	pass 

func add(isDialogue):
	GlobalManager.control.addCommentDialogue(isDialogue, get_index())
	# this receives the signal from the 2 buttons and passes it on to the main
	# box control/manager

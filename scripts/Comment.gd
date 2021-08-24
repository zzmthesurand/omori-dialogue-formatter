extends MarginContainer

onready var textedit = $MarginContainer/VBoxContainer/TextEdit

func getData():
	var text = ""
	for i in range(textedit.get_line_count()):
		var line = textedit.get_line(i)
		if line.begins_with("#"): text += line + "\n" # if line begins with #, move on
		elif line.length() < 1: text += "\n" # if the line is empty just move on
		elif !line.begins_with("#"): text += "#" + line + "\n" 
		# if line doesnt begin with #, then add one so it doesnt break the .yaml
	return {"comment": text}
	# return the dict for saving

func deleteButton():
	get_parent().get_child(get_index() + 1).queue_free()
	queue_free()
	# delete comment if x button is pressed

func textUpdate():
	textedit.rect_min_size.y = textedit.get_line_count() * 20
	# resize the textedit according to how many lines there are in the comment

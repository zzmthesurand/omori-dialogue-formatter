extends Control

onready var namedrop = $MarginContainer/Margin/VBox/Bar/NameDrop
onready var previewButton = $MarginContainer/Margin/VBox/Bar/PreviewButton
onready var textlabel = $MarginContainer/Margin/VBox/HBox/VBox/TextLabel
onready var nameLine = $MarginContainer/Margin/VBox/Bar/NameLine
onready var mIDLine = $MarginContainer/Margin/VBox/Bar/MessageIDLine
onready var facesetoption = $MarginContainer/Margin/VBox/Bar/FaceSet
onready var faceIndex = $MarginContainer/Margin/VBox/Bar/FaceIndex
onready var previewIn = preload("res://SyndiBoxPlus.tscn")
onready var preview

var faceDisable = false

func _ready():
	if GlobalManager.facesetsPath: facesetChange(facesetoption.selected)
	# if a facesetsPath has been chosen, then load em
	$MarginContainer/Margin/VBox/HBox/Face.texture.atlas.resource_local_to_scene = true
	$MarginContainer/Margin/VBox/HBox/Face.texture.resource_local_to_scene = true
	# this makes the face texture unique (so it doesnt share the texture with
	# other faces in other dialogue boxes
	
func _on_PreviewButton_toggled(button_pressed):
	if button_pressed == false: 
		if preview: preview.queue_free() 
		# deletes the preview. i have to do this because if you dont delete it
		# and use multiple fonts/font sizes then the text offset gets all 
		# screwed up, so i just decided to delete and reinstance the syndibox
		$MarginContainer/Margin/Control/Sprite.visible = false
		#hides the red hand
	else: 
		preview = previewIn.instance() # reinstance the syndibox
		$MarginContainer/Margin/VBox/HBox/VBox.add_child(preview) # add the syndibox
		preview.start(textlabel.text) # start displaying the text
		preview.connect("paused", self, "_on_SyndiBox_paused")
		# connects the syndibox signal for pausing to the method _on_SyndiBox_paused
	textlabel.visible = !button_pressed # toggle textlabel visibility


func _on_SyndiBox_paused(paused):
	$MarginContainer/Margin/Control/Sprite.visible = paused
	$MarginContainer/Margin/Control/Sprite/AnimationPlayer.play("float")
	# show red hand and play the animation

func faceIndexChange(value):
	$MarginContainer/Margin/VBox/HBox/Face.texture.region = Rect2(int(value*106)%(106*4), (floor(value / 4))*106, 106, 106)
	# change the selected region from the faceset atlas based on the face index

func facesetChange(index):
	if index != -1:
		$MarginContainer/Margin/VBox/HBox/Face.texture.atlas = GlobalManager.facesets[index]
	else:
		GlobalManager.pngError()
	faceIndexChange($MarginContainer/Margin/VBox/Bar/FaceIndex.value)
	# change the faceset atlas based on the loaded facesets and update the face

func namedropUpdate():
	var tempselect = namedrop.selected
	namedrop.clear()
	for x in GlobalManager.characters: namedrop.add_item(x)
	namedrop.selected = tempselect
	
func facesetUpdate():
	facesetoption.clear()
	for x in GlobalManager.facesetsnames: facesetoption.add_item(x)
	facesetChange(facesetoption.selected)
	# clear the options in the faceset dropdown and replace them with the new ones
	# then update face

func faceToggle(button_pressed):
	faceDisable = button_pressed
	$MarginContainer/Margin/VBox/HBox/Face.visible = !button_pressed
	$MarginContainer/Margin/VBox/Bar/FaceIndex.editable = !button_pressed
	$MarginContainer/Margin/VBox/Bar/FaceSet.disabled = button_pressed
	if !button_pressed: 
		$MarginContainer/Margin/Control/Sprite.rect_position.x -= 105
	else: $MarginContainer/Margin/Control/Sprite.rect_position.x += 105
	# adjust sprite position based on whether the face is shown or not
	
func getData():
	var charName = GlobalManager.characters[namedrop.selected]
	if nameLine.text: charName = nameLine.text
	var dialogue = {
		"messageID": mIDLine.text,
		"text": textlabel.text.replace("`", "").replace("\\<br>", "<br>"),
	}
	if charName != "GAME": # if the character name is GAME then its not a name so dont put it
		if nameLine.text == "":
			dialogue["character"] = GlobalManager.characters[namedrop.selected]
		else:
			dialogue["character"] = nameLine.text
	if !faceDisable: # if face is enabled, add faceset and faceindex
		dialogue["faceset"] = GlobalManager.facesetsnames[facesetoption.selected]
		dialogue["faceindex"] = faceIndex.value
	else: # if face is disabled, remove faceset and faceindex from dictionary
		dialogue.erase("faceset")
		dialogue.erase("faceindex")
	return dialogue

func deleteBox(): 
	get_parent().get_child(get_index() + 1).queue_free()
	queue_free()
	# remove the addbox after this dialogue box then remove itself

func IDchange(new_text):
		name = "message_" + new_text

extends Control

var dialoguebox = preload("res://scenes/Dialogue.tscn")
var commentbox = preload("res://scenes/Comment.tscn")
var addbox = preload("res://scenes/AddBox.tscn")
var currentFile 
onready var movefx = $ToolsMargin/ToolsVBox/MoveFX
onready var colorbutton = $ToolsMargin/ToolsVBox/ColorButton
onready var optionbutton = $OptionButton
onready var re = RegEx.new()
onready var namere = RegEx.new()
onready var customname = ""

func _ready():
	GlobalManager.control = self
	re.compile("(?i)(?:\\\\(?:sin.|quake)\\[.\\])|(?:\\\\(?:\\{|\\}))|(?:\\\\c\\[.+?\\])")
	# this regex searches for 3 patterns
	# 1. tags with sinv/sinh/quake with brackets (moveFX tags)
	# 2. tags that are \{ or \} (font size tags)
	# 3. tags that are \c[?] (color tags)
	namere.compile("\\\\n<(.*?)>")
	# this regex just searches for the \n<NAME> tags

func _on_FileDialog_file_selected(path):
	var file = File.new()
	var currentmessage = {}
	var currentline = []
	var messages = []
	currentFile = path #saving current file's path to check if a file is currently being edited
	file.open(path, 1)
	for i in file.get_as_text().split("\n"): # split document into lines
		if i.begins_with("message_"):
			messages.append(currentmessage)
			currentmessage = {"messageID": null}
			# if the line begins with "message_", create a dictionary for messages
		if i.begins_with("#"):
			messages.append(currentmessage)
			currentmessage = {"comment": i}
			# if the line begins with #, create a dictionary for comments
		else:
			currentline = i.split(":", true, 1) # split the line into before the : and after the :
			if currentline.size() > 1 and currentline[1] != "": 
				currentmessage[currentline[0].lstrip(" ")] = currentline[1]
				# add the left of the split line into the dictionary and give it the data of the right
				# faceindex:0 becomes {faceindex: 0}
				# we're basically making it readable for the program since i'm interpreting the YAML as raw text
			if currentline[0].begins_with("message_"): 
				currentmessage["messageID"] = currentline[0].split("_")[1]
				#  set message ID to whatever the number is in message_x
	messages.append(currentmessage) # append directory to list of directories
	for n in $ScrollContainer/VBoxContainer.get_children(): # delete all messages in the vbox list
		n.queue_free()
	var addBoxInstance = addbox.instance()
	$ScrollContainer/VBoxContainer.add_child(addBoxInstance) # add an add box (add dialogue/comment)
	for i in messages: # go through list of dictionaries
		if i.has("text"): 
			var message = messageProcessing(i) 
			# process the tags in the message, basically adding ` to the end of tags
			var text = message[0]
			var messageDict = message[2]
			var box = dialoguebox.instance()
			### get the nodes for the properties bar and the textedit
			var dropdown = box.get_node("MarginContainer/Margin/VBox/Bar/NameDrop")
			var textedit = box.get_node("MarginContainer/Margin/VBox/HBox/VBox/TextLabel")
			var mIDline = box.get_node("MarginContainer/Margin/VBox/Bar/MessageIDLine")
			var nameDisable = box.get_node("MarginContainer/Margin/VBox/Bar/FaceDisable")
			var nameLine = box.get_node("MarginContainer/Margin/VBox/Bar/NameLine")
			var faceIndex = box.get_node("MarginContainer/Margin/VBox/Bar/FaceIndex")
			var facesetsdrop = box.get_node("MarginContainer/Margin/VBox/Bar/FaceSet")
			### we use these variables so we dont have to repeat get_node a bunch of times
			for x in GlobalManager.characters: dropdown.add_item(x)
			# for the character name dropdown, we add an option for each preset (soon to add custom presets)
			for x in GlobalManager.facesetsnames: facesetsdrop.add_item(x)
			# add the facesets from faceset path
			var index = GlobalManager.characters.find(message[1])
			if index != -1: dropdown.selected = GlobalManager.characters.find(message[1])
			else: nameLine.text = message[1]
			# set the character name dropdown to the current character name if found
			# else, just put it in the custom name line
			textedit.text = text
			textedit.wrap_enabled = true
			textedit.size_flags_horizontal = SIZE_EXPAND_FILL
			textedit.size_flags_vertical = SIZE_EXPAND_FILL
			textedit.rect_min_size.y = 100
			# just setting the properties of the textedit
			box.name = "message_" + messageDict["messageID"]
			# rename the box node to the message ID for easier debugging
			if messageDict.has("faceindex"):
				faceIndex.value = int(messageDict["faceindex"])
				facesetsdrop.selected = GlobalManager.facesetsnames.find(messageDict["faceset"].lstrip(" ") + ".png")
				box.facesetChange(facesetsdrop.selected)
				box.faceIndexChange(faceIndex.value)
			# if the dialogue has a faceindex, then set the faceindex line to the faceindex value
			# also select the mentioned faceset, then update the facesets on the dialogue box
			else:
				nameDisable.pressed = true
				box.faceDisable = true
			# if it doesnt have a face index, just disable the face
			mIDline.text = messageDict["messageID"]
			# set the message ID roller to the current message ID
			$ScrollContainer/VBoxContainer.add_child(box)
			# finally add the dialogue box to the vbox
		if i.has("comment"):
			var comment = commentbox.instance()
			var commentText = comment.get_node("MarginContainer/VBoxContainer/TextEdit")
			# a comment is simpler so we're just setting the textedit variable
			commentText.text = i["comment"]
			if (messages.find(i) + 1 < messages.size()) and messages[messages.find(i) + 1].has("comment"):
				messages[messages.find(i) + 1]["comment"] = i["comment"] + "\n" + messages[messages.find(i) + 1]["comment"]
				#if the next line is a comment, then add the current text to the next comment
				#this is how i implemented having multiple comments in one comment box
				continue
			else:
				$ScrollContainer/VBoxContainer.add_child(comment)
				comment.textUpdate()
				# if the next line isn't a comment, add the comment to vbox
		if i.has("comment") or i.has("text"):
			addBoxInstance = addbox.instance()
			if i.has("text"): addBoxInstance.name = i["messageID"]
			$ScrollContainer/VBoxContainer.add_child(addBoxInstance)
			# if the previous box is a dialogue box or a comment, then add an add box (add dialogue/comment)

func addCommentDialogue(isDialogue : bool, index : int):
	if isDialogue:
		var box = dialoguebox.instance()
		var addBoxInstance = addbox.instance()
		# instancing the dialoguebox and the addbox
		var dropdown = box.get_node("MarginContainer/Margin/VBox/Bar/NameDrop")
		var facesetsdrop = box.get_node("MarginContainer/Margin/VBox/Bar/FaceSet")
		for x in GlobalManager.characters: dropdown.add_item(x)
		for x in GlobalManager.facesetsnames: facesetsdrop.add_item(x)
		# adding the options for character name dropdown and faceset dropdown
		$ScrollContainer/VBoxContainer.add_child(box)
		$ScrollContainer/VBoxContainer.add_child(addBoxInstance)
		$ScrollContainer/VBoxContainer.move_child(addBoxInstance, index + 1)
		$ScrollContainer/VBoxContainer.move_child(box, index + 1)
		# we move the addbox to the index of the addbox we clicked on,
		# then we move the dialogue box
	else:
		var comment = commentbox.instance()
		var addBoxInstance = addbox.instance()
		$ScrollContainer/VBoxContainer.add_child(addBoxInstance)
		$ScrollContainer/VBoxContainer.add_child(comment)
		$ScrollContainer/VBoxContainer.move_child(addBoxInstance, index + 1)
		$ScrollContainer/VBoxContainer.move_child(comment, index + 1)
		# does same thing as dialoguebox but comment
		

func messageProcessing(messageDict):
	var message = messageDict["text"]
	var charName
	
	
	#--------------------------- REMOVING NAME TAGS ----------------------------
	# we remove these tags and replace them with normal character names
	if "\\aub" in message:
		message = message.replace("\\aub", "")
		charName = "AUBREY"
	elif "\\her" in message:
		message = message.replace("\\her", "")
		charName = "HERO"
	elif "\\kel" in message:
		message = message.replace("\\kel", "")
		charName = "KEL"
	elif "\\mar" in message:
		message = message.replace("\\mar", "")
		charName = "MARI"
	elif "\\swh" in message:
		message = message.replace("\\swh", "")
		charName = "SWEETHEART"
	elif "\\spg" in message:
		message = message.replace("\\spg", "")
		charName = "SPACE PIRATE GUY"
	elif "\\sbf" in message:
		message = message.replace("\\sbf", "")
		charName = "SPACE BOYFRIEND"
	else:
		charName = "GAME"

	#--------------------------- NAME SUBSTITUTING  ----------------------------
	
#	we replace the party name subtitutes for their actual names
#	afaik, 2, 3, and 4 always refer to aubrey kel and hero (and i dont know 
#	very much, so please let me know if this causes issues. i'll just remove 
#	this section if necessary
	
	if "\\n[2]" in message:
		message = message.replace("\\n[2]", "AUBREY")
	if "\\n[3]" in message:
		message = message.replace("\\n[3]", "KEL")
	if "\\n[4]" in message:
		message = message.replace("\\n[4]", "HERO")
		
		
	#--------------------------- TAG CONVERSION --------------------------------
	# tags we replace (and convert back when we save)

	if "<br>" in message: 
		message = message.replace("<br>", "\\<br>`")
		# we add the \ and the ` to make it recognizable by the syndibox effects system 
	if "\\!" in message: 
		message = message.replace("\\!", "\\!`")
		# we add the ` to make it recognizable by the syndibox effects system
	if "\\|" in message: 
		message = message.replace("\\|", "\\|`")
	if "\\." in message: 
		message = message.replace("\\.", "\\.`")
	if re.search_all(message): 
		var results = []
		for x in re.search_all(message):
			if !(x.get_string() in results): results.append(x.get_string())
		for i in results:
			message = message.replace(i, i + "`")
	# for all the patterns in the earlier re.compile, add an ` to the end so 
	# the syndibox effects system knows where to stop searching when it recognizes
	# a tag
			
	
	if namere.search(message):
		customname = namere.search(message).strings
		charName = customname[1]
		message = message.replace(customname[0], "")
	# process \n<NAME> tags and set the charName to the inside of the brackets
		
	return [message, charName, messageDict]
	# we return these variables for the file opening in the previous method
	
func moveFX(index):
	var active = get_focus_owner()
	movefx.selected = 0
	if active is TextEdit:
		var brackets = active.get_selection_text()
		match index:
			# match the moveFX selection in the toolbar to one of the 5 moveFXs 
			# and add the tag before the selected text / cursor
			1: brackets = "\\SINV[1]`" + brackets
			2: brackets = "\\SINV[2]`" + brackets
			3: brackets = "\\SINH[1]`" + brackets
			4: brackets = "\\QUAKE[1]`" + brackets
			5: brackets = "\\QUAKE[2]`" + brackets
		if active.get_selection_text().length() > 0: 
			# if there's an active selection, also add the reset tag
			match index:
				1: brackets = brackets + "\\SINV[0]`"
				2: brackets = brackets + "\\SINV[0]`"
				3: brackets = brackets + "\\SINH[0]`"
				4: brackets = brackets + "\\QUAKE[0]`"
				5: brackets = brackets + "\\QUAKE[0]`"
		active.insert_text_at_cursor(brackets)

func _on_OptionButton_item_selected(index):
	match index:
		1:  # if New File is selected, clear all boxes and add an addbox
			for n in $ScrollContainer/VBoxContainer.get_children():
				n.queue_free()
			var addBoxInstance = addbox.instance()
			$ScrollContainer/VBoxContainer.add_child(addBoxInstance)
		2:  # if Open File is selected, open the file select menu
			$FileDialog.popup()
		3:  # if the file being edited has a path, save as is. if not, 
			# open file select menu for saving
			if currentFile:
				saveFileAs(currentFile)
			else:
				$SaveDialog.popup()
		4:  # opens the file select menu for saving
			$SaveDialog.popup()
	optionbutton.selected = 0 # resets the text to "File"

func waitForPlayerInput(dur):
	var active = get_focus_owner()
	if active is TextEdit: 
		if active.get_selection_text().length() > 0:
			active.cursor_set_column(active.get_selection_from_column ())
			# put cursor at start of selection if there's an active selection
		active.deselect()
		match dur:
			"playerinput": active.insert_text_at_cursor("\\!`")
			"1sec" : active.insert_text_at_cursor("\\|`")
			"0.25sec" : active.insert_text_at_cursor("\\.`")
		
func fontSizeChange(increase):
	var active = get_focus_owner()
	var text
	if active is TextEdit: 
		if active.get_selection_text().length() > 0:
			text = active.get_selection_text()
			if increase: text = "\\{`" + text + "\\}`" 
			else: text =  "\\}`" + text + "\\{`"
			active.insert_text_at_cursor(text)
			# if there's an active selection, add the appropriate pair of tags
			# to before and after the selection
		else: 
			# if there's no active selection, only add the chosen font size tag
			if increase: active.insert_text_at_cursor("\\{`")
			else: active.insert_text_at_cursor("\\}`")

func colorText(index):
	var active = get_focus_owner()
	if active is TextEdit:
		var brackets = active.get_selection_text()
		brackets = "\\c[" + str(index - 1) + "]`" + brackets + "\\c[0]`"
		# add the color tag for the specified color, using the index from the
		# dropdown menu
		if active.get_selection_text() != "": active.insert_text_at_cursor(brackets)
	colorbutton.selected = 0

func addLinebreak():
	var active = get_focus_owner() # gets current textedit focused
	if active is TextEdit: 
		if active.get_selection_text().length() > 0: # if there's a selection
			active.cursor_set_column(active.get_selection_from_column ()) 
			# set cursor to start of selection, otherwise it would replace the selected text with the tag
		active.deselect()
		active.insert_text_at_cursor("\\<br>`") # inserts tag

func saveFileAs(dir):
	var yamloutput = [] # array of lines to be added to the .YAML file
	var messageDicts = [] # array of messages/comments from the vbox container
	var IDset = {}
	for dialog in $ScrollContainer/VBoxContainer.get_children():
		if dialog.has_method("getData"): # check if the box has method getData to avoid errors from "add dialogue/comment boxes"
			messageDicts.append(dialog.getData()) # appends the dictionary that is returned from getData
	for i in messageDicts:
		if i.has("messageID"): # if message
			# checking if messageID has been used before
			if not (i["messageID"] in IDset): IDset[i["messageID"]] = 1
			else: 
				IDset[i["messageID"]] += 1
				i["messageID"] = i["messageID"] + "_" + str(IDset[i["messageID"]])
				# if messageID has been used before, add "_x" to the messageID with x being the amount of times it's been used
			yamloutput.append("message_" + str(i["messageID"]) + ":") # whatever the message ID is, add it as message_ID
			if i.has("faceset"): # checking if message has face enabled
				yamloutput.append("      " + "faceset: " + i["faceset"].rstrip(".png"))
				yamloutput.append("      " + "faceindex: " + str(i["faceindex"]))
			if i.has("character"): # adding the character name with the OMORI tag "\n<NAME"
				if !i["character"] == "GAME": i["text"] = "\\n<" + i["character"] + ">" + i["text"]
				# if the character is supposed to be the game, don't display character text
			yamloutput.append("      " + "text:" + i["text"])
			#add the text to the lines to be written to the .YAML file
		elif i.has("comment"): yamloutput.append(i["comment"]) # jsut appending the comment
	var save = File.new()
	save.open(dir, 2)
	for line in yamloutput: # for each line we added, write them into the .yaml file
		save.store_line(line)

func settingsPop():
	$SettingsWindow.popup_centered() # opens settings window

func goToMessage():
	var mIDquery = $ToolsMargin/ToolsVBox/HBoxContainer/IDquery
	var searched = get_node("ScrollContainer/VBoxContainer/message_" + mIDquery.text)
	# get the node that has the same message_ID as the set ID
	if searched: searched.grab_focus() 
	# grab the focus, the scroll container will automatically scroll to the focused box

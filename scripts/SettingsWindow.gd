extends WindowDialog

onready var tilesetsDialog = get_parent().get_node("TilesetsDialog")
onready var boxlist = get_parent().get_node("ScrollContainer/VBoxContainer")
onready var charPresetsLabel = $MarginContainer/VBoxContainer/CharacterPresets/CharPresetsLabel
var config = ConfigFile.new()
var save_path = "user://config.cfg"
var currentFaceSetPath


# Called when the node enters the scene tree for the first time.
func _ready():
	if config.load(save_path) == OK:
		currentFaceSetPath = config.get_value("directory", "facesetsDirectory", "")
		tilesetsDirSelected(currentFaceSetPath) 
		# gets faceset path from config file and loads it as the faceset path
		GlobalManager.characters = config.get_value("characterPresets", "characters", ["GAME", "AUBREY", "KEL", "HERO", "MARI", "SPACE PIRATE GUY", "SPACE BOYFRIEND"])
	for i in GlobalManager.characters:
		charPresetsLabel.text += i + ", "
	charPresetsLabel.text = charPresetsLabel.text.rstrip(",")


func browseButtonUp():
	tilesetsDialog.popup_centered()


func tilesetsDirSelected(dir):
	GlobalManager.facesetsPath = dir # lets program know we currently have a tileset path
	GlobalManager.loadFacesets()
	for i in boxlist.get_children():
		if i.has_method("facesetUpdate"): i.facesetUpdate()
	# if the box is a dialoguebox, update faceset
	$MarginContainer/VBoxContainer/HBoxContainer/FacesetsPathLabel.text = dir
	currentFaceSetPath = dir
	saveDirectory()

func loadPrevDirectory():
	# if a tileset path has previously been set, load the path
	config.load(save_path)
	currentFaceSetPath = config.get_value("directory", "facesetsDirectory", "")
	GlobalManager.characters = config.get_value("characterPresets", "characters", ["GAME", "AUBREY", "KEL", "HERO", "MARI", "SPACE PIRATE GUY", "SPACE BOYFRIEND"])
func saveDirectory():
	# save the tileset path for future boots
	config.set_value("directory", "facesetsDirectory", currentFaceSetPath)
	config.set_value("characterPresets", "characters", GlobalManager.characters)
	config.save(save_path)
	#print(save_path)

func openSocial(social):
	# opens the social media links based on the signal the button sends
	var link
	match social:
		"twitter": link = "https://twitter.com/_omariAU"
		"youtube": link = "https://www.youtube.com/channel/UCU9VqXnFxZbk7h0K6tmrkWw"
		"instagram": link = ""
	OS.shell_open(link)

func charpresetsChange(new_text):
	GlobalManager.characters = Array(new_text.split(","))
	for i in range(GlobalManager.characters.size()):
		GlobalManager.characters[i] = GlobalManager.characters[i].strip_edges()
	saveDirectory()
	$Timer.start(0.5)

func nameupdateTimer():
	for i in boxlist.get_children():
		if i.has_method("namedropUpdate"):
			i.namedropUpdate()

extends Node

var facesets = []
var facesetsnames = []
var characters = ["GAME", "AUBREY", "KEL", "HERO", "MARI", "SPACE PIRATE GUY", "SPACE BOYFRIEND"]
var control
var facesetsPath = ""

func loadFacesets():
	facesets = []
	facesetsnames = []
	var dir = Directory.new()
	dir.open(facesetsPath)
	dir.list_dir_begin()
	while true: # loops through the facesets path directory
		var file_name = dir.get_next()
		var image = Image.new()
		var texture = ImageTexture.new()
		if file_name == "": break
		elif file_name.ends_with(".png") and !file_name.begins_with("."): #
			image.load(facesetsPath + "/" + file_name) # load the image
			texture.create_from_image(image,0) # create a texture from the image
			facesets.append(texture) # append the texture to the faceset list
			facesetsnames.append(file_name) # append the name of the faceset
	print(dir.get_current_dir()) # prints dir for debugging
	dir.list_dir_end()

func pngError():
	# error window if there are no png files in the facesets dir
	control.find_node("pngError").popup()

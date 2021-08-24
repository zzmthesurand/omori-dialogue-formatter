# OMORI Dialogue Formatter
a tool used to easily format and modify omori dialogue (.yaml) files 

## Installation
Just download the .rar in the Release tab. Uncompress the .rar, and put the .exe and .pck wherever you want (they must be together). Just run the .exe, and you should be good to go.

All the scripts, scenes, and resources will be available as well in the Release tab. Otherwise, you may clone the master branch and make your own changes from there.

## Usage Guide
### Initial Setup 
To get started, you must first go to the settings. (This button -> ![2021-08-23_211538](https://user-images.githubusercontent.com/9362238/130453648-467c16f6-daa3-4717-96ec-c86987a5dd4a.jpg))


![2021-08-23_211427](https://user-images.githubusercontent.com/9362238/130453484-f145adfc-0940-4dc6-9fdd-50cc24671b5a.jpg)

Here, you must set your facesets directory (the place where you keep your .png facesets)
***NOTICE: Your faceset files must have a horizontal resolution of 424 pixels. Any width other than 424 pixels may cause accidental cropping and missing faces.***

For "Char Presets", I recommend that you add names at the end of the list, separated by commas. Changing the order of names or adding a name in the middle of the list will mess with the name index for the name dropdown menu, so I recommend you add names only to the end of the list.

After that, you're all ready go!

## Opening Files
In the  ![2021-08-23_211952](https://user-images.githubusercontent.com/9362238/130454257-40692703-061e-4cbd-a2f4-effef33244ad.jpg)  dropdown menu, you can do 4 things:
1. New File - this creates a new file for you to add dialogue and comments into
2. Open File - this opens any `.YAML` file for modification
3. Save File - if this is an opened file, this will save and overwrite the file you opened. if this is a new file, it will act as a "Save File As" option
4. Save File As - opens a dialog for you to name and choose the location of your `.YAML` file.

## Adding Dialogue and Comments
To simply add a dialogue or comment box, click the `Add Dialogue` and `Add Comment` buttons. A new dialogue or comment box will appear below it. 

## Dialogue Boxes
Let's start with the interface. There are two important parts: the `properties bar` and `the text edit`.
![image](https://user-images.githubusercontent.com/9362238/130455703-5689ac61-f334-4392-bbc7-25bbb2ccfc85.png)

### Properties Bar
![image](https://user-images.githubusercontent.com/9362238/130455796-4e3c2fbc-4450-45c9-b29b-a16b96ad9c93.png)
Within the properties bar, you will see these items (in order from left to right):
1. Name Dropdown Menu - your character presets from the settings menu will show up here. this is for character names you will use a lot, so you don't have to type them out. use "GAME" if the text box will not have a name.
2. Preview Button - when enabled, the preview with text effects will show. press Z to advance if the text is waiting for player input.
3. Message ID - this is what you will call within RPG maker events to show text. in the original OMORI game, message IDs were only numbers. each message is saved as "message_ID" make sure that no messages share the same message ID.
4. Custom Name - if your character is not in the character presets, just type their name in this text field. this is more useful for one-off characters, where you don't have to frequently type their name
5. Face Disable - if checked, the message will not store face index and faceset data. used for characters who do not have sprites
6. Face Index - this is for the face index you will use for your faceset.
7. Faceset Dropdown Menu - this is where you select which faceset the message will use.

### Text Edit
This is where you place your text and tags. I recommend writing your "text" first, then using the tools on the righthand menu to format the text with different font sizes, colors, and etc.

## Tags & Tools
RPG Maker uses a blackslash (\\) to denote their tags. Within the modified SyndiBox text engine, the tag must end with a grave accent " \` ". This is the key below escape and ***NOT the apostrophe character***

1. `Move FX` - this surrounds the highlighted text with the corresponding tags  
        a. Vertical Shake & Vertical Shake Strong - \\SINV\[x]\` and \\SINV\[0]\` (resets effect). x corresponds to shake speed (1 is slower and 2 is faster).  
        b. Horizontal Shake - \\SINH\[1]\` and \\SINH\[0]\` (resets effect). this only has one strength option.  
        c. Earthquake Strong & Earthquake - \\QUAKE\[x]\` and \\QUAKE\[0]\` (resets effect). x corresponds to shake speed (1 is faster and 2 is slower)  
    ***NOTE: earthquake effect in-game looks somewhat different from the earthquake effect in this program.***  
2. `Color` - colors the highlighted text with the selected color  
         - follows tag format \\c\[x], where x is the color index. 0 is white, so use that for resetting the color  
3. `Line Break` - adds a `\<br>` tag. ***NOTICE: Using the enter button to add a new line will break the dialogue. The text edit will automatically wrap the text for you.  
4. `Wait for...` - adds a tag that waits for the specified time  
        a. Wait for Z - \\!\` - waits for the player input before continuing text  
        b. Wait for 1s - \\|\` - waits for 1 second (60 RPG Maker ticks) before continuing text  
        c. Wait for 0.25s - \\.\` - waits for 0.25 seconds (15 RPG Maker ticks) before continuing text  
5. `Font size:` - adds a tag for increasing or decreasing the font size (does not accurately reflect font sizes in-game)  
        a. `+` - \\{\` - increases font size  
        b. `-` - \\}\` - decreases font size  
6. `GO TO:` - goes to the message with the specified ID  

## Comment Box
Place your comments here. Any non-commented lines will be commented when saving.

### Dev's Note
hi! this is my first piece of software ever so i apologize for the messy code. i've tried my best to comment everything so that all functions are easily understandable.

this project was made in the Godot Engine and uses a modified version of the [SyndiBox Text Engine](https://github.com/TeamSyndi/syndibox) for all text effects. all other scripts are original 

### Credits
OMORI Dialogue Formatter by ZZMthesurand
OMORI text sound by OMOCAT
SyndiBox Text Engine by Sudospective


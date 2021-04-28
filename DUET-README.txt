<--FRIDAY NIGHT FUNKIN DUET+ by glotch-->

The following readme covers the features of Modding+, the features of Duet+, and the features tacked on to Modding+.
Hopefully it's intuitive enough. If you have questions, hit me up.
First section covers Modding+ and misc features, second section only covers duet features.
If you find bugs or things to improve in this mod, report it at https://github.com/glotchalotch/Funkin-duet
(MAKE SURE BUGS AREN'T IN THE VANILLA GAME OR MODDING+ BEFORE REPORTING!!!)

How to use:
  Custom Songs:
    Make a new folder in assets/data
    Name it what you want the song name to be but lowercase and replace spaces
    with "-"
    (like Life Will Change > life-will-change)
    Add json files to folder
    Rename each file to the folder name + the difficulty ending, if applicable
    Make a temp folder in assets/music
    Add the music to the folder
    Rename them to the name of the song with hyphens ("-") with the suffix
    (like Life Will Change > Life-Will-Change)
    Drag them out to assets/music
    Go to freeplaySongJson.jsonc
    Add a section for your mod if you want to
    Add the song name(s) to it, with the same name as the music files
    (like Life Will Change > Life-Will-Change)
    Launch FNF
    For each difficulty:
    Open the song
    Hit the '7' key
    Go to the song tab
    Click on the text box
    Replace what is in there with the name of the music files
    (like Life Will Change > Life-Will-Change)
    Hit 'Save'
    Save the file and remember to add the difficulty suffix
    After finishing this add the saved file to the folder and overwrite.
  Custom Characters:
    Go to assets/images/custom_chars
    Make a new folder for your character with the name of the character in lowercase-dashed-format
    Drag in the mod png and xml (if no xml grab the base game one)
    Rename them to char.png and char.xml respectively
    If there are custom icons:
      Add the iconGrid.png
      Rename to icons.png
    Open custom_chars.jsonc in the custom_chars directory
    Add a new property:
      "(character name)": {
        "like": "(character this is based on)",
        "icons": [(alive icon number),(dead icon number)]
      }
    Remember your commas!
    Characters also now support portraits.
    If your character has a portrait drag it in and rename it to portrait.png
    They also support custom death sprites.
    If your character is based on pixel bf:
    drag in the death png + xml
    rename to 'dead'
    If it is based on bf: Great! Everything is already done for custom death!
    To apply these characters:
    Open a song
    Hit the '7' key
    go to the song tab
    Click on one of the top two text boxes with character names in them
    Select your custom character
    Hit save and save the json. Remember difficulty prefixes!
    Custom GF:
      Follow above instructions but instead of choosing one of the top two
      text boxes choose the one that says gf.
      Choose custom gf
      Hit save and save the json. Remember difficulty prefixes!
  Custom Stages:
    Goto assets/images/custom_stages
    Make a new folder with the name of your stage
    Drag in any custom stage assets
    Add a new property to custom_stages.json:
      "(stage name)": "(stage it is like)"
    Don't forget your commas!
    To apply these stages:
    Open a song
    Hit the '7' key
    go to the song tab
    Click on the drop down that says something like 'stage'.
    Select your custom stage.
    Hit save and save the json. Remember difficulty prefixes!
  Custom Weeks:
    If your mod has a custom week icon:
      Add the xml and png to the assets/images/campaign-ui-week folder
      (if no xml then grab one from one of the other weeks)
      rename them to what the week position is (week6, week7, week8)
    Else:
      Copy one of the weeks png + xml and rename them to the week position
      (week7,week8,week9)
    Open assets/data/storySonglist.json
    Add a new week:
      ["(animation name of the week, look at default weeks)", "(trackname)", "(trackname)", ...]
    Add a new character Array e.g.:
      ["parents-christmas", "bf", "gf"]
    Launch the game, open story menu and see your week!
    Custom UI Characters
      Add the mod png and xml to assets/images/campaign-ui-char
      (if no xml just copy another one)
      Rename files to "(character name)"
      Open custom characters json
      Add new property:
      "(character name)": "(character it goes over)"
      Don't forget your commas!
      To use these just replace the character in the character array with the
      name of your character
  Custom Cutscenes:
    You can now make your own cutscenes!
    To add them: Go to assets/images/custom_ui/dialog_boxes
    drag in the dialog box png + xml
    rename them to what you want the cutscene to be named
    If there is a senpai crazy png + xml, drag those in and rename them
    to the cutscene name +  '-crazy'
    Go to assets/data
    Open up "cutscenes.txt"
    add your cutscene name on a newline!
    Go to the song folder,
    Add a "dialog.txt" file
    Do this format
    "
    :dad: Senpai speaking
    :bf: Bf speaking
    :char-x: character x speaking
    :char-x:f character x with their portrait flipped (this will put them on bf's side unless you're flipping bf for some reason)
    "
    Also add a Lunchbox.ogg if you want dialog sound
    To apply these cutscenes:
    Open a song
    Hit the '7' key
    go to the song tab
    Go to the text box that says "none" and edit it to the cutscene type you want.
    Select your custom stage.
    Hit save and save the json. Remember difficulty prefixes!
  Custom UI:
    You can now add custom ui!
    Go to assets/images/custom_ui/ui_packs
    make a new folder with the name of your ui
    Add the following files:
    The arrow files
    The rating files (good, bad, shit, sick)
    The number files
    The intro files (ready, set, go)
    The Ogg files for the intro (intro1, intro2, intro3, introGo)
    (Remember, all of these files are required or the game will crash!)
    Go to assets/data
    Open uitypes.txt
    Add your ui type name on a new line!
    To apply these uis:
    Open a song
    Hit the '7' key
    go to the song tab
    Click on the drop down that says something like 'normal'.
    Select your custom stage.
    Hit save and save the json. Remember difficulty prefixes!
  Custom Difficulties:
    To add custom difficulties:
    go to assets/images/custom_difficulties
    add your difficulty png + xml
    add a new entry to difficulties.json inside of the array
    {
      "offset": (how far it should be offset from the arrow(?)),
      "anim": "(the animation name)",
      "name": "(the name used in freeplay mode)"
    }
    if you want to change the default difficulty change
    default to the position in the list - 1
    For songs you have to make a new json using the chart editor and rename
    the file with "-(difficulty name)" at the end.
  Custom Intro Text:
    To change the intro text, open assets/data/introText.json.
    "introText" is an array that contains the random splash text
    (it takes over the functionality of introText.txt)
    "ngText" changes the text normally used for "In Association with Newgrounds".
    (Maximum of 2 entries, line break using --)
    "showNgSprite" determines whether to show the newgrounds logo sprite
    "titleText" controls the text that normally says "Friday Night Funkin"
    (Maximum of 3 entries)
  Options.json:
    "skipVictoryScreen" skips the victory screen after a song
    "skipModifierMenu" skips the pre-song menu
    "alwaysDoCutscenes" forces cutscenes to play in freeplay mode
    "allowEditOptions" allows adding songs/weeks/chars from the options menu
    "useSaveDataMenu" determines whether to show the options menu
    "preferredSave" is which save slot to use by default (i think)
    "windowTitle" changes the window title on startup
    "skipSplash" skips the HaxeFlixel splash screen
  Misc Things:
    In the Song tab of the chart editor, you can switch between 3/4 and 4/4 time using
    the radio buttons that are labelled as such. You might want to clear the whole song if
    you're switching to 3/4 time by using the "Clear song" button.


ADDING DUETS: THE GAME: THE MOVIE: THE GUIDE

All duet characters are managed using the chart editor accessed by hitting 7 during a song.

In the Char tab:
- Click Add or Remove to add or remove a character that you want to sing with bf or with the opponent.
- The BF Duet/Enemy Duet column is the internal name of the character. (so make sure you know that)
- Offset X/Y is how much the character is offset from bf or the enemy. Positive X is right, positive Y is down.
  - You'll probably need to do a lot of offset tweaking in large increments to get the result you want.
- "Sync" determines whether they will sing along with or separately from BF (referred to henceforth as
  "synchronous" or "asynchronous"). If they're not, they will have to be charted separately.
- "Main Chart" will bring you back to the original chart after charting for an asynchronous character.

ASYNCHRONOUS CHARACTERS: THINGS TO KNOW:
- When charting async characters, *CHART FOR THE CORRECT SIDE.*
- If they're on bf's side, chart on bf's side and vice versa.
- There is also only one chart PER CHARACTER NAME, so don't freak out if you have the same character on
  different sides and have to edit the same chart for both of them.
- In the section tab, in addition to copying the last section, you can also copy sections from the main
  chart or from another character's chart.

In the Note tab (all of this affects SYNCHRONOUS characters only):
- When a note is selected, you can click Add or Remove to *toggle* the state of a character.
  (If a note isn't selected the game will crash so make sure it's selected. The only way to select a note
  at this time is to add a new one or re-add an old one.)
- If they're disabled, they will do an idle animation as opposed to singing.
- All characters start disabled apart from bf and the enemy.
- The toggle is inclusive to the note, meaning that the toggle will affect them on that note, not after.
- The toggle is also sided, meaning that if the character you want to toggle is on bf's side you need to
  use a note on his side, and vice versa.
- Put "player" to toggle the player (or enemy) character's singing animations.

In the Song tab:
- BF or Enemy Cam Offset X/Y will change the position of the camera when it's focused on BF or the opponent. This can be used to
  get a better view of all the duet characters. Try to use small adjustments, especially in the X direction,
  as the stage bounds are not super big.

Hope you enjoyed this tutorial make sure to like and subscribe and ring the bell for more videos
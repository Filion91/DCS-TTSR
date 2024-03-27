# DCS Text To Speech Reader

## What is DCS-TTSR?
A simple program made by a humble programmer meant to intercept DCS chat messages and read them aloud. The program is composed of two parts:
1. DCS Dedicated Server Lua hook script, socket client, captures DCS chat messages, processes commands, sends messages to be read 
2. Python Discord bot script, socket server, captures Discord messages, reads messages with Google's Text To Speech API

In the future, I would like to replace GTTS with something that has a more diverse set of voices so as to give each player a unique personality. 
Additionally, I would like to supplement Discord with a DCS-SRS option in order to add realism and immersion.

## Why DCS-TTSR?
1. it's hard on the eyes and not very convenient to read chat in DCS 
2. sometimes chat messages are of critical importance
3. many players lack microphones or prefer not to use them (hello Rick)

## Ok, but project XYZ does it better...
Certainly, but I enjoyed doing this and I'm learning a lot in the process.

## Requirements
1. a Discord bot of your own with permissions to read/delete messages and use voice, along with its token
2. a Python environment with GTTS (available with pip)
3. an install of FFmpeg (https://ffmpeg.org/)

## Installation
1. create a Python file named dBotSecrets.py in the same folder as the rest of the scripts
	1.1. put therein a variable named SECRET_Token containing your Discord bot's token
2. edit dBot_DCS-TTSR.py's CONFIGURATION PARAMETERS section as needed
3. edit DCS-TTRS.lua's CONFIGURATION PARAMETERS section as needed and desired
	3.1. see online for languages and accents (TLDs) supported by GTTS, use Google Translate to try them
4. move DCS-TTRS.lua to USER_DIRECTORY\SavedGames\DCS_server\Scripts\Hooks\, it will be executed automatically 

## Using DCS-TTSR
### Discord
1. run dBot_DCS-TTSR.py (the bot will become reactive after a few seconds)
2. join a voice channel
3. type "!start" in a text channel
type "!help" for a short help message)
### DCS
1. start the server and run a mission 
2. type "!start"
3. a message should indicate if the socket client and server are properly connected
4. any chat message sent by a player, on any side (including spectators), will be read
5. BLUE, RED, and spectators will have different accents
6. you can also map user ID's to specific accents
type "!help" for a short help message
### Exiting
1. Just close everything :)

## Feedback
I am open to any feedback you may have, don't hesitate
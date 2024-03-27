------------------------------
-- CONFIGURATION PARAMETERS --
------------------------------
local Address = "192.168.0.146" -- IPv4 address 
local Port = 5555 -- TCP port
local BlueAccent = "com" -- USA
local RedAccent = "co.in" -- India
local DefaultAccent = "com.au" -- Australia
-- CONFIGURATION PARAMETERS

-- Setup
local ChatIntercept = {}
local socket = require("socket") -- NOTE: DCS already includes this module, albeit an old version
local _client = nil -- TCP/IP socket (SOCK_STREAM in Python) with IPv4 family

local MessageCharLimit = 100 -- this is seemingly the hard limit for DCS chat messages
local PlayerUCID_AccentMappings = {} -- maps UCID (DCS account number) to an accent
local ServerID = 1 -- should always be 1, but subject to change, presumably in Two Weeks(tm)
local CommandChar = "!"
local CMD_Start = CommandChar .. "start"
local CMD_Stop = CommandChar .. "stop"
local CMD_Say = CommandChar .. "say"
local CMD_Help = CommandChar .. "help"
local CMD_Players = CommandChar .. "players"
local CMD_VoiceMap = CommandChar .. "voicemap"
local Commands = {CMD_Help, CMD_Start, CMD_Stop, CMD_Say, CMD_Players, CMD_VoiceMap}
local Help = {"Display this message", "Connect to the socket server and start reading chat messages", "Disconnect from the socket server and stop reading chat messages", "(for WebGUI only) Read message", "List all players, their playerID, and UCID", "Map a player ID to an accent"}
local PrivilgedUsers = {} -- list of all authorized users UCIDs who are able to pass commands UNIMPLEMENTED SO FAR

-- Even handler to intercept every chat message
function ChatIntercept.onPlayerTrySendChat(id, msg, to)
	ParseMessage(msg, id)
	return msg
end

-- Parse a chat message and determine what to do
function ParseMessage(message, senderID)
	if string.sub(message, 1, 1) == CommandChar then
		if string.find(message, "^" .. CMD_Help) then
			Command_Help()
		elseif string.find(message, "^" .. CMD_Start) then
			Command_Start()
		elseif string.find(message, "^" .. CMD_Stop) then
			Command_Stop()
		elseif string.find(message, "^" .. CMD_Say) then
			Command_Say(message)
		elseif string.find(message, "^" .. CMD_Players) then
			Command_Players()
		elseif string.find(message, "^" .. CMD_VoiceMap) then
			Command_VoiceMap(message)
		end
	else
		AutoTTS(message, senderID)
	end
end

-- Display the name, playerID, and UCID of every player on the server (to use for accent mapping)
function Command_Players()
	local players = net.get_player_list()
	local message = "Name | Player ID | UCID"
	for i = 1,#players do
		playerID = players[i]
		message = message .. "\n" .. net.get_name(playerID) .. " : " .. playerID .. " - " .. net.get_player_info(playerID, "ucid")
	end
	net.send_chat(message, true)
end

-- Connect the socket client to the server
function Command_Start()
	_client = socket.tcp()
	local result = _client:connect(Address, Port)
	if result == 1 then
		net.send_chat("Socket client connection to server successful", true)
	else
		net.send_chat("ERROR: socket client connection to server failed", true)
		_client = nil
	end
end

-- Disconnect the socket client from the server
function Command_Stop()
	if _client then
		net.send_chat("Closing socket client", true)
		_client:stop()
		_client = nil
	else
		net.send_chat("ERROR: socket client already closed", true)
		return
	end
end

-- TODO : get around MessageCharLimit restrictions if necessary
-- Display all available commands and a short description
function Command_Help()
	local message = ""
	for i = 1,#Commands do
		message = message .. Commands[i] .. " : " .. Help[i]
	end
	net.send_chat(message, true)
end

-- Read the message in the default accent, used mostly with the server's WebGUI
function Command_Say(message)
	message = string.sub(message, string.len(CMD_Say) + 2, -1)
	Say(message, DefaultAccent)
end

-- TODO : test me :)
-- Map voice settings to a UCID
function Command_VoiceMap(message)
	message = string.split(message, " ")
	local ucid = message[1]
	local language = message[2]
	local accent = message[3]
	PlayerUCID_AccentMappings[ucid] = accent
end

-- Called passively, determine the appropriate accent for the player and read the message
function AutoTTS(message, senderID)
	if senderID ~= ServerID then
		local playerUCID = net.get_player_info(senderID, "ucid")
		-- check for presence in the mappings
		local accent = PlayerUCID_AccentMappings[playerUCID]
		if accent then -- not nil
			print("do nothing")
		else
			local playerSide = net.get_player_info(senderID, "side")
			if playerSide == 1 then
				accent = RedAccent
			elseif playerSide == 2 then
				accent = BlueAccent
			else  -- side == 0
				accent = DefaultAccent -- repetition, but subject to change
			end
		end
		Say(message, accent)
	end
end

-- Send a message and an accent to be read by the Discord bot
function Say(message, accent)
	if _client then
		message = accent .. "_" .. message
		_client:send(message)
	else
		net.send_chat("ERROR: client not connected", true)
	end
end

-- Program start
DCS.setUserCallbacks(ChatIntercept)
-- Program end
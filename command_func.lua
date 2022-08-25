--[[
Region Areas and City
	erstelle Regionen in deiner Minetestwelt
	wilderness - alles was keiner Region zugewiesen ist
	city: in der City kann man Bauplätze (hier plot genannt) markieren 
	plot: diese Bauplätze können an Spieler vergeben werden.
	Für jede Region kann man das Verhalten einstellen und außerdem hat sie einen
		- Besitzer - owner, dieser kann die Attribute des Gebietes ändern
		- Namen unter dem sie im Spieler Hud angezeigt wird.
	Jedes Gebiet besitze Attribute, die es beeinflussen.  
		- Aneignen - claimable: kann sich das Gebiet jemand holen 
		- Art des Gebietes - zone: allowed_zones = { "none", "city", "plot", "owned"  }
		- Schutz - protected: nur der Besitzen (owner) kann hier interagieren
		- Gäste -guests: jeder Besitzer kann andere Spieler einladen in seinem Gebiet zu interagieren
		- pvp: ist auf dem Gebiet pvp erlaubt? 	Ist vom minetest.conf und dem Privileg PvP abhängig
		- Monster machen Schaden - mvp: der Monsterschaden kann auf dem Gebiet verboten werden
		- Effect: jedes Gebiet kann einen Effekt haben. allowed_effects = {"none", "hot", "dot", "bot", "choke", "holy", "evil"}
	 			hot: heal over time 
				bot: breath over time
  			holy: heal und bot
	 			dot: damage over time
	 			choke: reduce breath over time
	 			evil: dot und choke	
	
	

Copyright (c) 2022
	ralf Weinert <downad@freenet.de>
Source Code: 	
	https://github.com/downad/rac
License: 
	GPLv3
]]--
--#---------------------------------------
--
-- functions to handle chat commands
--
--#---------------------------------------




-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_help(param, name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region help {command}'
-- ein versuch dem Spieler die ChatCommands zu erklären
-- sende dem Spieler eine Nachricht, wie das Command funktioniert
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- return:
--	0			wenn fertig
--
-- msg/error handling: 
-- 	privileg: interact
-- 	return 20 --"msg: You don't have the privileg 'interact'! ",
-- 	return 0	-- no error
function rac:command_help(param, name)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:command_help - Version: "..tostring(func_version)	)
	end
	-- darf der user interacten?
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 	40 -- [40] = "ERROR: func: rac:command_help - Dier fehlt das Privileg 'interact'!",
	end
	
	minetest.log("action", "[" .. rac.modname .. "] rac:command_help param: "..tostring(param)) 
	
	local value = string.split(param, " ") 
	-- value[1] == 'help'
	local command = value[2]
	if command == nil then command = " ..' und das Command das dich interessiert" end
	local chat_start = "Call command '/region "..command  
	local chat_end 
	
	
	if command == "help" or value[1] == help then
		chat_end = chat_start.." {command}' um mehr Infos zu dem Command zu erhalten. [privileg: interact]"
	elseif command == "guide" then
		chat_end = chat_start.."' zeigt den rac-guide zur Verwaltung der Regionen an. [privileg: interact]"
--	elseif command == "status" then
--		chat_end = chat_start.."' to get some more infos about the region at your position. [privileg: interact]"
	elseif command == "border" then
		chat_end = chat_start.."' um dein Gebiet an dieser Position sichtbar zu machen. [privileg: interact]"..
			"\nDer region_admin kann mit '/region border' alle Regionen an dieser Stelle sichtbar machen. [privileg: region_admin]"..
			"\nDer region_admin kann mit '/region border {id}' die Region mit der ID sichtbar machen. [privileg: region_admin]"
	elseif command == "own" then
		chat_end = chat_start.."' teige eine Liste deiner Regionen. [privileg: region_set]"
	elseif command == "pos1" then
		chat_end = chat_start.."' setzte Position 1. Gehe an eine Ecke deines Gebietes und rufe  \'region pos1\', "..
			"\n auf, gehen zur gegenüberliegenden Ecke und nutze \'region pos2\'. Anschließend mit \'region set {region_name}\' claimst du das Gebiet. [privileg: region_set]"
	elseif command == "pos2" then
		chat_end = chat_start.."' setzte Position 2. Gehe an eine Ecke deines Gebietes und rufe  \'region pos1\', "..
			"\n auf, gehen zur gegenüberliegenden Ecke und nutze \'region pos2\'. Anschließend mit \'region set {region_name}\' claimst du das Gebiet. [privileg: region_set]"
--	elseif command == "mark" then
--		chat_end = chat_start.."' to select positions by punching two nodes. [privileg: region_mark]"
--	elseif command == "max_y" then
--		chat_end = chat_start.."' to set the y-values of your region to 90% of the max_height. 1/3 down and 2/3 up.  [privileg: region_mark]"
	elseif command == "set"	then
		chat_end = chat_start.." {region_name}' Wurden pos1 und pos2 gesetzt, kann man jetzt mit \'region set {region_name}\' das Gebiet claimen. [privileg: region_set]"
--	elseif command == "export" then
--		chat_end = chat_start.."' to export the AreaStore to an file! [privileg: region_admin]"
--	elseif command == "import" then
--		chat_end = chat_start.."' to import a region-export-file! [privileg: region_admin]"
--	elseif command == "import_areas" then
--		chat_end = chat_start.."' to import areas-export-file! [privileg: region_admin]"
	elseif command == "player" then
		chat_end = chat_start.." {player_name}' zeige eine Liste aller Regionen einser Spielers! [privileg: region_admin]"
	else
		chat_end = "The command is unknown!"
	end
	minetest.chat_send_player(name, chat_end)
	return 0
 end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command status
-- privileg: interact
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region status'
-- sends the player a list with details of the regions
--
--
-- input:
--		name 	(string) 	of the player
--		pos 	(table)		of the player
--
-- return:
--		0
--
-- msg/error handling: 
-- return 56 -- [56] = "ERROR: func: rac:command_status - Dir fehlt das Privileg 'interact'!",
-- return 0	-- no error
function rac:command_status(name,pos)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:command_status - Version: "..tostring(func_version)	)
	end
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 56 --[56] = "ERROR: func: rac:command_status - Dir fehlt das Privileg 'interact'!",
	end
	for region_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
		local counter = 1
		if region_id then
			local header = "status" 
			-- call command_show (without header!)
			rac:msg_handling( rac:command_show(header, name,region_id,nil) ) --  message and error handling
			counter = counter + 1	
		else
			minetest.chat_send_player(name, rac.default.wilderness)
		end -- end if regions_id then
	end -- end for regions_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
	return 0 -- no error
end
 
 
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command border
-- privileg: interact for own region
-- privileg: region_admin for more
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Das Command 'region border'
-- macht die Grenzen der Region sichtbar.
--	Aufruf als Player
--		'region border' 			zeigt die Grenzen der eigenen Region an dieser Pos an
--	Aufruf als region_admin
-- 		'region border' 			zeigt alle Regionen an, dabei werden outback,city,plot/owned in unterschiedlichen Farben angezeigt. 
--		'region border {id}'	zeigt die Region mit der ID an
--
-- input:
--		param 	(string)
--			der String beinhaltetet den 'border'-Anteil des Commands
--			dieser wird mit sub(7,-1) ignoriert
--			nach dem split sind folgende Fälle möglich
--			value[1]  	ist eine Zahl -> die ID der Region ie angezeigt werden soll
--			value[1] 		= nil, da keine ID mitgegeben wurde
--		name 	(string) 	of the player
--
-- return:
--	return 68 --		[68] = "ERROR: func: rac:command_border - Dir fehlt das Privileg 'interact'!",
-- 	return 0	-- no error
--
-- msg/error handling: yes
-- 		check privilegs
function rac:command_border(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_border"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err 
	local region_id  = nil	
	local pos1, pos2, data 
	local center
	local regions_at_pos

	-- check privs
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 68 --		[68] = "ERROR: func: rac:command_border - Dir fehlt das Privileg 'interact'!",
	end
	-- checke admin
	local can_modify = rac:player_can_modify_region_id(name)
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border ID = can_modify.admin = {"..tostring(can_modify.admin).."}" ) 
	
	-- get values of param
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border param = "..tostring(param) ) 
	local value = string.split(param:sub(7, -1), " ") 

	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border value = "..tostring(value) ) 
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border #value = "..tostring(#value) ) 
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border value[1] = "..tostring(value[1]) ) 
	if value[1] ~= nil then
		region_id = tonumber(value[1])
	end	
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border ID = value[1] = "..tostring(value[1]) ) 
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border region_id = "..tostring(region_id) ) 
	 
	local player = minetest.get_player_by_name(name)
	--local player = minetest.env:get_player_by_name(name)
	local pos = player:get_pos()		
	
	-- normaler Player es wird nur die eigene Region angezeigt
	if can_modify.admin == true then
		-- nur die Region mit der ID anzeigen
		if region_id ~= nil then
			rac:draw_border(region_id)	
		else -- if region_id ~= nil then
			-- hole alle Regionen an dieser Stelle
			for region_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do	
				minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border k = "..tostring(region_id) )  
				rac:draw_border(region_id)	
			end
		end
	end
end 
 
 
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:import(import_file_name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Load the exported AreaStore() from file
-- importiere ein Backup der Regionen
--
-- input: 
--		import_file_name as string-file-path
--
--
-- msg/error handling:
-- return 0 - no error
-- return 55 -- "ERROR: File does not exist!  func: func: rac:import(import_file_name) - File: "..minetest.get_worldpath() .."/rac_store.dat (if not changed)",
function rac:import(import_file_name)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:import - Version: "..tostring(func_version)	)
	end
	local counter = 1
	local pos1 
	local pos2
	local data
 
	-- does the file exist?
	local file = rac.worlddir .."/"..import_file_name 
	minetest.log("action", "[" .. rac.modname .. "] rrac:import(import_file_name) :"..tostring(import_file_name) )
	if rac:file_exists(file) ~= true then
		--minetest.log("action", "[" .. rac.modname .. "] rac:file_exists(file) :"..tostring(rac:file_exists(file))) 
		minetest.log("error", "[" .. rac.modname .. "] rac:file_exists(file) :"..file.." does not exist!") 
		return 	--	[55] = "ERROR: func: rac:import - ERROR: File does not exist! ",
	end		
	-- load every line of the file 
	local lines = rac:lines_from(file)

	-- loop all lines, step 3 
	-- set pos1, pos2 and data and rac:set_region
	while lines[counter] do
		-- deserialize to become a vector
		pos1 = minetest.deserialize(lines[counter])
		pos2 = minetest.deserialize(lines[counter+1])
		-- is an string
	 	data = lines[counter+2]

		rac:set_region(pos1,pos2,data)
	 	counter = counter + 3
	 	minetest.log("action", "[" .. rac.modname .. "] rac:import -pos1"..tostring(pos1).." pos2 "..tostring(pos2).." data "..data )
		
	end
	-- Save AreaStore()
	rac:save_regions_to_file()
	-- No Error
	return 0
end 


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command show 
-- privileg: region_admin *or call by command_status
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region show' <id1> <id2>  		<optional>
-- sends the player a list of regions
-- 
-- input: 
-- 	header									false/status
--														status, damit ein Player das aufrufen kann.
-- 	name										playername 
-- 	list_start,list_end			nil,nil -> dann wird die komplette Liste ausgegeben
-- 															andernfalls von :start bis _end
--
-- return:
--	0
--
-- msg/error handling:
-- return 0 - no error
-- [57] = "ERROR: func: rac:command_show - Dir fehlt das Privileg 'region_admin'!",
function rac:command_show(header, name,list_start,list_end)
	local func_version = "1.0.0"
	local func_name = "rac:command_show"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
--	local region_values = {}
--	local pos1 = ""
--	local pos2 = ""
--	local data = ""
	local stacked_zone = ""
	local chat_string = ""
	local chat_string_start = "### List of Regions ###"
	if header == false or header == "status" then
		chat_string_start = ""
	end
	-- no privileg check: header == status then command_show is called by command_status 
	-- else privileg region_admin / can_modify.admin == true
	-- rac:player_can_modify_region_id(player)
	local can_modify = rac:player_can_modify_region_id(name)
	if header ~= "status" then
		if not can_modify.admin then 
			return 57 -- [57] = "ERROR: func: rac:command_show - Dir fehlt das Privileg 'region_admin'!",
		end	 
	end

	-- if list_start is not set
	-- list_end is also not set
	-- list all, from 0 to end (-1)
	if list_start == nil then
		list_start = 0
		list_end = -1
	elseif list_end == nil then
		-- list_start is set an list_end not 
		-- show regions with id = list_start
		list_end = list_start
	end

	-- end < start then change start and end
	if list_end < list_start and list_end ~= -1 then
		local changer = list_end
		list_end = list_start 
		list_start = changer
	end
	
	local stop_list = list_end
	local counter = list_start
		minetest.log("action", "[" .. rac.modname .. "] rac:command_show - list_start: "..tostring(list_start)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:command_show - list_end: "..tostring(list_end)	)

	-- get all regions in AreaStore()
	while rac.rac_store:get_area(counter) do
		minetest.log("action", "[" .. rac.modname .. "] rac:command_show - counter: "..tostring(counter)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:command_show - stop_list: "..tostring(stop_list)	)
	
		
		if counter <= stop_list or stop_list < 0 then
			local err,data = rac:get_region_datatable(counter)
			minetest.log("action", "[" .. rac.modname .. "] rac:command_show - counter: "..tostring(counter)	)
			minetest.log("action", "[" .. rac.modname .. "] rac:command_show - err: "..tostring(err)	)
			minetest.log("action", "[" .. rac.modname .. "] rac:command_show - data: "..tostring(minetest.serialize(data) )	)
			if err > 0 then
				rac:msg_handling(err,func_name)
			else
				-- baue die Ausgaben zusammen
				-- was soll da rein?
				-- id, playername, Name der Region, pvp, mpv?
				stacked_zone = rac:get_stacked_zone_as_string(counter)
				chat_string = chat_string.."\n ID: "..tostring(counter).." "..data.region_name.." ("..data.owner..") ".." pvp - "..tostring(data.pvp).." mvp - "..tostring(data.mvp).." Zonen: "..stacked_zone
			end 
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while rac.rac_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string_start..chat_string..".")
	return 0
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_pos(name,pos,edge,set_entity)
-- privileg: region_set
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region pos1' or 'region pos2'
-- setze pos1 und pos2 und bereite alles für den region set [region_name} vor
--
--
-- input:
--		name 	(string) 	of the player
--		pos 	(table)		of the player
-- 		edge	(number)	1, 2 for the edges
--		set_entity			als Boolean, default = true
--
-- return:
--		0 		wenn alles OK
-- msg/error handling: yes
-- return err if privileg is missing
-- return 0 - no error
function rac:command_pos(name,pos,edge,set_entity)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:command_pos - Version: "..tostring(func_version)	)
	end
	if set_entity == nil then
		set_entity = true
	end
	
	-- check privileg
		-- Wer darf was machen?	
	local player = minetest.get_player_by_name(name)
	if not player then 
		return 42 -- [42] = "ERROR: func: rac:command_pos - kein Spieler mit dem Namen gefunden",
	end 
	local can_modify = rac:player_can_modify_region_id(player)
	if can_modify.admin or can_modify.set then
		if edge == 1 then	
			if not rac.command_players[name] then
				rac.command_players[name] = {pos1 = pos}
			else
				rac.command_players[name].pos1 = pos
			end
			minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
			if set_entity then 
				rac.markPos1(name)
			end
		elseif edge == 2 then
			if not rac.command_players[name] then
				rac.command_players[name] = {pos2 = pos}
			else
				rac.command_players[name].pos2 = pos
			end
			minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
			if set_entity then 
				rac.markPos2(name)
			end
		end
		return 0
	else
	--	rac:msg_handling( err, name ) --  message and error handling
		return err
	end

end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_change_owner(param, name, by_function)
-- privileg: region_set, region_admin, 
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region change_owner {id} {playername}
-- input:
--		param 	(string) ist ein String mit einem Leerzeichen
--											value[1] ist die IDm value[2] der neue Name
--		name 	(string) 	of the player
-- 		by_function as boolean		falls die Funktion von einer anderen Funktion aufgerufen wird.
--	
-- msg/error handling:
-- return 		[69] = "ERROR: func: rac:can_player_set_region - Dir fehlt das Privileg 'region_set! ",
-- return err = return from region_set_attribute
-- return 		[70] = "msg: Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_change_owner(param, name, by_function)
	local func_version = "1.0.0"
	local func_name = "rac:command_change_owner"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err = 0 -- alles ok
	local value
	-- check privileg
	-- wenn der Aufruf mit by_function kommt muss nicht nach privs geschaut werden
	-- ein "Käufer" eines Plot muss nicht zwingend das recht haben
	if by_function ~= true then
		local can_modify = rac:player_can_modify_region_id(player)	
		if can_modify.admin == false and can_modify.set == false then 
			return 69 --	[69] = "ERROR: func: rac:can_player_set_region - Dir fehlt das Privileg 'region_set! ",
		end
	end
	-- get the args after change_owner
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	if by_function ~= true then
		value = string.split(param:sub(13, -1), " ") --13 "change_owner"
	else
		value = string.split(param, " ") 
	end
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, rac.error_msg_text[70] )
		return 70 -- [70] = "msg: Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = rac:region_set_attribute(name, value[1], "owner", value[2]) 
		--rac:msg_handling(err, name) --  message and error handling
	end
	return err
end



-----------------------------------------
--
-- command mark
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region mark' 
-- Select positions by punching two nodes.
-- input:
-- 		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 36 - no error: "msg: Select positions by punching two nodes."
function rac:command_mark(param, name)
	-- check privileg
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- set set_command for the registered punchnode to pos1
	rac.set_command[name] = "pos1"
	return 36
end

-----------------------------------------
--
-- command max_y
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region max_y'
-- modifies y1 and y2 to 90% of max_height
-- input:
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function rac:command_max_y(name)

	-- check privileg
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	if not rac.command_players[name] or not rac.command_players[name].pos1 then
		minetest.chat_send_player(name, "Position 1 missing, use \"/region pos1\" to set.")
	elseif not rac.command_players[name].pos2 then
		minetest.chat_send_player(name, "Position 2 missing, use \"/region pos2\" to set.")
	else
		local pos1 = rac.command_players[name].pos1
		local pos2 = rac.command_players[name].pos2
		minetest.chat_send_player(name, "Position 1 = "..minetest.serialize(pos1))
		minetest.chat_send_player(name, "Position 2 = "..minetest.serialize(pos2))
		-- find the down and upper edge		
		-- what is missing to 90% of maximum_height?
		local y_diff =  math.abs(rac.maximum_height * 0.9) - math.abs(pos1.y - pos2.y) 
		-- 1/3 to the down
		local y_min = math.abs(y_diff / 3)
		-- 2/3 into the sky
		local y_max = y_diff - y_min
		minetest.chat_send_player(name, "y_diff = "..minetest.serialize(y_diff))
		-- a max_height check is not necessary. if the region is to height the min and max will be reduced
		if pos1.y < pos2.y then
			pos1.y = pos1.y - y_min
			pos2.y = pos2.y + y_max
		else
			pos1.y = pos1.y + y_max
			pos2.y = pos2.y - y_min
		end
		rac.command_players[name] = { pos1 = pos1, pos2 = pos2 }
		minetest.chat_send_player(name, "after maximum: Position 1 = "..minetest.serialize(pos1))
		minetest.chat_send_player(name, "after maximum: Position 2 = "..minetest.serialize(pos2))

		minetest.chat_send_player(name, "The height of pos1/pos2 is modified!")
	end
	return 0
end


-----------------------------------------
--
-- command own
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region own'
-- sends the player a list with all his regions
-- input:
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err - no error / rac:command_player_regions(header,name)
function rac:command_own(name)
	local header = "own"
	-- check privileg
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	err = rac:command_player_regions(header,"player "..name, name)
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_set(param, name) command set
-- privileg: region_set
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- claime ein Gebiet,
-- pos1, pos2 und region_name sind nötig
-- owner wird automatisch gesetzt, der Rest über rac_guide
-- pos1 und pos 2 stecken in
--		rac.command_players[name].pos1
--		rac.command_players[name].pos2
--  
-- input:
--		param 	(string) 	Name der Region
--		name 	(string) 		Name des Player
--
-- return:
-- 	0			alles OK
--	err aus anderen Funktionen
-- 	return 43 -- [43] = "ERROR: func: rac:command_set - kein Spieler mit dem Namen gefunden",
--	return 44 --	[44] = "ERROR: func: rac:command_set - Dir fehlt das Privileg 'region_set! ",
--
-- msg/error handling: yes
-- checke priv, player
function rac:command_set(param, name) 
	local func_version = "1.0.0"
	local func_name = "rac:command_set"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end

	local err = 0 
	local zone_table
	local region_data_string,data
	local pos1,pos2
	-- check privileg
	-- Wer darf was machen?	
	local player = minetest.get_player_by_name(name)
	if not player then 
		return 43 -- [43] = "ERROR: func: rac:command_set - kein Spieler mit dem Namen gefunden",
	end 
	
	local can_modify = rac:player_can_modify_region_id(player)
	if can_modify.admin or can_modify.set then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Erlaubnis zum Claimen - can_modify.admin "..tostring(can_modify.admin)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Erlaubnis zum Claimen - can_modify.set "..tostring(can_modify.set)	)
		-- passen den region_name an
		local region_name = param:sub(5, -1)
		
		-- prüfe pos1 und pos2
		if not rac.command_players[name] or not rac.command_players[name].pos1 then
			minetest.chat_send_player(name, "Position 1 missing, use \"/region pos1\" to set.")
			rac:msg_handling(64,func_name) -- [64] = "ERROR: func: command_set  - Pos1 fehlt",
			return 64
		elseif not rac.command_players[name].pos2 then
			minetest.chat_send_player(name, "Position 2 missing, use \"/region pos2\" to set.")
			rac:msg_handling(65,func_name) -- [65] = "ERROR: func: command_set  - Pos2 fehlt",
			return 65
		elseif string.len(region_name) < 1 then
			minetest.chat_send_player(name, "Region_name zu kurz!")
			rac:msg_handling(66,func_name) -- [66] = "ERROR: func: command_set  - region_name zu kurz",
			return 66
		elseif string.len(region_name) > 20 then
			minetest.chat_send_player(name, "Region_name zu lang!")
			rac:msg_handling(71,func_name) -- [71] = "ERROR: func: command_set - region_name zu lang!",
			return 71		
		end
		-- Prüfung, darf man hier setzen?
		-- Darf der Spieler oder der Admin hier etwas setzen?
		--			zone_table = {
		--						player=false, 					-- false = admin, true = Player
		--						plot_id = nil,					-- die ID des Plots, damit ein Player ihn ownen kann
		--						plot = true, 						-- kann nur von admin gesetzt werden
		--						city = true, 						-- kann nur von admin gesetzt werden
		--						outback = true, 				-- kann nur von admin gesetzt werden 
		err,zone_table = rac:can_player_set_region(rac.command_players[name].pos1,rac.command_players[name].pos2, name)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - err: "..tostring(err)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - admin_table.player: "..tostring(zone_table.player)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - admin_table.plot_id: "..tostring(zone_table.plot_id)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - admin_table.plot: "..tostring(zone_table.plot)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - admin_table.city: "..tostring(zone_table.city)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - admin_table.outback: "..tostring(zone_table.outback)	)

					-- Fehlerbehandlung 
		if type(err) ~= "boolean" then
			return err
		end
		-- err kann nur noch true oder false sein!
		if err == false then
			return 44 --	[44] = "ERROR: func: rac:command_set - Dir fehlt das Privileg 'region_set! ",
		end
		-- err kann nur noch true sein!
							
		-- setzte die Werte, unbekannte Werte = default
		local owner = name
		-- region_name wurde übergeben"
		local claimable = rac.region_attribute.claimable
		local zone = "owned" -- wenn ein Spieler claimed dann ist es immer owned
		local protected = true
		local guests_string = rac.region_attribute.guests
		local pvp = rac.region_attribute.pvp
		local mvp = rac.region_attribute.mvp
		local effect = rac.region_attribute.effect
		local do_not_check_player = true -- der Spieler muss nicht überprüft werden


		-- der Spieler darf die Region setzen
		-- der Admin darf setzen
		-- prüfe Spieler
		if zone_table.player then
			-- falls keine Plot_id übergeben wurde
			if zone_table.plot_id == nil then
				-- erzeuge den datastring
				claimable = false
				-- rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
				err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect)
				-- wenn err > 0 return err  
				if err > 0 then
					minetest.log("action", "[" .. rac.modname .. "] can not create data!" ) 
					return err -- rac:msg_handling(err) 
				else
					rac:set_region(rac.command_players[name].pos1,rac.command_players[name].pos2,region_data_string)
					minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< angelegt!")
				end
			end -- if zone_table.plot_id == false then
			if type(zone_table.plot_id) == "number" then
				-- überschreibe die Region mit der ID zone_table.plot_id an den Player
				-- muss man handisch machen, da der player nicht admin ist!
				local by_function = true
				--err = rac:command_change_owner(zone_table.plot_id.." "..name, name, true,by_function)
				--rac:region_set_attribute(name, id, region_attribute, value, bool,by_function)
				err = rac:region_set_attribute(name, zone_table.plot_id, "owner", name, false,by_function)
				--err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect)
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - err = "..tostring(err)	)
				if err == 0 then
					-- Player ist owner der Region
					-- passe zone an 				zone = owned
					err = rac:region_set_attribute(name, zone_table.plot_id, "zone", "owned")
					if err == 0 then			
						-- passe claimable an		claimable = false
						err = rac:region_set_attribute(name, zone_table.plot_id, "claimable", false)
						err = rac:region_set_attribute(name, zone_table.plot_id, "protected", true)
						minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< in Besitz genommen!")
					end
				end
				return err								
			end  -- if zone_table.plot_id == false then
		else -- if zone_table.player then
			-- es ist der admin
			-- es könne folgende Fälle vorkommen:
			-- outback,city,plot
			if zone_table.outback then
				zone = "outback"
			elseif zone_table.city then
				zone = "city"
			else 
				zone = "plot"
			end
			-- erzeuge den Datastring
			claimable = false
			-- rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
			err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect)
			if err > 0 then
				minetest.log("action", "[" .. rac.modname .. "] can not create data!" ) 
				return err -- rac:msg_handling(err) 
			else
				rac:set_region(rac.command_players[name].pos1,rac.command_players[name].pos2,region_data_string)
				minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< angelegt!")
			end
			
		end	 -- if zone_table.player then
	end -- if can_modify.admin or can_modify.set then	
end



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_compass(param, name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- aktiviere den Compass zur Region
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- return:
--	0			wenn ferig
--	err 	wenn rac:get_region_data_by_id(region_id) einen error liefert
--	74			[74] = "ERROR: func: command_compass - keine ID übergeben!",
--	75			[75] = "ERROR: func: command_compass - Dir fehlt das Privileg region_admin!",
-- msg/error handling: no
function rac:command_compass(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_compass"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local player = minetest.get_player_by_name(name)
	if not player then 
		return 43 -- [43] = "ERROR: func: rac:command_set - kein Spieler mit dem Namen gefunden",
	end 
	
	local can_modify = rac:player_can_modify_region_id(player)
	if not can_modify.admin then
		minetest.chat_send_player(name, "Dir fehlt das Privileg region_admin!")
		return 75 -- 		[75] = "ERROR: func: command_compass - Dir fehlt das Privileg region_admin!",
	end
	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - param: "..tostring(param)	)
	local region_id = param:sub(8, -1)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - number: "..tostring(region_id)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - type(number): "..tostring(type(region_id))	)
	region_id = tonumber(region_id)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - type(number): "..tostring(type(region_id))	)
	if region_id == nil then
		minetest.chat_send_player(name, "compass hat keine ID übergeben bekommen!")
		return 74 -- 		[74] = "ERROR: func: command_compass - keine ID übergeben!",
	end
	
	-- gibt es diese Regions ID
	local err,pos1, pos2, data = rac:get_region_data_by_id(region_id)
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	else
		if rac.compass_players[name] == nil then
			rac.compass_players[name] = { name = {} }
		end
		rac.compass_players[name] = {
			active = true,
			region_id = region_id,
			}
	end
	return err
end

-----------------------------------------
--
-- command remove
-- privileg: region_mark for own region
-- privileg: region_admin for regions by ID or all regions
--
-----------------------------------------
-- called: 'region remove {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function rac:command_remove(param, name)
	-- check privileg
	local func_version = "1.0.0"
	local func_name = "rac:command_remove"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	
	--- ??? muss das?
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err,func_name, name ) --  message and error handling
		return err
	end
	local id = tonumber(param:sub(8, -1))
	local data
	if id ~= nil then
		if rac.rac_store:get_area(id) then
			err,data_table = rac:get_region_datatable(id)
			if err ~= 0 then
				rac:msg_handling(err,func_name)
			end
			if name == data_table.owner or minetest.check_player_privs(name, { region_admin = true }) then
				-- make a backup of all region, use date
				local backup = rac.backup_file_name..(os.date("%y%m%d_%H%M%S")..".dat" )
				err = rac:export(backup)
				if err then
					rac:delete_region(id)
					minetest.chat_send_player(name, "The region with ID: "..tostring(id).." was removed!")	
				end
			else
				minetest.chat_send_player(name, "You are not the owner of the region with the ID: "..tostring(id).."!")
			end
		else
			minetest.chat_send_player(name, "There is no region with ID: "..tostring(id).."!")					
		end
	elseif param:sub(8, -1) == "all" and minetest.check_player_privs(name, { region_admin = true }) then
		-- make a backup of all region, use date
		local backup = rac.backup_file_name..(os.date("%y%m%d_%H%M%S")..".dat" )
		err = rac:export(backup)
		minetest.log("action", "[" .. rac.modname .. "] remove all - backupfile = "..backup)
		if err then
			minetest.log("action", "[" .. rac.modname .. "] remove all - backup done!")
			while rac.rac_store:get_area(1) do
				rac:delete_region(1)
			end
			rac.rac_store = AreaStore()
		else
			rac:msg_handling( err, name ) --  message and error handling
		end
	else
		minetest.chat_send_player(name, "Region with the ID: "..tostring(id).." is unknown!")
	end
	return 0
end


-----------------------------------------
--
-- command protect
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region protect {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_protect(param, name)
	-- check privileg
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after protect
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help protect\" for more information.")
		return 21 --"Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = rac:region_set_attribute(name, value[1], "protect", true)
		--rac:msg_handling(err, name) --  message and error handling
	end
	return err
end

-----------------------------------------
--
-- command open
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region open {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_open(param, name)
	-- check privileg
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after open
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(5, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help open\" for more information.")
		return 21 --"Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = rac:region_set_attribute(name, value[1], "protect", false)
		--rac:msg_handling(err, name) --  message and error handling
	end
	return err
end


-----------------------------------------
--
-- command invite player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region invite {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_invite(param, name)
	-- check privileg
	local err = rac:has_region_set(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help invite\" for more information.")
		return 21 -- invalie useage
	else
		local invite = true
		err = rac:region_set_attribute(name, value[1], "guest", value[2], invite)
		--rac:msg_handling(err, name) --  message and error handling
	end
	return err
end

-----------------------------------------
--
-- command ban player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region ban {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_ban(param, name)
	-- check privileg
	local err = rac:has_region_set(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after ban
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help ban\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		local invite = false
		err = rac:region_set_attribute(name, value[1], "guest", value[2], invite)
		--rac:msg_handling(err, name) --  message and error handling
	end
	return err
end





-----------------------------------------
--
-- command pvp +/-
-- privileg: region_pvp
--
-----------------------------------------
-- called: 'region pvp {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_pvp(param, name)
	-- check privileg
	local err = rac:has_region_pvp(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = rac:region_set_attribute(name, value[1], "PvP", true) 
		--rac:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = rac:region_set_attribute(name, value[1], "PvP", false) 
		--rac:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end


-----------------------------------------
--
-- command mvp +/-
-- privileg: region_mvp
--
-----------------------------------------
-- called: 'region mvp {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_mvp(param, name)
	-- check privileg
	local err = rac:has_region_mvp(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
--	elseif value[2] == "+" or value[2] == true or value[2] == "on" then
	elseif value[2] == "+" or value[2] == true or value[2] == "on" then
		err = rac:region_set_attribute(name, value[1], "MvP", true) 
		--rac:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false or value[2] == "off" then 
		err = rac:region_set_attribute(name, value[1], "MvP", false) 
		--rac:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end





-----------------------------------------
--
-- command player 
-- privileg: region_admin *or call by command_status
--
-----------------------------------------
-- called: 'region player <player_name>'
-- sends the player a list of all regions from player_name
-- msg/error handling:
-- return 0 - no error
function rac:command_player_regions(header,param, name)
	local player_name = param:sub(8, -1)
	minetest.log("action", "[" .. rac.modname .. "] command_player_regions param: {" .. tostring(param).."}")
	minetest.log("action", "[" .. rac.modname .. "] command_player_regions param:sub(8,-1): >" .. tostring(player_name).."<")
	local chat_string = ""
	local chat_string_start = "### List of "..player_name.." Regions ###"
	if header == false or header == "own" then
		chat_string_start = ""
	end
	-- no privileg check: header == own then command_player_regions is called by command_own 
	-- else privileg region_admin 
	local err = minetest.check_player_privs(name, { region_admin = true })
	if header ~= "own" then
		if not err then 
			return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
		end	 
	end
	-- check if player_name exists
	if not minetest.player_exists(player_name) then --player then
		return 9 -- "ERROR: There is no Player with this name! func: rac:region_set_attribute(name, id, region_attribute, value)",
	end	
		
	local counter = 1

	-- get all regions in AreaStore()
	while rac.rac_store:get_area(counter) do
		-- only look for player_name as owner
		if rac:get_region_attribute(counter, "owner") == player_name then
			err = rac:get_data_string_by_id(counter)
			if type(err) ~= "string" then
				return err
			else
				chat_string = chat_string..err
			end 
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while rac.rac_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string_start..chat_string..".")
	return 0
end








-----------------------------------------
--
-- command plot +/-
-- privileg: region_admin
--
-----------------------------------------
-- called: 'region plot {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
-- return err form minetest.check_player_privs(name, { region_admin = true })
function rac:command_plot(param, name)
	-- check privileg
	local err = minetest.check_player_privs(name, { region_admin = true })
	if not err then 
		return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
	end	 
		
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(5, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] command_plot! inputvalue param = "..tostring(param).." name = "..name )  
	minetest.log("action", "[" .. rac.modname .. "] command_plot! value = "..tostring(value) )  
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region plot\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = rac:region_set_attribute(name, value[1], "plot", true) 
		--rac:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = rac:region_set_attribute(name, value[1], "plot", false) 
		--rac:msg_handling(err, name) --  message and error handling
	else	
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help plot\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end

-----------------------------------------
--
-- command city ID +/-
-- privileg: region_admin
--
-----------------------------------------
-- called: 'region city {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
-- return err form minetest.check_player_privs(name, { region_admin = true })
function rac:command_city(param, name)
	-- check privileg
	local err = minetest.check_player_privs(name, { region_admin = true })
	if not err then 
		return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
	end	 
		
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(5, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] command_city! inputvalue param = "..tostring(param).." name = "..name )  
	minetest.log("action", "[" .. rac.modname .. "] command_city! value = "..tostring(value) )  
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region city\" for more information.")
	elseif value[2] == "+" or value[2] == true or value[2] == "on" then
		err = rac:region_set_attribute(name, value[1], "city", true) 
		--rac:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false or value[2] == "off" then 
		err = rac:region_set_attribute(name, value[1], "city", false) 
		--rac:msg_handling(err, name) --  message and error handling
	else	
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help city\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end


-----------------------------------------
--
-- command effect
-- privileg: region_effect
--
-----------------------------------------
-- called: 'region effect {id} {effect}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_effect(param, name)
	-- check privileg
	local err = rac:has_region_effect(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after effect
	-- value[1]: it must be an id of an region 
	-- value[2]: must be the effect
	local value = string.split(param:sub(7, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help effect\" for more information.")
		return 21 -- invalie useage
	else
		-- check effect is in rac.region_effects
		if not rac:string_in_table(value[2], rac.region_effects) then
			return 31 -- "ERROR: The effect dit not fit! ",
		end
		err = rac:region_set_attribute(name, value[1], "effect", value[2])
	end
	return err
end


-----------------------------------------
--
-- Check Privilegs
--
-----------------------------------------
--
--
-----------------------------------------
--
-- player has_region_mark
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 16 - for error
function rac:has_region_mark(name)
	if minetest.check_player_privs(name, { region_mark = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 16 -- "You dont have the privileg 'region_mark' "
end
-----------------------------------------
--
-- player has_region_set
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 17 - for error
function rac:has_region_set(name)
	if minetest.check_player_privs(name, { region_set = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 17 -- "You dont have the privileg 'region_set' "
end
-----------------------------------------
--
-- player has_region_pvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 18 - for error
function rac:has_region_pvp(name)
	if minetest.check_player_privs(name, { region_pvp = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 18 -- "You dont have the privileg 'region_pvp' "
end
-----------------------------------------
--
-- player has_region_mvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string-- msg/error handling: 
-- return true
-- return 19 - for error
function rac:has_region_mvp(name)
	if minetest.check_player_privs(name, { region_mvp = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 19 -- "You dont have the privileg 'region_mvp' "
end
-----------------------------------------
--
-- player has_region_mvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string-- msg/error handling: 
-- return true
-- return 19 - for error
function rac:has_region_effect(name)
	if minetest.check_player_privs(name, { region_effect = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 33 -- "You dont have the privileg 'region_effect' "
end

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
	local func_name = "rac:command_help"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	-- darf der user interacten?
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 	40 -- [40] = "ERROR: func: rac:command_help - Dier fehlt das Privileg 'interact'!",
	end
	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." param: "..tostring(param)) 
	
	local value = string.split(param, " ") 
	-- value[1] == 'help'
	local command = value[2]
	if command == nil then command = " ..' und das Command das dich interessiert" end
	local chat_start = "Call command '/region "..command  
	local chat_end 
	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." command: >"..tostring(command).."<"	)
	
	if command == "help" and value[1] == "help" then
		chat_end = chat_start.." {command}' um mehr Infos zu dem Command zu erhalten. [privileg: interact]"
	elseif command == "guide" then
		chat_end = chat_start.."' zeigt den rac-guide zur Verwaltung der Regionen an. [privileg: interact]"
	elseif command == "status" then
		chat_end = chat_start.."' zeigt wichtige Infos zur Region an dieser Position. . [privileg: interact]"
	elseif command == "own" then
		chat_end = chat_start.."' zeige eine Liste deiner Regionen. [privileg: region_set]"
	elseif command == "pos1" then
		chat_end = chat_start.."' setzte Position 1. Gehe an eine Ecke deines Gebietes und rufe  \'region pos1\', "..
			"\n auf, gehen zur gegenüberliegenden Ecke und nutze \'region pos2\'. Anschließend mit \'region set {region_name}\' claimst du das Gebiet. [privileg: region_set]"
	elseif command == "pos2" then
		chat_end = chat_start.."' setzte Position 2. Gehe an eine Ecke deines Gebietes und rufe  \'region pos1\', "..
			"\n auf, gehen zur gegenüberliegenden Ecke und nutze \'region pos2\'. Anschließend mit \'region set {region_name}\' claimst du das Gebiet. [privileg: region_set]"
	elseif command == "set"	then
		chat_end = chat_start.." {region_name}' Wurden pos1 und pos2 gesetzt, kann man jetzt mit \'region set {region_name}\' das Gebiet claimen. [privileg: region_set]"..
			"\nTipp: anschließend über den Rac-Guide die Region anpassen." 
	elseif command == "max_y" then
		chat_end = chat_start.."'  Setze die Region {id} auf max Höhe, 1/3 nach unten, 2/3 nach oben. 'region max_y {id}' [privileg: region_set]"..
			"\nDer region_admin kann auch einen Wert angeben, dieser wird dann nach 1/3-2/3 aufgeteilt und verwendet."
	elseif command == "border" then
		chat_end = chat_start.."' um dein Gebiet an dieser Position sichtbar zu machen. [privileg: interact]"..
			"\nDer region_admin kann mit '/region border' alle Regionen an dieser Stelle sichtbar machen. [privileg: region_admin]"..
			"\nDer region_admin kann mit '/region border {id}' die Region mit der ID sichtbar machen. [privileg: region_admin]"
	elseif command == "change_owner" then
		chat_end = chat_start.."' Der Besitzer einer Region kann mit '/region change_owner {id} {neuer Besitzer}' seine Region an einen anderen übertragen."..
			"\nDer region_admin kann alle Regionen an andere Besitzer übertragen"
	elseif command == "show" then
		chat_end = chat_start.."' [privileg: region_admin] mit 'region show' gibt es eine Liste mit Infos zu alle Regionen,"..
			"\nmit 'region show {id}' gibt es Infos zu dieser ID"..
			"\nmit 'region show {name}' gibt es Infos zu den Regionen dieses Spielers."
	elseif command == "compass" then
		chat_end = chat_start.."' [privileg: region_admin] Mit 'region compass {id}' zeigt das Hud mittels rechts/links an, in welcher Richtung die Region ist." 
	elseif command == "export" then
		chat_end = chat_start.."' Exportiere den AreaStore in ein file! [privileg: region_admin]"
	elseif command == "import" then
		chat_end = chat_start.."' Importiere den AreaStore von dem file! [privileg: region_admin]"
	elseif command == "player" then
		chat_end = chat_start.." {player_name}' zeige eine Liste aller Regionen einser Spielers! [privileg: region_admin]"..
			"\nist identische zu 'region show [player_name}'"
	elseif command == "remove" then
		chat_end = chat_start.." [privileg: region_admin] - mit 'region remove {id}' wird diese Region gelöscht."..
			"\nMit 'region remove all' werden ALLE Regionen gelöscht."
	elseif command == "list" then
		chat_end = chat_start.." [privileg: region_admin] - 'region list' zeigt eine Liste aller Regionen, sortiert nach outback,city,.."..
			"\nMit 'region list full' zeigt die Liste zusätzlich den Besitzer, die ID, den Region_Name und die 'Zustände' wie protected, claimable, pvp und mvp Status."
	elseif command == "pvp" then
		chat_end = chat_start.." [privileg: region_admin] - 'region pvp {id} {true/false}' aktiviert/deaktiviert das PvP für diese Region"
	elseif command == "mvp" then
		chat_end = chat_start.." [privileg: region_admin] - 'region mvp {id} {true/false}' aktiviert/deaktiviert den Monsterschaden für diese Region"
	elseif command == "claimable" then
		chat_end = chat_start.." [privileg: region_admin] - 'region claimable {id} {true/false}' aktiviert/deaktiviert das claimable für diese Region"
	elseif command == "protect" then
		chat_end = chat_start.." [privileg: region_admin] - 'region protect {id} {true/false}' aktiviert/deaktiviert den Schutz diese Region"
	elseif command == "effect" then
		chat_end = chat_start.." [privileg: region_admin] - 'region effect {id} {effect} {add/delete}' setzt oder löscht den {effect} für diese Region"
	elseif command == "change_zone" then
		chat_end = chat_start.." [privileg: region_admin] - 'region change_zone {id} {new Zone}' setzt den Zonen-Bezeichner der Region. Erlabute Zonen: outback, city, plot, owned."
	elseif command == "rename" then
		chat_end = chat_start.." [privileg: region_admin] - 'region rename {id} {neuer Name}' benennt die Region um."
	elseif command == "set_min" then
		chat_end = chat_start.." [privileg: region_admin] - 'region set_min {id} {x,y,z}' setzt die Min-Position der Region auf {x,y,z}."		
	elseif command == "set_max" then
		chat_end = chat_start.." [privileg: region_admin] - 'region set_max {id} {x,y,z}' setzt die Min-Position der Region auf {x,y,z}."			

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
	local func_name = "rac:command_status"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local chat_string
	
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 56 --[56] = "ERROR: func: rac:command_status - Dir fehlt das Privileg 'interact'!",
	end
	local once = true
	local header = "status"  
	local stacked_zone_string
	local this_zone_count, region_id
	local counter = 1
	-- welche Regionen sind an dieser Position?
	-- welche zählt?
	-- was sind ihre Einstellungen
	-- Ausgabe: eine - drei Zeilen die Werte der letzten
	--					ID - outback - Owner 
	--					ID - city - Owner
	--					ID plot/owned - Owner
	--	 - protected,pvp,mvp,
	
	for region_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
		if region_id then
			if once then 
				once = false
				stacked_zone_string = rac:get_stacked_zone_as_string(region_id)
				this_zone_count = region_id
				minetest.chat_send_player(name, "### Liste der Regionen an dieser Position ###")
			end
			-- call command_show (without header!)
			err = rac:command_show(header, name,region_id,nil)
			rac:msg_handling(err,func_name)
			counter = counter + 1	
		end -- end if regions_id then
	end -- end for regions_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - counter: "..tostring(counter)	)
	-- es wurde kein Gebiet gefunden!
	if counter == 1 then
		chat_string = rac.wilderness.name.." Besitz von "..rac.wilderness.owner.." ".." pvp ("..tostring(rac.wilderness.pvp).."), mvp ("..tostring(rac.wilderness.mvp).."),"
		chat_string = chat_string.." claimable ("..tostring(rac.wilderness.claimable)..")"
		minetest.chat_send_player(name, rac.wilderness.text_wilderness.."\n"..chat_string)
	end
	if once == false then
		minetest.chat_send_player(name, "Gebiete: "..stacked_zone_string)
		rac:msg_handling(err,func_name)
		-- this_zone_count holen
		-- und anzeigen
		if region_id ~= nil then
			chat_string = "Diese Gebiet zählt: "..tostring(this_zone_count)
		else
			chat_string = ""
		end
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - "..chat_string	)
	end
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

	local value = string.split(param:sub(7, -1), " ") 
	
	if rac.debug_level <= rac.debuf.info then
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border ID = can_modify.admin = {"..tostring(can_modify.admin).."}" ) 
		-- get values of param
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border param = "..tostring(param) ) 
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border value = "..tostring(value) ) 
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border #value = "..tostring(#value) ) 
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border value[1] = "..tostring(value[1]) ) 
	end
	
	if value[1] ~= nil then
		region_id = tonumber(value[1])
	end	
	if rac.debug_level <= rac.debuf.info then
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border ID = value[1] = "..tostring(value[1]) ) 	
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border region_id = "..tostring(region_id) ) 
	end
	 
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
--				minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border k = "..tostring(region_id) )  
				rac:draw_border(region_id)	
			end
		end
	end
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
-- 	header									false/status/stacked_zone
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
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - header: "..tostring(header)	)	
	end
--	local region_values = {}
--	local pos1 = ""
--	local pos2 = ""
--	local data = ""
	local stacked_zone = ""
	local chat_string = ""
	local chat_string_start = "### List of Regions ### "
	if header == false or header == "status" then
		chat_string_start = ""
	end
	local position -- Für die Ausgabe der min/max Werte der Region
	
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
			--local err,data = rac:get_region_datatable(counter)
			local err, min,max,data = rac:get_region_data_by_id(counter,false)
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
				if can_modify.admin then
					position = " Min ("..tostring(min)..") Max ("..tostring(max)..") "
				else
					position = ""
				end
				if header == "status" then
					chat_string = chat_string.."ID: "..tostring(counter).." "
				else
					chat_string = chat_string.."\n ID: "..tostring(counter).." "
				end
				chat_string = chat_string..data.region_name.." ("..data.owner..")".." Schutz ("..tostring(data.protected)..")\n"..
					" pvp ("..tostring(data.pvp).."), mvp ("..tostring(data.mvp)..")"..
					" claimable ("..tostring(data.claimable)..")"..
					"\n Zonen: "..stacked_zone..position
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
--				wenn true, dann wird eine Block_node 1 oder 2 an der Stelle angezeigt
--
-- return:
--		0 		wenn alles OK
-- msg/error handling: yes
-- return err if privileg is missing
-- 		[108] = "ERROR: func: rac:command_pos - kein ausreichendes Privileg",
-- return 0 - no error
function rac:command_pos(name,pos,edge,set_entity)
	local func_version = "1.0.0"
	local func_name = "rac:command_pos"
	if rac.show_func_version and rac.debug_level  <=  rac.debug.info then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	if set_entity == nil then
		set_entity = true
	end
	local err
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
	else -- if can_modify.admin or can_modify.set then
		-- kein admin , kein can_modify.set
	--	rac:msg_handling( err, name ) --  message and error handling
		err = 108 -- 		[108] = "ERROR: func: rac:command_pos - kein ausreichendes Privileg",
		rac:msg_handling(err,func_name,name)
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
		local can_modify = rac:player_can_modify_region_id(name)	
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

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_max_y(name,region_id,new_y)
-- privileg: region_admin, oder own region
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region max_y'
-- modifies y1 and y2 to 90% of max_height
--
-- input:
--		name 	(string) 	of the player
--		region_id 			region_id die angepasst werden soll
--		new_y					admin_only - wenn height gesetzt, wird die region so hoch, Verhältnis 1:2
--
-- return:
--		0 			alle Ok
--		return 79 --		[79] = "ERROR: func: rac:command_max_y - Keine ID angegeben. '/region max_y ID'",
--		return 80 --		[80] = "info: func: rac:command_max_y - Du bist nicht der Besitzer",
--		return 81 -- 		[81] = "info: func: rac:command_max_y - keine Admin-Berechtigung",
--		return 82 -- 		[82] = "info: func: rac:command_max_y - diese Region hat schon die maximale Höhe!",
--		return 83 --		[83] = "info: func: rac:command_max_y - Diese Region kann nicht so hoch / tief werden!",
--
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function rac:command_max_y(name,region_id,new_y)
	local func_version = "1.0.0"
	local func_name = "rac:command_max_y"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(type(region_id))	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - new_y: "..tostring(new_y)	)		
	
	-- es wurde kein region_id angeben.
	-- melde error.
	if region_id == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." keine ID -> FEHLER"	)		
		rac:msg_handling(79,func_name,name)
		return 79 --		[79] = "ERROR: func: rac:command_max_y - Keine ID angegeben. '/region max_y ID'",
	else
		region_id = tonumber(region_id)
	end
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - nach tonumber: region_id: "..tostring(region_id)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(type(region_id))	)		
	
	-- prüfe Berechtigung
	-- wenn owner ein error, dann ist owner eine Zahl
	local owner =  rac:get_region_attribute(region_id, "owner")
	if tonumber(owner) ~= nil then 
		rac:msg_handling(tonumber(owner),func_name,name)
		return tonumber(owner)
	end

	-- get privileg
	local can_modify = rac:player_can_modify_region_id(name)	
	local owner = rac:get_region_attribute(region_id, "owner")
	-- ist name = owner -> weiter
	-- ist can_modify.set oder can.modify.admin --> weiter
	if not can_modify.admin then
		if owner ~= name then
			return 80 --	[80] = "info: func: rac:command_max_y - Du bist nicht der Besitzer",
		end
		return 81 -- 		[81] = "info: func: rac:command_max_y - keine Admin-Berechtigung",
	end
	
	-- hole die zone, damit man den max_y Wert hat.
	local zone =  rac:get_region_attribute(region_id, "zone")
	if new_y == nil then
		new_y = rac.maximum_height[zone]
	else
		new_y = tonumber(new_y)
	end
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone: "..tostring(zone)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - new_y: "..tostring(new_y)	)		
	
	
	-- hole die Ecken der Region
	local err,pos1, pos2, data_table = rac:get_region_data_by_id(region_id)
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	end
	-- welcher Wert ist unten, setzen min und max
	local min, max
	if pos1.y < pos2.y then
		min = pos1
		max = pos2
	else
		max = pos1
		min = pos2
	end
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Vor der Veränderung - min: "..tostring(min)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Vor der Veränderung - max: "..tostring(max)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Vor der Veränderung - new_y: "..tostring(new_y)	)

	-- Prüfen auf max height?
	-- nur bei owner ~= admin
	if (max.y - min.y) > new_y then
		if not can_modify.admin then
			return 82 -- 		[82] = "info: func: rac:command_max_y - diese Region hat schon die maximale Höhe!",
		end
	end
	
	local y_diff =  math.abs( (new_y  - math.abs(pos1.y - pos2.y)) / 3 ) 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Vor der Veränderung - y_diff: "..tostring(y_diff)	)
	-- 1/3 to the down
	min.y = min.y - y_diff
	-- 2/3 into the sky
	max.y = max.y + (2 * y_diff)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Nach der Veränderung - min: "..tostring(min)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." Nach der Veränderung - max: "..tostring(max)	)

	-- prüfe das neue Gebiet
	-- wird witergereicht an rac:player_can_create_region(edge1, edge2, name, modify_region_id)
	if rac:can_modify_region(min, max, name, region_id) then
		-- setze die neue Größe
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - min: "..tostring(min)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - max: "..tostring(max)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - name: "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)
		
		err = rac:update_regions_data(region_id,min,max,data_table)
		if err == 0 then
			minetest.chat_send_player(name, "Die Höhe der Region ( "..region_id.." ) wurde angepasst.")
			local header = true
			err = rac:command_show(header,name,tonumber(region_id))
		else
			return err
		end
	else
		-- was tun?
		return 83 --		[83] = "info: func: rac:command_max_y - Diese Region kann nicht so hoch / tief werden!",
	end
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:can_modify_region(min, max, name, region_id) 
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- prüfe ob die angepasste Region sich mit anderen Regionen überlappt
--	Falls ja, dann ist es erlaubt die neue Region so zu setzen?
-- Aufruf von 
-- 	rac:can_player_create_region(edge1, edge2, name, modify_region_id)
--
-- input: 
--		edge1, edge2				as vector (table)
--		name								als String (playername)
--		modify_region_id 		als Nummer / false
-- 
-- return:
--	true		es geht
--	false		es geht nicht
function rac:can_modify_region(edge1, edge2, name, modify_region_id) 
	local func_version = "1.0.0"
	local func_name = "rac:can_modify_region"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local can_set_region,zone_table = rac:can_player_create_region(edge1, edge2, name, modify_region_id)
	
	--	return false,zone_table
	
	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - can_set_region: "..tostring(can_set_region)	)
	return can_set_region
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:command_set_min(param, name, edge) 
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region set_min'
-- Setzte die MIN-Ecke der Region
--
-- input:
--		param 			in param sollte die ID und Koordienate x,y,z stehen
--		name 	(string) 	of the player
--		edge				"min"/"max" entscheidet ob die min-Ecke oder die Max-Ecke verändert wird
--
-- return:
--		err 						von rac:update_regions_data(region_id,min,max,data_table)
--			0							alles OK
-- 		return 100 --		[100] = "info: func: rac:command_set_min - zu wenige Parameter übergeben",
--		return 101 -- 	[101] = "Error: func: rac:command_set_min - min/max wurde nicth übergeben",
--		return 102 -- 	[102] = "Error: func: rac:command_set_min - keine Admin-Berechtigung",
--
-- msg/error handling:
-- 	return 100 -- wenn die Parameter nicht reichen, id und/oder x,y,z fehlt
--	return 0 - no error
function rac:command_set_min(param, name, edge) 
	local func_version = "1.0.0"
	local func_name = "rac:command_set_min"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	-- check privileg
	local can_modify = rac:player_can_modify_region_id(name)
	if not can_modify.admin then
		return 102 -- 		[102] = "Error: func: rac:command_set_min - keine Admin-Berechtigung",
	end
	
	-- baue aus param die x,y,z Werte
	local value = string.split(param:sub(8, -1), " ")
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #value: "..tostring(#value)	)		
	if #value ~= 2 then
		minetest.chat_send_player(name, "Zu wenige Parameter übergeben, use ’/region set_min id x,y,z")
		return 100 --		[100] = "info: func: rac:command_set_min - zu wenige Parameter übergeben",
	end
	local region_id = value[1] 
	
	local value1 = string.split(value[2], ",") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #value1: "..tostring(#value1)	)		
	if #value1 ~= 3 then
		minetest.chat_send_player(name, "Zu wenige Parameter übergeben, use ’/region set_min id x,y,z")
		return 100 --		[100] = "info: func: rac:command_set_min - zu wenige Parameter übergeben",
	end

	local x = tonumber(value1[1])
	local y = tonumber(value1[2])
	local z = tonumber(value1[3])
	
	-- test auf nil
	if x == nil or y == nil or z == nil then
		minetest.chat_send_player(name, "Zu wenige Parameter übergeben, use ’/region set_min id x,y,z")
		return 100 --		[100] = "info: func: rac:command_set_min - zu wenige Parameter übergeben",
	end
	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(param)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - x: "..tostring(x)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - y: "..tostring(y)	)		
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - z: "..tostring(z)	)		
	
	
	-- eigentlich sollten nun die x,y,z Werte stimmen
	-- prüfe nun die region_id
	-- hole die Ecken und Werte der Region
	local err,min, max, data_table = rac:get_region_data_by_id(region_id)
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	end

	
	-- prüfe übergebenen edge, sollte min/max sein
	if edge == "min" then
		min = vector.new(x,y,z)
	elseif edge == "max" then
		max = vector.new(x,y,z)
	else
		return 101 -- 		[101] = "Error: func: rac:command_set_min - min/max wurde nicth übergeben",
	end
	
	err = rac:update_regions_data(region_id,min,max,data_table)
	if err == 0 then
		local header = true
		err = rac:command_show(header,name,tonumber(region_id))
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command own
-- privileg: region_admin / region_set
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region own'
-- sends the player a list with all his regions
-- input:
--		name 	(string) 	of the player
--
-- return err if privileg is missing
-- 		[99] = "info: func: rac:command_own - keine Admin-Berechtigung",
-- 		err - no error / rac:command_player_regions(header,name)
function rac:command_own(name)
	local func_version = "1.0.0"
	local func_name = "rac:command_own"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local header = "own"
	-- check privileg
	local can_modify = rac:player_can_modify_region_id(name)
	if can_modify.admin or can_modify.set then
		err = rac:command_player_regions(header,"player "..name, name)
	else
		return 99 -- 		[99] = "info: func: rac:command_own - keine Admin-Berechtigung",
	end
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





-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command pvp +/-
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region pvp {id} {+/-}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
-- 		return 85 -- 	[85] = "info: func: rac:command_pvp - keine Admin-Berechtigung",
-- 		return 86 -- 	[86] = "info: func: rac:command_pvp - Falscher Aufruf des Command 'region pvp' Tippe \"/region help pvp\" für mehr Informationen.",

function rac:command_pvp(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_pvp"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 85 -- 		[85] = "info: func: rac:command_pvp - keine Admin-Berechtigung",
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)
	
	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
		return 86 --		[86] = "info: func: rac:command_pvp - Falscher Aufruf des Command 'region pvp' Tippe \"/region help pvp\" für mehr Informationen.",

	elseif value[2] == "+" or value[2] == "true" then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "pvp", true) 
		rac:msg_handling(err, func_name) --  message and error handling
	elseif value[2] == "-" or value[2] == "false" then 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] - : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "pvp", false) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
		return 86 --		[86] = "info: func: rac:command_pvp - Falscher Aufruf des Command 'region pvp' Tippe \"/region help pvp\" für mehr Informationen.",
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command mvp +/-
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region mvp {id} {+/-}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
-- 		return 87 -- 	[87] = "info: func: rac:command_mvp - keine Admin-Berechtigung",
-- 		return 88 -- 	[88] = "info: func: rac:command_mvp - Falscher Aufruf des Command 'region mvp' Tippe \"/region help mvp\" für mehr Informationen.",

function rac:command_mvp(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_mvp"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 87 -- 		[87] = "info: func: rac:command_mvp - keine Admin-Berechtigung",
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)
	
	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
		return 88 --		[88 = "info: func: rac:command_mvp - Falscher Aufruf des Command 'region mvp' Tippe \"/region help pvp\" für mehr Informationen.",

	elseif value[2] == "+" or value[2] == "true" then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "mvp", true) 
		rac:msg_handling(err, func_name) --  message and error handling
	elseif value[2] == "-" or value[2] == "false" then 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] - : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "mvp", false) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
		return 88 --		[88] = "info: func: rac:command_mvp - Falscher Aufruf des Command 'region mvp' Tippe \"/region help pvp\" für mehr Informationen.",
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command claimable +/-
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region claimable {id} {+/-}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
--		[89] = "info: func: rac:command_claimable - keine Admin-Berechtigung",
--		[90] = "info: func: rac:command_claimable - Falscher Aufruf des Command 'region claimable' Tippe \"/region help claimable\" für mehr Informationen.",

function rac:command_claimable(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_claimable"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 89
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(10, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)
	
	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help claimable\" for more information.")
		return 90

	elseif value[2] == "+" or value[2] == "true" then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "claimable", true) 
		rac:msg_handling(err, func_name) --  message and error handling
	elseif value[2] == "-" or value[2] == "false" then 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] - : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "claimable", false) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help claimable\" for more information.")
		return 90
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command protected +/-
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region protected {id} {+/-}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
--		[91] = "info: func: rac:command_protected - keine Admin-Berechtigung",
--		[92] = "info: func: rac:command_protected - Falscher Aufruf des Command 'region pvp' Tippe \"/region help pvp\" für mehr Informationen.",

function rac:command_protect(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_protected"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 91
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(8, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)
	
	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help protected\" for more information.")
		return 92

	elseif value[2] == "+" or value[2] == "true" then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "protected", true) 
		rac:msg_handling(err, func_name) --  message and error handling
	elseif value[2] == "-" or value[2] == "false" then 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] - : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "protected", false) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help protected\" for more information.")
		return 92
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command effect {effect}
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region effect {id} {effect}
--	{set_attribut macht den Check des {effects}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
--		[93] = "info: func: rac:command_effect - keine Admin-Berechtigung",
--		[94] = "info: func: rac:command_effect - Falscher Aufruf des Command 'region effect' Tippe \"/region help effect\" für mehr Informationen.",

function rac:command_effect(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_effect"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local add_effect = nil
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 93
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: muss der effect sein
	local value = string.split(param:sub(7, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)
	if value[3] ~= nil then
		if value[3] == "delete" then
			add_effect = false
		elseif value[3] == "add" then
			add_effect = true	
		else
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[3]: "..tostring(value[1])	)
			minetest.chat_send_player(name, "Invalid usage.  Type \"/region help effect\" for more information.")
			return 94
		end
	end
	if value[1] == nil or tonumber(value[1]) == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help effect\" for more information.")
		return 94

	elseif value[2] ~= nil  then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "effect", value[2],add_effect) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help effect\" for more information.")
		return 94
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command change_zone {id} {zone}
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region change_zone {id} {zone}
--	{set_attribut macht den Check der {zone}
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
--		[95] = "info: func: rac:command_change_zone - keine Admin-Berechtigung",
--		[96] = "info: func: rac:command_change_zone - Falscher Aufruf des Command 'region change_zone' Tippe \"/region help effect\" für mehr Informationen.",


function rac:command_change_zone(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_change_zone"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 95
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: muss der effect sein
	local value = string.split(param:sub(12, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)

	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help change_zone\" for more information.")
		return 96

	elseif value[2] ~= nil  then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "zone", value[2]) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help change_zone\" for more information.")
		return 96
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command rename {id} {new name}
-- privileg: region_admin
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region change_zone {id} {new name}
--	{set_attribut macht den Check 
--
-- input:
--		param 	(string)
--		name 	(string) 	of the player
--
-- msg/error handling:
--		[97] = "info: func: rac:command_rename - keine Admin-Berechtigung",
--		[98] = "info: func: rac:command_rename - Falscher Aufruf des Command 'region rename' Tippe \"/region help rename\" für mehr Informationen.",


function rac:command_rename(param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_rename"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 95
	end
	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: muss der effect sein
	local value = string.split(param:sub(7, -1), " ") 
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2]: "..tostring(value[2])	)

	if value[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[1]: "..tostring(value[1])	)
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help rename\" for more information.")
		return 96

	elseif value[2] ~= nil  then
		local region_name =  value[2]
		if #value > 2 then
			for k,v in ipairs(value) do
				if k > 2 then
					region_name = region_name.." "..v
				end
			end
		end
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - value[2] + : "..tostring(value[2])	)
		err = rac:region_set_attribute(name, value[1], "region_name", region_name) 
		rac:msg_handling(err, func_name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help rename\" for more information.")
		return 96
	end
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- command player 
-- privileg: region_admin *or call by command_status
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- called: 'region player <player_name>'
-- Liste der Region dieses Player mit ID, Region_Name, Owner, pvp und mvp Status
--
-- input:
--	header		false, own -> chat_start = ""
--						true -> chat_start mit Überschrift
--						command show -> header wird true, aber playername aus parm - 'show'
--	param
--	name			für den  Player
-- 
-- return:
--	return 77 -- [77] = "ERROR: func: rac:command_player_regions - Dir fehlt das Privileg 'region_admin'!", 		
--	return 78 -- 		[78] = "ERROR: func: rac:command_player_regions - There is no Player with this name!",
--	
-- msg/error handling:
-- return 0 - no error
function rac:command_player_regions(header,param, name)
	local func_version = "1.0.0"
	local func_name = "rac:command_player_regions"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err, data
	local player_name
	if header == "command show" then
		player_name = param:sub(6, -1)
		header = true
	else
		player_name = param:sub(8, -1)
	end
	minetest.log("action", "[" .. rac.modname .. "] command_player_regions param: {" .. tostring(param).."}")
	minetest.log("action", "[" .. rac.modname .. "] command_player_regions param:sub(8,-1): >" .. tostring(player_name).."<")
	local chat_string = ""
	local chat_string_start = "### List of "..player_name.." Regions ###"
	if header == false or header == "own" then
		chat_string_start = "" -- ### Liste der Regionen ###"
	end


	-- no privileg check: header == own then command_player_regions is called by command_own 
	-- else privileg region_admin 
	local can_modify = rac:player_can_modify_region_id(name)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - can_modify.admin: "..tostring(can_modify.admin)	)
	if header ~= "own" and not can_modify.admin then
		return 77 -- [77] = "ERROR: func: rac:command_player_regions - Dir fehlt das Privileg 'region_admin'!", 		
	end
	-- check if player_name exists
	if not minetest.player_exists(player_name) then --player then
		return 78 -- 		[78] = "ERROR: func: rac:command_player_regions - There is no Player with this name!",
	end	
		
	local counter = 1
	local id
-- loop durch alle Regionen
-- wenn owner = player_name dann an den String anhängen
	-- get all regions in AreaStore()
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - fange mit dem loop an."	)
	while rac.rac_store:get_area(counter) do
		-- hole die region data_table
		id = counter - 1
		err,data = rac:get_region_datatable(id)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - err: "..tostring(err).." data.owner = "..tostring(data.owner)	)

		if err == 0 then
			-- only look for player_name as owner
			if data.owner == player_name then
				--  mit ID, Region_Name, Owner, pvp und mvp Status
				chat_string = chat_string.."\n ID  "..tostring(id).." : "..data.region_name.." ("..data.owner..") ".." pvp - "..tostring(data.pvp).." mvp - "..tostring(data.mvp).." Zone: "..tostring(data.zone)
			end 
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while rac.rac_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string_start..chat_string..".")
	return 0
end












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
	
	
	if command == "help" then
		chat_end = chat_start.." {command}' um mehr Infos zu dem Command zu erhalten. [privileg: interact]"
	elseif command == "guide" then
		chat_end = chat_start.."' open the RAC-Guidebook. [privileg: interact]"
--	elseif command == "status" then
--		chat_end = chat_start.."' to get some more infos about the region at your position. [privileg: interact]"
	elseif command == "border" then
		chat_end = chat_start.."' um dein Gebiet sichtbar zu machen. [privileg: interact]"..
			"\nDer region_admin kann mit '/region border {name}' die Region eines Players sicht barmachen. [privileg: region_admin]"
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


-----------------------------------------
--
-- command status
-- privileg: interact
--
-----------------------------------------
-- called: 'region status'
-- sends the player a list with details of the regions
-- input:
--		name 	(string) 	of the player
--		pos 	(table)		of the player
-- msg/error handling: 
-- return 20 --"msg: You don't have the privileg 'interact'! ",
-- return 0	-- no error
function rac:command_status(name,pos)
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 20 --"msg: You don't have the privileg 'interact'! ",		
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
-- owner wird automatisch gesetzt, der rest über rac_guide
-- pos1 und pos 2 stecken in
--		rac.command_players[name].pos1
--		rac.command_players[name].pos2
--  
-- input:
--		param 	(string) 	Name der Region
--		name 	(string) 		Name des Player
--
-- msg/error handling: yes
-- return err if privileg is missing
-- return 0 - no error
function rac:command_set(param, name) 
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:command_set - Version: "..tostring(func_version)	)
	end
	local err = 0 
	local admin_table
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
		local region_name = param:sub(5, -1)
		if not rac.command_players[name] or not rac.command_players[name].pos1 then
			minetest.chat_send_player(name, "Position 1 missing, use \"/region pos1\" to set.")
		elseif not rac.command_players[name].pos2 then
			minetest.chat_send_player(name, "Position 2 missing, use \"/region pos2\" to set.")
		elseif string.len(region_name) < 1 then
			minetest.chat_send_player(name, "please set a name behind set, use \"/region set {region_name}\" to set.")
		else
			-- Darf der Spieler oder der Admin hier etwas setzen?
			err,admin_table = rac:can_player_set_region(rac.command_players[name].pos1,rac.command_players[name].pos2, name)
			-- err = true,false, Nummer der ErrorMsg
			if type(err) == "number" then
				return err
			end
			-- setzte die Werte, ubnbekannte Werte = default
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
			if err == true then
				-- rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
				err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect) 
				if err > 0 then
					minetest.log("action", "[" .. rac.modname .. "] can not create data!" ) 
					rac:msg_handling(err) 
				else
					rac:set_region(rac.command_players[name].pos1,rac.command_players[name].pos2,region_data_string)
					minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< angelegt!")
				end	
			elseif err == false then
				-- darf der Spieler den plot übernehmen
				if admin_table.change_owner then
					zone = "plot"
					claimable = false -- der plot ist nicht mehr claimable 
					err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect) 
					if err > 0 then
						minetest.log("action", "[" .. rac.modname .. "] can not create data!" ) 
						rac:msg_handling(err) 
					else
						err, pos1,pos2,data = rac:get_region_data_by_id(admin_table.plot_id,false)
						rac:msg_handling(err)
						err = rac:update_regions_data(id,pos1,pos2,region_data_string)
						rac:msg_handling(err)
						minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< angelegt!")
					end		
				end
			end
			-- für den Admin
			if can_modify.admin then
				if admin_table.outback == true then
					zone = "outback"
				elseif admin_table.city == true then
					zone = "city"
				else 
					zone = "plot"
				end
				err,region_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect) 			
				if err > 0 then
					minetest.log("action", "[" .. rac.modname .. "] can not create data!" ) 
					rac:msg_handling(err) 
				else
					rac:set_region(rac.command_players[name].pos1,rac.command_players[name].pos2,region_data_string)
					minetest.chat_send_player(name, "Region mit dem Namen >"..region_name.."< angelegt!")
				end	
			end	

			-- lösche die gesetzten Positionen
			rac.command_players[name] = nil
		end
		return 0
	else
		return 44 --	[44] = "ERROR: func: rac:command_set - Dir fehlt das Privileg 'region_set! ",
	end
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
	local err = rac:has_region_mark(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end
	local id = tonumber(param:sub(8, -1))
	if id ~= nil then
		if rac.rac_store:get_area(id) then
			local data_table = rac:get_region_datatable(id)
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
-- command change_owner id player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region change_owner {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function rac:command_change_owner(param, name)
	-- check privileg
	local err = rac:has_region_set(name)
	if err ~= true then
		rac:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after change_owner
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(13, -1), " ") --string.trim(param:sub(7, -1))
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help change_owner for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = rac:region_set_attribute(name, value[1], "owner", value[2]) 
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
-- command show 
-- privileg: region_admin *or call by command_status
--
-----------------------------------------
-- called: 'region show' <id1> <id2>  		<optional>
-- sends the player a list of regions
-- msg/error handling:
-- return 0 - no error
function rac:command_show(header, name,list_start,list_end)
--	local region_values = {}
--	local pos1 = ""
--	local pos2 = ""
--	local data = ""
	local chat_string = ""
	local chat_string_start = "### List of Regions ###"
	if header == false or header == "status" then
		chat_string_start = ""
	end
	-- no privileg check: header == status then command_show is called by command_status 
	-- else privileg region_admin 
	local err = minetest.check_player_privs(name, { region_admin = true })
	if header ~= "status" then
		if not err then 
			return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
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

	-- get all regions in AreaStore()
	while rac.rac_store:get_area(counter) do
		if counter <= stop_list or stop_list < 0 then
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

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- Export the AreaStore() to a file 
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Exportiere die Regionen in ein File.
-- Zusammen mit import könnte man somit auch Regionen übertragen oder manuell anpassen
-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
-- 		return {["y"] = -15, ["x"] = -5, ["z"] = 154}
-- 		return {["y"] = 25, ["x"] = 2, ["z"] = 160}
--		return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["claimable"] = false, ["zone"] = "owend", ["protected"] = false, ["guests"] = ",", 
--			["pvp"] = false, ["mvp"] = true, ["effect"] = "dot",  ["version"] = "1.0" }
--
-- input: 
--		export_file_name as string-file-path
--
-- msg/error handling:
-- return 0 - no error
-- return err from io.open
-- return 13 -- "ERROR: No Table returned func: rac:export(export_file_name)", 
function rac:export(export_file_name)
	local file_name = rac.worlddir .."/".. export_file_name --rac.export_file_name
	local file, err

	-- open/create a new file for the export
	file, err = io.open(file_name, "w")
	if err then	
		--minetest.log("action", "[" .. rac.modname .. "] rac:file_exists(file_name) :"..tostring(rac:file_exists(file_name))) 
		minetest.log("error", "[" .. rac.modname .. "] file, err = io.open(file_name, w) ERROR :"..err) 
		return err
	end
	io.close(file)
	
	-- open file for append
	file = io.open(file_name, "a")

	--local region_values = {} 
	local pos1 = ""
	local pos2 = ""
	local data = ""
	local counter = 0
	-- loop AreaStore and write for every region 3 lines [min/pos1], [max/pos2], [data]
	while rac.rac_store:get_area(counter) do

		--region_values = rac.rac_store:get_area(counter,true,true)
		--pos1 = region_values.min
		--pos2 = region_values.max
		--data = region_values.data
		pos1,pos2,data = rac:get_region_data_by_id(counter,true)
		if type(pos1) ~= "table" then
			return 54 -- "ERROR: No table returned func: rac:export(export_file_name)", 
		end
		counter = counter + 1
		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
	-- No Error
	return 0
end

--+++++++++++++++++++++++++++++++++++++++
--
-- Load the exported AreaStore() from file
--
--+++++++++++++++++++++++++++++++++++++++
-- input: import_file_name as string-file-path
-- msg/error handling:
-- return 0 - no error
-- return 6 -- "ERROR: File does not exist!  func: func: rac:import(import_file_name) - File: "..minetest.get_worldpath() .."/rac_store.dat (if not changed)",
function rac:import(import_file_name)
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
		return 6 -- "ERROR: File does not exist!  func: func: rac:import(import_file_name) - File: "..minetest.get_worldpath() .."/rac_store.dat (if not changed)",
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


-----------------------------------------
--
-- command border
-- privileg: interact 	for own region
-- privileg: region_admin	for other, by name or ID
--
-----------------------------------------
-- called: 'region border'
-- 		'region {name}' if you are region_admin
--		'region {id}'	if you are region_admin
-- shows a box over the region
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling: 
-- return 20 --"msg: You don't have the privileg 'interact'! ",
-- return 0	-- no error
function rac:command_border(param, name)
	-- check privs
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 20 --"msg: You don't have the privileg 'interact'! ",		
	end
	local is_region_admin = minetest.check_player_privs(name, { region_admin = true })
	-- get values of param
	local value = string.split(param:sub(7, -1), " ") 
	-- region ID = nil -> no region
	local region_id  = nil	
	local pos1, pos2, data 
	local center
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border value[1] = {"..tostring(value[1]).."}" )  
	--local player = minetest.get_player_by_name(owner)
	local player = minetest.env:get_player_by_name(name)
	local pos = player:getpos()		
	local owner = name
	if is_region_admin and value[1] ~= nil then
		if minetest.player_exists(value[1]) == true then
			owner = value[1]
		end
		-- maybe a region ID is committed
		if rac.rac_store:get_area(tonumber(value[1])) then 
			region_id = tonumber(value[1])
		end
	end 
	
	-- two cases:
	-- case 1 region_id == nil 
	-- 		get pos1, pos2, center by name and pos
	if region_id == nil then 
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border owner = "..owner )  
		pos1, pos2, center = rac:get_region_center_by_name_and_pos(owner, pos)
	else
	-- case2 - region id is set
		pos1,pos2,data = rac:get_region_data_by_id(region_id)	
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border region_id = "..tostring(region_id) )  
		center = rac:get_center_of_box(pos1, pos2)
	end
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border pos1 = "..minetest.serialize(pos1) ) 
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border pos2 = "..minetest.serialize(pos2) ) 
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border center = "..tostring(center) ) 
 
	if type(center) == "table" then 
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border pos = "..minetest.serialize(pos) )  
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border center = "..minetest.serialize(center) )  
		center.y = (center.y-1)
		local box = minetest.env:add_entity(center, "rac:showarea")	
		box:set_properties({
				visual_size={x=math.abs(pos1.x - pos2.x), y=math.abs(pos1.y - pos2.y), z=math.abs(pos1.z - pos2.z)},
				collisionbox = {pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z},
			})
	else 
		minetest.chat_send_player(name, "No region found!")
	end
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

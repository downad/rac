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
	https://github.com/downad/rac
License: 
	GPLv3
]]--

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:msg_handling(err, player_name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- handle errors and messages
-- sende eine Nachricht an den Player oder in das log
-- check Player_name and chat_send msg to player
-- 			if name ~= nil 
-- if err == "", nil or 0 -> no Error: nothing happens
-- else minetest.log("error",
--
-- input: 
--		err as number -> die Error Texte sind in error_text.lua hinterlegt
--		err 0 -> no error, no output
--		player_name as string {default: name = nil}
--
-- return:
-- 	NOTHING - everything is ok
--	
-- msg/error handling: no
function rac:msg_handling(err, name)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err: "..tostring(err)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err.type: "..tostring(type(err))	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - rac.max_error: "..tostring(rac.max_error)	)
	end
	--		Schlüsselworte
	--		ERROR: -> Ausgabe in minetest.log
	--		Info:	-> Ausgabe in minetest.log
	--		msg: -> Ausgabe erfolgt nur an den Spieler

	if err == "" or err == nil or err == 0 then
		return 
	end
	local error_msg, player_msg
	
	-- Testen ob err vom Typ number ist
	if type(err) == "number" then
		if err > rac.max_error then
			-- [3] = "ERROR: func: rac:msg_handling(err, name) - die Nummer err ist größer als erlaubt!!!!",
			error_msg = rac.error_msg_text[3]
		else
			error_msg = rac.error_msg_text[err]
			-- check ERROR
			if error_msg:sub(1, 6) == "ERROR:" then
				minetest.log("error", "[" .. rac.modname .. "] Error: ["..tostring(err).."] ".. error_msg)
				player_msg = error_msg:sub(7, -1)	
			end
			-- check info
			if error_msg:sub(1, 5) == "info:" then
				minetest.log("action", "[" .. rac.modname .. "]".. error_msg:sub(6, -1))	
				player_msg = error_msg:sub(6, -1)	
			end
			-- check msg
			if error_msg:sub(1, 4) == "msg:" then
				-- msg = nur für den Player gedacht
				-- minetest.log("action", "[" .. rac.modname .. "]".. error_msg:sub(6, -1))	
				player_msg = error_msg:sub(4, -1)	
			end
		-- if name exists send chat
			if name ~= nil then 
				minetest.chat_send_player(name, player_msg)
			end
		end
	elseif type(err) == "string" then
		if err:sub(1, 5) == "info:" then 
			minetest.log("action", "[" .. rac.modname .. "] ".. err)	
		else
		-- err ist vom Typ String!
		-- es wurde aber keine Info vorgestellt
		-- Das ist ein Fehler!
		-- [1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
			minetest.log("error", "[" .. rac.modname .. "] Error: ".. rac.error_msg_text[1])
		end
 	else
		-- err ist nicht vom Typ number!
		-- es wurde keine Nummer übertragen
		-- Das ist ein Fehler!
		-- [1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
		minetest.log("error", "[" .. rac.modname .. "] Error: ".. rac.error_msg_text[1])
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:load_regions_from_file()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- load the AreaStore() from file
--
--
-- input: nothing
-- msg/error handling: no
-- return 0 = no error
function rac:load_regions_from_file(check)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:load_regions_from_file - Version: "..tostring(func_version)	)
	end
	rac.rac_store:from_file(rac.worlddir .."/".. rac.store_file_name) 

	-- integritätscheck
	if check == 1 then
		rac:check_region_integrity()
	end
 	-- übeprüfe Version und passe das an
	if check == 2 or check == 4 then
		-- prüfe rac.region_attribute.version
		rac:check_region_attribute_version()
	end

	
	return 0 	-- No Error
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:save_regions_to_file()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- save AreaStore() to file
--
--
-- input: 
--	nothing
--
-- return
--  0			alles hat geklappt
--
-- msg/error handling: YES
--  0 = no error
function rac:save_regions_to_file()
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:save_regions_to_file - Version: "..tostring(func_version)	)
	end
	local err = 0 -- No Error
	rac.rac_store:to_file(rac.worlddir .."/".. rac.store_file_name) 
	return err 	
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:delete_region(id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- delete region from AreaStore()
-- the get_areas return a pointer, so re-copie the areastore and 'forget' to copie the region with the id
--
--
-- input: 
--		id 		als number
--
-- check if id ~=0
-- msg/error handling:
-- return 0 - no error
-- return 1 -- "No region with this ID! func: raz:delete_region(id)", 
function rac:delete_region(id)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:delete_region - Version: "..tostring(func_version)	)
	end
	if rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:delete_region - id: "..tostring(id)	)
	end
	if rac.rac_store:get_area(id) == nil then
		-- Error
		return 48 -- [48] = "ERROR: func: rac:delete_region - No region with this ID! ",
	end 
	-- make a backup of all region, use date
	local backup = rac.backup_file_name..(os.date("%y%m%d_%H%M%S")..".dat" )
	err = rac:export(backup)
	rac:msg_handling(err)
	
	local counter = 0
	local temp_store = AreaStore() 
	local region_values = {}

	-- copy all regions to temp_store
	while rac.rac_store:get_area(counter) do
		if counter ~=id then
			-- no errorcheck - get_area / insert_area are build in
			region_values = rac.rac_store:get_area(counter,true,true)
			temp_store:insert_area(region_values.min, region_values.max, region_values.data)
		else
			-- no errorcheck - remove_area is build in
			minetest.log("action", "[" .. rac.modname .. "] rac:delete_region - überspringe id: "..tostring(id)	)
			rac.rac_store:remove_area(id)
		end
		counter = counter + 1
	end

	-- recreate raz.raz_store
	rac.rac_store = AreaStore()
	region_values = {}

	-- copy all value back
	counter = 0
	while temp_store:get_area(counter) do
			-- no errorcheck - get_area / insert_area are build in
			region_values = temp_store:get_area(counter,true,true)
			rac:set_region(region_values.min, region_values.max, region_values.data)
		counter = counter + 1
	end
	-- No Error
	return 0 
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:update_regions_data(id,pos1,pos2,data_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- update datafield  AreaStore()
--
--
-- input:
--		id				as number - the ID to change
-- 		pos1, pos2 		as vector (table)
--		data_table		as (designed) string
--
-- return:
--	true
--
-- msg/error handling: no
--	return true wenn fertig 
function rac:update_regions_data(id,pos1,pos2,data_table)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:update_regions_data - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:update_regions_data(id,pos1,pos2,data) ID: "..tostring(id).." data: "..minetest.serialize(data_table)) 
	end
	local err = 0
	local data_string = minetest.serialize(data_table)

	local counter = 0

	-- create an temporary AreaStore()
	local temp_store = AreaStore() 
	local region_values = {}

	-- copy all regions to temp_store
	while rac.rac_store:get_area(counter) do
		if counter ~=tonumber(id) then
			region_values = rac.rac_store:get_area(counter,true,true)
			temp_store:insert_area(region_values.min, region_values.max, region_values.data)
		else
			temp_store:insert_area(pos1, pos2, data_string)
		end
		
		counter = counter + 1
	end

	-- recreate rac.rac_store
	rac.rac_store = AreaStore()
	counter = 0

	-- copy all regions from temp_store to rac.rac_store
	while temp_store:get_area(counter) do
		region_values = temp_store:get_area(counter,true,true)
		rac.rac_store:insert_area(region_values.min, region_values.max, region_values.data)
		counter = counter + 1
	end
	temp_store = {}

	-- save changes
	rac:save_regions_to_file()
	if err == 0 then return true end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:get_region_at_pos(pos)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Suche alle Regionen die an diese Position pos zu finden sind
-- 
--
-- input: 
--		pos 			als Positionsvektor
--
-- return:
-- 	table 			(mit allen Gebietes Id)
--  nil 				if there is wilderness/no region at pos
--
-- msg/error handling: YES, hard coded:
--			wenn mehr als 2 Regionen an dieser Position sind
--			err, id
function rac:get_region_at_pos(pos)
	local func_version = "1.0.1" -- angepasstes return, nil,nil wenn keine Region gefunden wurde.
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_region_at_pos - Version: "..tostring(func_version)	)
	end
	local err = 0 -- Kein Fehler
	local id = {}
	
	for region_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
			table.insert(id,region_id)
	end 
	-- ist der #id größer als 2, wurden mehr als 2 ID gefunden
	if #id > 2 then
		err = 3 -- [3] = "ERROR: rac:msg_handling(err, name) die Nummer err ist größer als erlaubt!!!!",
		return err	-- ist der #id größer 0, wurde eine Region ID gefunden
	elseif #id > 0 then
		return err,id
	else
		-- keine Region gefunden
		if rac.debug_level > 0 then 
			rac:msg_handling(50) -- [50] = "ERROR: func: rac:get_region_at_pos - keine Region an dieser Position gefunden!",
		end
		--	return nil,nil
		return nil,nil -- keine ID gefunden
	end	
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_region_datatable(id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- hole den data_string einer Region  
--
--
-- input: 
--	id			number mit der ID der Region
--
-- return
--  err, data as table
--
-- msg/error handling: YES
--	err, data 
function rac:get_region_datatable(id)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - Version: "..tostring(func_version)	)
	end
	local err = 0
	--	no_deserialize == false = String
	local err, pos1,pos2,data = rac:get_region_data_by_id(id,false)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - id: "..tostring(id)	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - pos1: "..tostring(minetest.serialize(pos1))	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - pos2: "..tostring(minetest.serialize(pos2))	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - data: "..tostring(data)	)
	
	return err, data
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_region_data_by_id(id,no_deserialize)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Hole zu einer region_id 
-- 	pos1,pos2 = Ecke 1 und Ecke 2
--	data  
--
--
-- input: 
--		id 
--		no_deserialize as boolean {default: no_deserialize = nil}
--						no_deserialize = true then return data as string!
--						no_deserialize ~= true then return data as table!
--
-- return:
--	err
--	pos1,pos2				als Positionsvektor
--	data
--						no_deserialize = true then return data as string!
--						no_deserialize ~= true then return data as table!
--
-- msg/error handling: YES
-- err, pos1,pos2,data
function rac:get_region_data_by_id(id,no_deserialize)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_region_data_by_id - Version: "..tostring(func_version)	)
	end
	local err = 0
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data --= {}
	if rac.rac_store:get_area(id) then 
		region_values = rac.rac_store:get_area(id,true,true)
		pos1 = region_values.min
		pos2 = region_values.max
		if no_deserialize ~= true then
			data = minetest.deserialize(region_values.data)
		else
			data = region_values.data
		end
		return err,pos1,pos2,data
	end
	-- Error
	return 16 -- [16] = "ERROR: func: rac:get_region_data_by_id - no region with this ID!"get_region_at_pos
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:string_in_table(given_string, given_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- ist der String 'given_string' in der übergebenen Tabelle 'given_table'
--
-- input: given_string, given_table
--
-- return: 
--		true if 'given_string' is in 'given_table'
-- 		false
--
-- msg/error handling: no
function rac:string_in_table(given_string, given_table)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:string_in_table - Version: "..tostring(func_version)	)
	end
  for i,v in ipairs(given_table) do
    if v == given_string then
      return true
    end
  end
  return false
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:table_to_string(given_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- convert a table to a string
--
--
-- input: 
--		given_table		as table
--
-- return:
-- return string 		as string
--
-- msg/error handling: no
function rac:table_to_string(given_table)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:table_to_string - Version: "..tostring(func_version)	)
	end
	local return_string = ""
	for k, v in pairs(given_table) do
		if k then
			return_string = return_string..tostring(v)..","
		end
	end
	return return_string
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:convert_string_to_table(string, seperator)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- split string into a table, default seperator is ","
--
--
-- input: 
--		string 			as string
--		seperator 	as string {default: seperator = ","}
--
-- return:
-- 	value_tables with the elements
--	
-- msg/error handling: no
function rac:convert_string_to_table(string, seperator)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:convert_string_to_table - Version: "..tostring(func_version)	)
	end
	if seperator == nil then
		seperator = ","
	end
	local value_table = {}
	minetest.log("action", "[" .. rac.modname .. "] rac:convert_string_to_table - string: "..tostring(string)	)

	value_table = string.split(string,seperator)

	return value_table
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:remove_value_from_table(value, given_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- remove a value from table
--
--
-- input: 
--		value 		as string
--		given_table as table
--
-- return:
--	table ohne das removed Element
--
-- msg/error handling: no
function rac:remove_value_from_table(value, given_table)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:remove_value_from_table - Version: "..tostring(func_version)	)
	end
	local return_table = {}
	for k, v in ipairs(given_table) do
		if k then
		    if v ~= value then
				table.insert(return_table, v)
		    end
		end
	end
	return return_table
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:player_can_modify_region_id(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Diese Funktion gibt die Tabelle can_modify zurück
-- über die Privilegien kann der Spieler seine Regionen verwalten
-- ohne Privileg,wenn OWNER
--		umbenennen
--		schützen
--		löschen
-- mit Privileg	
-- 	effect:				Einen Effekt für das Gebiet wählen 	
--	mvp:					Monsterdamage auf dem Gebiet einschalten
--	pvp:					PVP  auf dem Gebiet einschalten (falls PVP in der Welt erlaubt ist)
-- 	guests:				Mit diesem Privileg kann der der Spieler Gäste auf sein Gebiet einladen. Die Gäste können in dem Gebiet handeln, auch wenn es geschützt ist.
--	set:					Ein Spieler mit dem set-Privileg kann Gebiete claimen und kann folgendes bearbeiten
--				umbenennen
--			 	Schutz ein- oder auschalten
--				Das Gebiet übertragen an einen anderen Spieler
--				Das Gebiet löschen
--	admin: Der Admin kann alles
--
-- input: 
--		player			als Player Objekt
--
-- return:
--  Table can_modify
--		can_modify.owner (true/false)
--		can_modify.name (true/false)
--		can_modify.claimable (true/false)
--		can_modify.zone (true/false)
--		can_modify.protected (true/false)
--		can_modify.guests (true/false)
--		can_modify.pvp (true/false)
--		can_modify.mvp (true/false)
--		can_modify.effect (true/false)
--		und zusätzlich
--		can_modify.change_owner (true/false)
--		can_modify.delete_region (true/false)
--		can_modify.rename_region (true/false)
--		can_modify.set (true/false)
-- 		can_modify.admin (true/false)
-- 		
--
-- msg/error handling: NO
--
function rac:player_can_modify_region_id(player_obj_or_string)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_can_modify_region_id - Version: "..tostring(func_version)	)
	end
	local player
  -- Errorhandling player ist ein String mit Name 
  if type(player_obj_or_string) == "string" then
  	player =  minetest.get_player_by_name(player_obj_or_string)
  else
   	player = player_obj_or_string
  end

	local can_modify = {
		owner = false,
		name = false,
		claimable = false,
		zone = false,
		protected = false,
		guests = false,
		pvp = false,
		mvp = false,
		effect = false,
		change_owner = false,
		delete_region = false,
		rename_region = false,
		set = false,
		admin = false,
	}
	
	
	if rac.debug and rac.debug_level > 5 then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_can_modify_region_id")
		minetest.log("action", "[" .. rac.modname .. "] rac:player_can_modify_region_id - can_modify: "..tostring(rac:table_to_string(can_modify)) )
	end
	-- teste die verschiedenen Privilegione	
	if minetest.check_player_privs(player, { region_admin = true }) or (rac.serveradmin_is_regionadmin and minetest.check_player_privs(player, { server = true })) then 
		can_modify = {
			owner = true,
			name = true,
			claimable = true,
			zone = true,
			protected = true,
			guests = true,
			pvp = true,
			mvp = true,
			effect = true,
			change_owner = true,
			delete_region = true,
			rename_region = true,
			set = true,
			admin = true,
		}
	end
	if	minetest.check_player_privs(player, { region_effect = true }) then
		can_modify.effect = true
	end
	if minetest.check_player_privs(player, { region_mvp = true }) then 
		can_modify.mvp = true
	end
	if minetest.check_player_privs(player, { region_pvp = true }) then 
		can_modify.pvp = true
	end
	if	minetest.check_player_privs(player, { region_guests = true }) then
		can_modify.guests = true
	end
	if minetest.check_player_privs(player, { region_set = true }) then 
		can_modify.owner = true
		can_modify.name = true
		can_modify.protected = true
		can_modify.change_owner = true
		can_modify.delete_region = true
		can_modify.rename_region = true
		can_modify.set = true
	end	
	return can_modify
end -- rac:can_modify = rac:player_can_modify_region_id(player)


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:region_set_attribute(name, id, region_attribute, value, bool)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- set an attribute in an datastring of an region
--
--
-- input: 
--		name				as string, playername
--		id					as number, region id
--		region_attribute	as string
--		value				as boolean or string, depending on region_attribute
--		bool				as boolean, only used for invite or ban guest
-- the default bool is 'nil' - this bool is used to add or remove guests 
-- this function checks id, region_attribut and value = bool or value = string (effects - hot, bot, holy, dot, choke, evil)
--
-- return:
--		[18] = "ERROR: func: rac:region_set_attribute - No region with this ID! ",
--		[19] = "ERROR: func: rac:region_set_attribute - The region_attribute dit not fit!",
--		[20] = "ERROR: func: rac:region_set_attribute - There is no Player with this name!",
--		[21] = "ERROR: func: rac:region_set_attribute - Wrong effect! ",
--		[22] = "ERROR: func: rac:region_set_attribute - You are not the owner of this region! ",
--		[23] = "ERROR: func: rac:region_set_attribute - No Player with this name is in the guestlist! ",
--
-- msg/error handling: YES
--	err
function rac:region_set_attribute(name, id, region_attribute, value, bool)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Version: "..tostring(func_version)	)
	end
	if rac.debug and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Übergabe ++++++++++++++++++++++++++++++++++++++++++++++++++++ "	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Player name: "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - id: "..tostring(id)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - region_attribute: "..tostring(region_attribute)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - value: "..tostring(value)	)		
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - bool: "..tostring(bool)	)
	end
	

	
	
	local err = 0
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data = {}
	-- return message
	local err_msg = "info: Region with ID: "..id.." modified attribute "..tostring(region_attribute).." with value "..tostring(value)
	
	-- ckeck is this ID in AreaStore()?
	if rac.rac_store:get_area(id) then
		-- get region values 
		err,pos1,pos2,data = rac:get_region_data_by_id(id)
		-- mal sehen was angekommen ist
		if rac.debug and rac.debug_level > 5 then
			minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - nach check ID ++++++++++++++++++++++++++++++++++++++++++++++++++++ "	)
			minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - err: "..tostring(err) ) 
			minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - pos1: "..minetest.serialize(pos1)) 
			minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - pos2: "..minetest.serialize(pos2)) 
			minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - data: "..minetest.serialize(data)) 
		end
		-- check if player is owner of the region
		-- or admin (can_modify.admin == true
		if name ~= data.owner then
			local can_modify = rac:player_can_modify_region_id(player)
			if not can_modify.admin then
				return 22 --		[22] = "ERROR: func: rac:region_set_attribute - You are not the owner of this region! ",
			end
		end
		
		
		-- check if the attribute is allowed
		if not rac:string_in_table(region_attribute, rac.region_attribute.allowed_region_attribute) then
			return 19 --		[19] = "ERROR: func: rac:region_set_attribute - The region_attribute did not fit!",
		end
		
		
		-- modify the attribute
		-- protected
		if 	region_attribute == "protected" then
				minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - protected ++++++++++++++++++++++++++++++++++++++++++++++++++++ "	)
				minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - region_attribute: "..tostring(region_attribute)	)

			if type(value) == "boolean" then 
				data.protected = value 
			end 
		-- region_name
		elseif 	region_attribute == "region_name" then
			if type(value) == "string" then 
				-- -- -- -- 
				-- String testen  
--				minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Stringtesten für {region_name}!!!!!!: ")
				--		region_attribute ==
				--			region_name 
				--			erlaubt [a-zA-Z], [ ], [0-9]
				--			wegen der Sprache Deutsch [äöüßÄÖÜ]
				-- eleminieren von gefährlichen Zeichen
--				minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - ersetzen von \\ : "..tostring(value)	)
				value = string.gsub(value, "\\", "")
				--minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - ersetzen von \\ hat geklappt?: "..tostring(value)	)
				minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Sonderzeichen? "..tostring(string.match(value, "%p"))	)
				-- ist das nötig? Stand August 22 - NEIN
				--local test_string = true
				-- Sonderzeichen 
				--if  string.match(value, "%p") == nil then
				--	minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - [Sonderzeichen == nil]: "	)		
				--else
				--	minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - [ Sonderzeichen ist ~= nil]: "..tostring(false)	)
				--	test_string = false		
				--end				

				-- mindestlänge 5 max: 64
				if #value < 4 then
					return 	46 --	[46] = "ERROR: func: rac:region_set_attribute - der Gebietsnamen ist zu kurz! ",	
				elseif #value > 64 then
					return 	47 -- [47] = "ERROR: func: rac:region_set_attribute - der Gebietsnamen ist zu lang! ",	
				end
				--
				--			owner, guest müssen nicht getestet werden das geht über existPlayer
				-- -- -- --
				data.region_name = value
			end 
		-- owner
		elseif 	region_attribute == "owner" then
			if type(value) == "string" then 
				-- check player"
				if not minetest.player_exists(value) then --player then
					return 20 --		[20] = "ERROR: func: rac:region_set_attribute - There is no Player with this name!",
				end			
				data.owner = value
			end 
		-- Gast hinzufügen
		elseif 	region_attribute == "guests" and bool == true then
			if type(value) == "string" then 
				-- check Gast ist ein Spieler 
				if not minetest.player_exists(value) then 
					return 20 --		[20] = "ERROR: func: rac:region_set_attribute - There is no Player with this name!",
				end			
				if data.guests == "," or data.guests == nil then
					data.guests = value
				else
					--check	if guest/value is in string guests
					local given_table = rac:convert_string_to_table(data.guests, ",")
					if not rac:string_in_table(value, given_table) then
						data.guests = data.guests..","..value 
					else
						return 26 -- [26] = "ERROR: func: rac:region_set_attribute - Dieser Gast ist schon auf der Gäste-Liste! ", 
					end
				end
				err_msg = err_msg.." Gast hinzugefügt. "
			end 
		-- Gast bannen
		elseif 	region_attribute == "guests" and bool == false then
			if type(value) == "string" then 
				-- check guests
				local guests = rac:convert_string_to_table(data.guests, ",")
				if not rac:string_in_table(value, guests) then
					return 23 --		[23] = "ERROR: func: rac:region_set_attribute - No Player with this name is in the guestlist! ",
				end
				-- remove value from guests
				guests = rac:remove_value_from_table(value, guests)
				-- data.guests must be an STRING!
				local new_guest_string = rac:table_to_string(guests)
				data.guests = new_guest_string
				err_msg = err_msg.." Gast verbannt. "
			end 
		-- pvp
		elseif 	region_attribute == "pvp" then
			if type(value) == "boolean" then 
				data.pvp = value 
			end 
		-- mvp
		elseif 	region_attribute == "mvp" then
			if type(value) == "boolean" then 
				data.mvp = value 
			end 
		-- zone
		elseif 	region_attribute == "zone" then
			if type(value) == "string" then 
				-- checke die erlaubten Zonen
				if not rac:string_in_table(value, rac.region_attribute.allowed_zones) then
					return 19 --		[19] = "ERROR: func: rac:region_set_attribute - The zone_attribute did not fit!",
				end
				data.zone = value
			end 
		-- claimable
		elseif 	region_attribute == "claimable" then
			if type(value) == "boolean" then 
				data.claimable = value
			else
				return 28 --	[28] = "ERROR: func: rac:region_set_attribute - Claimable needs a boolean.",
			end
		-- Effekt hinzufügen
		elseif 	region_attribute == "effect" and bool == true then
			if type(value) == "string" then 
				-- checke erlaubter Effekt
				if not rac:string_in_table(value, rac.region_attribute.allowed_effects) then
					return 29 --		[19] = "ERROR: func: rac:region_set_attribute - The effect attribute did not fit!",
				end
				-- ist der Effekt schon in der Liste?
				-- PRÜFEN
				if data.effect == "none" then
					data.effect = value
				else
					data.effect = data.effect..","..value
					err_msg = err_msg.." Effekt "..value.." hinzugefügt. "
				end				
			end 
		-- Effekt löschen
		elseif 	region_attribute == "effect" and bool == false then
			if type(value) == "string" then 
				-- ist der Effekt in der Liste
				local effects = rac:convert_string_to_table(data.effect, ",")
				if not rac:string_in_table(value, effects) then
					return 30 --[30] = "ERROR: func: rac:region_set_attribute - Dieser Effekt ist nicht auf der Region-Effekt-Liste! ",
				end
				-- remove effect
				effects = rac:remove_value_from_table(value, effects)
				local new_effect_string = rac:table_to_string(effects)
				data.effect = new_effect_string
				err_msg = err_msg.." Effekt "..value.." gelöscht. "
			end 
		end -- modify the attribute
		
		
		-- update_regions_data(id,pos1,pos2,data)
		if not rac:update_regions_data(id,pos1,pos2,data) then
			return 25 -- [25] = "ERROR: func: rac:region_set_attribute - in update_regions_data! ", 
		end
		if err == 0 then
			rac:msg_handling(err_msg)
			return 0
		end
	else -- if rac.rac_store:get_area(id) then
		-- Error
		return 24 -- 	[24] = "ERROR: func: rac:region_set_attribute - no region with this ID!",
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:region_in_region(pos1,pos2)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Gibt es in dem Bereich, dieser neuen Region andere Regionen?
-- - keine andere Region: jeder mit region_set darf setzen
-- - eine andere Region: diese ist "city" -> admin kann plot oder outback setzen
-- - eine andere Region: diese ist "outback" -> admin kann plot oder city setzen
-- - zwei andere Regionen: outback und city -> admin kann plot
-- - eine andere Region: diese ist "plot" dann darf man nichs setzen
-- - mehrere anderer Regionen: man darf nicht setzen	
--
--
-- input: 
--		pos1,pos2 	als Positionsvektor
--
-- return:
-- 	nil  - keine andere Region betroffen
--	table - mit den ID der betroffenen Regionen
-- 	
-- msg/error handling: no
function rac:OLD_region_in_region(pos1,pos2)
	local func_version = "1.0.0"
	if rac.show_func_version  then
		minetest.log("action", "[" .. rac.modname .. "] rac:region_in_region - Version: "..tostring(func_version)	)
	end
-- get all regions in this box
	local found = rac.rac_store:get_areas_in_area(pos1,pos2,true,true) --accept_overlap, include_borders, include_data):
	local is_city = false
	local count = 0
	
	-- loop all region
	for region_id,v in pairs(found) do
		-- if in one region the city-attribut is set is counts for all region there!
		minetest.log("action", "[" .. rac.modname .. "] region_in_region! region_id "..tostring(region_id) )  
--		minetest.log("action", "[" .. raz.modname .. "] region_is_plot! city "..tostring(raz:get_region_attribute(region_id,"city")) )  
--		minetest.log("action", "[" .. raz.modname .. "] region_is_plot! plot "..tostring(raz:get_region_attribute(region_id,"plot")) )  

		-- city hat plots und freie stellen zwischen den plots
		-- in einer City kann der region_admin plots setzen.
		if rac:get_region_attribute(region_id,"zone") == "city" then
			is_city = true
		end
		-- are there more than 1 region
		count = count + 1 
	end -- for region_id,v in pairs(found) do
	
	-- check:
	minetest.log("action", "[" .. rac.modname .. "] region_is_plot! count "..tostring(count) ) 
	
	-- es wurde keine Region gefunden - man kann diese Region also anlegen 
	if count == 0 then
		return nil			-- no regions found
	end
	
	-- 1 Region gefunden
	-- ist es eine City und kein Plot, kann man die Region anlegen
	if count == 1 then
		if is_city then
			return true
		end	
	-- mehr als 2 Regionen wurden gefunden, dann geht nichts
	else
		return count 	-- anzahl der gefunden Regionen
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_region_attribute(id, region_attribute)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- get one attribute from data-field of a regions 
-- hole das data field einer region und liefer den Wert zurück 
-- 
--
--
-- input: 
--			id					as number
--			region_attribute 	as sting
--
-- return
--		err, wenn es die id ncith gibt
--		return Value des datafields
--
-- msg/error handling: Yes 
-- return err, value
function rac:get_region_attribute(id, region_attribute)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_region_attribute - Version: "..tostring(func_version)	)
	end
	local err,data = rac:get_region_datatable(id)
	if err > 0 then
		rac:msg_handling(err)
		return err
	end			

	-- check if the attribute is allowed
	if not rac:string_in_table(region_attribute, rac.region_attribute.allowed_region_attribute) then
		-- 		[39] = "ERROR: func: rac:get_region_attribute - The region_attribute did not fit!",
		rac:msg_handling(39)
		return 39
	else
    local return_value = ""
		if 	region_attribute == "protected" then
			return_value = data.protected 
		elseif 	region_attribute == "region_name" then
			return_value = data.region_name
		elseif 	region_attribute == "owner" then
			return_value = data.owner
		elseif 	region_attribute == "guests" then
			return_value = data.guests
		elseif 	region_attribute == "pvp" then
			return_value = data.pvp
		elseif 	region_attribute == "mvp" then
			return_value = data.mvp
		elseif 	region_attribute == "effect" then
			return_value = data.effect
		elseif 	region_attribute == "version" then
			return_value = data.version
		elseif 	region_attribute == "zone" then
			return_value = data.zone
		elseif 	region_attribute == "claimable" then
			return_value = data.claimable
		end 

		return return_value
	end		
end




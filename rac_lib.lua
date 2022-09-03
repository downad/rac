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
-- sende eine Nachricht an den Player oder in das log
-- check Player_name and chat_send msg to player
-- 			if name ~= nil 
-- if err == "", nil or 0 -> no Error: nothing happens
-- else minetest.log("error",
--
-- input: 
--		err als Zahl 			-> die Error Texte sind in error_text.lua hinterlegt
--		err 0 						-> no error, no output
--		err als String		-> das Info/msg am Anfang wird abgeschitten error_msg:sub(1, 6/4)
-- 		func bool/string	-> Ausgabe der aufrufenden Funktion, 
--													bool = false passiert nichts  
--													string = Ausgabe des String
--		player_name as string {default: name = nil}
--
-- return:
-- 	NOTHING - everything is ok
--	
-- msg/error handling: no
function rac:msg_handling(err, func, name)
	local func_version = "1.0.0"
	local func_name = "rac:msg_handling"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err: "..tostring(err)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err.type: "..tostring(type(err))	)
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - rac.max_error: "..tostring(rac.max_error)	)
	end
	
	if func == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - func hat den Wert nil: "..tostring(func)	)
		-- bau bewusst den absturz ein
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - func hat den Wert nil: "..func	)
		
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
		-- minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err.type: "..tostring(type(err))	)
		if err > rac.max_error then
			-- [3] = "ERROR: func: rac:msg_handling(err, name) - die Nummer err ist größer als erlaubt!!!!",
			error_msg = rac.error_msg_text[3]
		else
			-- minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err <= rac.max_error: "..tostring(rac.max_error)	)
			error_msg = rac.error_msg_text[err]
			-- check ERROR
			if error_msg:sub(1, 6) == "ERROR:" then
				minetest.log("error", "[" .. rac.modname .. "] rac:msg_handling - Error: ["..tostring(err).."] ".. error_msg)
				player_msg = error_msg:sub(7, -1)	
			end
			-- check info
			if error_msg:sub(1, 5) == "info:" or error_msg:sub(1, 5) == "Info:"  then
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
			 	minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - type of name: ".. tostring(type(name)) )
			 	minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - name: ".. tostring(name) )
			 	minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - player_msg: ".. tostring(player_msg) )
			 	minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err: ".. tostring(err) )
			 	minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - func: ".. tostring(func) )
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
			minetest.log("error", "[" .. rac.modname .. "] rac:msg_handling - Error: ".. rac.error_msg_text[1])
		end
 	else
		-- err ist nicht vom Typ number!
		-- es wurde keine Nummer übertragen
		-- Das ist ein Fehler!
		-- [1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
			-- teste ob func angegeben wurde
		if func == nil then
			minetest.log("error", "[" .. rac.modname .. "] rac:msg_handling - Error: ".. rac.error_msg_text[1])
		else 	
			minetest.log("error", "[" .. rac.modname .. "] rac:msg_handling - Aufrufer: "..func.." Error: ".. rac.error_msg_text[1])
		end
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:load_regions_from_file(check)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- load the AreaStore() from file
--
--
-- input: 
--	check als Zahl
--				check = 0 -- 1 check integrity, 2 check version, 4 check both.
--				check = 1 		-> Integritätcheck für die Region
--				check = 2 		-> check Version des saved RegionStore
--				check = 4 		-> checke Version und Integrität des saved RegionStore
--			
--
-- return:
--		0	 keine Fehler
--		60 --	[60] = "ERROR: func: load_regions_from_file  - Der Check-Value ist noch erlaubt!",
--
--
-- msg/error handling: yes
-- 	prüfe ob check einen Wert von 0,1,2,4, hat.
function rac:load_regions_from_file(check)
	local func_version = "1.0.0"
	local func_name = "rac:load_regions_from_file"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	local is_error = true
	
	-- prüfe ob check 0,1,2,4 ist.
	if check == 0 then 
		is_error = false
	elseif check == 1 then 
		is_error = false
	elseif  check == 2 then 
		is_error = false
	elseif check == 4 then 
		is_error = false
	end
	
	-- es gibt keinen check-error
	if is_error == false then 
		-- lade das File
		rac.rac_store:from_file(rac.worlddir .."/".. rac.store_file_name) 

		-- Integritätscheck
		if check == 1  or check == 4 then
			rac:check_region_integrity()
		end
		
	 	-- übeprüfe Version und passe das an
		if check == 2 or check == 4 then
			-- prüfe rac.region_attribute.version
			rac:check_region_attribute_version()
		end
		
		return 0 	-- No Error
		
	else
		return 60 --	[60] = "ERROR: func: load_regions_from_file  - Der Check-Value ist noch erlaubt!",
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:check_region_integrity()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- durchlaufe alle Regionen, 
-- kontrolliere region_data,
-- falls data == nil
-- owner = serveradmin, protected = true, der rest default.
-- modifiziere den region_data_string
-- speichere die modifizierte Region ab
--
--
-- input:
-- 	nothing
--
-- return:
--	nothing
--
-- msg/error handling: no
-- 	err,id
function rac:check_region_integrity()
	local func_version = "1.0.0"
	local func_name = "rac:check_region_integrity"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	local counter = 0 -- die 1. REgion hat immer die ID 0
	local err = 0 -- No Error
	local region_data, new_data_string
	local must_modify = false
	local owner = rac.wilderness.name
	local region_name = "LostArea"
	local claimable = rac.region_attribute.claimable
	local zone = rac.region_attribute.zone
	local protected = true
	local guests_string = rac.region_attribute.guests
	local pvp = rac.region_attribute.pvp
	local mvp = rac.region_attribute.mvp
	local effect = rac.region_attribute.effect
	local do_not_check_player = true
	
	while rac.rac_store:get_area(counter) do
		-- hole das region_data
		local err, pos1,pos2,data = rac:get_region_data_by_id(counter,false)
		if err == 0 then
			rac:msg_handling(err)
		end
		-- prüfe data
		if region_data == nil then --kein data vorhanden
			must_modify = true
			region_name = region_name..tostring(counter)
			err, new_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
		end
		
		-- es muss etwas angepasst werden!
		if must_modify then
			-- erstelle den neuen data_string
				-- only for debugging
			if rac.debug == true then
				minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
				minetest.log("action", "[" .. rac.modname .. "] region_ID: "..tostring(counter))
				minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
				minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
				minetest.log("action", "[" .. rac.modname .. "] claimable: "..tostring(claimable))
				minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
				minetest.log("action", "[" .. rac.modname .. "] protected: "..tostring(protected))
				minetest.log("action", "[" .. rac.modname .. "] guests_string: "..tostring(guests_string))
				minetest.log("action", "[" .. rac.modname .. "] pvp: "..tostring(pvp))
				minetest.log("action", "[" .. rac.modname .. "] mvp: "..tostring(mvp))
				minetest.log("action", "[" .. rac.modname .. "] effect: "..tostring(effect))
				minetest.log("action", "[" .. rac.modname .. "] do_not_check_player: "..tostring(do_not_check_player))
			end
			err, new_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
			minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - region_data: "..tostring(minetest.serialize(region_data))	)
			minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - new_data_string: "..tostring(new_data_string)	)
			rac:msg_handling(err) 
			 
			-- update region
			err = rac:update_regions_data(counter,pos1,pos2,new_data_string)
			if err ~= 0 then
				rac:msg_handling(err,func_name)
			end 
		end
		must_modify = false
		counter = counter + 1
	end
	
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
--	0	alles ok
--	err bei Fehler
--
-- msg/error handling: no
function rac:update_regions_data(id,pos1,pos2,data_table)
	local func_version = "1.0.0"
	local func_name = "rac:update_regions_data"	
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:update_regions_data(id,pos1,pos2,data) ID: "..tostring(id).." data: "..minetest.serialize(data_table)) 
	end
	local err = 0
	local data_string
	if type(data_table) == "table" then
		data_string = minetest.serialize(data_table)
	else
		data_string = data_table
	end
	
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
	err = rac:save_regions_to_file()
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	end
	return err
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
--
-- msg/error handling: no
--  0 = no error
function rac:save_regions_to_file()
	local func_version = "1.0.0"
	local func_name = "rac:save_regions_to_file"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	rac.rac_store:to_file(rac.worlddir .."/".. rac.store_file_name) 
	return 0 -- No Error 	
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
-- return:
-- 	return 0 - no error
-- 	return 48 -- [48] = "ERROR: func: rac:delete_region - No region with this ID! ",
--
-- msg/error handling: yes
-- check ist die ID vorhanden
function rac:delete_region(id)
	local func_version = "1.0.0"
	local func_name = "rac:delete_region"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	
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
	rac:msg_handling(err,func_name)
	
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

	-- recreate rac.raz_store
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
-- return:
-- return 0 - no error
-- return err from io.open
-- return 54 --[54] = "ERROR: func: rac:export - keine Data-Tabelle bekommen",
--
-- msg/error handling: no
function rac:export(export_file_name)
	local func_version = "1.0.0"
	local func_name = "rac:export"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
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
		err,pos1,pos2,data = rac:get_region_data_by_id(counter,true)
		if err == 0 then
			rac:msg_handling(err,func_name)
		end
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


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:import(import_file_name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Load the exported AreaStore() from file
-- importiere ein Backup der Regionen
-- wenn es ein importfile gibt, lösche den AreaStore und importiere alles
--
-- input: 
--		import_file_name as string-file-path
--
--
-- msg/error handling:
-- return 0 - no error
-- return 55 -- "ERROR: File does not exist!  func: func: rac:import(import_file_name) - File: "..minetest.get_worldpath() .."/rac_store.dat (if not changed)",
function rac:import(import_file_name, only_part)
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
	
	if only_part ~= true then
		-- lösche den AreaStore()
		rac.rac_store = AreaStore()
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
--	rac:get_region_at_pos(pos)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Suche alle Regionen die an diese Position pos zu finden sind
-- mögliche Ereignisse:
--			keine andere Region ist dort -> return nil, nil
--			1-3 andere Region ist dort -> return 0, table		
-- 				die aufrufende Function muss testen!!!!
-- 			mehr als 3 Regionen können in v1.0 nicht sein - outback -> city -> plot nur das ist möglich
--
-- input: 
--		pos 			als Positionsvektor
--
-- return:
--	nil, nil			wenn es keine Region an pos gibt
-- 	0,table 		wenn es Regionen an pos gibt	(mit allen Gebietes Id)
--	61,talbe		[61] = "ERROR: func: get_region_at_pos  - mehr als 3 Regionen an diesr Position gefunden",
--
-- msg/error handling: no
function rac:get_region_at_pos(pos)
	local func_version = "1.0.1" -- angepasstes return, nil,nil wenn keine Region gefunden wurde.
	local func_name = "rac:get_region_at_pos"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err = 0 -- Kein Fehler
	local id = {}
	
	for region_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
			table.insert(id,region_id)
	end 
	
	-- ist der #id größer als 2, wurden mehr als 2 ID gefunden
	if #id > 3 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #id: "..tostring(#id)	)
		err = 61 -- [61] = "ERROR: func: get_region_at_pos  - mehr als 3 Regionen an diesr Position gefunden",
		return err,id	-- ist der #id größer 0, wurde eine Region ID gefunden
	elseif #id > 0 then
		return err,id
	else
		-- keine Region gefunden
		if rac.debug_level > 8 then 
			rac:msg_handling(50,func_name) -- [50] = "ERROR: func: rac:get_region_at_pos - keine Region an dieser Position gefunden!",
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
--  0, data as table 			-- alles OK
--  err, data as table
--
-- msg/error handling: no
function rac:get_region_datatable(id)
	local func_version = "1.0.0"
	local func_name = "rac:get_region_datatable"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err = 0
	--	no_deserialize == false = String
	local err, pos1,pos2,data = rac:get_region_data_by_id(id,false)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - id: "..tostring(id)	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - pos1: "..tostring(minetest.serialize(pos1))	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - pos2: "..tostring(minetest.serialize(pos2))	)
--	minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - data: "..tostring(data)	)
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	end	
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
-- 	err, pos1,pos2,data
--	err
--	pos1,pos2				als Positionsvektor
--	data
--						no_deserialize = true then return data as string!
--						no_deserialize ~= true then return data as table!
--	return 16 -- [16] = "ERROR: func: rac:get_region_data_by_id - no region with this ID!"get_region_at_pos
--
-- msg/error handling: YES
function rac:get_region_data_by_id(id,no_deserialize)
	local func_version = "1.0.0"
	local func_name = "rac:get_region_data_by_id"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - id: "..tostring(id)	)
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
	local func_name = "rac:string_in_table"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
-- 	return string 		as string
--
-- msg/error handling: no
function rac:table_to_string(given_table)
	local func_version = "1.0.0"
	local func_name = "rac:table_to_string"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
	local func_name = "rac:convert_string_to_table"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end

	if seperator == nil then
		seperator = ","
	end
	local value_table = {}
--	minetest.log("action", "[" .. rac.modname .. "] rac:convert_string_to_table - string: "..tostring(string)	)

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
	local func_name = "rac:remove_value_from_table"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
-- msg/error handling: yes
--		prüfe ob player ein objekt oder ein sting ist
function rac:player_can_modify_region_id(player_obj_or_string)
	local func_version = "1.0.0"
	local func_name = "rac:player_can_modify_region_id"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
--		by_function as boolean, wenn true, dann wird der user nicth gechecked	
-- the default bool is 'nil' - this bool is used to add or remove guests 
-- this function checks id, region_attribut and value = bool or value = string (effects - hot, bot, holy, dot, choke, evil)
--
-- return:
--		0				-> wenn alles OK
--		[18] = "ERROR: func: rac:region_set_attribute - No region with this ID! ",
--		[19] = "ERROR: func: rac:region_set_attribute - The region_attribute dit not fit!",
--		[20] = "ERROR: func: rac:region_set_attribute - There is no Player with this name!",
--		[21] = "ERROR: func: rac:region_set_attribute - Wrong effect! ",
--		[22] = "ERROR: func: rac:region_set_attribute - You are not the owner of this region! ",
--		[23] = "ERROR: func: rac:region_set_attribute - No Player with this name is in the guestlist! ",
--
-- msg/error handling: YES
-- check privs / owner
function rac:region_set_attribute(name, id, region_attribute, value, bool,by_function)
	local func_version = "1.0.0"
	local func_name = "rac:region_set_attribute"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
		if name ~= data.owner  then
			local can_modify = rac:player_can_modify_region_id(name)
			if not can_modify.admin and by_function ~= true then
					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - by_function = "..tostring(by_function)	)
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
				--		region_attribute ==
				--			region_name 
				--			erlaubt [a-zA-Z], [ ], [0-9]
				--			wegen der Sprache Deutsch [äöüßÄÖÜ]
				-- eleminieren von gefährlichen Zeichen
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
				if new_effect_string == "" or new_effect_string == nil then
					data.effect = "none"
				else
					data.effect = new_effect_string
				end
				err_msg = err_msg.." Effekt "..value.." gelöscht. "
			end 
		end -- modify the attribute
		
		
		-- update_regions_data(id,pos1,pos2,data)
		if not rac:update_regions_data(id,pos1,pos2,data) then
			return 25 -- [25] = "ERROR: func: rac:region_set_attribute - in update_regions_data! ", 
		end
		if err == 0 then
			rac:msg_handling(err_msg,func_name)
			return 0
		end
	else -- if rac.rac_store:get_area(id) then
		-- Error
		return 24 -- 	[24] = "ERROR: func: rac:region_set_attribute - no region with this ID!",
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
-- input: 
--			id					as number
--			region_attribute 	as sting
--
-- return
--		err, wenn es die id nicht gibt
--		return Value des datafields
--
-- msg/error handling: Yes 
-- 	falls es ID nicht gibt
function rac:get_region_attribute(id, region_attribute)
	local func_version = "1.0.0"
	local func_name = "rac:get_region_attribute"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err,data = rac:get_region_datatable(id)
	if err > 0 then
		rac:msg_handling(err,func_name)
		return err
	end			

	-- check if the attribute is allowed
	if not rac:string_in_table(region_attribute, rac.region_attribute.allowed_region_attribute) then
		-- 		[39] = "ERROR: func: rac:get_region_attribute - The region_attribute did not fit!",
		rac:msg_handling(err,func_name)
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

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:file_exists(file)
-- file exist?
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- input: 
--		file 
-- return:
--	NOTHING
--
-- msg/error handling: no
-- return f
function rac:file_exists(file)
	local func_version = "1.0.0"
	local func_name = "rac:file_exists"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:lines_from(file)
-- get all lines from a file
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- input: 
--	file
-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
-- msg/error handling: no
-- return {} if file does not exist
-- return lines as table
function rac:lines_from(file)
	local func_version = "1.0.0"
	local func_name = "rac:lines_from"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	if not rac:file_exists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do 
	lines[#lines + 1] = line
	end
	return lines
end



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_region_center_by_name_and_pos(name, pos)
-- find the center of a region found by name and pos
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- input:
--		name 	as string
--		pos		as vector
-- get the first area of player at pos 
-- calculate the center and return center_pos 
-- msg/error handling: no 
-- return center_pos as vector
-- retrun 67 --		[67] = "msg: func: rac:get_region_center_by_name_and_pos - keine Region an dieser Position gefunden!",
function rac:get_region_center_by_name_and_pos(name, pos)
	local func_version = "1.0.0"
	local func_name = "rac:get_region_center_by_name_and_pos"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local data_table = {}
	local center_pos = 67 --		[67] = "msg: func: rac:get_region_center_by_name_and_pos - keine Region an dieser Position gefunden!",
	local pos1 , pos2
	-- get all region for this position
	for regions_id, v in pairs(rac.rac_store:get_areas_for_pos(pos)) do
		if regions_id then
			err,pos1, pos2, data_table = rac:get_region_data_by_id(regions_id)
			if err ~= 0 then
				rac:msg_handling(err,func_name)
			end
			if name == rac:get_region_attribute(regions_id, "owner") then
				center_pos = rac:get_center_of_box(pos1, pos2)
				return pos1, pos2, center_pos
			end
		end
	end
	return nil, nil, 67 --		[67] = "msg: func: rac:get_region_center_by_name_and_pos - keine Region an dieser Position gefunden!",
end



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_center_of_box(pos1, pos2)
-- find the center of box with pos1 and pos2
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- input:
--		pos1, pos2		as vector
-- calculate the center and return center_pos 
-- msg/error handling: no 
-- return center_pos as vector
function rac:get_center_of_box(pos1, pos2)
	local func_version = "1.0.0"
	local func_name = "rac:get_center_of_box"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
--	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box pos1 = "..minetest.serialize(pos1) )  
--	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box pos2 = "..minetest.serialize(pos2) )  

	local x,y,z
	x = math.abs( pos1.x - pos2.x ) / 2
	y = math.abs( pos1.y - pos2.y ) / 2
	z = math.abs( pos1.z - pos2.z ) / 2
--	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box x = "..tostring(x) )  
--	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box y = "..tostring(y) )  
--	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box z = "..tostring(z) )  

	if pos1.x < pos2.x then
		x = x + pos1.x
	else
		x = x + pos2.x
	end
	if pos1.y < pos2.y then
		y = y + pos1.y
	else
		y = y + pos2.y
	end
	if pos1.z < pos2.z then
		z = z + pos1.z
	else
		z = z + pos2.z
	end

	return vector.new( x, y, z)
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_regions_in_region(edge1,edge2)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- prüfe ob in der Region zwischen edge1 und edge2 andere Regionen sind 
-- und liefere deren ID zurück
--
-- input:
--		edge1,edge2		as vector
--
-- return:
--	region_id, region_data
--	region_id 				als Table mit key = 1...n und value = region_id 
-- 	region 						als Table mit min,max,data
--
-- msg/error handling: no 
function rac:get_regions_in_region(edge1,edge2)
	local func_version = "1.0.0"
	local func_name = "rac:get_regions_in_region"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	--local counter = 0
	local region_has_regions = rac.rac_store:get_areas_in_area(edge1,edge2,true,true,true) --accept_overlap, include_borders, include_data)
	
	-- die ID der Region ist im Key
	-- zähle die schleife damit man erkennen kann wieviele Region sich hier treffen 
	local region_id = {} -- maximal 3 Region überlappen
	local region = {} -- maximal 3 Region überlappen
	for id, data in pairs(region_has_regions) do	
		--minetest.log("action", "[" .. rac.modname .. "] rac:region_has_regions - counter = "..tostring(counter) )  
--		minetest.log("action", "[" .. rac.modname .. "] rac:region_has_regions - region_has_regions k = "..tostring(id) )  
--		minetest.log("action", "[" .. rac.modname .. "] rac:region_has_regions - region_has_regions v = "..tostring(data) )  
		--counter = counter + 1
		table.insert(region_id, id)
		table.insert(region, data)
	end
	return region_id,region
end



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:draw_border(region_id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- zeichne zu der Id die Border-Box 
--
-- input:
--		region_id
--
-- return:
--	region_id
--	region_id as Table mit key = 1...n und value = region_id 
--
-- msg/error handling: no 
function rac:draw_border(region_id)
	local func_version = "1.0.0"
	local func_name = "rac:draw_border"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	local err,pos1, pos2, data = rac:get_region_data_by_id(region_id)
	local box
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border err = {"..tostring(err).."}" ) 
	if err ~= 0 then
		rac:msg_handling(err,func_name)
	else
		data = rac:get_region_attribute(region_id, "zone")
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border data = {"..tostring(data).."}" ) 
		
		local center = rac:get_center_of_box(pos1, pos2)
		minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border center = {"..tostring(center).."}" )
		-- je nach zone eine andere entity
		if data == "outback" then
			minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border - outback - data = {"..tostring(data).."}" ) 
			box = minetest.add_entity(center, "rac:showarea_outback")	
		elseif data == "city" then
			minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border - city - data = {"..tostring(data).."}" ) 
			box = minetest.add_entity(center, "rac:showarea_city")	
		elseif data == "plot" then
			minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border - plot - data = {"..tostring(data).."}" ) 
			box = minetest.add_entity(center, "rac:showarea_plot")	
		else -- default
			minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border - owned - data = {"..tostring(data).."}" ) 
			box = minetest.add_entity(center, "rac:showarea_default")	
		end
	 

	--			local box = minetest.env:add_entity(center, "rac:showarea")	
		
		box:set_properties({
				visual_size={x=math.abs(pos1.x - pos2.x), y=math.abs(pos1.y - pos2.y), z=math.abs(pos1.z - pos2.z)},
				collisionbox = {pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z},
			})	
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:region_areasquare(edge1,edge2)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- berechnen die Fläche der Region (x,z) 
--
-- input:
--		edge1, edge2 	als Koordinaten
--
-- return:
--	squareblock		als Fläche von x+z 	
--
-- msg/error handling: no 
function rac:region_areasquare(edge1,edge2)
	local func_version = "1.0.0"
	local func_name = "rac:region_areasquare"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local squareblock, a,b
	a = edge1.x - edge2.x
	if a < 0 then a = -a end
	b = edge1.z - edge2.z
	if b < 0 then b = -b end
	squareblock = a * b
	if rac.debug and rac.debug_level > 3 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - edge1: "..tostring(edge1)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - edge2: "..tostring(edge2)	)
		
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - a: "..tostring(a)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - b: "..tostring(b)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - squareblock: "..tostring(squareblock)	)
	end	

	return squareblock
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_stacked_zone_of_region(region_id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- ausgehened von der region_id gibt die Funktion eine Liste zurück.
-- in der Liste stehen alle Zonen zu der gegebenen ID
-- mögliche Resultate:
--	es ist nur die aktuelle Zone betroffen
--			--> Rückgabe des Zonen-Bezeichners
--	es sind mehrere Zonen betroffen
--			--> Rückgabe aller Zonen-Bezeichner, sortiert nach
--				outback, city, plot, owned
--
-- input:
--		region_id			als Integer
--
-- return:
--	stacked_zone		als table 	
--			0					dieser Zonen-Bezeicher war nicht dabei
--			1				dieser Zonen-Bezeicher war dabei
--			2				der Zonen-Bezeicher der übergebenen Zone

--
-- msg/error handling: no 
function rac:get_stacked_zone_of_region(region_id,with_id)
	local func_version = "1.0.0"
	local func_name = "rac:get_zone_stack_of_region"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local stacked_zone = {
			outback = 0,
			city = 0,
			plot = 0,
			owned = 0,
			number = 0,
	}
	if with_id then
		stacked_zone = {
				outback = "-1",
				city = "-1",
				plot = "-1",
				owned = "-1",
		}
	end
	-- hole die min/max der aktuellen zone
	local err, edge1,edge2,region_data = rac:get_region_data_by_id(region_id,false)
	rac:msg_handling(err,func_name)
		
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data.min = "..tostring(region_data.min)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data.max = "..tostring(region_data.max)	)
		
	-- rac:get_regions_in_region(edge1,edge2)
	local found_region_id,found_region_data = rac:get_regions_in_region(edge1,edge2)




	-- hole aus den Ergebnissen die zonen
	-- durchlaufe alle Ergebnisse und setze stacked_zone auf true
	-- baue die Rückgabe-Tabelle
	for key, id in pairs(found_region_id) do
		-- erstelle eine Table aus dem data_string
		found_region_data[key].data = minetest.deserialize(found_region_data[key].data) 
		if with_id ~= true then
			stacked_zone[found_region_data[key].data.zone]=1
		else
			if id ~= region_id then
				stacked_zone[found_region_data[key].data.zone]=id
			else
				stacked_zone[found_region_data[key].data.zone]=id
			end
		end
	end
		
	-- wieviele Regionen gab es zu dieser region_id?
	stacked_zone.number = #found_region_id
	-- region_id war ZONE und wird somit zur aktiven (=2)
	if with_id ~= true then
		stacked_zone[region_data.zone] = 2
	end
	-- Probleme???
	--	auf city können mehrere plot / owned liegen
	-- 	auf outback können mehrere city, plot und owned liegen
	if with_id then
--		stacked_zone[region_data.zone] = region_id
		if region_data.zone == "outback" then
			stacked_zone.outback = region_id
			stacked_zone.city = "-1"
			stacked_zone.plot = "-1"
			stacked_zone.owned = "-1"
		end
		if region_data.zone == "city" then
			stacked_zone.city = region_id
			stacked_zone.plot = "-1"
			stacked_zone.owned = "-1"
			return stacked_zone
		end
	end	
	return stacked_zone
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_stacked_zone_as_string(region_id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- ausgehened von der stacked_zone gibt die Funktion einen String zurück.
-- stacked_zone value wird übersetzt
--			0				rac.zone_text.none "none"/	dieser Zonen-Bezeicher war nicht dabei
--			1				(rac.zone_text...) in Klammern je nach Wert	dieser Zonen-Bezeicher war dabei
--			2				rac.zone_text... je nach Wert	dieser Zonen-Bezeicher war dabei
--
-- input:
--		stacked_zone			als table
--
-- return:
--	string_stacked_zone		als string 	
--
-- msg/error handling: no 
function rac:get_stacked_zone_as_string(region_id)
	local func_version = "1.0.0"
	local func_name = "rac:get_zone_stack_of_region"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local string_stacked_zone = ""
	local table_out = {
			outback = 0,
			city = 0,
			plot = 0,
			owned = 0,
	}
	local stacked_zone = rac:get_stacked_zone_of_region(region_id)
	for zone, value in pairs(stacked_zone) do
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone: "..tostring(zone).." value = "..tostring(value)	)
		if zone ~="number" then
			if value == 1 then
				table_out[zone] = " ("..rac.zone_text[zone]..") "
			elseif  value == 2 then
				table_out[zone] = " "..rac.zone_text[zone].." "
			else
				table_out[zone] = " ("..rac.zone_text.none..") "
			end
		end
	end
	string_stacked_zone = table_out.outback..table_out.city..table_out.plot..table_out.owned
	return string_stacked_zone
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac.markPos1 = function(name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Marks region position 1
--
--
-- input: 
--	name 		as string, playername
-- msg/error handling: no
rac.markPos1 = function(name)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "]  rac.markPos1 = func() - Version: "..tostring(func_version)	)
	end
	local pos = rac.command_players[name].pos1
	minetest.log("action", "[" .. rac.modname .. "]  rac.markPos1 = func() - pos: "..tostring(minetest.serialize(pos) )	)
	if rac.marker1[name] ~= nil then -- Marker already exists
		rac.marker1[name]:remove() -- Remove marker
		rac.marker1[name] = nil
	end
	if pos ~= nil then -- Add marker
		rac.marker1[name] = minetest.add_entity(pos, "rac:pos1")
		rac.marker1[name]:get_luaentity().active = true
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac.markPos2 = function(name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Marks region position 2
--
--
-- input: 
--	name 		as string, playername
-- msg/error handling: no
rac.markPos2 = function(name)
		local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac.markPos2 = func() - Version: "..tostring(func_version)	)
	end
	local pos = rac.command_players[name].pos2
	if rac.marker2[name] ~= nil then -- Marker already exists
		rac.marker2[name]:remove() -- Remove marker
		rac.marker2[name] = nil
	end
	if pos ~= nil then -- Add marker
		rac.marker2[name] = minetest.add_entity(pos, "rac:pos2")
		rac.marker2[name]:get_luaentity().active = true
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:player_is_guest (name,guests_stringe)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- überprüfe ob der Spieler in 'guests_string' seht
--
--
-- input:
--  name							Name des zu testenen Spieler
--  guests_string			Strinf mit einr Liste, mit "," getrennt
--
-- return:
--  true 			if the name is
-- 	return 		false if not
-- 
-- msg/error handling: no
function rac:player_is_guest(name,guests_string)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_is_guest - Version: "..tostring(func_version)	)
	end
	
	local guests_table = rac:convert_string_to_table(guests_string, ",")
	local is_guest = rac:string_in_table(name, guests_table)
	
	return is_guest
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,PvP,MvP,effect,do_not_check_player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- create the designed data string for the AreaStore()
-- TESTE alle Werte ob sie erlaubnt sind
--	andernfalls, msg an player und entweder
--	ERROR oder
-- 	default	
--
-- input:
--		owner								as string,
--		region_name					as string, 
--		claimable						as boolean
--		zone								as string, allowed_zones = { "none", "city", "plot", "owned"  },
--		protected						as boolean
--		guests_string				as string, comma separated Player_names
--		pvp									as boolean
--		mvp									as boolean
--		effect							as string, allowed: dot,hot,bot,choke,holy,evil
--		check_player				as boolean
--
-- return:
--		0,data_string			alles ist OK
--		err 	die Nummer des Fehlers
-- 		data_string for insert_area(edge1, edge2, DATA) as string
-- 			data must be an designed string
--
-- msg/error handling: YES
-- 	err,data_string
function rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:create_data_string - Version: "..tostring(func_version)	)
	end
	-- local err -> is hardcoded!
		-- only for debugging
	if rac.debug == true then
		minetest.log("action", "[" .. rac.modname .. "] **************ÜBERGABE***********************")
		minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
		minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
		minetest.log("action", "[" .. rac.modname .. "] claimable: "..tostring(claimable))
		minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
		minetest.log("action", "[" .. rac.modname .. "] protected: "..tostring(protected))
		minetest.log("action", "[" .. rac.modname .. "] guests_string: "..tostring(guests_string))
		minetest.log("action", "[" .. rac.modname .. "] pvp: "..tostring(pvp))
		minetest.log("action", "[" .. rac.modname .. "] mvp: "..tostring(mvp))
		minetest.log("action", "[" .. rac.modname .. "] effect: "..tostring(effect))
		minetest.log("action", "[" .. rac.modname .. "] do_not_check_player: "..tostring(do_not_check_player))
	end
	-- default do_check_player = true
	-- local do_check_player = true
	if do_not_check_player == nil then -- nicht gesetzt dann check_player = false
		do_not_check_player = false
--		do_check_player = not check_player
	end
	-- check input-values
	-- owner yes? NO = error
	local player = minetest.get_player_by_name(owner)
	-- ist der Owner ein Player
	if player then
		-- alles OK
	elseif do_not_check_player == true then
	-- muss der Player/Owner getestet werden?
	-- do_check_player = false
	-- nein, dann alles OK
	else
	-- es gibt den Player nicht!
	-- er soll aber getestet werden
	-- >>Fehler
		return 4 -- [4] = "ERROR: func: rac:create_data_string - no Player found for owner! ",
	end
	
	-- region_name
	if not type(region_name) == "string" then
		return 5 -- [5] = "ERROR: func: rac:create_data_string - no region name submitted! ",
	end
	
	-- claimable
	if not type(claimable) == "boolean" then
		return 6 -- [6] = "ERROR: func: rac:create_data_string - no claimable set! ",
	end
	
	-- zone
	if not type(zone) == "string" then
		return 7 -- 		[7] = "ERROR: func: rac:create_data_string - no zone set! ", 
	elseif not rac:string_in_table(zone, rac.region_attribute.allowed_zones) then 
		return 8 -- 	[8] = "ERROR: func: rac:create_data_string - zone ist nicht in der Liste! "..tostring(rac.allowed_zones),
	end
	
	-- protected
	if not type(protected) == "boolean" then
		return 9 -- [9] = "ERROR: func: rac:create_data_string - no protected set! ",
	end
	
	-- guests
	if not type(guests_string) == "string" or guests_string == nil then
		return 10 -- [10] = "ERROR: func: rac:create_data_string - no guests set! ",
	end
	
	
	-- pvp
	if not type(pvp) == "boolean" then
		return 11 -- [11] = "ERROR: func: rac:create_data_string - no pvp set! ",
	end
	
	
	-- mvp
	if not type(mvp) == "boolean"  then
		return 12 -- [12] = "ERROR: func: rac:create_data_string - no mvp - Monsterdamage set! ",
	end
	
	-- effect
	if not type(effect) == "string" then
		return 13 -- [13] = "ERROR: func: rac:create_data_string - effect ist nicht in der Liste! "..tostring(rac.allowed_effects),
	end
	if not rac:string_in_table(effect, rac.region_attribute.allowed_effects) then 
		minetest.log("action", "[" .. rac.modname .. "] rac:create_data_string - effect: "..tostring(effect))
		return 14 -- [14] = "ERROR: func: rac:create_data_string - no effect set! ",
	end


	-- only for debugging
	if rac.debug == true then
		minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
		minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
		minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
		minetest.log("action", "[" .. rac.modname .. "] claimable: "..tostring(claimable))
		minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
		minetest.log("action", "[" .. rac.modname .. "] protected: "..tostring(protected))
		minetest.log("action", "[" .. rac.modname .. "] guests: "..tostring(guests_string))
		minetest.log("action", "[" .. rac.modname .. "] pvp: "..tostring(pvp))
		minetest.log("action", "[" .. rac.modname .. "] mvp: "..tostring(mvp))
		minetest.log("action", "[" .. rac.modname .. "] effect: "..tostring(effect))
	end
	-- create the datastring
	-- data = "return {[\"owner\"] = \"playername\", [\"region_name\"] = \"Meine Wiese mit Haus\" , [\"protected\"] = true, 
	--			[\"guests\"] = \"none/List\", [\"PvP\"] = false, [\"MvP\"] = true,
	--			[\"zone\"] = \"city\"  [\"plot\"] = false, [\"effect\"] = \"none\", [\do_not_check_player\] = false}"
	-- because in the datafield could only stored a string
	local data_string = "return {owner = \""..owner.."\", region_name = \""..region_name.."\", claimable = "..tostring(claimable)..
		", zone = \""..zone.."\", protected = "..tostring(protected)..", guests = \""..guests_string..
		"\", pvp = "..tostring(pvp)..", mvp = "..tostring(mvp)..", effect = \""..effect.."\", version = \""..rac.region_attribute.version.."\"}" 
 
	return 0,data_string
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:check_region_attribute_version()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- durchlaufe alle region, 
-- kontrolliere die Version,
-- passse sie an
-- modifiziere den region_data_string
-- speichere die modifizierte Region ab
--
--
-- input:
-- 	nothing
--
-- return:
--	nothing
--
-- msg/error handling: no
-- 	err,id
function rac:check_region_attribute_version()
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - Version: "..tostring(func_version)	)
	end
	local counter = 0 -- die 1. REgion hat immer die ID 0
	local err = 0 -- No Error
	local region_data, new_data_string
	local must_modify = false
	-- Variablen für den aktuellen data_string
	local owner,region_name,claimable,zone,plot,protected,guests_string,pvp,mvp,effect
	local do_not_check_player = true -- den owner nicht checken
	-- durchlaufe alle Regionen
	while rac.rac_store:get_area(counter) do
		-- hole das region_data
		err, region_data = rac:get_region_datatable(counter)
		if err == 0 then
			rac:msg_handling(err)
		end
		-- prüfe version
		if region_data.version == nil then -- altes RAZ, frühes rac
			must_modify = true
			if rac.region_attribute.version == "1.0" then
				-- anpassen von NICHTS auf version 1.0
				-- rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,PvP,MvP,effect,do_not_check_player)
				-- RAC defaults
				-- region_attribute = {"owner", "region_name", "protect", "guest", "PvP", "MvP", "effect", "plot", "city", },
				-- region_effects = { "none", "hot", "bot", "fot", "holy", "dot", "starve", "choke", "evil", }
				-- Änderungen / identisches
				-- "owner" -- identisch
				owner = region_data.owner
				-- "region_name" -- identisch
				region_name = region_data.region_name
				-- "protect",
						-- ändern ist nun protected
						-- prüfen, bei den ersten rac gab es schon proteced aber keine version
				if region_data.protect ~= nil then
					protected = region_data.protect		 
				elseif region_data.protected  ~= nil then
					protected = region_data.protected		 
				else -- das Feld gibt es nicht, dann default
					protected = rac.region_attribute.protected
				end
				-- "guest",
						-- ändern ist nun guests
						-- prüfen, bei den ersten rac gab es schon guests aber keine version
				if region_data.guest ~= nil then
					guests_string = region_data.guest		 
				elseif region_data.guest  ~= nil then
					minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - region_data.protected ~= nil "..tostring(region_data.protected)	)
					minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - region_data.protected = "..tostring(region_data.protected)	)
					guests_string = region_data.guests		 
				else -- das feld gibt es nicht, dann default
					guests_string = rac.region_attribute.guests
				end				
				-- "PvP",
				-- ändern ist nun pvp
						-- prüfen, bei den ersten rac gab es schon pvp aber keine version
				if region_data.PvP ~= nil then
					pvp = region_data.PvP		 
				elseif region_data.pvp  ~= nil then
					pvp = region_data.pvp		 
				else -- das feld gibt es nicht, dann default
					pvp = rac.region_attribute.pvp
				end	
				-- "MvP",
				-- ändern ist nun pvp
						-- prüfen, bei den ersten rac gab es schon mvp aber keine version
				if region_data.MvP ~= nil then
					mvp = region_data.MvP		 
				elseif region_data.mvp  ~= nil then
					mvp = region_data.mvp		 
				else -- das feld gibt es nicht, dann default
					mvp = rac.region_attribute.mvp
				end	
				-- "effect", sollte identisch sein
				if not rac:string_in_table(region_data.effect, rac.region_attribute.allowed_effects) then 
					rac:msg_handling(51) -- 		[51] = "ERROR: func: rac:check_region_attribute_version - unpassenden Effect gefunden!",
					-- setze effect auf "none"
					effect = "none"
				else
					effect = region_data.effect
				end		 
				-- "city", -- muss angepasst werden, city ist nun eine zone
				if region_data.city ~= nil then
					zone = "city"
					-- prüfe plot
					plot = region_data.plot
					if plot then
						zone = "plot"
						claimable = true
					else
						claimable = false
					end
				else --city nicht gefunden
					-- prüfe zone
					if region_data.zone == nil then
						rac:msg_handling(52) -- [52] = "ERROR: func: rac:check_region_attribute_version - keine City und keine Zone gefunden, setzte default!",
						zone = rac.region_attribute.zone
						claimable = rac.region_attribute.claimable
					else -- zone gib es also altes rac ohne Version
						zone = region_data.zone
						-- prüfe claimable
						if region_data.claimable == nil then
							-- setzte default
							claimable = rac.region_attribute.claimable
						else
							claimable = region_data.claimable
						end
					end -- if region_data.zone == nil then
				end -- if region_data.city ~= nil then
			end -- if rac.region_attribute.version = "1.0" then
		end -- if region_data.version == nil then -- altes RAZ
		
		-- es muss angepasst werden!
		if must_modify then
			-- erstelle den neuen data_string
				-- only for debugging
			if rac.debug == true then
				minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
				minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
				minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
				minetest.log("action", "[" .. rac.modname .. "] claimable: "..tostring(claimable))
				minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
				minetest.log("action", "[" .. rac.modname .. "] protected: "..tostring(protected))
				minetest.log("action", "[" .. rac.modname .. "] guests_string: "..tostring(guests_string))
				minetest.log("action", "[" .. rac.modname .. "] pvp: "..tostring(pvp))
				minetest.log("action", "[" .. rac.modname .. "] mvp: "..tostring(mvp))
				minetest.log("action", "[" .. rac.modname .. "] effect: "..tostring(effect))
				minetest.log("action", "[" .. rac.modname .. "] do_not_check_player: "..tostring(do_not_check_player))
			end
			err, new_data_string = rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,do_not_check_player)
			minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - region_data: "..tostring(minetest.serialize(region_data))	)
			minetest.log("action", "[" .. rac.modname .. "] rac:check_region_attribute_version - new_data_string: "..tostring(new_data_string)	)
			rac:msg_handling(err) 
		end
		must_modify = false
		
		
		counter = counter + 1
	end -- end while
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:set_region(pos1,pos2,data)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- erzeuge eine neue region, 
-- update AreaStore,
-- save AreaStore
--
--
-- input:
-- 		pos1, pos2 		as vector
-- 		data 			as (designed) string 
--	  	use: rac:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,city,do_not_check_player)
-- 			because in the datafield could only stored a string	
--
-- return:
--	err
--  id of new region
--
-- msg/error handling: YES
-- 	err,id
function rac:set_region(pos1,pos2,data)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0


	-- falls data als Tabelle kommt
	if type(data) ~= "string" then
		if type(data) == "table" then
			data = minetest.serialize(data)
		else
			-- data war kein String und keine table
			return 15 --[15] = "ERROR: func: rac:set_region - übergebenes 'data' war weder table noch string!!!",
		end
	end
	-- füge alles in den Store
	local id = rac.rac_store:insert_area(pos1, pos2, data)
	-- speichere den store
	rac.save_regions_to_file()
	-- liefere err, id zurück
	return err,id
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_owner_by_region_id(id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- hole den data_string einer Region  
--
--
-- input: 
--	id			number mit der ID der Region
--
-- return
--  err
--	owner 		as String
--
-- msg/error handling: YES
--	err, data 
function rac:get_owner_by_region_id(id)
	local func_version = "1.0.0"
	if rac.show_func_version then -- and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_owner_by_region_id - Version: "..tostring(func_version)	)
	end
	if rac.debug then -- and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_owner_by_region_id - id: "..tostring(id)	)
	end
	local err = 0
	local data 
	--	no_deserialize == false
	err,data = rac:get_region_datatable(id)
	if err > 0 then
		return err
	elseif data.owner ~= nil then
		return 0,data.owner
	end
	return 17 -- [17] = "ERROR: func: rac:get_owner_by_region_id - no owner in Region with this ID!",	
	end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:marker_placed( pos, placer, itemstack )
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Die Marker immer gesetzt werden, die Marker löschen sich selbständig nach rac.marker_delete_time
-- Setze einen Marker pos1 oder pos2
-- Wurde der 2. Marker gesetz wird das Gebiet versucht zu claimen
-- 	dort in der Claim-Funktion
--		stimmen die Privs
--		gibt es pos1 und pos1
--		ist kein anderes Gebiet betroffen
--		ja 		- Claim 	- return 0
--		nein 	- Error		- return error
--
-- input: 
--		pos				als Positionsvektor
--		placer 		als Player-Object
-- 		itemstack
--
-- return:
--	nothing
--
-- msg/error handling: yes
--	prüfe die Privilegien
function rac:marker_placed( pos, placer, itemstack )
	local func_version = "1.0.0"
	local func_name = "rac:marker_placed"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	--sind pos und placer vorhanden
  if( not( pos ) or not( placer )) then
  	return;
  end


	-- die Metawerte eines Nodes an einem Ort (ist ein String)
  local meta = minetest.get_meta( pos );
  
  -- der placer by name  
  local name = placer:get_player_name();

  meta:set_string( 'infotext', 'Marker at '..minetest.pos_to_string( pos )..
				' (placed by '..tostring( name )..'). '..
				'Right-click to update.');
  meta:set_string( 'owner',    name );
  -- this allows protection of this particular marker to expire
  meta:set_string( 'time',     tostring( os.time()) );
	minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.list_of_marker mit pos gesetzt = "..tostring(pos)	)
  -- table.insert(rac.list_of_marker, pos)



	-- setzte pos1 oder pos2 in gang 
	-- ist schon ein command_players.pos1 vorhanden dann fülle pos2 ansonsten pos1 
	-- geht das anlog zu command region pos1?
	-- noch ist nichts gesetzt
	if not rac.command_players[name] then
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Setze Ecke 1: "	)
		err = rac:command_pos(name,pos,1,false)
		rac:msg_handling(err,func_name)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] name = "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] pos1 = "..tostring(rac.command_players[name].pos1)	)
		
	else
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Setze Ecke 2: "	)
		err = rac:command_pos(name,pos,2,false)
		rac:msg_handling(err,func_name)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] name = "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] pos2 = "..tostring(rac.command_players[name].pos2)	)

		-- checke Logik, passt der Raum usw.
		-- rufe set_region auf, evtl. FORM?
		-- lösche rac.command[name] ist nicht nötig, das macht rac:command_set
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - versuche das Gebiet zu setzen. "	)
		-- teste die Höhe (y-Werte)
		-- speicher die Position für später 
		local pos1 = rac.command_players[name].pos1
		local pos2 = rac.command_players[name].pos2
		local region_height = math.abs(rac.command_players[name].pos1.y - rac.command_players[name].pos2.y)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - region_high = "..tostring(region_height)	)
		-- falls die Höhe nicht passt
		if region_height < rac.minimum_height then
			-- mach es 2 tiefer und 2 höher
			if rac.command_players[name].pos1.y < rac.command_players[name].pos2.y then
				rac.command_players[name].pos1.y = rac.command_players[name].pos1.y - rac.marker_modify_height
				rac.command_players[name].pos2.y = rac.command_players[name].pos2.y + rac.marker_modify_height
			else
				rac.command_players[name].pos1.y = rac.command_players[name].pos1.y + rac.marker_modify_height
				rac.command_players[name].pos2.y = rac.command_players[name].pos2.y - rac.marker_modify_height
			end		
		end
		local randomNumber = math.random(#rac.area_names) --Also returns a number between 1 and #rac.area_names
		local region_name = string.gsub(rac.area_names[randomNumber],"{name}",name)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - randomNumber = "..tostring(randomNumber)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - region_name = "..tostring(region_name)	)
		-- mit den ggf um rac.marker_modify_height veränderten Höhe wird das Gebiet angelegt
		-- region_name muss um 4 verlängert werden, da command_set links was abschneidet.
		err = rac:command_set("set "..region_name, name) 
		rac:msg_handling(err,func_name)	
		rac.command_players[name] = nil	

			
	end		
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:can_player_set_region(edge1, edge2, name)
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
-- input: 
--		edge1, edge2	as vector (table)
--		name			as string (playername)
-- 
-- return:
--  	can_set_region,zone_table 	von rac:player_can_create_region(edge1, edge2, name, modify_region_id)
--
function rac:can_player_set_region(edge1, edge2, name)
	local func_version = "1.0.0"
	local func_name = "rac:can_player_set_region"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local modify_region_id = false
	local can_set_region,zone_table = rac:can_player_create_region(edge1, edge2, name, modify_region_id)
	--	return false,zone_table
	return can_set_region,zone_table
end	
	
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:can_player_create_region(edge1, edge2, name, modify_region_id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Gibt es in dem Bereich, dieser neuen Region andere Regionen?
-- - keine andere Region: jeder mit region_set darf setzen
-- - eine andere Region: diese ist "city" -> admin kann plot oder outback setzen
-- - eine andere Region: diese ist "outback" -> admin kann plot oder city setzen
-- - zwei andere Regionen: outback und city -> admin kann plot
-- - eine andere Region: diese ist "plot" dann darf man nichs setzen
-- wird modify_region_id angegeben, wird diese region_id aus der Liste gelöscht, 
--		es wird die neue Region mit	edge1, edge2 betrachtet. 
-- 		can_modify.set / player wird nicht berücksichtigt
--		es wird mit con_modify.admin == true getestet.
--
-- input: 
--		edge1, edge2				as vector (table)
--		name								als String (playername)
--		modify_region_id 		als Nummer / false
-- 
-- return:
--  	true/false, table
--		true 		Gebiet setzen ist erlaubt
--		false 	Das Gebiet kann nicht gesetzt werden
-- 		Table 	was der admin setzen kann
--			zone_table = {
--						player=false, 					-- false = admin, true = Player
--						plot_id = nil,					-- die ID des Plots, damit ein Player ihn ownen kann
--						plot = true, 						-- kann nur von admin gesetzt werden
--						city = true, 						-- kann nur von admin gesetzt werden
--						outback = true, 				-- kann nur von admin gesetzt werden 
--
--
-- msg/error handling: YES
-- return 31 -- "ERROR: func: rac:can_player_set_region - Dir fehlt das Privileg 'region_set! ",
-- return 32 -- "msg: Your region is too small (x)!",
-- return 33 -- "msg: Your region is too small (z)!",
-- return 34 -- "msg: Your region is too small (y)!",
-- return 35 -- "msg: Your region is too width (x)!",
-- return 36 -- "msg: Your region is too width (z)!",
-- return 37 -- "msg: Your region is too hight (y)!",
-- return 38 -- "msg: There are other region in. You can not mark this region",
-- return 42 -- [42] = "ERROR: func: rac:command_pos - kein Spieler mit dem Namen gefunden",	
function rac:can_player_create_region(edge1, edge2, name, modify_region_id)
	local func_version = "1.0.0"
	local func_name = "rac:can_player_create_region"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err
	local found_plot = false
	
	-- check if player, get privilegs
	local player = minetest.get_player_by_name(name)
	if not player then 
		return 45 -- [42] = "ERROR: func: rac:command_pos - kein Spieler mit dem Namen gefunden",
	end 
	local can_modify = rac:player_can_modify_region_id(player)	
	if can_modify.admin == false and can_modify.set == false then 
		return 31 --[31] = "ERROR: func: rac:can_player_set_region - Dir fehlt das Privileg 'region_set! ",
	end

	-- nur der Spieler hat max/min Werte
	if can_modify.set then
	--[[
		-- check minimum
		if math.abs(edge1.x - edge2.x) < rac.minimum_width then 
			return 32 -- [32] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu schmal (x)!",
		end
		if math.abs(edge1.z - edge2.z) < rac.minimum_width then 
			return 33 --[33] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu schmal (z)!",
		end
		if math.abs(edge1.y - edge2.y) < rac.minimum_height then 
			return 34 -- [34] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu schmal (y)!",
		end
		-- check maximum
		if math.abs(edge1.x - edge2.x) >= rac.maximum_width then 
			return 35 -- [35] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu weit (x)!",
		end
		if math.abs(edge1.z - edge2.z) >= rac.maximum_width then 
			return 36 -- [36] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu weit (z)!",
		end
		if math.abs(edge1.y - edge2.y) >= rac.maximum_height then 
			return 37 -- [37] = "ERROR: func: rac:can_player_set_region - Das Gebiet ist zu hoch (y)!",
		end	
]]--
	end --if can_modify.set then
	
	-- Definition der Rückgabewerte
	-- in zone_table wird zurückgegeben, welche zone gesetzt werden kann.
	-- player = false, der admin
	-- player = true, der Spieler, kann nur plot oder owned setzen
	local zone_table = {
			player=false, 					-- false = admin, true = Player
			plot_id = nil,					-- die ID des Plots, damit ein Player ihn ownen kann
			plot = false, 						-- kann nur von admin gesetzt werden
			city = false, 						-- kann nur von admin gesetzt werden
			outback = false, 				-- kann nur von admin gesetzt werden
			}
	-- Rückgabewert, ob die Region gesetzt werden darf	
	local set_zone_table = function (string, value)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - set_zone_table string = "..tostring(string).." value = "..tostring(value)	)	
		-- keine Prüfung von string und value
		if string == "owned" then 
			zone_table.owned = value
		elseif string == "plot" then 
			zone_table.plot = value
		elseif string == "city" then 
			zone_table.city = value
		elseif string == "outback" then 
			zone_table.outback = value
		elseif string == "player" then 
			zone_table.outback = value
		elseif string == "plot_id" then 
			zone_table.outback = value
		end
	end
	local can_set_region = false 
	
	
	-- prüfe ob in andere Regionen davon betroffen sind
	local region_id,region = rac:get_regions_in_region(edge1,edge2)
		-- region_id 		Table der Region IDs
		-- region				Table der Region Datas 
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_id und region geholt" ) 	 
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_id  "..tostring(#region_id) ) 	 
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - type(region_data)  "..tostring(type(region)) ) 	
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data: "..tostring(minetest.serialize(region))	)	
--	region_data = minetest.serialize(region_data)
	if #region_id ~= 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].max: "..tostring(region[1].max)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].min: "..tostring(region[1].min)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - type(region[1].data:  "..tostring(type(region[1].data)) ) 	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - String region[1].data: "..tostring(region[1].data).."\n"	)
	end
	-- wandel String in Table um	(DESERIALISE)
--	region[1].data = minetest.deserialize(region[1].data) 
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - nach der Umwandlung type(region[1].data:  "..tostring(type(region[1].data)) ) 	
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].zone: "..tostring(region[1].data.zone)	)	

	-- modify_region_id beachten!
	--		nil oder false 									region_id so wie es ist
	-- 		tonumber(modify_region_id) 			~= nil, dann wurde eine region_id übergeben
	--																				löschen aus region_id
	if modify_region_id ~= nil or modify_region_id ~= false then
		if tonumber(modify_region_id) ~= nil then  -- eine Zahl wurde übergeben
			for key,id in ipairs(region_id) do
				if modify_region_id == id then
					-- die Übergebene ID aus der Liste entfernen
					table.remove(region_id,key)
					table.remove(region,key)
					-- setzte zum Testen can_modify.admin auf true
					can_modify.admin = true
				end
			end
		end
	end
	
	
	
	-- es wurde keine andere Region gefunden
	if #region_id == 0 then 
		-- Player mit can_modify.set = true
		if can_modify.admin then
			-- setzte die Region mit zone = outback
			minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - keine Region, Player - #region_id == 0 " )  
			zone_table = {
				player=false, 					-- true = Player
				plot_id = nil,				
				plot = false, 				-- kann nur von admin gesetzt werden
				city = false, 				-- kann nur von admin gesetzt werden
				outback = true, 			-- kann nur von admin gesetzt werden
				}
				can_set_region = true -- player darf setzen		
		else
			-- setzte die Region mit zone = owned
			minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - keine Region, Player - #region_id == 0 " )  
			zone_table = {
				player=true, 					-- true = Player
				plot_id = nil,				
				plot = false, 				-- kann nur von admin gesetzt werden
				city = false, 				-- kann nur von admin gesetzt werden
				outback = false, 			-- kann nur von admin gesetzt werden
				}
			can_set_region = true -- player darf setzen
		end
	elseif #region_id == 1 then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - keine Region, Player - #region_id == 1 " )  
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_id  "..tostring(#region_id) ) 
		-- wandel String in Table um	(DESERIALISE)
		region[1].data = minetest.deserialize(region[1].data) 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Betroffene region_id[1]: "..tostring(region_id[1])	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].max: "..tostring(region[1].max)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].min: "..tostring(region[1].min)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[1].data.zone: "..tostring(region[1].data.zone)	)	
		-- #region_id == 1
		--	falls:
		--		outback			-> city anlegen
		--		city, prüfe die Größe
		--			kleiner:	-> plot anlegen
		--			größer:		-> outback anlegen
		--		plot und name ist ein Player
		--			return PlotID zur übernahme
		local zone = region[1].data.zone 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Betroffen Region ist diese zone: "..tostring(zone)	)	
		if zone == "outback" then
			zone_table = {
				player=false, 				-- false = admin
				plot_id = nil,				
				plot = false, 				-- kann nur von admin gesetzt werden
				city = true, 					-- kann nur von admin gesetzt werden
				outback = false, 			-- kann nur von admin gesetzt werden
				}
			can_set_region = true -- player darf setzen
		elseif zone == "city" then
			if rac:region_areasquare(edge1,edge2) < rac:region_areasquare(region[1].min,region[1].max) then
				zone_table = {
					player=false, 				-- false = admin
					plot_id = nil,				
					plot = true, 					-- kann nur von admin gesetzt werden
					city = false, 				-- kann nur von admin gesetzt werden
					outback = false, 			-- kann nur von admin gesetzt werden
					}
				can_set_region = true -- player darf setzen
			else
				zone_table = {
					player=false, 				-- false = admin
					plot_id = nil,				
					plot = false, 				-- kann nur von admin gesetzt werden
					city = false, 				-- kann nur von admin gesetzt werden
					outback = true, 			-- kann nur von admin gesetzt werden
					}
				can_set_region = true -- player darf setzen
			end
		elseif zone == "plot" and can_modify.admin == false then
			-- sicher gehen, dass es kein admin ist!
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Zone ist plot, can_modify.admin == false") 	
			zone_table = {
				player=true, 					-- true = player
				plot_id = region_id[1],				
				plot = false, 				-- kann nur von admin gesetzt werden
				city = false, 				-- kann nur von admin gesetzt werden
				outback = false, 			-- kann nur von admin gesetzt werden
				}
			can_set_region = true -- player darf setzen
		elseif (zone == "plot" or zone == "owned" ) and can_modify.admin == true then
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Zone ist plot/owned, can_modify.admin == true") 	
			-- sicher gehen, dass es der admin ist!
			zone_table = {
				player=false, 					-- false = admin
				plot_id = region_id[1],				
				plot = false, 				-- kann nur von admin gesetzt werden
				city = false, 				-- kann nur von admin gesetzt werden
				outback = true, 			-- kann nur von admin gesetzt werden
				}
			can_set_region = true -- player darf setzen
		end
	elseif #region_id > 1 then	
		zone_table = {
				player=false, 					-- false = admin
				plot_id = nil,				
				plot = true, 				-- kann nur von admin gesetzt werden
				city = true, 				-- kann nur von admin gesetzt werden
				outback = true, 		-- kann nur von admin gesetzt werden
				owned = true				-- nur zum check wichtig
				}
		local check_region_id, check_region
		can_set_region = true -- player darf setzen
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_id > 1 #region_id = "..tostring(#region_id) ) 	 
		for key, id in pairs(region_id) do
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - \n\nloop region_id key = "..tostring(key).." id = "..tostring(id)	)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[key].max: "..tostring(region[key].max)	)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[key].min: "..tostring(region[key].min)	)	
			-- wandel String in Table um	(DESERIALISE)
			region[key].data = minetest.deserialize(region[key].data) 
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[key].data.regoin_name: "..tostring(region[key].data.region_name)	)
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[key].data.zone: "..tostring(region[key].data.zone)	)
			-- ist das ein plot, ist der claimable?
			if region[key].data.zone == "plot" then
				-- prüfe can_modify ~= admin
				if can_modify.admin == false then
					-- prüfe claimable
					if region[key].data.claimable then
						zone_table = {
							player=true, 				-- true = player
							plot_id = key,				
							plot = false, 			-- kann nur von admin gesetzt werden
							city = false, 			-- kann nur von admin gesetzt werden
							outback = false,	 	-- kann nur von admin gesetzt werden
							owned = true				-- nur zum check wichtig
						}
						found_plot = true
						can_set_region = true -- player darf setzen
					end -- if check_region[key].data.claimable then
				end -- if can_modify.admin == false then
			end	-- if check_region[key].data.zone = "plot" then	
		end -- for key, id in pairs(region_id) do
	end -- elseif #region_id > 1 then	
	
		-- falls ja, liegen die nebeneinander oder übereinander?
		-- loop alle Gebiete
		--	ist das Gebiet in einem weiteren Gebiet?
		--		nein, dann Gebiet
		--				zone merken, denn diese zone darf nicht verwendet werden
		--		mehr als 2
		--				verboten, denn es können nicht mehr als 3 Regionen übereinander liegen
		--		ja, dann prüfe Zone
		--			erlaubt: 	
		--				outback mit 	city, plot oder owned
		--				city mit			outback, plot oder owned
		--			verboten:
		--				plot - plot oder owned
		--				Meldung an Admin
		--				sollte eigentlich nicht vorkommen
		--				Problem, rac-guide admin set_zone!
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - \n\n Begin Checke Regionen im neuen Gebiet"	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - neues Gebiet min = "..tostring(edge1)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - neues Gebiet max = "..tostring(edge2).."\n"	)	
		-- -179,19,73 / 207,20,53   -> edge1 / edge2 = -179,17,73 / -207,22,53 --WARUM!!!!

	if #region_id > 1 and found_plot == false then
		for key, id in pairs(region_id) do
			check_region_id, check_region = rac:get_regions_in_region(region[key].max, region[key].min)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id key = "..tostring(key)	)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region[key].min = "..tostring(region[key].min)	)	

			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region[key].max = "..tostring(region[key].max)	)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region[key].zone = "..tostring(region[key].data.zone)	)	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region[key].region_name = "..tostring(region[key].data.region_name).."\n"	)	
			if #check_region_id ~= nil then
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #check_region_id "..tostring(#check_region_id)	)
			end
			-- kein anderes Gebiet betroffen
			-- zone auf false stellen
			if #check_region_id == 0 then
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id"	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id == 0 ")	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id = "..tostring(key).." id = "..tostring(id)	)	
				
				set_zone_table(region[key].data.zone, false)
				
			elseif #check_region_id == 1 then
				check_region[1].data = minetest.deserialize(check_region[1].data) 
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id"	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id == 1 ")	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id = "..tostring(key).." id = "..tostring(id)	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop zone key = "..tostring(region[key].data.zone).." region_name = "..tostring(region[key].data.region_name)	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop zone[1] = "..tostring(check_region[1].data.zone).." region_name = "..tostring(check_region[1].data.region_name)	)	

				set_zone_table(check_region[1].data.zone, false)

			elseif #check_region_id == 2 then
				check_region[1].data = minetest.deserialize(check_region[1].data) 
				check_region[2].data = minetest.deserialize(check_region[2].data) 
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id"	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id == 2 ")	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id = "..tostring(key).." id = "..tostring(id)	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop zone key = "..tostring(region[key].data.zone).." region_name = "..tostring(region[key].data.region_name)	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop zone[1] = "..tostring(check_region[1].data.zone).." region_name = "..tostring(check_region[1].data.region_name)	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop zone[2] = "..tostring(check_region[2].data.zone).." region_name = "..tostring(check_region[2].data.region_name)	)	
				-- beide city oder outback?
				--	ja, dann fehler, 2 überlappende zonen dürfen nicht gleich sein
				-- nein, dann table_zone ohne diese zonen-Bezeichner
				if check_region[1].data.zone == check_region[2].data.zone then
					-- 	[72] = "ERROR: func: can_player_set_region - Bezeichner Zone1 ist gleich Zone2.",
					rac:msg_handling(72,func_name)
					can_set_region = false
				else
					-- diese Zone dürfen nicht verwendet werden
					set_zone_table(check_region[1].data.zone, false)
					set_zone_table(check_region[2].data.zone, false)
				end	
				
			elseif #check_region_id > 2 then
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id"	)	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id > 2 ")	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - loop #check_region_id = "..tostring(key).." id = "..tostring(id)	)	
				-- 		[73] = "ERROR: func: can_player_set_region - Mehr als 2 Zonen überlappen.",
				rac:msg_handling(73,func_name)
				can_set_region = false
			end
		end	
		-- nebeneinander sollte bedeuten 
		--		eine city und plots / owned
		--		oder outback mit city/oder citys und plots / owned
		--		plots/owned
		-- übereinander darf je pos nur maximal 3 sein
		--	outback, city, plot/owned
		-- 	nie 2 gleiche zonen
		-- 	nie owned/plot
		-- Auswahltentscheidungen  
		--  2 oder mehr outback -> geht nicht, err outback können nicht gestapelt werden
		--	1 oder mehr city,	aber kein outback 		-> outback anlegen
		--	sind owned / plot betroffen, muss jeder mit region_has_regions(min,max) getestet werden
		--		Stapel betrachten
		--		es dürfen keine 2 gleichen zonen sein!
		--		es dürfen max 2 Regionen sein (die 3. soll angelegt werden )
		--			falls plot/owned und city 					-> outback anlegen
		--			falls plot/owned und outback 				-> city anlegen									
	elseif #region_id == 3 then
		-- 
	elseif #region_id > 3 then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions > 3  "	)		
		return 38 -- [38] = "ERROR: func: rac:can_player_set_region - Andere Gebiete sind davon betroffen, du kannst das so nicht claimen!",
	end
	
	if rac.debug and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." #### RETRUN #####: "	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #region_id war: "..tostring(#region_id) ) 	 
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - can_set_region: "..tostring(can_set_region)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone_table.player: "..tostring(zone_table.player)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone_table.plot_id: "..tostring(zone_table.plot_id)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone_table.outback: "..tostring(zone_table.outback)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone_table.city: "..tostring(zone_table.city)	)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - zone_table.plot: "..tostring(zone_table.plot)	)	
	end	
--	return false,zone_table
	return can_set_region,zone_table
end



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:regions_by_zone()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- durchlaufe alle Regionen 
-- erstelle eine Übersicht nach
-- 		outback, city, plot, owned
--
-- input:
--		name 		mit dem Spielername
--		all	=		nil 	-> dann wird nur die Sortierung ausgegeben
--		all =		full  -> dann mit den Attributen id: zone, owner, name, claimable,protected, guests, pvp, mvp, effect 
--
-- return:
--		0								alles OK
--		return 84 -- 		[84] = "info: func: rac:regions_by_zone - keine Admin-Berechtigung",
-- msg/error handling: no 
function rac:regions_by_zone(name,all)
	local func_version = "1.0.0"
	local func_name = "rac:regions_by_zone"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local can_modify = rac:player_can_modify_region_id(name)	
	-- ist can.modify.admin --> weiter
	if not can_modify.admin then
		return 84 -- 		[84] = "info: func: rac:regions_by_zone - keine Admin-Berechtigung",
	end
	
	local with_id = true
	local region_id = 0
	local outback = {}
	local city = {}
  -- durchlaufe alle Ergebnisse und setze stacked_zone auf true
	-- baue die Rückgabe-Tabelle
	local err, pos1,pos2,data -- = rac:get_region_data_by_id(region_id,true)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - err bei region_id = 0: "..tostring(err)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - all = "..tostring(all)	)
	local new_city_order = {}
	local region_order = {}
	local new_order = {}
	local this_input = {}
	local count_table_lines = 0
		
	while rac.rac_store:get_area(region_id) do
		-- hole das region_data, data als Table!
		err, pos1,pos2,data = rac:get_region_data_by_id(region_id,true)
		rac:msg_handling(err,func_name)

		local stacked_zone = rac:get_stacked_zone_of_region(region_id,with_id)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - stacked_zone.outback: "..tostring(stacked_zone.outback)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - stacked_zone.city: "..tostring(stacked_zone.city)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - stacked_zone.plot: "..tostring(stacked_zone.plot)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - stacked_zone.owned: "..tostring(stacked_zone.owned)	)
		
		
		local zone = rac:get_region_attribute(region_id, "zone")
		region_id = region_id + 1
		table.insert(region_order, stacked_zone )
	
	end
	table.sort(region_order, function(a,b) return (tostring(a.outback) < tostring(b.outback))  end )



	for key,id in ipairs(region_order) do
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - key: "..tostring(key).." --- .outback = "..tostring(region_order[key]["outback"]	)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - stacked_zone.outback: "..tostring(region_order[key]["outback"]	) )
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." --- .city: "..tostring(region_order[key]["city"] ) )
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." --- .plot: "..tostring(region_order[key]["plot"] ) )
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." --- .owned: "..tostring(region_order[key]["owned"] ) )
		
		
		if key > 1 then
			if (region_order[key]["outback"] == region_order[(key-1) ]["outback"]) then
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - - - - order[key][outback] == order[(key-1) ][outback]) "..tostring(region_order[key]["outback"])	)
				this_input = {}
				this_input = {
					outback = region_order[key]["outback"],
					city = region_order[key]["city"],
					plot = region_order[key]["plot"],
					owned = region_order[key]["owned"]
				}
				table.insert(new_city_order, this_input )
			else
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - - - - order[key][outback] ~= order[(key-1) ][outback]) "..tostring(region_order[key]["outback"])	)
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - order[key][outback]: "..tostring(region_order[key]["outback"]	) )
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - order[(key-1)][outback]: "..tostring(region_order[(key-1)]["outback"]	) )

				table.sort(new_city_order, function(a,b) return (tostring(a.city) < tostring(b.city))  end )
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - nach der Sortierung der City!"	)
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #new_city_order = "..tostring(#new_city_order)	)
				for k,_ in ipairs(new_city_order) do
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - k = "..tostring(k)	)
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .outback: "..tostring(region_order[(key-1)]["outback"]	) )
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .city: "..tostring(new_city_order[k]["city"] ) )
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .plot: "..tostring(new_city_order[k]["plot"] ) )
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .owned: "..tostring(new_city_order[k]["owned"] ) )		
					count_table_lines = count_table_lines + 1		
					table.insert(new_order, new_city_order[k] )
				end
				new_city_order = {}
				this_input = {}
				this_input = {
					outback = region_order[key]["outback"],
					city = region_order[key]["city"],
					plot = region_order[key]["plot"],
					owned = region_order[key]["owned"]
				}
				table.insert(new_city_order, this_input )
			end
		else
			this_input = {}
			this_input = {
				outback = region_order[key]["outback"],
				city = region_order[key]["city"],
				plot = region_order[key]["plot"],
				owned = region_order[key]["owned"]
			}
			table.insert(new_city_order, this_input )
		end
		
	end
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - count_table_lines = "..tostring(count_table_lines)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #region_order = "..tostring(#region_order)	)
	if count_table_lines < #region_order then
		for k,_ in ipairs(new_city_order) do
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - k = "..tostring(k)	)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .outback: "..tostring(region_order[(#region_order)]["outback"]	) )
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .city: "..tostring(new_city_order[k]["city"] ) )
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .plot: "..tostring(new_city_order[k]["plot"] ) )
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .owned: "..tostring(new_city_order[k]["owned"] ) )		
			count_table_lines = count_table_lines + 1	
			table.insert(new_order, new_city_order[k] )	
		end
	end
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #new_order = "..tostring(#new_order)	)
	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - der neue String new_order"	)
	
	local once = true
	local chat_string	
	local this_id
	for k,_ in ipairs(new_order) do
 		-- Ausgabe an den Spieler
		if once then
			once = false
			minetest.chat_send_player(name, "Ausgabe der Zonen, sortiert nach outback, city!")
		end
		if tostring(new_order[(k)]["outback"]	) > tostring(0) then
			chat_string = "outback (id = "..tostring(new_order[(k)]["outback"] )..") "
			this_id = new_order[(k)]["outback"]
		else
			chat_string = "- - - - - - - - "
		end
		if tostring(new_order[(k)]["city"]	) > tostring(0) then
			chat_string = chat_string.."city (id = "..tostring(new_order[(k)]["city"] )..") "
			this_id = new_order[(k)]["city"]
		else
			chat_string = chat_string.." - - - - - - "
		end	
		if tostring(new_order[(k)]["plot"]	) > tostring(0) then
			chat_string = chat_string.."plot (id = "..tostring(new_order[(k)]["plot"] )..") "
			this_id = new_order[(k)]["plot"]
		end
		if tostring(new_order[(k)]["owned"]	) > tostring(0) then
			chat_string = chat_string.."owned (id = "..tostring(new_order[(k)]["owned"] )..") "
			this_id = new_order[(k)]["owned"]
		end
		if all == "full" then
			--minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - .this_id: "..tostring(this_id ) )		
			err, pos1,pos2,data = rac:get_region_data_by_id(this_id,false)
			rac:msg_handling(err,func_name)
			-- id: zone, owner, name, claimable,protected, guests, pvp, mvp, effect 
			chat_string = chat_string.."\nid "..this_id.." ("..data.zone.."). Name der Region: "..data.region_name
			chat_string = chat_string.."\nBesitzer "..data.owner..": claimable ("..tostring(data.claimable).."), geschützt ("..tostring(data.protected).."), Gäste ("..data.guests.."),"
			chat_string = chat_string.."\nPvP ("..tostring(data.pvp).."), Monsterdamage ("..tostring(data.mvp).."), Effekte ("..data.effect..")."
		end	
		minetest.chat_send_player(name, chat_string)	
		-- Ausgabe ins Log
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - k = "..tostring(k)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - "..tostring(chat_string) )		
	end
	

	-- Probleme???
	--	auf city können mehrere plot / owned liegen
	-- 	auf outback können mehrere city, plot und owned liegen
		
	--return 0
end

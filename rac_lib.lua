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
		minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err.type: "..tostring(type(err))	)
		if err > rac.max_error then
			-- [3] = "ERROR: func: rac:msg_handling(err, name) - die Nummer err ist größer als erlaubt!!!!",
			error_msg = rac.error_msg_text[3]
		else
			minetest.log("action", "[" .. rac.modname .. "] rac:msg_handling - err <= rac.max_error: "..tostring(rac.max_error)	)
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
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
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
function rac:region_set_attribute(name, id, region_attribute, value, bool)
	local func_version = "1.0.0"
	local func_name = "rac:region_set_attribute"
	if rac.show_func_version and rac.debug_level > 8 then
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
	if rac.show_func_version and rac.debug_level > 0 then
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
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box pos1 = "..minetest.serialize(pos1) )  
	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box pos2 = "..minetest.serialize(pos2) )  

	local x,y,z
	x = math.abs( pos1.x - pos2.x ) / 2
	y = math.abs( pos1.y - pos2.y ) / 2
	z = math.abs( pos1.z - pos2.z ) / 2
	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box x = "..tostring(x) )  
	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box x = "..tostring(y) )  
	minetest.log("action", "[" .. rac.modname .. "] get_center_of_box x = "..tostring(z) )  

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
-- rac:region_has_regions(edge1,edge2)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- prüfe ob in der Region zwischen edge1 und edge2 andere Regionen sind 
-- und liefere deren ID zurück
--
-- input:
--		edge1,edge2		as vector
--
-- return:
--	region_id
--	region_id as Table mit key = 1...n und value = region_id 
--
-- msg/error handling: no 
function rac:region_has_regions(edge1,edge2)
	local func_version = "1.0.0"
	local func_name = "rac:region_has_regions"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local region_has_regions = rac.rac_store:get_areas_in_area(edge1,edge2,true,true,true) --accept_overlap, include_borders, include_data)
	
	-- die ID der Region ist im Key
	-- zähle die schleife damit man erkennen kann wieviele Region sich hier treffen 
	local region_id = {} -- maximal 3 Region überlappen
	local region = {} -- maximal 3 Region überlappen
	for id, data in pairs(region_has_regions) do	
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - counter = "..tostring(counter) )  
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions k = "..tostring(id) )  
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions v = "..tostring(data) )  
		counter = counter + 1
		table.insert(region_id, id)
		table.insert(region, data)
	end
	return region_id
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
	end
	data = rac:get_region_attribute(region_id, "zone")
	minetest.log("action", "[" .. rac.modname .. "] chatcommand command_border data = {"..tostring(data).."}" ) 
	
	-- suche das Zentrum
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

--[[
Region Areas and City
	erstelle Regionen in deiner Minetestwelt
	
Copyright (c) 2013
	ralf Weinert <downad@freenet.de>
Source Code: 	
	https://github.com/downad/rac
License: 
	GPLv3
]]--


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
	local func_version = "1.0.0"
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
		return err,nil -- keine ID gefunden
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
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_is_guest - Version: "..tostring(func_version)	)
	end
	
	local guests_table = rac:convert_string_to_table(guests_string, ",")
	local is_guest = rac:string_in_table(name, guests_table)
	
	return is_guest
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:string_in_table(given_string, given_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- check if a string is in an table
--
--
-- input: 
--		given_string 	as string
--		given_table 	as table
--
-- return:
-- 	true 			if given_string is in given_table
-- 	false 		if not
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

	value_table = string.split(string,seperator)

	return value_table
end


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
		-- es wurde aber kien Info vorgestellt
		-- Das ist ein Fehler!
		-- [1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
			minetest.log("error", "[" .. rac.modname .. "] Error: ".. rac.error_text[1])
		end
 	else
		-- err ist nicht vom Typ number!
		-- es wurde keine Nummer übertragen
		-- Das ist ein Fehler!
		-- [1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
		minetest.log("error", "[" .. rac.modname .. "] Error: ".. rac.error_text[1])
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:create_data_string(owner,region_name,claimable,zone,plot,protected,guests_string,PvP,MvP,effect,do_not_check_player)
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
--		err 	die Nummer des Fehlers
-- 		data_string for insert_area(edge1, edge2, DATA) as string
-- 			data must be an designed 
--
-- msg/error handling: YES
-- 	err,data_string
function rac:create_data_string(owner,region_name,claimable,zone,protected,guests_string,pvp,mvp,effect,check_player)
	local func_version = "1.0.0"
	if rac.show_func_version  and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:create_data_string - Version: "..tostring(func_version)	)
	end
	-- local err -> is hardcoded!
	
	-- default do_check_player = true
	local do_check_player = true
	if check_player ~= nil then
		do_check_player = not check_player
	end
	-- check input-values
	-- owner yes? NO = error
	local player = minetest.get_player_by_name(owner)
	-- ist der Owner ein Player
	if player then
		-- alles OK
	elseif do_check_player == false then
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
		return 8 -- 	[8] = "ERROR: func: rac:create_data_string - zone ist nichtt in der Liste! "..tostring(rac.allowed_zones),
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
		return 13 -- [13] = "ERROR: func: rac:create_data_string - effect ist nichtt in der Liste! "..tostring(rac.allowed_effects),
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
		"\", pvp = "..tostring(pvp)..", mvp = "..tostring(mvp)..", effect = \""..effect.."\"}" 
 
	return 0,data_string
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- function rac:string_in_table(given_string, given_table)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- ist der 'string' in der übergebenen Tabelle 'given_table'
--
-- input: string, given_table
--
-- return: 
--		true if 'given_string' is in 'given_table'
-- 		false
--
-- msg/error handling: no
function rac:string_in_table(given_string, given_table)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
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
	if rac.show_func_version and rac.debug_level == 10 then
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
--  0			alles ht geklappt
--
-- msg/error handling: YES
--  0 = no error
function rac:save_regions_to_file()
	local func_version = "1.0.0"
	if rac.show_func_version then
		minetest.log("action", "[" .. rac.modname .. "] rac:save_regions_to_file - Version: "..tostring(func_version)	)
	end
	local err = 0 -- No Error
	rac.rac_store:to_file(rac.worlddir .."/".. rac.store_file_name) 
	return err 	
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
--  err
--	data as table
--
-- msg/error handling: YES
--	err, data 
function rac:get_region_datatable(id)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_region_datatable - Version: "..tostring(func_version)	)
	end
	local err = 0
	--	no_deserialize == false
	local err, pos1,pos2,data = rac:get_region_data_by_id(id,false)
	return err, data
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_region_data_by_id(id,no_deserialize)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Hole zu einer region_id 
-- 	pos1,pos2
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
	if rac.show_func_version and rac.debug_level == 10 then
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
	if rac.show_func_version then -- and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_owner_by_region_id - Version: "..tostring(func_version)	)
	end
	if rac.debug then -- and rac.debug_level > 8 then
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
	if rac.show_func_version then
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - übergabe ++++++++++++++++++++++++++++++++++++++++++++++++++++ "	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - name: "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - id: "..tostring(id)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - region_attribute: "..tostring(region_attribute)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - value: "..tostring(value)	)		
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - bool: "..tostring(bool)	)
	end
	
	-- -- -- -- 
	-- Sting testen für 
	--		region_attribute ==
	--			region_name 
	--					suche nach verbotenen Zeichen?
	--			owner, guest 
	--					unnötig, da das über existPlayer gehandelst wird		
	-- -- -- --
	
	
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
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - nach check ID ++++++++++++++++++++++++++++++++++++++++++++++++++++ "	)
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - err: "..tostring(err) ) 
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - pos1: "..minetest.serialize(pos1)) 
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - pos2: "..minetest.serialize(pos2)) 
		minetest.log("action", "[" .. rac.modname .. "] rac:region_set_attribute - data: "..minetest.serialize(data)) 
		
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
	if rac.show_func_version  then
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
	if rac.show_func_version  then
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
	if rac.show_func_version  then
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


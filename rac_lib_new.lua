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
-- rac:check_region_integrity()
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- durchlaufe alle region, 
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
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] rac:check_region_integrity - Version: "..tostring(func_version)	)
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
			rac:msg_handling(err) 
		end
		must_modify = false
		counter = counter + 1
	end
	
	
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
-- Die Marker kann jeder setzen, unabhängig vom Privileg
-- Setzen einen Marker pos1 oder pos2
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
-- msg/error handling: no
function rac:marker_placed( pos, placer, itemstack )
	local func_version = "1.0.0"
	if rac.show_func_version  then
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Version: "..tostring(func_version)	)
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

	-- setzte pos1 oder pos2 in gang 
	-- ist schon ein command_players.pos1 vorhanden dann fülle pos2 ansonsten pos1 
	-- geht das anlog zu command region pos1?
	-- noch ist nichts gesetzt
	if not rac.command_players[name] then
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Setze Ecke 1: "	)
		err = rac:command_pos(name,pos,1,false)
		rac:msg_handling(err)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] name = "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] pos1 = "..tostring(rac.command_players[name].pos1)	)
		
	else
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Setze Ecke 2: "	)
		err = rac:command_pos(name,pos,2,false)
		rac:msg_handling(err)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] name = "..tostring(name)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - rac.command_players[name] pos2 = "..tostring(rac.command_players[name].pos2)	)

		-- checke Logik, passt der Raum usw.
		-- rufe set_region auf, evtl. FORM?
		-- lösche rac.command[name] ist nicht nötig, das macht rac:command_set
		minetest.log("action", "[" .. rac.modname .. "] rac:marker_placed - Setze Gebiet: "	)
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
		rac:msg_handling(err)	
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
--		true 		Spieler darf
-- 		Table 	dem was der admin setzen kann
--							city = true/false
--							plot = true/false
--							outback = true/false 
--
--
-- msg/error handling: YES
-- return true oder plot,city,outback für admin
-- return 31 -- "msg: You don't have the privileg 'region_mark'! ",
-- return 32 -- "msg: Your region is too small (x)!",
-- return 33 -- "msg: Your region is too small (z)!",
-- return 34 -- "msg: Your region is too small (y)!",
-- return 35 -- "msg: Your region is too width (x)!",
-- return 36 -- "msg: Your region is too width (z)!",
-- return 37 -- "msg: Your region is too hight (y)!",
-- return 38 -- "msg: There are other region in. You can not mark this region",
function rac:can_player_set_region(edge1, edge2, name)
	local func_version = "1.0.0"
	if rac.show_func_version  then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - Version: "..tostring(func_version)	)
	end
	-- check if player privilegs
	-- if region_admin, he can place everythere, return true
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
	end --if can_modify.set then
	
	-- Definition der Rückgabewerte
	local admin_table = { plot = true, city = true, outback = true, change_owner = false, plot_id = nil}
	local return_player = false
	
	-- check ob die Region eine andere betrifft	
	-- schaue ob die Region in AreaStore ist
	local region_has_regions = rac.rac_store:get_areas_in_area(edge1,edge2,true,true) --accept_overlap, include_borders, include_data):
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions type - "..tostring(type(region_has_regions))	)
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions: serialize - "..tostring(minetest.serialize(region_has_regions))	)
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions: value - "..tostring(region_has_regions)	)
	
	if region_has_regions[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions[1] == nil "	)
		-- nicht in einer Region, dann wildniss
		-- prüfe claimable der Wildnis / oder region_admin
		if rac.wilderness.claimable or can_modify.admin then
			return true, admin_table
		else
			return 53 -- [53] = "ERROR: func: rac:can_player_set_region - Das Gebiete hat kein 'claimable' gesetzt!",
		end 
		-- es gibt eine überlappende Region 
		-- claimable = false -> player kann nicht, admin kann
	elseif #region_has_regions == 1 then --if region_has_regions == nil then
		-- es gibt eine Region
		-- darf man hier claimen
		if rac:get_region_attribut(region_has_regions[1],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[1],"zone") == "city"  then
				return_player = true
				admin_table.city = false
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
				return_player = true
				admin_table.outback = false
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "plot" then
				return_player = false
				admin_table.plot = false
				admin_table.change_owner = true
				admin_table.plot_id = region_has_regions[1]
			end
		end -- if rac:get_region_attribut(region_has_regions[1],"claimable") then
		-- prüfe die Anzahl der überalppenden Gebiete
		return return_player,admin_table
	elseif #region_has_regions == 2 then --if region_has_regions == nil then
		-- es gibt zwei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 1 claimable und 1 = city, dann 2 outback
		-- wenn 1 claimable und 1 = outback -- kann nicht claimen
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- wenn 2 claimable und 2 = city, dann 1 outback
		-- wenn 2 claimable und 2 = outback -- kann nicht claimen
		-- der Admin kann
		--	city/outback = plot - city/plot =outback - outback/plot = city 
		if rac:get_region_attribut(region_has_regions[1],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot"  then
				if rac:get_region_attribut(region_has_regions[2],"zone") == "city" or rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
					return_player = false
					admin_table.change_owner = true
					admin_table.plot_id = region_has_regions[1]
				end 
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "city" then
				if rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
					return_player = true	
				end
			end
		end
		if rac:get_region_attribut(region_has_regions[2],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[2],"zone") == "plot"  then
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					return_player = false
					admin_table.change_owner = true
					admin_table.plot_id = region_has_regions[1]	
				end --admin_table.city = false
			elseif rac:get_region_attribut(region_has_regions[2],"zone") == "city" then
				if rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					return_player = true	
				end --admin_table.city = false
			end	
		end
		-- für den admin
		if can_modify.admin then
			if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[2],"zone") == "city" then
				admin_table.city = false
			end
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot" or rac:get_region_attribut(region_has_regions[2],"zone") == "plot" then
				admin_table.plot = false
			end
			if rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
				admin_table.outback = false
			end			
		end
		return return_player,admin_table
	elseif #region_has_regions == 3 then
		-- es gibt drei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- return ist dann false und admin_table.change_owner = true
		-- der Admin kann
		-- kann keine weiteren Gebiete überlappen lassen
		if can_modify.set then
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot" and rac:get_region_attribut(region_has_regions[1],"claimable") then
				admin_table.plot_id = region_has_regions[1]
				if rac:get_region_attribut(region_has_regions[2],"zone") == "city" or rac:get_region_attribut(region_has_regions[3],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[2],"zone") == "outback" or rac:get_region_attribut(region_has_regions[3],"zone") == "outback" then
					admin_table.outback = true
				end 
			elseif rac:get_region_attribut(region_has_regions[2],"zone") == "plot" and rac:get_region_attribut(region_has_regions[2],"claimable") then
				admin_table.plot_id = region_has_regions[2]
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[3],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[3],"zone") == "outback" then
					admin_table.outback = true
				end 
			elseif rac:get_region_attribut(region_has_regions[3],"zone") == "plot" and rac:get_region_attribut(region_has_regions[3],"claimable") then
				admin_table.plot_id = region_has_regions[3]
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[1],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					admin_table.outback = true
				end 
			end
			if admin_table.city and admin_table.outback then
				admin_table.city = false
				admin_table.outback = false
				admin_table.change_owner = true
				return_player = false
			end	
		end
		return return_player,admin_table
	else
		return 38 -- [38] = "ERROR: func: rac:can_player_set_region - Andere Gebiete sind davon betroffen, du kannst das so nicht claimen!",
	end	
end








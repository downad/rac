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
--  	true/false, table
--		true 		Gebiet setzen ist erlaubt
--		false 	Das Gebiet kann nicht gesetzt werden
-- 		Table 	dem was der admin setzen kann
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
function rac:can_player_set_region(edge1, edge2, name)
	local func_version = "1.0.0"
	local func_name = "rac:can_player_set_region"
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
]]--
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
	-- in zone_table wird zurückgegeben, welche zone gesetzt werden kann.
	-- player = false, der admin
	-- player = true, der Spieler, der kann nur plot oder owned
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
--[[


	
	-- es gibt keine Region
	if region_has_regions[1].data == nil then
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
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 1  "	)
		-- es gibt eine Region, allowed: outback, city, plot
		-- darf man hier claimen
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		if region1.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region1.zone == "city"  then
				return_player = true
				admin_table.city = false
			elseif region1.zone == "outback" then
				return_player = true
				admin_table.outback = false
			elseif region1.zone == "plot" then
				return_player = false
				admin_table.plot = false
				admin_table.change_owner = true
				region_center = 
					((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
					((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
					((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
			end
		end -- if region1.claimable then
		return return_player,admin_table
	-- prüfe die Anzahl der überalppenden Gebiete
	elseif #region_has_regions == 2 then --if region_has_regions == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 2  "	)
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
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		region2 =  minetest.deserialize(region_has_regions[2].data)
		if region1.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region1.zone == "plot"  then
				if region2.zone == "city" or region2.zone == "outback" then
					return_player = false
					admin_table.change_owner = true
					region_center = 
						((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
						((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
						((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
					admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				end 
			elseif region1.zone == "city" then
				if region2.zone == "outback" then
					return_player = true	
				end
			end
		end
		if region2.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region2.zone == "plot"  then
				if region1.zone == "city" or region1.zone == "outback" then
					return_player = false
					admin_table.change_owner = true
					region_center = 
						((region_has_regions[2].max.x + region_has_regions[2].min.x) / 2)..",".. -- x
						((region_has_regions[2].max.y + region_has_regions[2].min.y) / 2)..",".. -- y
						((region_has_regions[2].max.z + region_has_regions[2].min.z) / 2) -- z
					admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				end --admin_table.city = false
			elseif region2.zone == "city" then
				if region1.zone == "outback" then
					return_player = true	
				end --admin_table.city = false
			end	
		end
		-- für den admin
		if can_modify.admin then
			if region1.zone == "city" or region2.zone == "city" then
				admin_table.city = false
			end
			if region1.zone == "plot" or region2.zone == "plot" then
				admin_table.plot = false
			end
			if region1.zone == "outback" or region2.zone == "outback" then
				admin_table.outback = false
			end			
		end
		return return_player,admin_table
	elseif #region_has_regions == 3 then
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 1  "	)
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
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		region2 =  minetest.deserialize(region_has_regions[2].data)
		region3 =  minetest.deserialize(region_has_regions[3].data)
		if can_modify.set then
			if region1.zone == "plot" and region1.claimable then
				region_center = 
					((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
					((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
					((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region2.zone == "city" or region3.zone == "city" then
					admin_table.city = true
				elseif region2.zone == "outback" or region3.zone == "outback" then
					admin_table.outback = true
				end 
			elseif region2.zone == "plot" and region2.claimable then
				region_center = 
					((region_has_regions[2].max.x + region_has_regions[2].min.x) / 2)..",".. -- x
					((region_has_regions[2].max.y + region_has_regions[2].min.y) / 2)..",".. -- y
					((region_has_regions[2].max.z + region_has_regions[2].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region1.zone == "city" or region3.zone == "city" then
					admin_table.city = true
				elseif region1.zone == "outback" or region3.zone == "outback" then
					admin_table.outback = true
				end 
			elseif region3.zone == "plot" and region3.claimable then
				region_center = 
					((region_has_regions[3].max.x + region_has_regions[3].min.x) / 2)..",".. -- x
					((region_has_regions[3].max.y + region_has_regions[3].min.y) / 2)..",".. -- y
					((region_has_regions[3].max.z + region_has_regions[3].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region1.zone == "city" or region1.zone == "city" then
					admin_table.city = true
				elseif region1.zone == "outback" or region1.zone == "outback" then
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
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions > 3  "	)		
		return 38 -- [38] = "ERROR: func: rac:can_player_set_region - Andere Gebiete sind davon betroffen, du kannst das so nicht claimen!",
	end	
end
	
	]]--
--[[	
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
]]--



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



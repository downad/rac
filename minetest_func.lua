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
		- pvp: ist auf dem Gebiet pvp erlaubt? 	Ist vom minetest.conf und dem Privileg pvp abhängig
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
-- register_on_protection_violation - send message
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Show a message on protection violators
	-- who can interact?
	-- function can_interact returns true or false
	-- send message to player if that position is protected.
minetest.register_on_protection_violation(function(pos, name)
	-- rac:can_interact(pos, name)  liefert true/false und den Ower_string
	local can_interact, owner_string = rac:can_interact(pos, name) 
--	if not rac:can_interact(pos, name) then
	if not can_interact then
		local pos_string = minetest.pos_to_string(pos)
		minetest.log("action", "[" .. rac.modname .. "] register_on_protection_violation - can_interact: "..tostring(can_interact)	)
		minetest.chat_send_player(name, pos_string.." is protected by "..owner_string)
	end
end)
 
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- register_on_protection_violation - do damage
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--Damage protection violators
minetest.register_on_protection_violation(function(pos, name)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	if rac.do_damage_for_violation then 
		minetest.log("action", "[" .. rac.modname .. "] register_on_protection_violation - rac.do_damage_for_violation: "..tostring(rac.do_damage_for_violation)	)
		player:set_hp(math.max(player:get_hp() - rac.damage_on_protection_violation, 0))
		minetest.chat_send_player(name, "The protection deals you " ..rac.damage_on_protection_violation.." damage.")
	else
		minetest.chat_send_player(name, "This block is protected!")
	end
end)

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- override minetest.is_protected(pos, name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- the function can_interact returns true or false
-- return true: yes this region is protected
-- return false: no this region is not protecred
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	-- check if pos is in a protected area
	-- and name can interact with the nodes
	if not rac:can_interact(pos, name) then
		return true
	end
	return old_is_protected(pos, name)
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- can_interact(pos, name)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- this function is called by 
--		minetest.is_protected(pos, name)
--		minetest.register_on_protection_violation(function(pos, name)
-- 
-- Checks ob die Postion 
--		ungeschütz ist - unprotected? 
--		geschützt - protected
-- 		ist der name der owner -owned by (player)name?
--		name ist Gast - name is guest?
-- 			if an player/name is guest in an region he can interact.
--
-- input:
-- 	pos				als Positionsvektor
-- 	name			als Spielername
--
-- return:
--  boolearn
-- 		true 			if Player/name can interact at this *position*
--		false 		if not
--	owner				der Beitzer der Region / bei wilderness rac.wilderness.owner
--
-- msg/errorhandling: no
-- 			[62] = "ERROR: func: can_interact  - 2 Regionen gefunden, sei dürfen so ab er nicht liegen"
--
function rac:can_interact(pos, name)
	local func_version = "1.0.1" -- angepasstes get_region_at_pos err == nil für keine ID bei Position pos gefunden
	local func_name = "rac:can_interact"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	
	-- niemand darf was machen
	local can_interact = false
	
	-- es gibt keine region_id
	local is_region_id = false

	
	-- einige benötigte Variablen
	local data_table = {} -- der data_string einer Region
	local data_table2 = {} -- der data_string einer Region
	local data_table3 = {} -- der data_string einer Region
	local owner = ""			-- weil man gegen den owner prüft
	local guests = {}			-- weil man gegen die Gäste prüft
	local is_protected 		-- wird mit dem Region_Attribut protected gefüllt
	local owners = {}			-- eine Liste der Owner, falls sich mehrere Gebiete überlagern
		-- Problem Owner1 schützt das Gebiet, Owner2 nicht.
		-- 		Darf nun Owner2 interagieren - JA oder NEIN?
		--			NEIN darf er nicht -> Es sei denn die geschütze zone ist eine City und die andere Zone ist ein Plot
		--			in anderen Fällen dürfen sich Zonen nicht überlagern!
	local stacked_zone = {
		outback = nil,
		city = nil,
		plot = nil,
		owned = nil,
	}	
	local set_stacked_zone = function (string, value)	
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - set_stacked_zone string = "..tostring(string).." value = "..tostring(value)	)	
		-- keine Prüfung von string und value
		if string == "owned" then 
			stacked_zone.owned = value
		elseif string == "plot" then 
			stacked_zone.plot = value
		elseif string == "city" then 
			stacked_zone.city = value
		elseif string == "outback" then 
			stacked_zone.outback = value
		end
	end
	-- the region is not protected
	local protected = false -- wenn eine Region geschützt ist zählt das für alle
	
	local this_zone_counts = nil -- diese Zone gilt!							

	-- hole eine eine Tabelle mit allen region ID
	-- ist der wert nil dann gibt es keine ID
	local err
	local region_id 
	err,region_id = rac:get_region_at_pos(pos)

	-- keine Region gefunden
	if err == nil then
		err = 0 -- Alles ist gut, Globlastep geht auf region_id == nil
	elseif err >  0 then
		rac:msg_handling(err,func_name)
	end	

	if region_id == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - if region_id == nil "	)
		-- es gibt keine Region, nutze den wilderness Werte protected
		-- was muss gepüft werden für die Interaktion
		-- protected = true -> can_interact = false
		if rac.wilderness.protected then
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - return true - if rac.wilderness.protected "..tostring(rac.wilderness.protected)	)
			return false, rac.wilderness.owner
		else
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - retrun false - if rac.wilderness.protected "..tostring(rac.wilderness.protected)	)
			return true, rac.wilderness,owner
		end
	elseif #region_id <= 3 then
		for key, id in pairs(region_id) do
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - key: "..tostring(key).." id = "..tostring(id)	)
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - type(id) = "..tostring(type(id))	)

			err,data_table = rac:get_region_datatable(id)
			set_stacked_zone(data_table.zone,id)
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - data_table.zone = "..tostring(type(data_table.zone))	)
		end
		if stacked_zone.outback ~= nil then
			this_zone_counts = stacked_zone.outback
		end
		if stacked_zone.city ~= nil then
			this_zone_counts = stacked_zone.city
		end
		if  stacked_zone.plot ~= nil then
			this_zone_counts = stacked_zone.plot
		end
		if  stacked_zone.owned ~= nil then
			this_zone_counts = stacked_zone.owned
		end
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - this_zone_counts = "..tostring(this_zone_counts)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - region_id[this_zone_counts] = "..tostring(region_id[this_zone_counts])	)
			
	elseif #region_id > 3 then
		rac:msg_handling(63,func_name)
		return false, rac.wilderness.owner
	end	 -- if region_id == nil then

	--return true,owner

	if #region_id == 1 or this_zone_counts ~= nil then
		-- einfacher Fall es gibt nur eine Region
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 1: region_id = "..tostring(rac:table_to_string(region_id)) )
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact -  or this_zone_counts ~= nil "..tostring(this_zone_counts)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 1: region_id[1] = "..tostring(region_id[1])	)
		if this_zone_counts == nil then
			err,data_table = rac:get_region_datatable(region_id[1])
		else
			err,data_table = rac:get_region_datatable(this_zone_counts)
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - hole die Werte der this_zone_counts Region "	)
		end
		if err >  0 then
			rac:msg_handling(err,func_name)
		end	
		owner = data_table.owner
		guests = data_table.guests --<- this is a string!
		is_protected = data_table.protected	
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact -  owner "..tostring(owner)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact -  is_protected "..tostring(is_protected)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact -  region_name "..tostring(data_table.region_name)	)
			
		if is_protected then
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - is_protected = "..tostring(is_protected)	)
			-- prüfer owner
			if name == owner then -- and is_protected == true then
				return true, owner
			end
			-- prüfe guest
			if rac:player_is_guest(name, guests) then 
				return true, owner
			end	
			return false, owner
		else
			return true, owner
		end	
	end -- if #region_id == 1 or this_zone_counts ~= nil then
	
end







-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- Register punchplayer callback.
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- punchplayer callback
-- should return true to prevent the default damage mechanism
-- is hitter a player -> pvp 
-- 	return false  - (do damage) in pvp regions			
--  return true   - (no damage) if pvp is forbidden
-- 	if no region is set: 
-- 	return true	  - (do damage) if pvp_only_in_pvp_regions = false
-- 	return true	  - (no damage) if pvp_only_in_pvp_regions = true
--
-- is hitter a mob -> mvp
--	return false  - (do damage) if mvp is set true in a region
--  return false  - (do damage) if no region is set -> mvp == nil
--  return true   - (no damage) if mvp is set false (forbidden) in an region
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local func_version = "1.0.0"
	local func_name = "rac:register_on_punchplayer"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local pos = player:get_pos() 
	local name = player:get_player_name()
	local hitter_name = hitter:get_player_name()
	local msg = 103 -- 		[103] = "info: func: register_on_punchplayer - Monster machen hier Schaden!",
	-- get the pvp and mvp attribute of the region
	-- pvp can be true / false - if region is set
	-- pvp = nil if no region is set - wildernes - the rest off the world
	local pvp, mvp = rac:get_combat_attributs_for_pos(pos)
	-- wenn pvp eine Zahl > 0 dann error
	if tonumber(pvp) ~= nil and tonumber(pvp) > 0 then
		-- error durch den Aufruf von rac:get_combat_attributs_for_pos(pos)
		return err
	end
	
	-- if the damage-dealer is no player then 
	--  deal damage => mvp = true or in wilderness mvp = nil
	--	deal no damage if mvp = false
	if hitter:is_player() == false then
		if mvp == true or mvp == nil then
			return false	-- MOB do Damage
		else
			rac:msg_handling(msg,func_name, name) --  message
			return true		-- MOB don't do Damge
		end
	end
	-- wenn man hier ist, dann ist der hitter ein Spieler!

	msg = 105 -- 		[105] = "info: func: register_on_punchplayer - Keine PVP-Zone!",
	if pvp == true then
		return false	-- Player do Damage
	elseif pvp == false then
		rac:msg_handling(msg,func_name, name) --  message
		rac:msg_handling(msg,func_name, hitter_name) --  message
		return true		-- No pvp Damge
	else -- pvp == nil
		msg = 106 -- 		[106] = "info: func: register_on_punchplayer - Warum ist hier pvp == nil?",
		rac:msg_handling(msg, func_name) --  message
		return true		-- No Mpvp no Damge
	end

end)

minetest.register_on_player_hpchange(function(player, hp_change, reason, modifier)
	-- modifier = true -> return hp_change
	local func_version = "1.0.0"
	local func_name = "rac:register_on_player_hpchange"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local pos = vector.round(player:get_pos())
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - hp_change: "..tostring(hp_change)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - reason.type: "..tostring(reason.type)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - reason.from: "..tostring(reason.from)	)
	if reason.from == "engine" then
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - reason.from == engine"	)
		if reason.type == "punch" then
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - punched: hp_change"..tostring(hp_change)	)
			local err,id,zone_name = rac:this_zone_counts(pos)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - punched: err "..tostring(err)	)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - punched: id "..tostring(id)	)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - punched: zone_name "..tostring(zone_name)	)
			if zone_name == nil then
				zone_name = "none"
			end
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - rac.zone_mob_damage[zone_name] "..tostring(rac.zone_mob_damage[zone_name])	)
			hp_change = hp_change * rac.zone_mob_damage[zone_name]
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - hp_change"..tostring(hp_change)	)
		end
	end
	return hp_change
	
end)


--+++++++++++++++++++++++++++++++++++++++
--
-- Register register_on_punchnode callback.
--
--+++++++++++++++++++++++++++++++++++++++
-- punchnode callback
-- is user for the command '/region mark'
-- to punch a node an set pos1 and pos2 of an region
-- if pos1 and pos2 are set 
-- rac.set_command[name] = nil clears the function
minetest.register_on_punchnode(function(pos, node, puncher)
	local name = puncher:get_player_name()
	-- Currently setting position
	if name ~= "" and rac.set_command[name] then
		if rac.set_command[name] == "pos1" then
			if not rac.command_players[name] then
				rac.command_players[name] = {pos1 = pos}
			else
				rac.command_players[name].pos1 = pos
			end
			-- set marker pos1
			rac.markPos1(name)
			-- be ready for pos2
			rac.set_command[name] = "pos2"
			minetest.chat_send_player(name,
					"Position 1 set to "
					..minetest.pos_to_string(pos))
		elseif rac.set_command[name] == "pos2" then
			if not rac.command_players[name] then
				rac.command_players[name] = {pos2 = pos}
			else
				rac.command_players[name].pos2 = pos
			end
			-- set marker pos2
			rac.markPos2(name)
			-- clear set_command
			rac.set_command[name] = nil
			minetest.chat_send_player(name,
					"Position 2 set to "
					..minetest.pos_to_string(pos))
		end
	end
end)




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
	elseif #region_id == 2 then
		-- es sind 2 Regionen an dieser Stelle
		-- is_protected gilt in der Reihenfolge: outback < city < plot < owned
		-- city 		& 	 	plot oder owned
		-- outback	&			plot oder owned
		-- outback	&			city
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 2: region_id = "..tostring(rac:table_to_string(region_id))	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif region_id[1] = "..tostring(region_id[1])	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif region_id[2] = "..tostring(region_id[2])	)
		
		err,data_table = rac:get_region_datatable(region_id[1])
		err,data_table2 = rac:get_region_datatable(region_id[2])
		
		local zone1 = data_table.zone
		local zone2 = data_table2.zone

		if ( zone1 == "owned" or zone1 == "plot" ) and ( zone2 == "city" or zone2 == "outback" )then
			this_zone_counts = 1
		elseif ( zone2 == "owned" or zone2 == "plot" ) and ( zone1 == "city" or zone1 == "outback" )then
			this_zone_counts = 2
		else
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif zone1..2 - hier darf man nicht sein! "	)
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - zone 1 = "..tostring(zone1) )
			minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - zone 2 = "..tostring(zone2) )
			-- produziere absturz
			rac:msg_handling(62,func_name)
			return false, data_table.owner..", "..data_table2.owner
		end
		-- das Problem wurde auf die relevante Zone beschänkt und kann wie #region_id = 1 abgehandelt werden
		
	elseif #region_id == 3 then
	-- es sind 3 Regionen an dieser Stelle
	-- is_protected gilt in der Reihenfolge: outback < city < plot < owned
	-- outback 		& city 	 & 	plot oder owned
	minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 3: region_id = "..tostring(rac:table_to_string(region_id))	)
	minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif region_id[1] = "..tostring(region_id[1])	)
	minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif region_id[2] = "..tostring(region_id[2])	)
	minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif region_id[3] = "..tostring(region_id[3])	)
	
	err,data_table = rac:get_region_datatable(region_id[1])
	err,data_table2 = rac:get_region_datatable(region_id[2])
	err,data_table3 = rac:get_region_datatable(region_id[3])
	
	local zone1 = data_table.zone
	local zone2 = data_table2.zone
	local zone3 = data_table3.zone
	
	if ( zone1 == "owned" or zone1 == "plot" ) and ( zone2 == "city" or zone2 == "outback" ) and ( zone3 == "city" or zone2 == "outback" ) then
		this_zone_counts = 1
	elseif ( zone2 == "owned" or zone2 == "plot" ) and ( zone1 == "city" or zone1 == "outback" ) and ( zone3 == "city" or zone2 == "outback" ) then
		this_zone_counts = 2
	elseif ( zone3 == "owned" or zone3 == "plot" ) and ( zone2 == "city" or zone2 == "outback" ) and ( zone1 == "city" or zone1 == "outback" ) then
		this_zone_counts = 3
	else
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif zone1..2 - hier darf man nicht sein! "	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - zone 1 = "..tostring(zone1) )
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - zone 2 = "..tostring(zone2) )
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - zone 3 = "..tostring(zone3) )
		-- produziere absturz
		rac:msg_handling(62,func_name)
		return false, data_table.owner..", "..data_table2.owner
	end
	-- das Problem wurde auf die relevante Zone beschänkt und kann wie #region_id = 1 abgehandelt werden
	
	elseif #region_id > 3 then
		rac:msg_handling(63,func_name)
		return false, rac.wilderness.owner
	end	 -- if region_id == nil then

	if #region_id == 1 or this_zone_counts ~= nil then
		-- einfacher Fall es gibt nur eine Region
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 1: region_id = "..tostring(rac:table_to_string(region_id)) )
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact -  or this_zone_counts ~= nil "..tostring(this_zone_counts)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:can_interact - elseif #region_id == 1: region_id[1] = "..tostring(region_id[1])	)
		if this_zone_counts == nil then
			err,data_table = rac:get_region_datatable(region_id[1])
		else
			err,data_table = rac:get_region_datatable(region_id[this_zone_counts])
		end
		if err >  0 then
			rac:msg_handling(err,func_name)
		end	
		owner = data_table.owner
		guests = data_table.guests --<- this is a string!
		is_protected = data_table.protected	
			
		if is_protected then
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







--+++++++++++++++++++++++++++++++++++++++
--
-- Register punchplayer callback.
--
--+++++++++++++++++++++++++++++++++++++++
-- punchplayer callback
-- should return true to prevent the default damage mechanism
-- is hitter a player -> PvP 
-- 	return false  - (do damage) in PvP regions			
--  return true   - (no damage) if PvP is forbidden
-- 	if no region is set: 
-- 	return true	  - (do damage) if pvp_only_in_pvp_regions = false
-- 	return true	  - (no damage) if pvp_only_in_pvp_regions = true
--
-- is hitter a mob -> MvP
--	return false  - (do damage) if MvP is set true in a region
--  return false  - (do damage) if no region is set -> MvP == nil
--  return true   - (no damage) if MvP is set false (forbidden) in an region
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local pos = player:get_pos() 
	local name = player:get_player_name()
	local hitter_name = hitter:get_player_name()
	local msg = 35 --  "Mob do no damage in this zone!",
	-- get the PvP and MvP attribute of the region
	-- PvP can be true / false - if region is set
	-- PvP = nil if no region is set - wildernes - the rest off the world
	local PvP, MvP = rac:get_combat_attributs_for_pos(pos)

	-- if the damage-dealer is no player then 
	--  deal damage => MvP = true or in wilderness MvP = nil
	--	deal no damage if MvP = false
	if hitter:is_player() == false then
		if MvP == true or MvP == nil then
			return false	-- MOB do Damage
		else
			rac:msg_handling(msg, name) --  message
			return true		-- MOB don't do Damge
		end
	end

	msg = 14 -- "NO PvP in this zone!",
	-- if pvp_only_in_pvp_regions == true
	-- PvP only in PvP regions!
	if rac.pvp_only_in_pvp_regions == true then
		if PvP == true then
			return false	-- Player do Damage
		else
			rac:msg_handling(msg, name) --  message
			rac:msg_handling(msg, hitter_name) --  message
			return true		-- No PvP no Damge
		end
	else
		-- all in the world is PvP allowed
		if PvP == true or PvP == nil then  
			return false	-- Player do Damage
		else
			rac:msg_handling(msg, name) --  message
			rac:msg_handling(msg, hitter_name) --  message
			return true		-- No MPvP no Damge
		end
	end

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




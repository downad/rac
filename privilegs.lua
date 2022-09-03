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

-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can modify and remove all regions.")
minetest.register_privilege("region_effect", "Can set or remove and effect for own regions.")
minetest.register_privilege("region_mvp", "Can allow/disallow MvP for own regions.")
minetest.register_privilege("region_pvp", "Can allow/disallow PvP for own regions.")
minetest.register_privilege("region_guests", "Can invite/ban guests.") 
minetest.register_privilege("region_set", "Can set, remove and rename own regions and protect and open them or change owner of own regions.")


minetest.register_chatcommand("region", {
	description = "Call \'region help <command>\' to get more information about the chatcommand.",
	params = "<help> <guide> <status> <own> <pos1> <pos2> <max_y> <set> \n <show> <border> <export> <import> \n <import_areas> <player>",
	privs = "interact", -- no spezial privileg
	func = function(name, param)
		local func_version = "1.0.0"
		local func_name = "register_chatcommand"
		if rac.show_func_version and rac.debug_level > 0 then
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		end
		local player = minetest.get_player_by_name(name)
		local pos = vector.round(player:get_pos())
		if not player then
			return false, "Player not found"
		end
		local err
		if param:sub(1, 4) == "help" then			
			err = rac:command_help(param,name)
		elseif param == "guide" then			
			err =	rac:guide(player,1)
		elseif param == "status" then			-- 'end' if param == 
			err = rac:command_status(name,pos)
		elseif param == "own" then				-- 'end' if param == 
			err = rac:command_own(name)
		elseif param == "pos1" then				-- 'end' if param == 
			err = rac:command_pos(name,pos,1)
		elseif param == "pos2" then 			-- 'end' if param == 
			err = rac:command_pos(name,pos,2)
		elseif param:sub(1, 5) == "max_y" then 			-- 'end' if param == 
			local numbers = string.split(param, " ")
			-- [1] command max_y, [2] id, [3] new_y
			err = rac:command_max_y(name,numbers[2],numbers[3])
		elseif param:sub(1, 3) == "set" and param:sub(1, 5) ~= "set_m"then 	-- 'end' if param == 
			err = rac:command_set(param, name)
		elseif param:sub(1, 4) == "show" then	-- 'end' if param == 
			local numbers = string.split(param:sub(6, -1), " ")
			local header = true
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - numbers[1]: "..tostring(numbers[1])	)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - type(numbers[1]): "..tostring(type(numbers[1]))	)
--			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - tonumber(numbers[1]): "..tostring(tonumber(numbers[1]))	)
						
			if numbers[1] == nil then		
				err = rac:command_show(header,name,nil,nil)
			elseif tonumber(numbers[1]) ~= nil then
				-- if numbers only contains strings then tonumber become 0 - no error_handling
				err = rac:command_show(header,name,tonumber(numbers[1]),tonumber(numbers[2]))
			else -- number[1] ist eine String, das sollte der Name eines Spielers sein...
				-- ' region show {name}' ist somit 'region {name}
				local header = 'command show'
				err = rac:command_player_regions(header,param, name)
			end
		elseif param:sub(1, 6) == "border" then		-- 'end' if param == 
			err = rac:command_border(param, name)
		elseif param:sub(1, 7) == "compass" then		-- 'end' if param == 
			err = rac:command_compass(param, name)
		elseif param == "export" then 			-- 'end' if param == 
			-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 59 --[59] = "ERROR: func: register_chatcommand(\"region\"  - Dir fehlt das Privileg 'region_admin'!",
			end
			err = rac:export(rac.export_file_name)
			if err == 0 then
				rac:msg_handling(58, func_name, name)  -- [58] = "Info: func: register_chatcommand(\"region\" - RegionStore wurde erfolgreich exportiert.",
			end
		elseif param == "import" then 			-- 'end' if param == 
						-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 59 --[59] = "ERROR: func: register_chatcommand(\"region\"  - Dir fehlt das Privileg 'region_admin'!",
			end
			rac:import(rac.export_file_name)
		elseif param:sub(1, 12) == "change_owner" then 	-- 'end' if param == 
			err = rac:command_change_owner(param, name, false)
		elseif param:sub(1, 6) == "player" then
			local header = true
			err = rac:command_player_regions(header,param, name)
			rac:msg_handling(err, name) 
--		elseif param:sub(1, 4) == "mark" then
--			err = rac:command_mark(param, name)
		elseif param:sub(1, 6) == "remove" then -- 'end' if param == 
			err = rac:command_remove(param, name)	
		elseif param:sub(1, 4) == "list" then -- 'end' if param == 
			local all = string.split(param:sub(5, -1), " ")
			err = rac:regions_by_zone(name,all[1])	
		elseif param:sub(1, 3) == "pvp" then	-- 'end' if param == 
			err = rac:command_pvp(param, name)
		elseif param:sub(1, 3) == "mvp" then	-- 'end' if param == 
			err = rac:command_mvp(param, name)
		elseif param:sub(1, 9) == "claimable" then	-- 'end' if param == 
			err = rac:command_claimable(param, name)
		elseif param:sub(1, 7) == "protect" then	-- 'end' if param == 
			err = rac:command_protect(param, name)
		elseif param:sub(1, 6) == "effect" then	-- 'end' if param == 
			err = rac:command_effect(param, name)
		elseif param:sub(1, 6) == "rename" then	-- 'end' if param == 
			err = rac:command_rename(param, name)
		elseif param:sub(1, 11) == "change_zone" then	-- 'end' if param == 
			err = rac:command_change_zone(param, name)
		elseif param:sub(1, 7) == "set_min" then	-- 'end' if param == 
			err = rac:command_set_min(param, name, "min")
		elseif param:sub(1, 7) == "set_max" then	-- 'end' if param == 
			err = rac:command_set_min(param, name, "max")
		elseif param ~= "" then 				-- if no command is found 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region\" for more information.")
		else
			minetest.chat_send_player(name, "Region chatcommands: Type \"/help region\" for more information.")
		end -- 'end' if param == 

		rac:msg_handling(err, name) --  message and error handling
	end -- end function(name, param)
})


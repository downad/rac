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
-- Globalstep: create info for the hud
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- loop all connected player
-- find the region of the players position -> get_areas_for_pos
-- create a string with region-name and owner and show it in the hud
-- if there is an effect in the area - do it to the player
local timer = 0
minetest.register_globalstep(function(dtime)
	local func_version = "1.0.1" -- angepasstes get_region_at_pos err == nil für keine ID bei Position pos gefunden
	local func_name = "rac:register_globalstep"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	local err = 0
	
	-- der Timer läuft
	rac.timer = rac.timer + dtime
	
	local name 	-- Name des Spielers
	local pos 	-- pos des Spielers

	--color for PvP and protected
	local color = rac.color["white"]	-- default
	
	-- einige weitern Variablen
	local is_protected = false
	local is_pvp_allowed = false	
	local data_table, data_table1
	local region_name
	local owner,plot_owner, city_owner,zone
	local effect1, effect2
	local protected_string, enable_pvp
	local this_zone_counts -- die region_id für die Zone die gilt 
	local stacked_zone = {
		outback = nil,
		city = nil,
		plot = nil,
		owned = nil,
	}	
	local set_stacked_zone = function (string, value)	
----		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - set_stacked_zone string = "..tostring(string).." value = "..tostring(value)	)	
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
	
	-- das ist der String für das hud_update
	local hud_string

	-- gibt es eine region_id?
	local region_id
		 
	for _, player in pairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		pos = vector.round(player:get_pos())

		err,region_id = rac:get_region_at_pos(pos)
		
		-- keine Region gefunden
		if err == nil then
			err = 0 -- Alles ist gut, Globlastep geht auf region_id == nil
		elseif err >  0 then
			rac:msg_handling(err,func_name)
		end	
		
		if region_id == nil then
			-- es gibt keine Region, nutze den wilderness Werte protected
--	--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - if region_id == nil then: - Wildniss")	
			zone = rac.wilderness.zone
			-- erzeuge den hud_string
			region_name = rac.wilderness.text_wilderness
			hud_string = region_name 
			if rac.wilderness.protected then
				is_protected = true
				hud_string = hud_string .." ".. rac.wilderness.text_protected
			end
			if rac.wilderness.pvp then
				hud_string = hud_string .." ".. rac.wilderness.text_pvp
				is_pvp_allowed = true
			end
			if rac.enable_pvp then
				hud_string = hud_string .." PvP ist global erlaubt!"
				is_pvp_allowed = true
			end
			if rac.wilderness.protected then
				is_protected = true
			end
		elseif #region_id > 0  then
			-- es gibt 1 mehr Regionen
			-- nur die oberste Region zählt outback<city<plot<owned
			
			is_protected = false
			for key, id in pairs(region_id) do
		--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - key: "..tostring(key).." id = "..tostring(id)	)
		--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - type(id) = "..tostring(type(id))	)

				err,data_table = rac:get_region_datatable(id)
				set_stacked_zone(data_table.zone,id)
		--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - data_table.zone = "..tostring(data_table.zone)	)
		--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - err = "..tostring(err)	)
			end
			this_zone_counts = nil
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
			
			-- wenn eine this_zone_counts gesetzt wurde
			-- hole data von Region this_zone_counts
	--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - this_zone_counts = "..tostring(this_zone_counts)	)
			if this_zone_counts ~=nil then
				err,data_table1 = rac:get_region_datatable(this_zone_counts) 
			else
				err = 76 --		[76] = "ERROR: func: register_globalstep - keine ID gesetzt",
				rac:msg_handling(err,func_name)
				err,data_table1 = rac:get_region_datatable(region_id[1]) 
			end
			-- ohne Fehler, dann fülle die Werte
			if err == 0 then
				zone = data_table1.zone
				-- hole den ersten owner
				city_owner = data_table1.owner	
				-- hole is_protectet
				is_protected = data_table1.protected
				-- hole is_pvp_allowed
				is_pvp_allowed = data_table1.pvp
				-- 	hole region_name
				region_name = data_table1.region_name
				-- hole den Effect
				-- ist kein Effekt da sollte der Werte "none" sein
				if data_table1.effect ~= "none" then
					-- es können maximal 2 Effekt aktiv sein
					local table_effect =  rac:convert_string_to_table(data_table1.effect, ",")
					effect1 = table_effect[1]
					if #table_effect > 1 then
						effect2 = table_effect[2]
					end
				else
					-- Effekt ist "none"
					effect1 = data_table1.effect
				end
			else
			-- err hat einen Fehler gemeldet
			rac:msg_handling(err,func_name)
			end
			
			-- teste ob der Effect ein erlaubter Effekt ist
			if rac:string_in_table(effect1, rac.region_attribute.allowed_effects) then
			-- do region effect
				if effect1 ~= "none" and rac.timer >= rac.region_effect.time then
					rac:do_effect_to_player(player,effect1)
					rac.timer = 0
				end	
			end		
		end -- #region_id > 0  then
		


		-- baue den hud - String
		-- wenn #region_id > 1,
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id = "..tostring(region_id)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - #region_id = "..tostring(#region_id)	)
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id[1] = "..tostring(region_id[1])	)

		if region_id ~= nil then
--	--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." if region_id ~= nil then")
			if is_protected then
				protected_string = rac.wilderness.text_protected
			else
				protected_string = ""
			end 
			if plot_owner ~= nil  then
--		--		minetest.log("action", "[" .. rac.modname .. "] if plot_owner ~= : "..tostring(plot_owner))
				owner = plot_owner
				hud_string = region_name .." "..protected_string.."\n"
			else
				owner = city_owner
				hud_string = region_name .." "..protected_string.."\n".."Diese Region gehört: "..owner
			end

			-- is pvp allowed in this region
			-- UND ist enable_pvp in der minetest.conf gesetzt
			if rac.enable_pvp then
				if is_pvp_allowed  then
					hud_string = hud_string .."\n"..rac.wilderness.text_pvp 
				end			
			else
				hud_string = hud_string .."\nDas PvP ist ausgeschaltet!"
			end
		end		
		
				-- only for debugging
		if rac.debug == true and rac.debug_level > 4 then
	--		minetest.log("action", "[" .. rac.modname .. "] *************baue den hud - String*************")
	--		minetest.log("action", "[" .. rac.modname .. "] this_zone_counts: "..tostring(this_zone_counts))
	--		minetest.log("action", "[" .. rac.modname .. "] protected_string: "..tostring(protected_string))
	--		minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
	--		minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
	--		minetest.log("action", "[" .. rac.modname .. "] rac.enable_pvp: "..tostring(rac.enable_pvp))
	--		minetest.log("action", "[" .. rac.modname .. "] is_pvp_allowed: "..tostring(is_pvp_allowed))
	--		minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
	--		minetest.log("action", "[" .. rac.modname .. "] hud_string: "..tostring(hud_string))
		end
		
		-- ermittle die Farbe und update das hud
		--rac:get_color_for_region_text(zone,is_protected)	
		color = rac:get_color_for_region_text(zone)	
		-- only for debugging
		if rac.debug == true and rac.debug_level == 10 then
	--		minetest.log("action", "[" .. rac.modname .. "] *************Color und hud *************")
	--		minetest.log("action", "[" .. rac.modname .. "] color: "..tostring(color))
		end
		rac:update_hud(player,hud_string, color)
	
	end -- ende der For-Schleife
end)




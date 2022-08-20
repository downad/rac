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
	
	
	--[[
	-- der Timer für die rac:mark die Marker
 	rac.marker_timer = rac.marker_timer + dtime

	
	
	-- test rac.mark Time to Live
	-- on_place füllt einen Stack 
	-- durchlaufe diesen Stack und zerstöre die rac.mark nach default Time 
	-- rac:delte_mark_after_ttl
	if rac.marker_timer > rac.marker_verify_timer then
		for i,v in ipairs(rac.list_of_marker) do
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker: i: "..tostring(i).." pos: "..tostring(rac:table_to_string(v))	)
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker: get_node at pos: "..tostring(minetest.get_node(v)) )
			local my_node = minetest.get_node(v)
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker: get_node.name at pos: "..tostring(my_node.name) )
			local meta = minetest.get_meta( v );
			local my_pos = v	
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker: get_node meta:get_string'time': "..tostring(meta:get_string( 'time') ) )  
			local this_time = 	 os.time() - meta:get_string( 'time')				
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker:   os.time(): "..tostring( os.time() ) )  
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - list_of_marker: node this_time: "..tostring(this_time ) )  
			if this_time > 30 then
				minetest.set_node(my_pos, {name="air"})
				rac.list_of_marker = rac:remove_value_from_table(v, rac.list_of_marker)
			end
		end
		rac.marker_timer = 0
	end	
	]]--
	
	local name 	-- Name des Spielers
	local pos 	-- pos des Spielers

	--color for PvP and protected
	local color = rac.color["white"]	-- default
	
	-- einige weitern Variablen
	local is_protected = false
	local is_pvp_allowed = false	
	local is_wilderness = true
	local data_table1, data_table2
	local region_name
	local owner,plot_owner, city_owner
	local effect1, effect2
	local protected_string, enable_pvp


	-- das ist der String für das hud_update
	local hud_string

	-- gibt es eine region_id?
	local region_id
		 
	for _, player in pairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		pos = vector.round(player:get_pos())

		err,region_id = rac:get_region_at_pos(pos)
		
--		minetest.log("action", "[" .. rac.modname .. "] register_globalstep - err: "..tostring(err)	)
--		minetest.log("action", "[" .. rac.modname .. "] register_globalstep - region_id: "..tostring(region_id)	)
--		minetest.log("action", "[" .. rac.modname .. "] register_globalstep - region_id: "..tostring(minetest.serialize(region_id))	)


		-- keine Region gefunden
		if err == nil then
			err = 0 -- Alles ist gut, Globlastep geht auf region_id == nil
		elseif err >  0 then
			rac:msg_handling(err,func_name)
		end	
		
		if region_id == nil then
			-- es gibt keine Region, nutze den wilderness Werte protected
			is_wilderness = true
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
			-- es gibt 1 oder 2 Regionen
			-- 2 bedeutet city und plot, es gelten die Einstellungen des plot
			-- das muss noch geprüft werden
			
			is_wilderness = false
			is_protected = false
			is_pvp_allowed = false

--			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - region_id[1]: "..tostring(region_id[1])	)
			-- hole data von Region 1
			err,data_table1 = rac:get_region_datatable(region_id[1]) 
-- 			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - err: "..tostring(err)	)
--			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - data_table1 serialize: "..tostring(minetest.serialize(data_table1))	)
--			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - data_table1 string?: "..tostring((data_table1))	)
--			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - data_table1.effect : "..tostring(data_table1.effect)	)
			if err == 0 then
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
			
				
			
		-- gibt es 2 Regionen muss
		-- pvp und protected geprüft werden
		elseif #region_id == 2 then
		 --- muss noch gemacht werden!

		else -- mehr als 2 Regionen!
			-- [2] = "ERROR: register_globalstep(function(dtime) - mehr als 2 Regionen!",
			rac:msg_handling(2, func_name, name)
		end -- #region_id > 0  then
		


		-- baue den hud - String
		-- wenn #region_id > 1
		if region_id ~= nil then
			if is_protected then
				protected_string = rac.wilderness.text_protected
			else
				protected_string = ""
			end 
			if plot_owner ~= nil  then
				minetest.log("action", "[" .. rac.modname .. "] if plot_owner ~= : "..tostring(plot_owner))
				owner = plot_owner
				hud_string = region_name .." "..protected_string.."\n"
			else
				owner = city_owner
				hud_string = region_name .." "..protected_string.."\n"..owner
			end

			-- is pvp allowed in this region
			-- UND ist enable_pvp in der minetest.conf gesetzt
			if rac.enable_pvp then
				if is_pvp_allowed  then
					hud_string = hud_string .." "..rac.wilderness.text_pvp 
				end			
			else
				hud_string = hud_string .."Das PvP ist ausgeschaltet!"
			end
		end		
		
				-- only for debugging
		if rac.debug == true and rac.debug_level > 5 then
			minetest.log("action", "[" .. rac.modname .. "] *************baue den hud - String*************")
			minetest.log("action", "[" .. rac.modname .. "] protected_string: "..tostring(protected_string))
			minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
			minetest.log("action", "[" .. rac.modname .. "] owner: "..tostring(owner))
			minetest.log("action", "[" .. rac.modname .. "] rac.enable_pvp: "..tostring(rac.enable_pvp))
			minetest.log("action", "[" .. rac.modname .. "] is_pvp_allowed: "..tostring(is_pvp_allowed))
			minetest.log("action", "[" .. rac.modname .. "] hud_string: "..tostring(hud_string))
		end
		
		-- ermittle die Farbe und update das hud
		color = rac:get_color_for_region_text(is_wilderness,is_protected,is_pvp_allowed)	
		-- only for debugging
		if rac.debug == true and rac.debug_level == 10 then
			minetest.log("action", "[" .. rac.modname .. "] *************Color und hud *************")
			minetest.log("action", "[" .. rac.modname .. "] color: "..tostring(color))
		end
		rac:update_hud(player,hud_string, color)
	
	end -- ende der For-Schleife
end)




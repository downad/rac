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
-- Globalstep: create info for the hud
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- loop all connected player
-- find the region of the players position -> get_areas_for_pos
-- create a string with region-name and owner and show it in the hud
-- if there is an effect in the area - do it to the player
local timer = 0
minetest.register_globalstep(function(dtime)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] register_globalstep - Version: "..tostring(func_version)	)
	end
	local err = 0
	
	local name 
	local pos 

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
	local protected_string, enable_pvp, 

	-- der Timer läuft
	timer = timer + dtime

	-- das ist der String für den hud_update
	local hud_string

	-- gibt es eine region_id?
	local is_region_id = false
	local region_id
		 
	for _, player in pairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		pos = vector.round(player:get_pos())

		
		err,region_id = rac:get_region_at_pos(pos)
		if err >  0 then
			rac:msg_handling(err)
		end	
		if rac.debug and rac.debug_level == 10 then
			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - type(region_id): "..tostring(type(region_id))	)
			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - region_id: "..tostring(region_id)	)
			minetest.log("action", "[" .. rac.modname .. "] register_globalstep - #region_id: "..tostring(#region_id)	)
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
			-- pvp auf einer Region 				=> pvp allowed
			-- protected auf einer Region 	=> protected
			-- wenn 2 Regionen, dann wilderness = false!
			-- owner: es wird der plot_owner angezeigt, wenn es den nicht gibt den city_owner 						
			
			is_wilderness = false
			is_protected = false
			is_pvp_allowed = false

			-- hole data von Region 1
			err,data_table1 = rac:get_region_datatable(region_id[1])
			if err == 0 then
				-- hole den ersten owner
				city_owner = data_table1.owner	
				-- hole is_protectet
				is_protected = data_table1.protected
				-- hole is_pvp_allowed
				is_pvp_allowed = data_table1.pvp
				-- 	hole region_name
				region_name = data_table1.region_name
				-- hole den Effecr
				effect1 = data_table1.effect
			else
				-- err hat einen Fehler gemeldet
				rac:msg_handling(err)
			end
			
			-- only for debugging
			if rac.debug == true and rac.debug_level == 10 then
				minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
				minetest.log("action", "[" .. rac.modname .. "] region_name: "..tostring(region_name))
				minetest.log("action", "[" .. rac.modname .. "] city_owner: "..tostring(city_owner))
				minetest.log("action", "[" .. rac.modname .. "] is_protected: "..tostring(is_protected))
				minetest.log("action", "[" .. rac.modname .. "] is_pvp_allowed: "..tostring(is_pvp_allowed))
				minetest.log("action", "[" .. rac.modname .. "] effect: "..tostring(effect1))
			end
			
			-- test Effect und do Effect
			
			if rac:string_in_table(effect1, rac.region_attribute.allowed_effects) then
			-- do region effect
				if effect1 ~= "none" and timer >= rac.effect.time then
					rac:do_effect_to_player(player,effect1)
					timer = 0
				end	
			end		
			
				
			
		-- gibt es 2 Regionen muss
		-- pvp und protected geprüft werden
		elseif #region_id == 2 then
			err,data_table2 = rac:get_region_datatable(region_id[2])
			if err == 0 then
				if data_table2.protected then
					is_protected = true
				end						
				if data_table2.pvp == true then
					is_pvp_allowed = true
				end
				-- finde den city_owner und den plot_owner
				if data_table1.zone == "city" then
					plot_owner = data_table.owner
					city_owner = data_table1.owner
					region_name = "City: ".. data_table1.region_name.." (Owner: "..city_owner..") Plot: "..data_table.region_name.." (Owner: "..plot_owner.." )" 
				else
					plot_owner = data_table1.owner
					city_owner = data_table.owner				
					region_name = "City: ".. data_table.region_name.." (Owner: "..city_owner..") Plot: "..data_table1.region_name.." (Owner: "..plot_owner.." )" 
				end
			else
				-- err hat einen Fehler gemeldet
				rac:msg_handling(err)
			end
			
			-- test Effect und do Effect
			effect2 = data_table2.effect
			if rac:string_in_table(effect2, rac.region_attribute.allowed_effects) then
			-- do region effect
				if effect2 ~= "none" and timer >= rac.effect.time then
					rac:do_effect_to_player(player,effect1)
					timer = 0
				end	
			end			

		else -- mehr als 2 Regionen!
			-- [2] = "ERROR: register_globalstep(function(dtime) - mehr als 2 Regionen!",
			rac:msg_handling(2, name)
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




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
-- minetest.register_on_joinplayer(function(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- when a player joins the game
-- register Hud
minetest.register_on_joinplayer(function(player)
    rac:update_hud(player, rac.wilderness.text_wilderness, rac.color.white)
end)
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- minetest.register_on_joinplayer(function(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- when player leaves the game
-- lösche das hud
minetest.register_on_leaveplayer(function(player)
    rac.player_huds[player:get_player_name()] = nil
end)


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:update_hud(player, hud_stringtext, color)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- spiele in das Hud des Player die passenden Texte
--
--
-- input: 
--		player					as playerobject
--		hud_stingtext 	as string
--		color 					as string
-- 
-- return:
--	nothing
--
-- msg/error handling: no 
function rac:update_hud(player, hud_stringtext, color)
	local func_version = "1.0.0"
	local func_name = "rac:update_hudport"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:update_hud - Version: "..tostring(func_version)	)
	end
	if rac.debug and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:update_hud: hud_stringtext = ".. tostring(hud_stringtext))
	end
	
  local name = player:get_player_name()
  local ids = rac.player_huds[name]
  -- ids = hud-id  
  if ids then
  	if rac.compass_players[name] ~= nil then
			if rac.compass_players[name].active then
--				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - rac.compass_players[name].region_id: "..tostring(rac.compass_players[name].region_id)	)
				local direction = rac:get_direction_to_region(rac.compass_players[name].region_id, player) 
				if direction ~= "OK" then
--					minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - get_look_horizontal(): "..tostring(player:get_look_horizontal())	)
					hud_stringtext = " Richtung zu Region ( "..tostring(rac.compass_players[name].region_id).." ): "..direction.."\n"..hud_stringtext
				else
					-- das Ziel ist erreicht, stoppe aktiv.
					rac.compass_players[name].active = false
					minetest.chat_send_player(name, "Du hast dein Ziel erreicht!")
					rac:draw_border(rac.compass_players[name].region_id)	
				end 
			end
		end
		player:hud_change(ids, "text", hud_stringtext)
		player:hud_change(ids, "number", color)
	  else
      ids = {}
      ids = player:hud_add({
				hud_elem_type = "text",
				name = "Areas",
				number = 0xFFFFFF,
				position      = {x = 0, y = 0.85},
				offset        = {x = 10,   y = -10},
				--position = {x=0, y=1},
				--offset = {x=8, y=-8},
				text = hud_stringtext,
				scale = {x=200, y=60},
				alignment = {x=1, y=-1},
			})
		rac.player_huds[name] = ids
  end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_direction_to_region(region_id)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- hole das zentrum der Region
-- berechne die Richtung und gib einen Bezeichner   mit oben/unten zurück
--
-- input: 
--		region_id 			als Nummer
-- 
-- return:
--	sting			'links von dir' 'rechts von dir'
--
-- msg/error handling: no 
function rac:get_direction_to_region(region_id,player)
	local func_version = "1.0.0"
	local func_name = "rac:get_direction_to_region"
	if rac.show_func_version and rac.debug_level > 4 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_id: "..tostring(region_id)	)
	end
	local position = vector.round(player:get_pos())
	local return_string = "keine Region gefunden"
	local err,pos1, pos2, data = rac:get_region_data_by_id(region_id)
	local check_region_id
	local compass, up_down
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - rac:get_region_data_by_id(region_id) -> err: "..tostring(err)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - position: "..tostring(position)	)
	if err ~= 0 then
		return  return_string
	end

	local center = rac:get_center_of_box(pos1, pos2)
	if position.y > center.y then
		up_down = "-"
	elseif position.y < center.y then
		up_down = "+"
	else		
		up_down = "+"
	end
	
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - position: "..tostring(position)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - position.x =  "..tostring(position.x)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - position.y =  "..tostring(position.y)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - position.z =  "..tostring(position.z)	)
	local delta_x, delta_z
	delta_x = (position.x - center.x)
	delta_z =	(position.z - center.z ) 
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - delta_x: "..tostring(delta_x)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - delta_z: "..tostring(delta_z)	)
	local	m
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - up_down: "..tostring(up_down)	)
	if not (position.x - center.x) ~= 0 then
		m = (position.z - center.z ) /  (position.x - center.x)
	else
--		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - (position.z - center.z ), darum Korrektur "	)
		m = (position.z - center.z ) /  (0.001) -- Korrektur, da man nicht durch 0 Teilen kann
	end
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - m: "..tostring(m)	)
	m = math.atan2(delta_x,delta_z) -- math.atan(m)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - m als Bogenmaß: "..tostring(m).." math.pi = "..tostring(math.pi)	)
	--m = 2 * math.pi * m / 360
	--minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - m in Bogenmaß: "..tostring(m)	)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - get_look_horizontal(): "..tostring(player:get_look_horizontal())	)

	m = player:get_look_horizontal() + m - (1.5 * math.pi)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - m  modifiziert um Blickrichtung: "..tostring(m)	)
	-- -pi < m < 0 links 
	-- 	pi > m > 0 rechts 

	-- bin ich schon da?
	err,check_region_id = rac:get_region_at_pos(position)
--	minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - rac:get_region_at_pos(position -> err: "..tostring(err)	)
	if err ~= nil then
		if rac:string_in_table(region_id, check_region_id) then 
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - id in given Table: "	)
			-- ziel erreicht
			return_string = "OK"
		end
		
	else-- if err ~= nil then
		if m > (-math.pi/2)  and m < (math.pi/2) then
			compass = "rechts von dir"
		elseif m < (-math.pi/2) or m > (math.pi/2) then
			compass = "links von dir"
		else
			compass = "gerade aus"
		end
	 return_string = compass.." "..up_down 		
	end -- if err = 0
	
	return return_string
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:get_color_for_region_text(zone,is_protected)	
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- finde die Farbe color für den Hud Region String
--
-- input:
-- 			zone 						String
--			is_protected		bool
--
-- return:
--  color
--
-- msg/error handling: no	
function rac:get_color_for_region_text(zone,is_protected)	
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_color_for_region_text - Version: "..tostring(func_version)	)
	end
	local color
	-- only for debugging
	if rac.debug == true and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
		minetest.log("action", "[" .. rac.modname .. "] zone: "..tostring(zone))
		minetest.log("action", "[" .. rac.modname .. "] is_protected: "..tostring(is_protected))
	end
	if zone=="outback" or zone=="city" then
		if is_protected then
		 color = rac.color["orange"]
		else
		 color = rac.color["yellow"]
		end
	elseif zone == "plot" or zone == "owned" then
		if is_protected then
			color = rac.color["crimson"]
		else
			 color = rac.color["white"]
		end
	elseif zone == rac.wilderness.zone then
		if is_protected then
			color = rac.color["red"]
		else
			color = rac.color["magenta"]
		end
	else
		if is_protected then
			 color = rac.color["purple"]
		else
			 color = rac.color["blue"]
		end
	end
	return color
end




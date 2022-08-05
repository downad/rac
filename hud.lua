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
		if rac.show_func_version and rac.debug_level > 8 then
			minetest.log("action", "[" .. rac.modname .. "] rac:update_hud - Version: "..tostring(func_version)	)
		end
		if rac.debug and rac.debug_level > 8 then
			minetest.log("action", "[" .. rac.modname .. "] rac:update_hud: hud_stringtext = ".. tostring(hud_stringtext))
		end
		
    local name = player:get_player_name()
    local ids = rac.player_huds[name]
    -- ids = hud-id  
    if ids then
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
-- rac:get_color_for_region_text(is_wilderness,is_protected,is_pvp_allowed)	
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- finde die Farbe color für den Hus Rgion String
--
--		color						white	yellow	orange	crimson	blue		black	purple	red
--		is_wildernes		yes		yes			yes			yes			no			no		no			no												
--		is_protected		no		yes			yes			no			no			yes		no			yes
-- 		is_pvp_allowed	no		no			yes			yes			no			no		yes			yes
--
--
-- input:
-- 			is_wilderness 	bool
--			is_protected		bool
--			is_pvp_allowed	bool
--
-- return:
--  color
--
-- msg/error handling: no	
function rac:get_color_for_region_text(is_wilderness,is_protected,is_pvp_allowed)	
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level > 8 then
		minetest.log("action", "[" .. rac.modname .. "] rac:get_color_for_region_text - Version: "..tostring(func_version)	)
	end
	local color
	-- only for debugging
	if rac.debug == true and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] ***********************************************")
		minetest.log("action", "[" .. rac.modname .. "] is_wilderness: "..tostring(is_wilderness))
		minetest.log("action", "[" .. rac.modname .. "] is_protected: "..tostring(is_protected))
		minetest.log("action", "[" .. rac.modname .. "] is_pvp_allowed: "..tostring(is_pvp_allowed))
	end
	if is_wilderness then
		if is_protected then
			if is_pvp_allowed then
				 color = rac.color["orange"]
			else
				 color = rac.color["yellow"]
			end
		else
			if is_pvp_allowed then
				 color = rac.color["crimson"]
			else
				 color = rac.color["white"]
			end
		end						
	else
		if is_protected then
			if is_pvp_allowed then
				 color = rac.color["red"]
			else
				 color = rac.color["magenta"]
			end
		else
			if is_pvp_allowed then
				 color = rac.color["purple"]
			else
				 color = rac.color["blue"]
			end
		end	
	end
	return color
end




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
--register items and enitiy

minetest.register_node("rac:mark", {
	description = "Damit kannst du dein Gebiet markieren, 2 Ecken eines Rechtecks.",
	tiles = {"rac_markers_marked.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=1}, 
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.5, -0.1, 0.1, 1.5, 0.1 },
			},
		},

        after_place_node = function(pos, placer, itemstack)
        	-- hole die Position
        	-- speicher diese am Spieler
        	-- hat er pos1 und pos2 kann man mit rechtsclick das Gebiet setzen
        	-- die marker verschwinden dann
           --markers.marker_placed( pos, placer, itemstack );
           rac:marker_placed( pos, placer, itemstack )
           
        end,

        -- the node is digged immediately, so we may as well do all the work in can_dig (any wrong digs are not that critical)
 --       can_dig = function(pos,player)
 --      	-- nur der owner kann abbauen
 --          return markers.marker_can_dig( pos, player );
 --       end,

--        after_dig_node = function(pos, oldnode, oldmetadata, digger)
--           return markers.marker_after_dig_node( pos, oldnode, oldmetadata, digger );
--        end,

--	on_rightclick = function(pos, node, clicker)
--
--           minetest.show_formspec( clicker:get_player_name(),
--				   "markers:mark",
--				   markers.get_marker_formspec(clicker, pos, nil)
--			);
--	end,
})
minetest.register_node("rac:marked", {
	description = "Das ist ein Gebiet mit einem Besitzer.",
	tiles = {"rac_markers_mark.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=1}, 
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.5, -0.1, 0.1, 1.5, 0.1 },
			},
		},
})

minetest.register_craft({
   output = "rac:mark 2",
   recipe = { { "group:stick" },
              { "default:apple" },
              { "group:stick" },
             } });







minetest.register_entity("rac:showarea",{
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(16,function()
			self.object:remove()
		end)
	end,
	initial_properties = {
		hp_max = 1,
		physical = true,
		weight = 0,
		visual = "mesh",
		mesh = "landrush_showarea.x",
		textures = {nil, nil, "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	}
})

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- entity rac:pos1
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- region pos1 and pos2 marker
-- got this from
-- areas - ShadowNinja - https://github.com/minetest-mods/areas
-- made it workable with rac by downad 
minetest.register_entity("rac:pos1", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"areas_pos1.png", "areas_pos1.png",
		            "areas_pos1.png", "areas_pos1.png",
		            "areas_pos1.png", "areas_pos1.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		rac.marker1[name] = nil
	end,
})



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- entity rac:pos1
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
minetest.register_entity("rac:pos2", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"areas_pos2.png", "areas_pos2.png",
		            "areas_pos2.png", "areas_pos2.png",
		            "areas_pos2.png", "areas_pos2.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		rac.marker2[name] = nil
	end,
})


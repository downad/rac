--[[
Region Areas and City
	erstelle Regionen in deiner Minetestwelt
	wilderness - alles was keiner REgion zugewiesen ist
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

minetest.register_node("rac:plot_stone", {
	description = "Use the correct key on this plot_stone to own the plot.",
	tiles = {"rac_plot_stone.png", "rac_plot_stone.png", "rac_plot_stone_side.png",
                "rac_plot_stone_side.png", "rac_plot_stone_side.png", "rac_plot_stone_side.png" },

-- TODO
-- protected - only owner can dig
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,

-- only owner can open form for writing
-- any player can read the form
	on_rightclick = function(pos, node, clicker)

					-- of owner: write an text 
           markers.show_marker_stone_formspec( clicker, pos );
           
           -- only player: read the text
	end,
})


minetest.register_craft({
   output = "markers:stone",
   recipe = { { "markers:mark" },
              { "default:cobble" },
             } });


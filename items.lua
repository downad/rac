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



--alles für den Erweb von Plot

if rac.craft.plotstone then 
	minetest.register_craft({
		 output = "rac:plotstone",
		 recipe = { 
		 	{ "rac:mark" },
		 	{ "default:stone" },
		 	{ "rac:mark" },
		 }
	});
end

minetest.register_tool("rac:plotkey", {
	description = "Wenn die PlotNr zum Plotstone passt, kannst du das Gebiet übernehmen.",
	inventory_image = "plotkey.png",
	on_use = function(itemstack, user, pointed_thing)
		--pointed_thing.under ist die Position des rac:plotstone
		local pos = pointed_thing.under
		local name = user:get_player_name();
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - pointed_thing.under "..tostring(pointed_thing.under))
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - pos "..tostring(pos))

		local meta_plotstone
		local plot_number_from_plotstone
		if pos ~= nil then
			-- hole die PlotNr aus dem plotstone
			meta_plotstone = minetest.get_meta( pos );
			plot_number_from_plotstone = meta_plotstone:get_string("PlotNr")
		end
		
		
		-- hole die PlotNr aus dem plotkey
		local meta_plotkey = itemstack:get_meta()
		local plot_number_from_plotkey = meta_plotkey:get_string("PlotNr")
		local plotstone_pos = meta_plotkey:get_string("plotstone_pos")
		local plotkey_text	= meta_plotkey:get_string("plotkey_text")
		
		
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - plot_number_from_plotstone "..tostring(plot_number_from_plotstone))
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - plot_number_from_plotkey "..tostring(plot_number_from_plotkey))
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - plotstone_pos "..tostring(plotstone_pos))
		minetest.log("action", "[" .. rac.modname .. "] rac:plotkey - plotkey_text "..tostring(plotkey_text))
		
		-- sind beide PlotNr identische, übertrage das Gebiet und lösche die Items
		if plot_number_from_plotstone == plot_number_from_plotkey then
			-- hole die Zone
			local err, zone_id, zone_name  = rac:this_zone_counts(pos)
			if err == 0 then
				-- claime die Region
				err = rac:claim_plot(name,zone_id)
			end -- if err == 0 then
			
			if err == 0 then 	
				-- hole das Inventar des users
				local inv = user:get_inventory()
				
				-- das muss wahrscheinlich nicht geprüft werden aber... OK
				if inv:contains_item("main", itemstack) then
					-- lösche den key
					local taken = inv:remove_item("main", itemstack)
					-- lösche den rac:plotstone
					minetest.set_node(pos, {name="air"})
					minetest.chat_send_player(name, "Das Gebiet gehör nun dir!")
					return nil
				end
			end -- if err == 0 then
			
		else -- if plot_number_from_plotstone == plot_number_from_plotkey then
			-- Ausgabe an den Spieler/user:
			-- der Plotstone befindet sich an Pos (pos)
			minetest.chat_send_player(name, "Dieser Schlüssel mit der PlotNr "..tostring(plot_number_from_plotkey).."\n"..
					"gehört zum Plotstone bei Position: "..tostring(plotstone_pos) )
			return itemstack
		end -- if plot_number_from_plotstone == plot_number_from_plotkey then
		
	end 
});
-- Damit kann man ein Gebiet claimen, 
-- wird der rac_plotstone auf einen Plot gesetzt,
-- erzeugt er einen key im inv des spieler
-- mit diesem key kann man den Plot claimen
minetest.register_node("rac:plotstone", {
	description = "Setze den Stein auf eine plot- oder owned-Region",
	tiles = {"rac_plot_stone.png", "rac_plot_stone.png", "rac_plot_stone_side.png",
                "rac_plot_stone_side.png", "rac_plot_stone_side.png", "rac_plot_stone_side.png" },
--	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=1}, 
 	drawtype = "normal", 
	groups = {cracky=2},
	is_ground_content = false,
	stack_max = 1,
	drop = rac.drop_plotstone,
	on_place = function(itemstack, placer, pointed_thing)
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - itemstack " ..tostring(itemstack))
			local name = placer:get_player_name()
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - placer:get_player_name() "..tostring(name))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - pointed_thing "..tostring(pointed_thing))
			local pos = pointed_thing.above
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - pos "..tostring(pos))
			local pointed_node = pointed_thing.type
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - pointed_node "..tostring(pointed_node))

			-- hole die aktive Zone an dieser pos
			local err, zone_id, zone_name  = rac:this_zone_counts(pos)
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - err "..tostring(err))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - zone_id "..tostring(zone_id))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - zone_name "..tostring(zone_name))

			-- ist die Zone ein plot oder owned
			if zone_name == "owned" or zone_name == "plot" then
				-- ist der placer der owner?
				local owner = rac:get_region_attribute(zone_id, "owner")
				minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - owner "..tostring(owner))
				-- ist der owner von owned oder plot der placer
				if owner == name then
					-- ja, dann setze den Stein
					return minetest.item_place(itemstack, placer, pointed_thing)
				else
					-- nein, dann lass es bleiben
					minetest.chat_send_player(name, "Du bist nicht der Besitzer dieses Gebietes")
				end
			else
				minetest.chat_send_player(name, "Der Plotstone kann nur auf 'plot' oder 'owned' gesetzt werde.")
			end
			
	end,
	after_place_node= function(pos, placer, itemstack)		
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - itemstack " ..tostring(itemstack))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - placer:get_player_name() "..tostring(placer:get_player_name()))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - pos  "..tostring(pos))
			local meta = minetest.get_meta( pos );
  
			-- der placer name  
			local name = placer:get_player_name();
			local random_plot_string = "Plot_"..tostring(math.random(10000,99999)).."_"..name
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - random_plot_string  "..random_plot_string)
			-- prüfen auf unique?
			-- Stand 9/2022 nein
			
			-- setze die Meta-Werte für den plotstone 
			meta:set_string( 'infotext', "Placed by "..tostring( name ).."\nDie PlotNr lautet: \n"..random_plot_string);
			meta:set_string( 'owner',    name );
			meta:set_string( 'PlotNr',    random_plot_string );
			-- this allows protection of this particular marker to expire
			--local player_inv = minetest.get_inventory({type="player", name = name})
			--local stack = player_inv.
			local inv = placer:get_inventory()
			--inv:add_item("main","rac:plotkey")
			
			local list = inv:get_list("main")
			
			-- erzeuge einen plotkey
			local item = ItemStack("rac:plotkey")
			-- wie bekomme ich das item rac_plotkey aus dem Player-Inventory?			
			local item_name = item:get_name()
			local item_description = item:get_meta():get_string("description")
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - item_name  "..tostring(item_name))
			minetest.log("action", "[" .. rac.modname .. "] rac:plotstone - item_description  "..tostring(item_description))
			
			-- Setze die Meta-Werte für den Key.
			item:get_meta():set_string("PlotNr", random_plot_string)
			item:get_meta():set_string("plotkey_text", "Mit diesem Key kannst du am Plotstone "..tostring(pos).." den Plot übernehmen.")
			item:get_meta():set_string("plotstone_pos", tostring(pos))
			
			
			-- item in das Inventar packen
			local leftover = inv:add_item("main", item)			
			if leftover:get_count() > 0 then
				-- 		[107] = "Error: func: minetest.register_node('rac:plotstone' - Konne das Item nicht in das Inventar legen!",
				rac:msg_handling(err,"minetest.register_node('rac:plotstone'")
			end
			
--			itemstack.add_item("default:stone")
--			local stack = inv:get_name("rac:plotkey")
--			stack:get_meta():set_string("Parzelle", "123")
			
	end,
})


-- Damit kann man ein Gebiet claimen, benötigt werden 2 rac_mark an den Ecken.
-- Das rechteck dazwischen wird geclaimed.
minetest.register_node("rac:mark", {
	description = "Damit kannst du dein Gebiet markieren, 2 Ecken eines Rechtecks.",
	tiles = {"rac_mark.png"},
	drop =  "rac:mark",
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
        	local err = rac:marker_placed( pos, placer, itemstack )
        	rac:msg_handling(err,"minetest.register_node rac:mark")
					minetest.get_node_timer(pos):start(rac.marker_delete_time,0)
       end,

				on_timer = function(pos, elapsed)
					--minetest.after(16,function()
						minetest.remove_node(pos)
						minetest.set_node(pos, {name="air"})
					--end)
				end,
        -- the node is digged immediately, so we may as well do all the work in can_dig (any wrong digs are not that critical)
 --       can_dig = function(pos,player)
 --      	-- nur der owner kann abbauen
 --          return markers.marker_can_dig( pos, player );
 --       end,

--        after_dig_node = function(pos, oldnode, oldmetadata, digger)
--           return markers.marker_after_dig_node( pos, oldnode, oldmetadata, digger );
--        end,

				on_rightclick = function(pos, node, clicker)
					local name = clicker:get_player_name()
					-- die Metawerte eines Nodes an einem Ort (ist ein String)
  				local meta = minetest.get_meta( pos )
					local marked_time =   meta:get_string( 'time' )
					minetest.log("action", "[" .. rac.modname .. "] rac:mark - clicker = "..name.." Zeit = "..tostring(marked_time).." aktuelle Zeit = "..  tostring( os.time()) )
					if (marked_time + rac.marker_delete_time) < os.time() then
						minetest.log("action", "[" .. rac.modname .. "] rac:mark - Zeit verstichen!")
						minetest.chat_send_player(name, "Zeit des markers ist abgelaufen. der Marker wird gelöscht.")
						minetest.set_node(pos, {name="air"})
					end
					
				end,

})
--[[
-- unnötig?
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
]]--
if rac.craft.mark then
	minetest.register_craft({
		 output = "rac:mark 2",
		 recipe = { { "group:stick" },
		            { "group:tree" },
		            { "group:stick" },
		           } });
end





-- showarea_outback
minetest.register_entity("rac:showarea_outback",{
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
		textures = {nil, nil, "showarea_outback.png", "showarea_outback.2.png", "showarea_outback.png", "showarea_outback.2.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
	}
})
-- showarea_city
minetest.register_entity("rac:showarea_city",{
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
		textures = {nil, nil, "showarea_city.png", "showarea_city.2.png", "showarea_city.png", "showarea_city.2.png"}, -- number of required textures depends on visual
		colors = {"green"}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
	}
})
-- showarea_plot
minetest.register_entity("rac:showarea_plot",{
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
		textures = {nil, nil, "showarea_plot.png", "showarea_plot.2.png", "showarea_plot.png", "showarea_plot.2.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
	}
})

-- showarea_owned
minetest.register_entity("rac:showarea_owned",{
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
		textures = {nil, nil, "showarea_owned.png", "showarea_owned.2.png", "showarea_owned.png", "showarea_owned.2.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
	}
})

minetest.register_entity("rac:showarea_default",{
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
		automatic_rotate = 0,
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
-- entity rac:pos2
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


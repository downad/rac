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


--[[


	
	-- es gibt keine Region
	if region_has_regions[1].data == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions[1] == nil "	)
		-- nicht in einer Region, dann wildniss
		-- prüfe claimable der Wildnis / oder region_admin
		if rac.wilderness.claimable or can_modify.admin then
			return true, admin_table
		else
			return 53 -- [53] = "ERROR: func: rac:can_player_set_region - Das Gebiete hat kein 'claimable' gesetzt!",
		end 
	-- es gibt eine überlappende Region 
	-- claimable = false -> player kann nicht, admin kann
	elseif #region_has_regions == 1 then --if region_has_regions == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 1  "	)
		-- es gibt eine Region, allowed: outback, city, plot
		-- darf man hier claimen
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		if region1.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region1.zone == "city"  then
				return_player = true
				admin_table.city = false
			elseif region1.zone == "outback" then
				return_player = true
				admin_table.outback = false
			elseif region1.zone == "plot" then
				return_player = false
				admin_table.plot = false
				admin_table.change_owner = true
				region_center = 
					((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
					((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
					((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
			end
		end -- if region1.claimable then
		return return_player,admin_table
	-- prüfe die Anzahl der überalppenden Gebiete
	elseif #region_has_regions == 2 then --if region_has_regions == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 2  "	)
		-- es gibt zwei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 1 claimable und 1 = city, dann 2 outback
		-- wenn 1 claimable und 1 = outback -- kann nicht claimen
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- wenn 2 claimable und 2 = city, dann 1 outback
		-- wenn 2 claimable und 2 = outback -- kann nicht claimen
		-- der Admin kann
		--	city/outback = plot - city/plot =outback - outback/plot = city 
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		region2 =  minetest.deserialize(region_has_regions[2].data)
		if region1.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region1.zone == "plot"  then
				if region2.zone == "city" or region2.zone == "outback" then
					return_player = false
					admin_table.change_owner = true
					region_center = 
						((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
						((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
						((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
					admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				end 
			elseif region1.zone == "city" then
				if region2.zone == "outback" then
					return_player = true	
				end
			end
		end
		if region2.claimable then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if region2.zone == "plot"  then
				if region1.zone == "city" or region1.zone == "outback" then
					return_player = false
					admin_table.change_owner = true
					region_center = 
						((region_has_regions[2].max.x + region_has_regions[2].min.x) / 2)..",".. -- x
						((region_has_regions[2].max.y + region_has_regions[2].min.y) / 2)..",".. -- y
						((region_has_regions[2].max.z + region_has_regions[2].min.z) / 2) -- z
					admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				end --admin_table.city = false
			elseif region2.zone == "city" then
				if region1.zone == "outback" then
					return_player = true	
				end --admin_table.city = false
			end	
		end
		-- für den admin
		if can_modify.admin then
			if region1.zone == "city" or region2.zone == "city" then
				admin_table.city = false
			end
			if region1.zone == "plot" or region2.zone == "plot" then
				admin_table.plot = false
			end
			if region1.zone == "outback" or region2.zone == "outback" then
				admin_table.outback = false
			end			
		end
		return return_player,admin_table
	elseif #region_has_regions == 3 then
	minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions == 1  "	)
		-- es gibt drei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- return ist dann false und admin_table.change_owner = true
		-- der Admin kann
		-- kann keine weiteren Gebiete überlappen lassen
		-- hole aus der Table die table mit data
		region1 =  minetest.deserialize(region_has_regions[1].data)
		region2 =  minetest.deserialize(region_has_regions[2].data)
		region3 =  minetest.deserialize(region_has_regions[3].data)
		if can_modify.set then
			if region1.zone == "plot" and region1.claimable then
				region_center = 
					((region_has_regions[1].max.x + region_has_regions[1].min.x) / 2)..",".. -- x
					((region_has_regions[1].max.y + region_has_regions[1].min.y) / 2)..",".. -- y
					((region_has_regions[1].max.z + region_has_regions[1].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region2.zone == "city" or region3.zone == "city" then
					admin_table.city = true
				elseif region2.zone == "outback" or region3.zone == "outback" then
					admin_table.outback = true
				end 
			elseif region2.zone == "plot" and region2.claimable then
				region_center = 
					((region_has_regions[2].max.x + region_has_regions[2].min.x) / 2)..",".. -- x
					((region_has_regions[2].max.y + region_has_regions[2].min.y) / 2)..",".. -- y
					((region_has_regions[2].max.z + region_has_regions[2].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region1.zone == "city" or region3.zone == "city" then
					admin_table.city = true
				elseif region1.zone == "outback" or region3.zone == "outback" then
					admin_table.outback = true
				end 
			elseif region3.zone == "plot" and region3.claimable then
				region_center = 
					((region_has_regions[3].max.x + region_has_regions[3].min.x) / 2)..",".. -- x
					((region_has_regions[3].max.y + region_has_regions[3].min.y) / 2)..",".. -- y
					((region_has_regions[3].max.z + region_has_regions[3].min.z) / 2) -- z
				admin_table.plot_id = rac.rac_store:get_areas_for_pos(region_center.string_to_pos,true,false)
				if region1.zone == "city" or region1.zone == "city" then
					admin_table.city = true
				elseif region1.zone == "outback" or region1.zone == "outback" then
					admin_table.outback = true
				end 
			end
			if admin_table.city and admin_table.outback then
				admin_table.city = false
				admin_table.outback = false
				admin_table.change_owner = true
				return_player = false
			end	
		end
		return return_player,admin_table
	else
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - #region_has_regions > 3  "	)		
		return 38 -- [38] = "ERROR: func: rac:can_player_set_region - Andere Gebiete sind davon betroffen, du kannst das so nicht claimen!",
	end	
end
	
	]]--
--[[	
	if region_has_regions[1] == nil then
		minetest.log("action", "[" .. rac.modname .. "] rac:can_player_set_region - region_has_regions[1] == nil "	)
		-- nicht in einer Region, dann wildniss
		-- prüfe claimable der Wildnis / oder region_admin
		if rac.wilderness.claimable or can_modify.admin then
			return true, admin_table
		else
			return 53 -- [53] = "ERROR: func: rac:can_player_set_region - Das Gebiete hat kein 'claimable' gesetzt!",
		end 
		-- es gibt eine überlappende Region 
		-- claimable = false -> player kann nicht, admin kann
	elseif #region_has_regions == 1 then --if region_has_regions == nil then
		-- es gibt eine Region
		-- darf man hier claimen
		if rac:get_region_attribut(region_has_regions[1],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[1],"zone") == "city"  then
				return_player = true
				admin_table.city = false
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
				return_player = true
				admin_table.outback = false
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "plot" then
				return_player = false
				admin_table.plot = false
				admin_table.change_owner = true
				admin_table.plot_id = region_has_regions[1]
			end
		end -- if rac:get_region_attribut(region_has_regions[1],"claimable") then
		-- prüfe die Anzahl der überalppenden Gebiete
		return return_player,admin_table
	elseif #region_has_regions == 2 then --if region_has_regions == nil then
	
		-- es gibt zwei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 1 claimable und 1 = city, dann 2 outback
		-- wenn 1 claimable und 1 = outback -- kann nicht claimen
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- wenn 2 claimable und 2 = city, dann 1 outback
		-- wenn 2 claimable und 2 = outback -- kann nicht claimen
		-- der Admin kann
		--	city/outback = plot - city/plot =outback - outback/plot = city 
		if rac:get_region_attribut(region_has_regions[1],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot"  then
				if rac:get_region_attribut(region_has_regions[2],"zone") == "city" or rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
					return_player = false
					admin_table.change_owner = true
					admin_table.plot_id = region_has_regions[1]
				end 
			elseif rac:get_region_attribut(region_has_regions[1],"zone") == "city" then
				if rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
					return_player = true	
				end
			end
		end
		if rac:get_region_attribut(region_has_regions[2],"claimable") then
			-- wenn es outback oder city ist und claimable = true, dann darf der Spieler setzen
			if rac:get_region_attribut(region_has_regions[2],"zone") == "plot"  then
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					return_player = false
					admin_table.change_owner = true
					admin_table.plot_id = region_has_regions[1]	
				end --admin_table.city = false
			elseif rac:get_region_attribut(region_has_regions[2],"zone") == "city" then
				if rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					return_player = true	
				end --admin_table.city = false
			end	
		end
		-- für den admin
		if can_modify.admin then
			if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[2],"zone") == "city" then
				admin_table.city = false
			end
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot" or rac:get_region_attribut(region_has_regions[2],"zone") == "plot" then
				admin_table.plot = false
			end
			if rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[2],"zone") == "outback" then
				admin_table.outback = false
			end			
		end
		return return_player,admin_table
	elseif #region_has_regions == 3 then
		-- es gibt drei Regionen
		-- ein Spieler darf nur claimen wenn
		--	claimable Reihenfolge plot, city, outback 
		--	city/outback - city/plot - outback/plot
		-- für Spieler
		-- wenn 1 claimable und 1 = plot, dann 2 city oder outback
		-- wenn 2 claimable und 2 = plot, dann 1 city oder outback
		-- return ist dann false und admin_table.change_owner = true
		-- der Admin kann
		-- kann keine weiteren Gebiete überlappen lassen
		if can_modify.set then
			if rac:get_region_attribut(region_has_regions[1],"zone") == "plot" and rac:get_region_attribut(region_has_regions[1],"claimable") then
				admin_table.plot_id = region_has_regions[1]
				if rac:get_region_attribut(region_has_regions[2],"zone") == "city" or rac:get_region_attribut(region_has_regions[3],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[2],"zone") == "outback" or rac:get_region_attribut(region_has_regions[3],"zone") == "outback" then
					admin_table.outback = true
				end 
			elseif rac:get_region_attribut(region_has_regions[2],"zone") == "plot" and rac:get_region_attribut(region_has_regions[2],"claimable") then
				admin_table.plot_id = region_has_regions[2]
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[3],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[3],"zone") == "outback" then
					admin_table.outback = true
				end 
			elseif rac:get_region_attribut(region_has_regions[3],"zone") == "plot" and rac:get_region_attribut(region_has_regions[3],"claimable") then
				admin_table.plot_id = region_has_regions[3]
				if rac:get_region_attribut(region_has_regions[1],"zone") == "city" or rac:get_region_attribut(region_has_regions[1],"zone") == "city" then
					admin_table.city = true
				elseif rac:get_region_attribut(region_has_regions[1],"zone") == "outback" or rac:get_region_attribut(region_has_regions[1],"zone") == "outback" then
					admin_table.outback = true
				end 
			end
			if admin_table.city and admin_table.outback then
				admin_table.city = false
				admin_table.outback = false
				admin_table.change_owner = true
				return_player = false
			end	
		end
		return return_player,admin_table
	else
		return 38 -- [38] = "ERROR: func: rac:can_player_set_region - Andere Gebiete sind davon betroffen, du kannst das so nicht claimen!",
	end	
end
]]--


--[[
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:region_in_region(pos1,pos2)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Gibt es in dem Bereich, dieser neuen Region andere Regionen?
-- - keine andere Region: jeder mit region_set darf setzen
-- - eine andere Region: diese ist "city" -> admin kann plot oder outback setzen
-- - eine andere Region: diese ist "outback" -> admin kann plot oder city setzen
-- - zwei andere Regionen: outback und city -> admin kann plot
-- - eine andere Region: diese ist "plot" dann darf man nichs setzen
-- - mehrere anderer Regionen: man darf nicht setzen	
--
--
-- input: 
--		pos1,pos2 	als Positionsvektor
--
-- return:
-- 	nil  - keine andere Region betroffen
--	table - mit den ID der betroffenen Regionen
-- 	
-- msg/error handling: no
function rac:OLD_region_in_region(pos1,pos2)
	local func_version = "1.0.0"
	if rac.show_func_version  then
		minetest.log("action", "[" .. rac.modname .. "] rac:region_in_region - Version: "..tostring(func_version)	)
	end
-- get all regions in this box
	local found = rac.rac_store:get_areas_in_area(pos1,pos2,true,true) --accept_overlap, include_borders, include_data):
	local is_city = false
	local count = 0
	
	-- loop all region
	for region_id,v in pairs(found) do
		-- if in one region the city-attribut is set is counts for all region there!
		minetest.log("action", "[" .. rac.modname .. "] region_in_region! region_id "..tostring(region_id) )  
--		minetest.log("action", "[" .. raz.modname .. "] region_is_plot! city "..tostring(raz:get_region_attribute(region_id,"city")) )  
--		minetest.log("action", "[" .. raz.modname .. "] region_is_plot! plot "..tostring(raz:get_region_attribute(region_id,"plot")) )  

		-- city hat plots und freie stellen zwischen den plots
		-- in einer City kann der region_admin plots setzen.
		if rac:get_region_attribute(region_id,"zone") == "city" then
			is_city = true
		end
		-- are there more than 1 region
		count = count + 1 
	end -- for region_id,v in pairs(found) do
	
	-- check:
	minetest.log("action", "[" .. rac.modname .. "] region_is_plot! count "..tostring(count) ) 
	
	-- es wurde keine Region gefunden - man kann diese Region also anlegen 
	if count == 0 then
		return nil			-- no regions found
	end
	
	-- 1 Region gefunden
	-- ist es eine City und kein Plot, kann man die Region anlegen
	if count == 1 then
		if is_city then
			return true
		end	
	-- mehr als 2 Regionen wurden gefunden, dann geht nichts
	else
		return count 	-- anzahl der gefunden Regionen
	end
end

]]--

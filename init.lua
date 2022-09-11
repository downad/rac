--[[
Region Areas and City
	erstelle Regionen in deiner Minetestwelt
	wilderness - alles was keiner Region zugewiesen ist
	city: in der City kann man Bauplätze (hier plot genannt) markieren 
	plot: diese Bauplätze können an Spieler vergeben werden.
	Jeder Gebiet hat einen Zonenbezeichner:
		allowed_zones = { "none", "city", "plot", "owned"  },
		none 		- das Gebiet ist noch nicht besetzt
		owned		- es gibt einen Besitzer,
						Der Spieler hat ein Gebiet geclaimed
						Dazu muss claimable = true
						Ein spieler darf im "outback", auf einer "city" oder in der Wildnis ("none") claimen
		outback	- Der region_admin kann ein Gebiet als outback markierern.
						darauf kann man city oder plots setzen.	In der Regel ist das Outback nicht claimable.			 	
		city		- Der region_admin kann Gebiete als city bestimmen und dafür Attribute festlegen.
						Auf einem City-Gebiet kann der region_admin plots, Bauplätze für die Spieler festlegen.
						Eine city kann in der Wildniss oder im outback sein.
						In der Regel ist eine City-Zone nicht Claimable, die Spieler sollen hier nicht einfach so claimen können
		plot		- der Bauplatz, er liegt immer auf einem anderen Gebiet.
						Der Bauplatz wird von region_admin angelegt.
						Er ist in der Regel nicht claimable. 
						In der REgel überträgt der region_admin den Bauplatz an den Spieler.
						!Auf dem plot gelten die Regeln des Besitzer!				 
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


-- namespace rac = region, areas and zones
rac = {

	-- Paths and infos to the mod
	worlddir = minetest.get_worldpath(),
	modname = minetest.get_current_modname(),
	modpath = minetest.get_modpath(minetest.get_current_modname()),
	
	-- diese Attribute gelten für die freien Gebiete, die Wildnis
	wilderness = {
		owner = "King Arthur",  -- default: "king arthur". Dieser Name wird angezeigt, mögliches Problem: ein Spieler heißt so!!!!!
		name = "Wildnis",				-- default: "wilderness". Diese Anzeige erscheint im Hud	
		claimable = true,				-- default: true. Ein Spieler mit dem passenden Recht kann sich eine Region aneignen 	
		zone = "none",					-- default: "none". Das Gebiet ist keiner Zone zugewiesen
		protected = false,			-- default: false. Das Gebiet is nicht geschützt. true würde einen weltweiter Schutz bedeuten (oder das Schutzleve des Gebietes) 
		guests = "",						-- default: "". Es gibt keine Gäste
		pvp = false,							-- default: false. Kein PvP erlaubt
		mvp = true,							-- default: true. Monster machen schaden
		effect = "none",				-- default: "none", In der Wildnis gibt es keine besonderen Effekte 
		text_wilderness = "Du bist in der Wildnis!", 
		text_pvp ="Vorsicht PvP ist erlaubt!",
		text_protected ="(geschützt) ",
		text_owner ="gehört",  -- daraus wird ein String: name .. "gehört" .. owner
	},
	-- diese Attribute gelten für ein frisch angelegtes Gebiet	
	region_attribute = {
		-- in Version 1.0 sind diese Attribute erlaubt
		allowed_region_attribute= {"owner","region_name","claimable","zone","protected","guests","pvp","mvp","effect" },
		--	owner								as string, this MUST be!
		--	region_name					as string, this MUST be!
		--	claimable						as boolean
		--	zone								as string, allowed_zones = { "none", "outback", "city", "plot", "owned"  },
		--	protected						as boolean
		--	guests							as string, comma separated Player_names
		--	pvp									as boolean
		--	mvp									as boolean
		--		effect							as string, allowed_effects = {"none", "hot", "dot", "bot", "choke", "holy", "evil"},
		--   version							as string
		claimable = false, -- true wenn der Player das Gebiet claimen darf
		zone = "none",  
		allowed_zones = { "none","outback", "city", "plot", "owned"  },
		protected = true,	-- der admin stellt das um wenn nötig
		guests = "",		--empty list finals with ','
		pvp = false,
		mvp = true,
		effect = "none",
		allowed_effects = {"none", "hot", "dot", "bot", "choke", "holy", "evil"},
		version = "1.0",
	},


	-- for debugging
	debug = {
		error = 4,
		warning = 3,
		info = 2,
		verbose = 1,
	}, 
	show_func_version = true, -- wird ab debug.info gezeigt
	
	-- 4 error, 3 warning, 2 info, 1 verbose, 
	debug_level = 3, 
	
	
	-- some minimum/maximum values for the regions
	minimum_width = 2,			-- the smalest region for player is a square of 3 x 3
	minimum_height = 4,			-- the minimum heigh is 4 
	maximum_width = 100,		-- for player
	landrush_width = 16,			-- if a landrush module will be created
	landrush_height = 16,			-- if a landrush module will be created
	maximum_height = {
		owned = 60,		-- for player
		plot = 60,			-- for player
		city = 100,		-- admin
		outback = 150,	-- admin
		none = 0,
	},
	drop_plotstone = "rac:plotstone",
	-- some values for the region effects
	timer = 0,
	region_effect = {
		-- the interval of dealing effects
		time = 1,
		-- life gaining 1 HP per effect_time seconds 	
		hot = 1,
		-- food gaining 1 per effect_time seconds 	
		--effect_fot = 1,
		-- breath gaining 1 per effect_time seconds 	
		bot = 1,
		-- loosing life 1 HP per effect_time seconds 	
		dot = 1,
		-- loosing food 1  per effect_time seconds 	
		--effect_starve = 1,
		-- loosing breath 5 per effect_time seconds 	
		choke = 5,
	},

	
	-- der AreaStore() wird initialisiert
	rac_store = AreaStore(),
	
	-- the filename for AreaStore
	store_file_name = "rac_store.dat",
	export_file_name ="rac_export_file.txt",
	backup_file_name ="rac_backup_",
	
	-- init saved huds 
	player_huds = {},
	-- init player_guide
	player_guide = {},
	
	-- some color for the hud
	color = {
		red = "0xFF0000", 				-- 					schlecht lesbar
		orange = "0xFF8C00",			-- outback
		purple = "0x800080", 			-- 
		yellow = "0xFFFF00",			-- city
		blue = "0x0000FF",				-- 					schlecht lesbar, besser als rot
 		white = "0xFFFFFF",				-- owned
		magenta = "0xFF00FF",			-- plot
		crimson = "0xDC143C",			-- wilderness/none
	},

	-- some more defaults
	region_order = { },
	
	-- global PvP in minetest.conf
	enable_pvp = minetest.settings:get_bool("enable_pvp"),

	-- init command_players for chatcommands
	command_players = {},
	compass_players =  {},
	marker_modify_height = 2, -- falls bei setzen mit markern die Höhe nicht stimmt, halber minimum-Wert
	marker1 = {},		-- for placing edges-boxes 
	marker2 = {},		-- for placing edges-boxes 
	set_command = {},	-- for punchnode function
	
	marker_delete_time = 16, -- nach 600  -> 10 minuten löschen sich die Marker selbständig 
}

--rac.compass_players = { adownad = {} }
--rac.compass_players["adownad"].active = true
--rac.compass_players["adownad"].region_id = 1
-----------------------------------
-- load some .luas
-----------------------------------
--
-- the functions for this mod
dofile(rac.modpath.."/settings.lua")			-- errorhandling: NONE
dofile(rac.modpath.."/rac_lib.lua")			-- errorhandling: done
dofile(rac.modpath.."/rac_lib_new.lua")			-- errorhandling: done
dofile(rac.modpath.."/error_msg_text.lua")			-- Tabelle mit Error/msg Nummer
dofile(rac.modpath.."/command_func.lua")	-- errorhandling: done

-- init globalstep for the hud
dofile(rac.modpath.."/globalstep.lua") 		-- errorhandling: done

-- do effects 
dofile(rac.modpath.."/effect_func.lua")		-- errorhandling: done

-- create an hud
dofile(rac.modpath.."/hud.lua")				-- errorhandling: done

-- modify minetest-functions
dofile(rac.modpath.."/minetest_func.lua")	-- errorhandling: done

-- set priviles and commands
dofile(rac.modpath.."/privilegs.lua")	-- errorhandling: done	

-- set items Landrush, entity,...
dofile(rac.modpath.."/items.lua")

-- set region RAC-Guide
dofile(rac.modpath.."/rac_guide.lua")		

-- if you want do set some default regions, 
-- use debug.lua 
-- dofile(rac.modpath.."/debug.lua")


-- load regions from file
-- fill AreaStore()
--local err = rac:load_regions_from_file()
--rac:msg_handling(err)

-- check if region must be converted
--err = rac:convert_region_to_version()
--rac:msg_handling(err)


minetest.log("action", "[" .. rac.modname .. "] Daten aus mintest.conf: enable_pvp = "..tostring(rac.enable_pvp))
local serveradmin = minetest.settings:get("name")
minetest.log("action", "[" .. rac.modname .. "] Daten aus mintest.conf: serveradmin = "..tostring(serveradmin))
	
--[[	
-- zu Testzwecken
--return {["y"] = -8, ["x"] = -555, ["z"] = -366}
--return {["y"] = 21, ["x"] = -517, ["z"] = -320}
--return {["protected"] = true, ["city"] = false, ["guests"] = "adownad,Cori", ["owner"] = "Downad", ["plot"] = false, ["region_name"] = "DunDownad", ["PvP"] = false, ["effect"] = "none", ["MvP"] = false}
local pos1 = minetest.deserialize("return {[\"y\"] = -8, [\"x\"] = -555, [\"z\"] = -366}")
local pos2 = minetest.deserialize("return {[\"y\"] = 21, [\"x\"] = -517, [\"z\"] = -320}")
--local data = minetest.deserialize("return {[\"protected\"] = true, [\"city\"] = false, [\"guests\"] = \"adownad,Cori\", [\"owner\"] = \"Downad\", [\"plot\"] = false, [\"region_name\"] = \"DunDownad\", [\"PvP\"] = false, [\"effect\"] = \"none\", [\"MvP\"] = false}")
local data = "return {[\"protected\"] = true, [\"city\"] = false, [\"guests\"] = \"adownad,Cori\", [\"owner\"] = \"Downad\", [\"plot\"] = false, [\"region_name\"] = \"DunDownad\", [\"PvP\"] = false, [\"effect\"] = \"none\", [\"MvP\"] = false}"
minetest.log("action", "[" .. rac.modname .. "] data = "..tostring(data))
local err
-- aufruf mit den Parameter siehe eintrag
-- function rac:create_data_string(owner   ,region_name,claimable,zone	 ,protected,guests_string,pvp  ,mvp  ,effect,check_player)
err, data = rac:create_data_string("Downad","DunDownad",true		 ,"owned",true     ,"-"          ,false,false,"none",true)
minetest.log("action", "[" .. rac.modname .. "] nach rac:create_data_string - err = "..err)
if err >  0 then
	rac:msg_handling(err)
else
	minetest.log("action", "[" .. rac.modname .. "] nach rac:create_data_string - data = "..data)
end
-- ein TESTgebiet wird angelegt
minetest.log("action", "[" .. rac.modname .. "] -- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +")
minetest.log("action", "[" .. rac.modname .. "] lege das Testgebiet an")
err,id = rac:set_region(pos1,pos2,data)
if err >  0 then
	rac:msg_handling(err)
else
	minetest.log("action", "[" .. rac.modname .. "] nach rac:create_data_string - region_id = "..tostring(id))
end
minetest.log("action", "[" .. rac.modname .. "] -- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +")


]]--

-- load regions from file
-- fill AreaStore()
local check = 0 -- 1 check integrity, 2 check version, 4 check both.
local err = rac:load_regions_from_file(check)
rac:msg_handling(err,"init.lua")

--err = rac:delete_region(2)
-- rac:msg_handling(err)


-- all done then ....
minetest.log("action", "[" .. rac.modname .. "] version "..rac.region_attribute.version.." successfully loaded")












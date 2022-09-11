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


-- Aus diesen Namen wird ein zufälliger Regionname gebildet.
-- der {name} wird durch den Namen des Spielers ausgetauscht
rac.area_names = {
		[1] = "Haus {name}",
		[2] = "Castle {name}",
		[3] = "Schloß {name}",
		[4] = "Burg {name}",
		[5] = "Anwesen {name}",
		[6] = "{name}ingen",
		[7] = "{name}heim",
		[8] = "{name}furt",
	}
	
-- diese Texte werden im hud angezeigt
rac.zone_text = {
		none = "-",					-- default: none
		outback = "outback",		-- default: outback
		city = "city",					-- default: city
		plot =  "plot",					-- default: plot
		owned = "owned", 				-- default: owned
}	

-- Standarthöhe von Regionen
rac.zone_default_height = {
		none = 0,					-- default: 0 ist wilderness das sollte es nicht geben
		outback = 120,		-- default: 120, im Normalfall 2/3 nach oben über der Mitte der gesetzten Ecken
		city = 100,				-- default: 100, im Normalfall 2/3 nach oben über der Mitte der gesetzten Ecken
		plot =  80,				-- default: 80, im Normalfall 2/3 nach oben über der Mitte der gesetzten Ecken
		owned = 60, 			-- default: 60, im Normalfall 2/3 nach oben über der Mitte der gesetzten Ecken
}	

-- Falls die Monster in den REgionen unterschiedlichen Schaden machen sollen
-- Dieser Multiplikator findet nur bei MvP Verwendung 
rac.zone_mob_damage = {
		none = 2,					-- default: 2
		outback = 1.5,		-- default: 1.5
		city = 1,					-- default: 1
		plot =  1,				-- default: 1
		owned = 1, 				-- default: 1
}	
	
		-- falls der Serveradmin automatisch region_admin sein soll
rac.serveradmin_is_regionadmin = false -- default: false

	-- if 'digging in an protected region damage the player
rac.do_damage_for_violation = true			-- default: true

	-- the damage a player get for 'digging' in a protected region
rac.damage_on_protection_violation = 4 -- default: 4. Der Spieler bekommt 4 Schaden wenn er in einem geschützten Gebiet etwas abbaut.
	
rac.craft = {
	plotstone = true, 	-- Soll der Plotstone gecrafted werden können True/false	
	mark = true,				-- Soll man die rac:mark zum claimen von Region bauen können? 
	}
	
	

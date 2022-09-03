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
	
	
	razguide wurde inspiriert von serverguide of AiTechEye 
	https://github.com/AiTechEye/serverguide.git
	Licence: Licenses: LGPL-2.1
	
	
]]--
-- weiter variablen
-- hier sind alle Texte für den RAC Guide
rac.razguide = {
		Book_title="Ein Guide für das Mod RAZ, Regionen, Areas und Zonen",
		Tab_1="verwalten",
		Tab_2="mehr",
		Tab_3="player-Handbuch",
		Tab_4="Admin-Handbuch",
		Tab_5="aktuelles Gebiet",
		-- Tab_6 ist das X zum Schließen der Form
		-- zusätzlich zu den Tabs oben am Buch gibt es buttons
		Button_7 = "Schutz ausschalten",	-- protection ausschalten
		Button_8 = "Schutz einschalten", 	-- protection einschalten		
		Button_9 = "add", 							 	-- Gast speichern
		Button_10 = "ban",		 					 	-- Gast löschen
		Button_11 = "rename", 				 		-- region Name ändern
		Button_12 = "PvP ausschalten",		-- pvp ausschalten
		Button_13 = "PVP einschalten", 		-- pvp einschalten		
		Button_14 = "MvP ausschalten",		-- mvp ausschalten
		Button_15 = "MVP einschalten", 		-- mvp einschalten
		Button_16 = "change Owner",		 		-- Gebiet übertragen - Change_Owner
		Button_17 = "delete Region",	 		-- Gebiet löschen 
		Button_18 = "add", 							 	-- Effekt hinzufügen
		Button_19 = "delete",		 					-- Effekt löschen 
		Button_20 = "claimable off",			-- claimable off
		Button_21 = "claimable on",		 		-- claimable on
		Button_22 = rac.zone_text.none,		-- Zone 'none'
		Button_23 = "use",		 						-- Button Zeile 1
		Button_24 = "use",		 						-- Button Zeile 2
		Button_25 = "use",		 						-- Button Zeile 3 
		Button_26 = "active",	 						-- Button Zeile 1-3 - activ 
		Button_27 = rac.zone_text.outback,		-- Zone 'outback'
		Button_28 = rac.zone_text.city,		-- Zone 'city'
		Button_29 = rac.zone_text.plot,		-- Zone 'plot'
		Button_30 = rac.zone_text.owned,		-- Zone 'owned'
		
	
		
		-- Texte für die Seiten
		Tab_Text_1="", -- wird bei do_this == 1 gebaut
		Tab_Text_2="Effekte:\n Je nach Privileg kann man sein Gebiet mit Effekten belegen. \n -> region_effect: \n - - hot: das Gebiete heilt den Spieler \n - - dot: das Gebiet macht dem Spieler Schaden\n - - bot: breath over time, der Atembalken wird gefüllt.\n - - choke: reduce breath over time, die Atemluft wird abgezogen.\n - - holy: hier wirken zwei Effekte, hot und bot\n - - evil: auch hier sind zwei Effekte (dot, choke) aktive.\n -> region_pvp: \n - - mit dem Command: 'region pvp {on/off}' \n - - kann man das pvp in diesem Gebiet an- bzw. ausschalten.\n -> region_mvp: \n - - mit dem Command: 'region mvp {on/off}' \n - - kann man den Schaden von Mobs (Monster) in diesem Gebiet \n - - an- bzw. ausschalten.",
		Tab_Text_3="Admin-Info:\nÜbersicht über die Commands: \n - region remove {id/all} \n - - löscht die Region {id} oder alle Regionen \n - region show \n zeigt eine Liste mit allen Gebieten \n - region show {id} - zeigt das Gebieten mit der [id} \n - region show {id1} {id2} - zeigt alle Gebiete in diesem Intervall \n - region export \n- - eine Liste aller Gebiete wird in das World-Verzeichnis gespeichert.\n - - Diese könnte angepasst werden (3 Zeilen je Gebiet und alles Eigenschaften) \n - region import\n - - damit kann die Liste wieder importiert werden. \n - - Tipp: zuvor alle Gebiete löschen (region remove all). \n - region city {on/off} \n - - in einer City kann der Admin Bauplätze ausweisen, die die Spieler bekommen können.\n ",
		Tab_Text_4="Privilegien:\n Es gibt 6 privilegien für das mod RAZ \n - region_mark -> damit kann man ein Gebiet setzen. \n - - Eigene Gebiete schützen (protect = true) oder freigegeben (protect = false). \n - - - Du kannst dein Gebiet umbenennen oder löschen.\n - region_set -> anderen Spielen (Gäste) erlauben in deinem Gebiet zu \"arbeiten\".\n - - Du kannst dein Gebiet an andere übertragen (change_owner)\n - region_pvp -> damit kann man auf seinen Gebiet das PVP aktivieren oder deaktivieren\n - region_mvp -> damit schaltest du den Monsterdamage auf dem Gebiet an oder aus.\n - region_effect -> damit kann das Gebiet mit \"Effekte\" belgt werden \n - - z.B. hot = heal over time \n - - dot = damage over time \n - - bot = breath over time\n - - choke = reduce breath over time \n - - holy = hot & bot \n - - evil = dot & choke \n - region_admin = Der Admin kann alles \n - - zusätzlich löschen einzelner/aller Gebiete \n - - exportieren und importieren der Gebiete",
		Tab_Text_5="Hilfe-Info:\n bei Fragen wende dich an das minetest-Forum: \n https://forum.minetest.net/viewtopic.php?p=346397 \n oder sende eine email an downad@freenet.de.",
	
	}

-- Diese Werte sind Positionen der Form Elemente 
-- l zeile, lb zeile für den Button
rac.line = {
			l1 = 2.3,   	-- Zeile 1
			b1 = 2.3,
			l2 = 3.4,  		-- Zeile 2
			b2 = 3.4, 	 
 			l3 = 4.6,			-- Zeile 3
 			b3 = 4.6,
			l4 = 5.9,			-- verwalten: Schutz
			b4 = 5.8,
			l5 = 7.2,			-- verwalten: rename
			b5 = 6.9,
			l6 = 8.3,			-- verwalten: change Owner
			b6 = 8.0,
			l7 = 9.4,			-- verwalten: löschen
			b7 = 9.1,
			l8 = 10.5,		-- verwalten: Gäste 
			b8 = 10.2,
			bcol1 = 0, 	-- Spalte Button eins	
			bcol2 = 1.4, 		-- Spalte Button zwei
			bcol3 = 2.8, 	-- Spalte Button drei	
			bcol4 = 4.2, 		-- Spalte Button vier
			bcol5 = 5.6, 	-- Spalte Button fünf	
			bcol6 = 7, 		-- Spalte Button sechs
			bcol7 = 8.4, 	-- Spalte Button sieben	
			bl1	= 2.7, 		-- Länge: langer Button
			bl2 = 1.3,		-- Länge: kurzer Button	
			bl3 = 2.0,		-- Länge: mittlerer Button	
			lin = 6.5,		-- Länge des Inputfeldes
			bh = 1,				-- Höhe des Button / der Felder	
		}



-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:guide(player,do_this)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Diese Funktion steuert das RAC-Guide
-- ein Spieler kann so seine Regionen verwalten (ganz ohne Commands)
--	
--
-- input: 
--		player			als Player Objekt
--		do_this			as number, Das ist der Schalter für das Buch 
--
-- return:
--  return "done" 
-- 	dennoch erfolgt ein Aufruf von 
-- 	minetest.register_on_player_receive_fields(function(player, form, pressed)
--	als Form wird hier 'razguide' verwendet
--
-- zum Austausch zwischen dem guide und der Form
--	rac.player_guide[player_name].err								-- Infomesg oder Errormeg
-- 	rac.player_guide[player_name].region_id					-- Table mit den Region ID zur aktiven Region
-- 	rac.player_guide[player_name].active_region			-- aktive Region, eine Zahl von 1..3 => given_region
-- 	rac.player_guide[player_name].do_this						-- do_this
--
-- msg/error handling: YES
-- 	hardcoded, direkter Aufruf von rac:msg_handling(err)	
-- 	über rac.player_guide[player_name].err kann ein austausch von Fehlern / nachrichten zwischen der Form und dieser Funktion stattfinden
function rac:guide(player,do_this)
	local func_version = "1.0.0"
	local func_name = "rac:guide"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - do_this: "..tostring(do_this)	)
	end
	
	local err  							-- Fehler
	local info_text = ""		-- Error/Infoanzeige in der Form
	-- Sting für die Texte, die angezeigt werden 
	local text_allgemein = ""
	local text = ""
	local text_attribute = ""
	local line = rac.line -- die Koordinaten der Zeilen 
	local given_region = nil -- es wurde keine ID übergeben 
	-- da man mit dem Buch das Gebiet verwalten kann benötig man einige Werte
	-- aus der Position ds Spieler wird können die Regions_ID ermittelt werden
	local pos = vector.round(player:get_pos())
	if rac.debug and rac.debug_level > 7 then
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - pos: "..tostring(minetest.serialize(pos))	)
	end
	
	-- hole den Playername 	
	local player_name = player:get_player_name()
	-- wurde eine ID übergeben, dann muss das aktiv gesetzt werden
	local active_region = 1 -- das ist der key für region_id, ohne Übergabe das 1. Element

	-- wurde zu diesem Player eine 	rac.player_guide[player_name] angelegt?
	-- wenn ja, erfolgt der Aufruf dieser Funkion über eine Aktion aus dem Buch
	-- also könnte man mögliche Nachrichten ausgeben müssen
	-- z. B:
	-- 	"Es gab einen Fehler"
	--  "alles hat geklappt"
	if rac.player_guide[player_name] ~= nil then
		-- test ob eine Fehlermeldung da war
		err = rac.player_guide[player_name].err
		--minetest.log("action", "[" .. rac.modname .. "] rac:guide - rac.player_guide[player_name].err > 0 - err: "..tostring(err)	)
		-- es ist kein Text vorhanden
		if err == nil then
			info_text = ""
		elseif err > 0 then	 -- es gibt einen error_msg_text!
			-- laden den error_msg_text in info_text
			-- muss das noch angepasst werden?????
			info_text = rac.error_msg_text[rac.player_guide[player_name].err] 
		else
			info_text = "Vorgang abgeschlossen"
		end
		
		-- wurde eine ID übergeben?
		given_region = rac.player_guide[player_name].active_region -- _id
		
		if rac.player_guide[player_name].active_region ~= nil then
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - if rac.player_guide[player_name].active_region ~= nil then "	)
			active_region = rac.player_guide[player_name].active_region
		else
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - if rac.player_guide[player_name].active_region == nil then "	)

		end
	end	
	
	minetest.log("action", "[" .. rac.modname .. "] rac:guide - info_text: "..tostring(info_text)	)
	
	-- resette den rac.player_guide
	rac.player_guide[player_name] = {}
	
	
	-- hole die Region(en) zu der aktuellen Position
	local region_data = {} --1,region_data2,region_data3												-- alle Region Atrtibute
	local data

	
	local err,region_id = rac:get_region_at_pos(pos)
		rac:msg_handling(err,func_name)	
		
		if err ~= nil then
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - nachdem die Regionen geholt wurden: "	)
			minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Anzahl gefundener Regionen #region_id: "..tostring(#region_id)	)
			
			-- hole die Werte der Regionen
			for key, id in pairs(region_id) do
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - key: "..tostring(key).." ID = "..tostring(id)	)
				err, data = rac:get_region_datatable(id)
				minetest.log("action", "[" .. rac.modname .. "] rac:guide - rac:get_region_at_pos(pos) err: "..tostring(err)	)

				if err == 0 then 
					table.insert(region_data, data)
--					region_data = { key = data }
				else
					rac:msg_handling(err,func_name)
				end
				-- es wurde ein ID übergeben
				-- setzen aktive_id
				--if given_region_id ~= nil then
				--	if given_region_id == id then active_region = key end
				--end	
				minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - region_data[key].region_name= "..tostring(region_data[key].region_name)	)
			end
			
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - #region_id: "..tostring(#region_id)	)
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - region_id[1]: "..tostring(region_id[1])	)
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - given_region_id: "..tostring(given_region)	)
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - active_region: "..tostring(active_region)	)
	else
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - keine region_id: "..tostring(err)	)
	end
	
	--  Table can_modify	-->siehe privilegs.lua
	-- erlaubt das Modifizieren des Region / Was ist für den Spieler erlaubt?	
	local can_modify = rac:player_can_modify_region_id(player)					
	
	-- local is_protected, guests, region_name		-- Region Attribute die verwaltet werden können
	

	-- Tab_1 - Verwalten des Gebiet (Owner und/oder privs: effect,mvp,pvp,guest) 
	if do_this==1 or do_this == 2 then --text=rac.razguide["Tab_Text_1"] end
	
	-- überarbeiten
	-- alle region_at_pos holen und anzeigen
	-- player ist owner das anzeigen / auswählen
	-- admin, umschalten zwischen den ID zulassen, evtl. übergabe über rac.player_guide[player_name] = {}
	-- umbauen der UI
	-- 3 Blöcke mit infos zu zone 1..3
	-- das sollte platz schaffen
	-- page1 bis gäste
	-- page2 pvp,mv, und effekte auf admin seite
	
	
	

		-- es gibt mindestens eine Region!
		if region_id ~= nil then
			-- test owner, bei 2 Gebieten city und plot muss der player plot_owner sein
			-- ausnahme Admin
		

			-- hole die RegionData und mache das Errorhandling
--			err, region_data = rac:get_region_datatable(region_id[1]) 
--			rac:msg_handling(err,func_name)
				
			-- allgemeine Infos	(unabhängig von Rechten oder Owner-schaft)
			text_allgemein = "Aktives Gebiet: "..region_data[active_region].region_name.." (ID: "..region_id[active_region]..") Dieses Gebiet gehört: "..region_data[active_region].owner
			-- text_allgemein = text_allgemein.."\n" --Das ist bisher eingestellt:"

			-- ende allgemeine Infos
			
			if do_this == 1 then
				text_allgemein = text_allgemein.."\nDiese Gebiete "
				if region_data[active_region].claimable then 
					text_allgemein = text_allgemein.." kann man  claimen."
				else
					text_allgemein = text_allgemein.." darf man nicht claimen!"
				end
				
				-- prüfe Owner, der darf maches immer.
				if region_data[active_region].owner == player_name then
					--err, region_data = rac:get_region_datatable(region_id[1]) 
					can_modify.is_owner = true
					-- owner darf immer
					can_modify.protected = true
					can_modify.change_owner = true
					can_modify.delete_region = true
					can_modify.rename_region = true
					text_allgemein = text_allgemein.."\n"..info_text
				else
					text_allgemein = text_allgemein..text.. "\nDa du nicht der Besitzer bist, kannst du es nicht verwalten!"
				end
			end
			text_allgemein = text_allgemein..text
		else -- region_id == nil
			text_allgemein = rac.wilderness.text_wilderness.." Hier kann man nichts sehen oder verwalten."
		end -- region_id == nil
		
	end -- if do_this==1 then 
	
	-- diese Tabs verändern den Text der Form, das muss angepasst werden
	-- text = text_allgemein 
	--if do_this==2 then text_allgemein=rac.razguide["Tab_Text_2"] end
	if do_this==3 then text_allgemein=rac.razguide["Tab_Text_3"] end
	if do_this==4 then text_allgemein=rac.razguide["Tab_Text_4"] end
	if do_this==5 then text_allgemein=rac.razguide["Tab_Text_5"] end
	

	minetest.log("action", "[" .. rac.modname .. "] rac:guide -vor Form - text_allgemein "..tostring(text_allgemein)	)
	-- bau die Ausgabe zusammen
	-- Tab_1 .. Tab_5 sind die Reiter oben
	-- darunter steht dann immer ein Text in einem "label"
	-- abhängig vom Privileg des Player wird weiter unter die Form erweitert.	
	local form="size[10.1,11]" ..default.gui_bg..default.gui_bg_img..
		"button[0,0;1.7,1;tab1;" .. rac.razguide["Tab_1"] .. "]" ..
		"button[1.8,0;1.7,1;tab2;" .. rac.razguide["Tab_2"] .. "]" ..
		"button[3.6,0;1.7,1;tab3;" .. rac.razguide["Tab_3"] .. "]" ..
		"button[5.4,0;1.7,1;tab4;" .. rac.razguide["Tab_4"] .. "]" ..
		"button[7.2,0;1.7,1;tab5;" .. rac.razguide["Tab_5"] .. "]" ..
		"button_exit[9,0; 1,1;tab6;X]" ..
		"label[0,1;"..text_allgemein .."]"
		
		
	
	
	-- ohne priv admin kann man nur eigenen Gebiete anpassen
	-- das folgende gilt nur für den Tab 1 = do_this == 1!!!
	-- und region_id ~= nil
	if region_id ~= nil then
		-- Baue die oberen 3 Zeilen für 'verwalten' und 'mehr'	
		local region_text1 = ""
		local region_text2 = ""
		local region_text3 = "" 
		
		-- speichere das do_this, wird bei der Form benötigt
		rac.player_guide[player_name].do_this	= do_this
		-- speichere region_id
		rac.player_guide[player_name].region_id	= region_id
		rac.player_guide[player_name].active_region=active_region
		
		----
		minetest.log("action", "[" .. rac.modname .. "] rac:guide Warum kann man nicht umstellen?"	)
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - #region_id: "..tostring(#region_id)	)
		minetest.log("action", "[" .. rac.modname .. "] rac:guide - active_region: "..tostring(active_region)	)
		for key, id in pairs(region_id) do
			minetest.log("action", "[" .. rac.modname .. "] rac:guide - key: "..tostring(key).." id = "..tostring(id)	)
		end
		----
		
		
		-- unterscheiden nach can.modify.admin und owner
		if #region_id > 0 then
			region_text1 = "ID "..region_id[1]..": "
			if can_modify.admin then
				region_text1 = region_text1.. " > "..rac:get_stacked_zone_as_string(region_id[1]).." <\n "			
			end
			region_text1 = region_text1.. "Owner: "..region_data[1].owner..", "..region_data[1].region_name
			
			form = form.."label[0,"..line.l1..";"..region_text1.."]"
			if active_region == 1 and (can_modify.is_owner or can_modify.admin) then
				form = form.."button["..line.bcol7..","..line.b1..";"..line.bl2..","..line.bh..";tab23;"..rac.razguide["Button_26"] .. "]"
			else
				form = form.."button["..line.bcol7..","..line.b1..";"..line.bl2..","..line.bh..";tab23;"..rac.razguide["Button_23"] .. "]"
			end
		end
		if #region_id > 1 then
			region_text2 = "ID "..region_id[2]..": "
			if can_modify.admin then
				region_text2 = region_text2.. " > "..rac:get_stacked_zone_as_string(region_id[2]).." < \n "	
			end
			region_text2 = region_text2.. "Owner: "..region_data[2].owner..", "..region_data[2].region_name
			
			form = form.."label[0,"..line.l2..";"..region_text2.."]"
			if  active_region == 2 and (can_modify.is_owner or can_modify.admin) then
				form = form.."button["..line.bcol7..","..line.b2..";"..line.bl2..","..line.bh..";tab24;"..rac.razguide["Button_26"] .. "]" 
			else
				form = form.."button["..line.bcol7..","..line.b2..";"..line.bl2..","..line.bh..";tab24;"..rac.razguide["Button_24"] .. "]" 
			end
		end
		if #region_id > 2 then
			region_text3 = "ID "..region_id[3]..": "
			if can_modify.admin then
				region_text3 = region_text3.. " > "..rac:get_stacked_zone_as_string(region_id[3]).." <\n "	
			end
			region_text3 = region_text3.. "Owner: "..region_data[3].owner..", "..region_data[3].region_name
			
			form = form.."label[0,"..line.l3..";"..region_text3.."]"
			if  active_region == 3 and (can_modify.is_owner or can_modify.admin) then
				form = form.."button["..line.bcol7..","..line.b3..";"..line.bl2..","..line.bh..";tab25;"..rac.razguide["Button_26"] .. "]" 
			else
				form = form.."button["..line.bcol7..","..line.b3..";"..line.bl2..","..line.bh..";tab25;"..rac.razguide["Button_25"] .. "]"  
			end	
		end
		if (can_modify.is_owner or can_modify.admin) and do_this == 1  then
		
			-- speichere die ID in rac.player_guide
			rac.player_guide[player_name]["guests"] = {}
			
			-- Spieler darf protected ändern
			-- Text und ein langer Button
			if can_modify.protected then
				text_attribute = "Schutz/Protektion: Dieses Gebiet ist "
				if region_data[active_region].protected then
					form = form.."label[0,"..line.l4..";"..text_attribute.." geschützt!  ".."]".."button["..line.bcol6..","..line.b4..";"..line.bl1..","..line.bh..";tab7;" .. rac.razguide["Button_7"] .. "]" 
				else
					form = form.."label[0,"..line.l4..";"..text_attribute.." ungeschützt.".."]".."button["..line.bcol6..","..line.b4..";"..line.bl1..","..line.bh..";tab8;" .. rac.razguide["Button_8"] .. "]" 
				end	
			end
					
			-- Spieler darf Region_name ändern
			-- Text und ein langer Button
			if can_modify.rename_region then
				text_attribute = "Name des Gebietes:"
				form = form.."field[0.3,"..line.l5..";"..line.lin..","..line.bh..";rename;"..text_attribute..region_data[active_region].region_name..";]".."button["..line.bcol6..","..line.b5..";"..line.bl1..","..line.bh..";tab11;".. rac.razguide["Button_11"] .. "]" 
			end
			
			-- Spieler darf Region an andere übertragen
			-- Text und ein langer Button
			if can_modify.change_owner then
				text_attribute = "Besitzer: "
				form = form.."field[0.3,"..line.l6..";"..line.lin..","..line.bh..";change_owner;"..text_attribute..region_data[active_region].owner..";]".."button["..line.bcol6..","..line.b6..";"..line.bl1..","..line.bh..";tab16;".. rac.razguide["Button_16"] .. "]" 
			end
			
			-- Spieler darf Region an andere übertragen
			-- Text und ein langer Button
			if can_modify.delete_region then
				text_attribute = "VORSICHT: Region löschen! Region ID eingeben!"
				form = form.."field[0.3,"..line.l7..";"..line.lin..","..line.bh..";delete_region;"..text_attribute..";]".."button["..line.bcol6..","..line.b7..";"..line.bl1..","..line.bh..";tab17;".. rac.razguide["Button_17"] .. "]" 
			end
			
			-- Spieler darf Gäste einladen oder bannen
			-- Text und zwei kurze Button
			if can_modify.guests then
				text_attribute = "Gäste: "
				form = form.."field[0.3,"..line.l8..";"..line.lin..","..line.bh..";guest;"..text_attribute..region_data[active_region].guests..";]".."button["..line.bcol6..","..line.b8..";"..line.bl2..","..line.bh..";tab9;".. rac.razguide["Button_9"] .. "]".."button["..line.bcol7..","..line.b8..";"..line.bl2..","..line.bh..";tab10;".. rac.razguide["Button_10"] .. "]" 
			end


	
			
		end -- if can_modify then
		if can_modify.admin and do_this == 2  then
			-- der Adminbereich
			-- speichere die ID in rac.player_guide
--			rac.player_guide[player_name]["region_id"]=active_region_id
--			rac.player_guide[player_name]["region_id"]=active_region_id
--			rac.player_guide[player_name]["guests"] = {}
			
			
			-- auf Seite Admin
					
			-- Spieler darf pvp ändern
			-- Text und ein langer Button
			if can_modify.pvp then
				text_attribute = "PvP: "
				if region_data[active_region].pvp then
					form = form.."label[0,"..line.l4..";"..text_attribute.." erlaubt.".."]".."button["..line.bcol6..","..line.b4..";"..line.bl1..","..line.bh..";tab12;" .. rac.razguide["Button_12"] .. "]" 
				else
					form = form.."label[0,"..line.l4..";"..text_attribute.." verboten.".."]".."button["..line.bcol6..","..line.b4..";"..line.bl1..","..line.bh..";tab13;" .. rac.razguide["Button_13"] .. "]" 
				end	
			end
					
			-- Spieler darf mvp ändern
			-- Text und ein langer Button
			text_attribute = "Monsterdamage: "
			if can_modify.mvp then
				if region_data[active_region].mvp then
					form = form.."label[0,"..line.l5..";"..text_attribute.." erlaubt.".."]".."button["..line.bcol6..","..line.b5..";"..line.bl1..","..line.bh..";tab14;" .. rac.razguide["Button_14"] .. "]" 
				else
					form = form.."label[0,"..line.l5..";"..text_attribute.." verboten.".."]".."button["..line.bcol6..","..line.b5..";"..line.bl1..","..line.bh..";tab15;" .. rac.razguide["Button_15"] .. "]" 
				end	
			end		
			
			-- Spieler darf Effecte setzen
			-- Text und zwei kurze Button
			if can_modify.effect then
				text_attribute = "Effekte: "
				form = form.."field[0.3,"..line.l6..";"..line.lin..","..line.bh..";effect;"..text_attribute..region_data[active_region].effect..";]".."button["..line.bcol6..","..line.b6..";"..line.bl2..","..line.bh..";tab18;".. rac.razguide["Button_18"] .. "]".."button["..line.bcol7..","..line.b6..";"..line.bl2..","..line.bh..";tab19;".. rac.razguide["Button_19"] .. "]" 
			end
	
			
			
			-- claimable
			-- Text und ein langer Button
			text_attribute = "Das Gebiet "
			if region_data[active_region].claimable then
				form = form.."label[0,"..line.l7..";"..text_attribute.." ist claimable.".."]".."button["..line.bcol6..","..line.b7..";"..line.bl1..","..line.bh..";tab20;".. rac.razguide["Button_20"].."]" 
			else
					form = form.."label[0,"..line.l7..";"..text_attribute.." kann nicht geclaimed werden".."]".."button["..line.bcol6..","..line.b7..";"..line.bl1..","..line.bh..";tab21;" .. rac.razguide["Button_21"] .. "]" 
			end
			-- zone
			-- inputfield
			text_attribute = "Eingestellte Zone: "
			form = form.."label[0,"..(line.l8-0.4)..";"..text_attribute.."\n"..rac.zone_text[region_data[active_region].zone].."]"..
				"button["..line.bcol3..","..line.b8..";"..line.bl2..","..line.bh..";tab22;".. rac.razguide["Button_22"].."]"..
				"button["..line.bcol4..","..line.b8..";"..line.bl2..","..line.bh..";tab27;".. rac.razguide["Button_27"].."]"..
				"button["..line.bcol5..","..line.b8..";"..line.bl2..","..line.bh..";tab28;".. rac.razguide["Button_28"].."]"..
				"button["..line.bcol6..","..line.b8..";"..line.bl2..","..line.bh..";tab29;".. rac.razguide["Button_29"].."]"..
				"button["..line.bcol7..","..line.b8..";"..line.bl2..","..line.bh..";tab30;".. rac.razguide["Button_30"].."]"
--				form = form.."field[0.3,"..line.l8..";"..line.lin..","..line.bh..";zone;"..text_attribute..region_data[active_region].zone..";]".."button["..line.bcol6..","..line.b8..";"..line.bl1..","..line.bh..";tab22;".. rac.razguide["Button_22"] .. "]"




		end
	end -- if region_id ~= 0 then
	
	
	minetest.show_formspec(player_name, "rac:racguide",form)
	return 0 --"done"
end







minetest.register_on_player_receive_fields(function(player, form, pressed)
	-- wenn es nicht von razguide kommt return
	if form ~="rac:racguide" then 
		return 
	end
		local func_version = "1.0.0"
	local func_name = "rac:register_on_player_receive_fields"
	if rac.show_func_version and rac.debug_level > 0 then
		minetest.log("action", "[" .. rac.modname .. "] "..func_name.." - Version: "..tostring(func_version)	)
	end
	-- prüfen ob sicher in razguide
	if form=="rac:racguide" then
		-- damit man nicht immer den ganzen Table rac.player_guide[PlayerNAME] mitnehmen muss
		local context = rac.player_guide[player:get_player_name()]
		local err -- Variable für das Errorhandling
		local active_region = context.active_region
		--	rac.player_guide[player_name].err							-- Infomesg oder Errormeg
		-- 	rac.player_guide[player_name].active_region_id				-- aktive Region = given_region_id
		-- 	rac.player_guide[player_name].do_this					-- do_this
		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - context.err: "..tostring(context.err) )
		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - context.active_region: "..tostring(context.active_region) )
		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - context.do_this: "..tostring(context.do_this) )
		
		
		
				
		if rac.debug and rac.debug_level > 0 then
			minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - err: "..tostring(err) )
			if context.region_id ~= nil then
				minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - context.region_id: "..tostring(context.region_id	) )
			end
			minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - minetest.serialize(pressed): "..tostring(minetest.serialize(pressed)	) )
		end
			
		-- hier werden die Tabs gesteuert	
		if pressed.tab1 then rac:guide(player,1) end
		if pressed.tab2 then 
			minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields - in tab2 admin" )
			rac:guide(player,2) 
		end
		if pressed.tab3 then rac:guide(player,3) end
		if pressed.tab4 then rac:guide(player,4) end
		if pressed.tab5 then rac:guide(player,5) end
		-- tab_6 = X wird weiter unten verarbeitet
		
		-- tab7 und tab8 sind Schutz  aus / an
		-- setze protected = false
		if pressed.tab7 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab7" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "protected", false, nil) 
			context.err = err
			rac:guide(player,1)
		end -- protection ausschalten

		-- setze protected = true
		if pressed.tab8 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab8" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "protected", true, nil) 
			context.err = err
			rac:guide(player,1)
	 	end -- protection einschalten


		-- tab 9/tab10 ist für Gast zuständig, in Verbindung mit dem String aus
		-- pressed.guest als dem Name des Gasts
		-- setzte Gast	
		if pressed.tab9 then 
	 		-- checke ob guest ein existierender Player ist macht rac:region_set_attribute
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab9" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.guest = "..tostring(pressed.guest) )
  		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "guests", pressed.guest, true) 
			context.err = err
			rac:guide(player,1)
		end -- setze Gast

		-- tab 9/tab10 ist für Gast zuständig, in Verbindung mit dem String aus
		-- pressed.guest als dem Name des Gasts
		-- lösche Gast	
		if pressed.tab10 then 
	 		-- checke ob guest ein existierender Player ist macht rac:region_set_attribute
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab10" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.guest = "..tostring(pressed.guest) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "guests", pressed.guest, false) 
			context.err = err
			rac:guide(player,1)
		end -- lösche Gast

		-- Region umbenennen -  pressed.tab11	
		if pressed.tab11 then 
			-- pressed.rename beinhaltet den neuen Name
  		if pressed.rename == nil then
  			pressed.rename = "musste das Ändern"
  		end
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab11" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.rename = "..tostring(pressed.rename) )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: #pressed.rename = "..tostring(#pressed.rename) )

	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "region_name", pressed.rename) 
			context.err = err
			rac:guide(player,1)
		end
		
		
		-- tab12 und tab13 sind PvP an / aus
		-- setze pvp = false
		if pressed.tab12 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab12" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "pvp", false, nil) 
			context.err = err
			rac:guide(player,context.do_this)
		end -- pvp ausschalten

		-- tab12 und tab13 sind PvP an / aus
		-- setze pvp = true
		if pressed.tab13 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab13" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "pvp", true, nil) 
			context.err = err
			rac:guide(player,context.do_this)
	 	end -- pvp einschalten
		
		-- tab14 und tab15 sind MvP an / aus
		-- setze mvp = false
		if pressed.tab14 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab14" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "mvp", false, nil) 
			context.err = err
			rac:guide(player,context.do_this)
		end -- mvp ausschalten

		-- tab14 und tab15 sind MvP an / aus
		-- setze mvp = true
		if pressed.tab15 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab15" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "mvp", true, nil) 
			context.err = err
			rac:guide(player,context.do_this)
	 	end -- mvp einschalten		
		
		-- Besitz übertragen =  pressed.tab16
		if pressed.tab16 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab16" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.change_owner) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "owner", pressed.change_owner) 
			context.err = err
			rac:guide(player,context.do_this)
		end


		-- Region löschen =  pressed.tab17
		if pressed.tab17 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab17" )
	 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.delete_region: "..tostring(pressed.delete_region	) )
	 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: type(pressed.delete_region): "..tostring(type(pressed.delete_region)	) )
	 		local delete_region = tonumber(pressed.delete_region)
	 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: type(delete_region): "..tostring(type(delete_region)	) )
	 		
			-- ist die übergeben region_ID identisch mit der verwalteten region_ID
			if context.region_id[active_region] == delete_region then
		 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab17 - context.region_id[active_region] == pressed.delete_region" )
		 		err = rac:delete_region(tonumber(delete_region))
				context.err = err
			else			
		 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab17 - context.region_id[active_region] != pressed.delete_region" )
				context.err = 49 --		[49] = "info: Falsche Region_ID eingegeben!  ",
			end
			rac:guide(player,context.do_this)
		end

		-- tab18 und tab19 für Effekte setzen / löschen
		-- setze Effekt
		if pressed.tab18 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab18" )
	 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.effect: "..tostring(pressed.effect	) )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "effect", pressed.effect, true)
			context.err = err 
			rac:guide(player,context.do_this)
		end -- setze Effekt


		-- tab18 und tab19 für Effekte setzen / löschen
		-- lösche Effekt
		if pressed.tab19 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab19" )
	 		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.effect: "..tostring(pressed.effect	) )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "effect", pressed.effect, false) 
			context.err = err
			rac:guide(player,context.do_this)
	 	end -- lösche Effekt
	 	
	 	-- tab20 und tab21 für Claimable / admin do_this = 2
	 	-- setzte claimable = false
		if pressed.tab20 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab20" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "claimable", false, nil) 
			context.err = err
			rac:guide(player,2)
		end	 	
	 	-- tab20 und tab21 für Claimable / admin do_this = 2
	 	-- setzte claimable = true
		if pressed.tab21 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab21" )
			err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "claimable", true, nil) 
			context.err = err
			rac:guide(player,2)
		end	 	
	 
 		-- tab22 set zone 'none' / admin do_this = 2
		if pressed.tab22 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab22" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.tab22) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "zone", "none") 
			context.err = err
			rac:guide(player,2)
		end	
		
	 	-- tab23 bis tab25 setze die Aktive region_id
		if pressed.tab23 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab23" )
			context.active_region = 1
			rac:guide(player,context.do_this)
		end	
		if pressed.tab24 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab24" )
			context.active_region = 2
			rac:guide(player,context.do_this)
		end	
		if pressed.tab25 then 
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab25" )
			context.active_region = 3
			rac:guide(player,context.do_this)
		end
			
		-- tab27 set zone 'outback' / admin do_this = 2
		if pressed.tab27 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab27" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.tab27) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "zone", "outback") 
			context.err = err
			rac:guide(player,2)
		end	
		 -- tab28 set zone 'city' / admin do_this = 2
		if pressed.tab28 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab28" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.tab28) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "zone", "city") 
			context.err = err
			rac:guide(player,2)
		end	
		 -- tab29 set zone 'plot' / admin do_this = 2
		if pressed.tab29 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab28" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.tab29) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "zone", "plot") 
			context.err = err
			rac:guide(player,2)
		end	
		 -- tab30 set zone 'owned' / admin do_this = 2
		if pressed.tab30 then
			-- pressed.change_owner beinhaltet den Name des Gast
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.tab28" )
  		minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: pressed.change_owner = "..tostring(pressed.tab30) )
	 		err = rac:region_set_attribute(player:get_player_name(), context.region_id[active_region]	, "zone", "owned") 
			context.err = err
			rac:guide(player,2)
		end			
		-- Errorhandling!
		if err ~= nil then
			if err >  0 then
				minetest.log("action", "[" .. rac.modname .. "] rac:register_on_player_receive_fields: error: "..tostring(err) )
				rac:msg_handling(err, func_name)
			end
		end				
		-- pressed.tab6 ist das X für schließen 
--		if not pressed.tab6 then
--			rac:guide(player,5)
--		end
	end --if form=="razguide" then


end)




minetest.register_tool("rac:guidebook", {
	description = rac.razguide["Book_title"],
	inventory_image = "default_book.png",
	on_use = function(itemstack, user, pointed_thing)
	rac:guide(user,1)
	return itemstack
	end 
})

minetest.register_alias("guide", "rac:guidebook")
minetest.register_craft({output = "rac:guidebook",recipe = {{"default:stick","default:stick"},}})


-- jeder neue Spieler bekommt en racguide
minetest.register_on_newplayer(function(player)
player:get_inventory():add_item("main", "rac:guidebook")
end)


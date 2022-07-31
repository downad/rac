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

-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can modify and remove all regions.")
minetest.register_privilege("region_effect", "Can set or remove and effect for own regions.")
minetest.register_privilege("region_mvp", "Can allow/disallow MvP for own regions.")
minetest.register_privilege("region_pvp", "Can allow/disallow PvP for own regions.")
minetest.register_privilege("region_guests", "Can invite/ban guests.") 
minetest.register_privilege("region_set", "Can set, remove and rename own regions and protect and open them or change owner of own regions.")



 
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:player_can_modify_region_id(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- Diese Funktion gibt die Tabelle can_modify zurück
-- über die Privilegien kann der Spieler seine Regionen verwalten
-- ohne Privileg,wenn OWNER
--		umbenennen
--		schützen
--		löschen
-- mit Privileg	
-- 	effect:				Einen Effekt für das Gebiet wählen 	
--	mvp:					Monsterdamage auf dem Gebiet einschalten
--	pvp:					PVP  auf dem Gebiet einschalten (falls PVP in der Welt erlaubt ist)
-- 	guests:				Mit diesem Privileg kann der der Spieler Gäste auf sein Gebiet einladen. Die Gäste können in dem Gebiet handeln, auch wenn es geschützt ist.
--	set:					Ein Spieler mit dem set-Privileg kann Gebiete claimen und kann folgendes bearbeiten
--				umbenennen
--			 	Schutz ein- oder auschalten
--				Das Gebiet übertragen an einen anderen Spieler
--				Das Gebiet löschen
--	admin: Der Admin kann alles
--
-- input: 
--		player			als Player Objekt
--
-- return:
--  Table can_modify
--		can_modify.owner (true/false)
--		can_modify.name (true/false)
--		can_modify.claimable (true/false)
--		can_modify.zone (true/false)
--		can_modify.protected (true/false)
--		can_modify.guests (true/false)
--		can_modify.pvp (true/false)
--		can_modify.mvp (true/false)
--		can_modify.effect (true/false)
--		und zusätzlich
--		can_modify.change_owner (true/false)
--		can_modify.delete_region (true/false)
--		can_modify.rename_region (true/false)
--		can_modify.set (true/false)
-- 		can_modify.admin (true/false)
-- 		
--
-- msg/error handling: NO
--
function rac:player_can_modify_region_id(player)
	local func_version = "1.0.0"
	if rac.show_func_version  then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_can_modify_region_id - Version: "..tostring(func_version)	)
	end

	local can_modify = {
		owner = false,
		name = false,
		claimable = false,
		zone = false,
		protected = false,
		guests = false,
		pvp = false,
		mvp = false,
		effect = false,
		change_owner = false,
		delete_region = false,
		rename_region = false,
		set = false,
		admin = false,
	}
	
	
	if rac.debug then
		minetest.log("action", "[" .. rac.modname .. "] rac:player_can_modify_region_id")
		minetest.log("action", "[" .. rac.modname .. "] rcan_modify: "..tostring(rac:table_to_string(can_modify)) )
	end
	-- teste die verschiedenen Privilegione	
	if minetest.check_player_privs(player, { region_admin = true }) or rac.serveradmin_is_regionadmin then 
		can_modify = {
			owner = true,
			name = true,
			claimable = true,
			zone = true,
			protected = true,
			guests = true,
			pvp = true,
			mvp = true,
			effect = true,
			change_owner = true,
			delete_region = true,
			rename_region = true,
			set = true,
			admin = true,
		}
	end
	if	minetest.check_player_privs(player, { region_effect = true }) then
		can_modify.effect = true
	end
	if minetest.check_player_privs(player, { region_mvp = true }) then 
		can_modify.mvp = true
	end
	if minetest.check_player_privs(player, { region_pvp = true }) then 
		can_modify.pvp = true
	end
	if	minetest.check_player_privs(player, { region_guests = true }) then
		can_modify.guests = true
	end
	if minetest.check_player_privs(player, { region_set = true }) then 
		can_modify.owner = true
		can_modify.name = true
		can_modify.protected = true
		can_modify.change_owner = true
		can_modify.delete_region = true
		can_modify.rename_region = true
		can_modify.set = true
	end	

	return can_modify
	
	
end -- rac:can_modify = rac:player_can_modify_region_id(player)

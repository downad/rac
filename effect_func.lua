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

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
-- rac:do_effect_to_player(player,effects)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- do an / all effect to player
--
-- 
-- input: 
--		player 		as object player
--		effect 		as string
--				muss nicht getestet werden, die aufrufend Funktion hat das gemacht!
--
-- msg/error handling: no 
function rac:do_effect_to_player(player,effect)
	local func_version = "1.0.0"
	if rac.show_func_version then
		minetest.log("action", "[" .. rac.modname .. "] rac:do_effect_to_player - Version: "..tostring(func_version)	)
	end
	local err = 0
	
	-- abhängig von Effekt wird die passende Funktion aufgerufen
	-- und der Fehler oder bei err = 0 nicht ausgegeben
	if effect == "hot" then
		rac:msg_handling( rac:do_effect_hot(player) )
	end
	if effect == "bot" then
		rac:msg_handling( rac:do_effect_bot(player) )
	end
	if effect == "holy" then
		rac:msg_handling( rac:do_effect_holy(player) )
	end
	if effect == "dot" then
		rac:msg_handling( rac:do_effect_dot(player) )
	end
	if effect == "choke" then
		rac:msg_handling( rac:do_effect_choke(player) )
	end
	if effect == "evil" then
		rac:msg_handling( rac:do_effect_evil(player) )
	end
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_hot(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- hot - heal over time
--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_hot(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
	if player:get_hp() < 20 then
		player:set_hp(math.max(player:get_hp() + rac.region_effect.hot, 0))
		minetest.chat_send_player(player:get_player_name(), "The region regenerate you with "..rac.effect.hot.." life!")
	end
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_dot(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- dot - damage over time
--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_dot(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
		player:set_hp(math.max(player:get_hp() - rac.region_effect.dot, 0))
		minetest.chat_send_player(player:get_player_name(), "You get "..rac.region_effect.dot.." damage in this region!")
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_bot(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- bot - breath over time--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_bot(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
	if player:get_breath() < 11 then
		player:set_breath(math.max(player:get_breath() + rac.region_effect.bot, 0))
		minetest.chat_send_player(player:get_player_name(), "The region gives you "..rac.effect.bot.." breath!")
	end
		--minetest.chat_send_player(player:get_player_name(), "Your are full of air.")
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_hot(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- choke: die Atemluft wird weniger 
--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_choke(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
		player:set_breath(math.max(player:get_breath() - rac.region_effect.choke, 0))
		minetest.chat_send_player(player:get_player_name(), "The region steels you "..rac.region_effect.choke.." breath!")
	return err
end


-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_holy(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- holy - the effect of hot and bot
--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_holy(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
	local done = ""
		done = rac:do_effect_hot(player)
		done = rac:do_effect_bot(player)
		minetest.chat_send_player(player:get_player_name(), "This is an holy region!")
	return err
end

-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--
--	rac:do_effect_evil(player)
--
-- + -- + -- + -- + -- + -- + -- +-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- evil - the effect of dot and choke
--
--
-- input:
--	player 						als Objekt
--
-- return:
--	0				wenn alles gut geht
--
-- msg/error handling: no
function rac:do_effect_evil(player)
	local func_version = "1.0.0"
	if rac.show_func_version and rac.debug_level == 10 then
		minetest.log("action", "[" .. rac.modname .. "] rac:set_region - Version: "..tostring(func_version)	)
	end
	local err = 0
	local done = ""
		done = rac:do_effect_dot(player)
		done = rac:do_effect_choke(player)
		minetest.chat_send_player(player:get_player_name(), "This is an evil region!")
	return err
end

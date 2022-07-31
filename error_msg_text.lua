	-- definiert Fehlertexte und Msg-Texte
	-- die Table ist ao aufgebaut 
	-- [nr] - die msg/error nummer
	--				nicht aufgelistet, da es "alles OK" anzeigt [0]
	-- = string
	--		der String besteht aus einem Schlüsselwort, getennt mit einem doppelpunkt ":" und dem Text
	--		Schlüsselworte
	--		ERROR: 	-> Ausgabe in minetest.log
	--		Info:		-> Ausgabe in minetest.log
	--		msg: 		-> Ausgabe erfolgt nur an den Spieler
rac.max_error = 29	
rac.error_msg_text = {
		[1] = "ERROR: func: rac:msg_handling(err, name) - err ist keine Nummer",
		[2] = "ERROR: register_globalstep(function(dtime) - mehr als 2 Regionen!",
		[3] = "ERROR: func: rac:msg_handling(err, name) - die Nummer err ist größer als erlaubt!!!!",
		[4] = "ERROR: func: rac:create_data_string - no Player found for owner! ",
		[5] = "ERROR: func: rac:create_data_string - no region name submitted! ",
		[6] = "ERROR: func: rac:create_data_string - no claimable set! ",
		[7] = "ERROR: func: rac:create_data_string - no zone set! ", 
		[8] = "ERROR: func: rac:create_data_string - zone ist nichtt in der Liste! "..tostring(rac.allowed_zones),
		[9] = "ERROR: func: rac:create_data_string - no protected set! ",
		[10] = "ERROR: func: rac:create_data_string - no guests set! ",
		[11] = "ERROR: func: rac:create_data_string - no pvp set! ",
		[12] = "ERROR: func: rac:create_data_string - no mvp - Monsterdamage set! ",
		[13] = "ERROR: func: rac:create_data_string - effect ist nichtt in der Liste! "..tostring(rac.allowed_effects),
		[14] = "ERROR: func: rac:create_data_string - no effect set! ",
		[15] = "ERROR: func: rac:set_region - übergebenes 'data' war weder table noch string!!!",
		[16] = "ERROR: func: rac:get_region_data_by_id - no region with this ID!",
		[17] = "ERROR: func: rac:get_owner_by_region_id - no owner in Region with this ID!",
		[18] = "ERROR: func: rac:region_set_attribute - No region with this ID! ",
		[19] = "ERROR: func: rac:region_set_attribute - The region_attribute did not fit!",
		[20] = "ERROR: func: rac:region_set_attribute - There is no Player with this name!",
		[21] = "ERROR: func: rac:region_set_attribute - Wrong effect! ",
		[22] = "ERROR: func: rac:region_set_attribute - You are not the owner of this region! ",
		[23] = "ERROR: func: rac:region_set_attribute - No Player with this name is in the guestlist! ",
		[24] = "ERROR: func: rac:region_set_attribute - no region with this ID!",
		[25] = "ERROR: func: rac:region_set_attribute - in update_regions_data! ", 
		[26] = "ERROR: func: rac:region_set_attribute - Dieser Gast ist schon auf der Gäste-Liste! ", 
		[27] = "ERROR: func: rac:region_set_attribute - The zone attribute did not fit!",
		[28] = "ERROR: func: rac:region_set_attribute - Claimable needs a boolean.",
		[29] = "ERROR: func: rac:region_set_attribute - The effect attribute did not fit!",
		[30] = "ERROR: func: rac:region_set_attribute - Dieser Effekt ist nicht auf der Region-Effekt-Liste! ",
	}

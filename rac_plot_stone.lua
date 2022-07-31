
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


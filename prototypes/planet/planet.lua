-- Space Ageploration Planets and Surfaces
-- Define custom planets and surfaces using PlanetsLib

local map_gen_settings = require("map-gen-settings")

PlanetsLib:extend({
  {
    type = "planet",
    name = "nauvis-orbit",

    orbit = {
      parent = { type = "planet", name = "nauvis" },
      distance = 1,
      orientation = 0.25,
      is_satellite = true
    },

    -- Visual properties
    icon = "__base__/graphics/icons/nauvis.png",
    icon_size = 64,
    starmap_icon = "__base__/graphics/icons/starmap-planet-nauvis.png",
    starmap_icon_size = 512,

    gravity_pull = 10,
    magnitude = 1.0,
    order = "a[nauvis]-b[nauvis-orbit]",
    subgroup = "planets",

    surface_properties = {
      ["solar-power"] = 200,
      ["pressure"] = 100,
      ["gravity"] = 10
    },

    map_gen_settings = map_gen_settings.nauvis_orbit(),

    
    asteroid_spawn_definitions = {},

    hidden = false,

    pollutant_type = nil -- No pollution in orbit
  }
})

data:extend({
	{
		type = "space-connection",
		name = "nauvis-nauvis-orbit",
		subgroup = "planet-connections",
		from = "nauvis",
		to = "nauvis-orbit",
		order = "c",
		length = 800,
	},
})
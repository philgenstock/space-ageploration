-- Space Ageploration Planets and Surfaces
-- Define custom planets and surfaces

data:extend({
  {
    type = "planet",
    name = "nauvis-orbit",
    icon = "__space-age__/graphics/icons/nauvis.png",
    icon_size = 256,
    starmap_icon = "__space-age__/graphics/icons/starmap-planet-nauvis.png",
    starmap_icon_size = 512,
    gravity_pull = 10,
    distance = 10,
    orientation = 0.25,
    magnitude = 1.0,
    order = "a[nauvis]-b[nauvis-orbit]",
    subgroup = "planets",

    -- Surface properties
    surface_properties = {
      ["solar-power"] = 200,
      ["pressure"] = 100,
      ["gravity"] = 10
    },

    map_gen_settings = {
      property_expression_names = {
        -- Always day
        time_of_day = 0.5
      },
      autoplace_controls = {},
      autoplace_settings = {
        tile = {
          settings = {
            ["space-platform-foundation"] = {}
          }
        }
      },
      default_enable_all_autoplace_controls = false,
      cliff_settings = {
        cliff_elevation_0 = 1024,
        cliff_elevation_interval = 0
      }
    },

    -- Prevent spaceship travel to this location
    -- Players must use other means to access this surface
    asteroid_spawn_definitions = {},

    -- Hide from normal planet selection
    hidden = true,

    -- Link it conceptually to Nauvis
    distance_from_sun = 10, -- Same as Nauvis

    pollutant_type = nil -- No pollution in orbit
  }
})

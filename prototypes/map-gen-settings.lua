
local map_gen_settings = {}

-- Nauvis Orbit: Flat dirt surface with only cargo landing pads
function map_gen_settings.nauvis_orbit()
  return {
    -- No terrain generation - create a flat surface
    terrain_segmentation = "none",
    water = "none",

    -- Disable cliffs completely
    cliff_settings = {
      name = "cliff",
      cliff_elevation_0 = 1024,
      cliff_elevation_interval = 0,
      richness = 0
    },

    -- No autoplace controls (no resource sliders)
    autoplace_controls = {},

    -- Strict control - only allow what we explicitly enable
    autoplace_settings = {
      tile = {
        treat_missing_as_default = false,
        settings = {
          ["empty-space"] = {
          }
        }
      },
      entity = {
        treat_missing_as_default = false,
        settings = {}  -- No entities (ores, trees, rocks, etc.)
      },
      decorative = {
        treat_missing_as_default = false,
        settings = {}  -- No decoratives
      }
    },

    -- Property expressions to ensure flat, empty generation
    property_expression_names = {
      -- Always day
      time_of_day = 0.5,
      -- Completely flat terrain
      elevation = 0,
      aux = 0,
      moisture = 0,
      temperature = 0,
      cliffiness = 0,
      -- No enemies
      enemy_base_intensity = 0,
      enemy_base_frequency = 0,
      enemy_base_radius = 0
    }
  }
end

return map_gen_settings

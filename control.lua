-- Space Ageploration Control Stage
-- Runtime logic and event handlers

-- Initialize Nauvis Orbit surface
local function init_nauvis_orbit()
  local surface = game.surfaces["nauvis-orbit"]

  if not surface then
    -- Create the surface if it doesn't exist
    surface = game.create_surface("nauvis-orbit", {
      property_expression_names = {
        -- Force always day
        time_of_day = 0.5
      }
    })
    log("Created Nauvis Orbit surface")
  end

  -- Configure surface properties
  if surface then
    -- Set solar power multiplier to 200%
    surface.solar_power_multiplier = 2.0

    -- Freeze time to keep it always day
    surface.freeze_daytime = true
    surface.daytime = 0.5  -- Noon

    -- Disable wind (optional, for space-like conditions)
    surface.wind_speed = 0
    surface.wind_orientation = 0
    surface.wind_orientation_change = 0

    log("Nauvis Orbit surface configured: solar efficiency 200%, always day")
  end
end

-- Event handlers
script.on_init(function()
  -- Initialize mod on first load
  log("Space Ageploration initialized")
  init_nauvis_orbit()
end)

-- Debug command to teleport to Nauvis Orbit (for testing)
commands.add_command("goto-nauvis-orbit", "Teleport to Nauvis Orbit", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local surface = game.surfaces["nauvis-orbit"]
  if not surface then
    player.print("Nauvis Orbit surface doesn't exist!")
    return
  end

  -- Find a safe position or use 0,0
  local position = surface.find_non_colliding_position("character", {0, 0}, 100, 1) or {0, 0}
  player.teleport(position, surface)
  player.print("Teleported to Nauvis Orbit")
end)

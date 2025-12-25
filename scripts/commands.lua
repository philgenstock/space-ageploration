-- Space Ageploration Debug Commands
-- Custom console commands for testing and debugging

local commands = {}

-- Debug command to teleport to Nauvis Orbit
commands.register_goto_nauvis_orbit = function()
  commands.add_command("goto-nauvis-orbit", "Teleport to Nauvis Orbit", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local surface = game.surfaces["nauvis-orbit"]
    if not surface then
      player.print("Nauvis Orbit surface doesn't exist!")
      return
    end

    local position = surface.find_non_colliding_position("character", {0, 0}, 100, 1) or {0, 0}
    player.teleport(position, surface)
    player.print("Teleported to Nauvis Orbit")
  end)
end

-- Debug command to list orbital landing pads
commands.register_list_orbital_pads = function()
  commands.add_command("list-orbital-pads", "List all orbital cargo landing pads", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    if not storage.orbital_landing_pads or #storage.orbital_landing_pads == 0 then
      player.print("No orbital cargo landing pads registered")
      return
    end

    player.print("Orbital Cargo Landing Pads:")
    for i, pad_data in ipairs(storage.orbital_landing_pads) do
      if pad_data.entity and pad_data.entity.valid then
        player.print(string.format("  #%d: Unit %d at %s", i, pad_data.unit_number, serpent.line(pad_data.entity.position)))
      else
        player.print(string.format("  #%d: Invalid (will be cleaned up)", i))
      end
    end
  end)
end

-- Debug command to check platform status
commands.register_check_orbit_platform = function()
  commands.add_command("check-orbit-platform", "Check Nauvis Orbit platform status", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    if not storage.nauvis_orbit_platforms then
      player.print("No platforms registered")
      return
    end

    for force_name, platform_data in pairs(storage.nauvis_orbit_platforms) do
      if platform_data.platform and platform_data.platform.valid then
        player.print(string.format("Force %s: Platform exists, hidden=%s",
          force_name, tostring(platform_data.platform.hidden)))
      else
        player.print(string.format("Force %s: Platform invalid or missing", force_name))
      end
    end
  end)
end

-- Register all commands
commands.register_all = function()
  commands.register_goto_nauvis_orbit()
  commands.register_list_orbital_pads()
  commands.register_check_orbit_platform()
end

return commands

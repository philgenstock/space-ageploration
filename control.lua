storage = storage or {}

local function init_nauvis_orbit()
  local surface = game.surfaces["nauvis-orbit"]

  if not surface then
    surface = game.create_surface("nauvis-orbit", {
      property_expression_names = {
        -- Force always day
        time_of_day = 0.5
      }
    })
    log("Created Nauvis Orbit surface")
  end

  if surface then
    surface.solar_power_multiplier = 2.0

    surface.freeze_daytime = true
    surface.daytime = 0.5  -- Noon

    surface.wind_speed = 0
    surface.wind_orientation = 0
    surface.wind_orientation_change = 0

  end
end

-- Create hidden space platform for Nauvis Orbit relay
local function create_nauvis_orbit_platform(force)
  -- Check if platform already exists
  if storage.nauvis_orbit_platforms and storage.nauvis_orbit_platforms[force.name] then
    local platform_data = storage.nauvis_orbit_platforms[force.name]
    if platform_data.platform and platform_data.platform.valid then
      return platform_data.platform
    end
  end

  local platform = force.create_space_platform({
    name = "[space-location=nauvis-orbit] Nauvis Orbit Relay",
    planet = "nauvis",  -- Orbiting Nauvis
    starter_pack = "nauvis-orbit-platform-starter-pack"
  })

  platform.apply_starter_pack()

  platform.hidden = true

  local hub = platform.hub
  if hub and hub.valid then
    hub.operable = false      -- Disable manual interaction
    hub.destructible = false  -- Prevent deletion
  end

  storage.nauvis_orbit_platforms = storage.nauvis_orbit_platforms or {}
  storage.nauvis_orbit_platforms[force.name] = {
    platform = platform,
    tracked_pods = {}
  }

  log("Created hidden Nauvis Orbit platform for force: " .. force.name)
  return platform
end

local function get_nauvis_orbit_platform(force)
  if not storage.nauvis_orbit_platforms then
    storage.nauvis_orbit_platforms = {}
  end

  local platform_data = storage.nauvis_orbit_platforms[force.name]
  if platform_data and platform_data.platform and platform_data.platform.valid then
    return platform_data.platform
  end

  return create_nauvis_orbit_platform(force)
end
-- Get platform name for comparison
local function get_platform_name()
  return "[space-location=nauvis-orbit] Nauvis Orbit Relay"
end

local function init_all_platforms()
  for _, force in pairs(game.forces) do
    if force.technologies then  -- Only for player forces
      create_nauvis_orbit_platform(force)
    end
  end
end

script.on_init(function()
  log("Space Ageploration initialized")

  -- Initialize storage
  storage.nauvis_orbit_platforms = {}
  storage.orbital_landing_pads = {}
  storage.pending_pods = {}

  -- Create Nauvis Orbit surface
  init_nauvis_orbit()

  -- Create platforms for all forces
  init_all_platforms()
end)

script.on_configuration_changed(function(data)
  log("Space Ageploration configuration changed")

  -- Initialize storage if missing
  storage.nauvis_orbit_platforms = storage.nauvis_orbit_platforms or {}
  storage.orbital_landing_pads = storage.orbital_landing_pads or {}
  storage.pending_pods = storage.pending_pods or {}

  -- Ensure Nauvis Orbit exists and is properly configured
  init_nauvis_orbit()

  -- Ensure all forces have platforms
  init_all_platforms()
end)

-- Track when cargo landing pads are built on Nauvis Orbit
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.created_entity or event.entity
  if not entity or not entity.valid then return end

  if entity.name == "cargo-landing-pad" then
    -- Only track pads on Nauvis Orbit surface
    if entity.surface.name == "nauvis-orbit" then
      -- Register the landing pad
      storage.orbital_landing_pads = storage.orbital_landing_pads or {}
      table.insert(storage.orbital_landing_pads, {
        entity = entity,
        unit_number = entity.unit_number,
        force = entity.force
      })

      log("Registered cargo landing pad on Nauvis Orbit #" .. entity.unit_number)
    end
  end
end, {
  {filter = "name", name = "cargo-landing-pad"}
})

-- Track when orbital cargo landing pads are removed
local function unregister_landing_pad(entity)
  if storage.orbital_landing_pads then
    for i, pad_data in ipairs(storage.orbital_landing_pads) do
      if pad_data.unit_number == entity.unit_number then
        table.remove(storage.orbital_landing_pads, i)
        log("Unregistered orbital cargo landing pad #" .. entity.unit_number)
        break
      end
    end
  end
end

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity and event.entity.valid and event.entity.name == "cargo-landing-pad" then
    if event.entity.surface.name == "nauvis-orbit" then
      unregister_landing_pad(event.entity)
    end
  end
end, {
  {filter = "name", name = "cargo-landing-pad"}
})

script.on_event(defines.events.on_player_mined_entity, function(event)
  if event.entity and event.entity.valid and event.entity.name == "cargo-landing-pad" then
    if event.entity.surface.name == "nauvis-orbit" then
      unregister_landing_pad(event.entity)
    end
  end
end, {
  {filter = "name", name = "cargo-landing-pad"}
})

-- Intercept rocket launches targeting Nauvis Orbit platform
script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  local rocket = event.rocket
  local silo = event.rocket_silo

  if not (rocket and rocket.valid and silo and silo.valid) then return end
  if not (rocket.attached_cargo_pod and rocket.attached_cargo_pod.valid) then return end

  local cargo_pod = rocket.attached_cargo_pod
  local destination = cargo_pod.cargo_pod_destination

  -- Check if destination is our hidden platform
  if destination and destination.type == defines.cargo_destination.station then
    local station = destination.station
    if station and station.valid and station.surface and station.surface.platform then
      local platform = station.surface.platform

      -- Check if it's the Nauvis Orbit platform
      if platform.name == get_platform_name() then
        -- Redirect to Nauvis Orbit surface instead
        local orbit_surface = game.surfaces["nauvis-orbit"]
        if not orbit_surface then
          orbit_surface = init_nauvis_orbit()
        end

        cargo_pod.cargo_pod_destination = {
          type = defines.cargo_destination.surface,
          surface = orbit_surface
        }

        log("Redirected cargo pod from platform to Nauvis Orbit surface")
      end
    end
  end
end)

-- Handle cargo pods arriving on the hidden platform (intermediate relay)
script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  local cargo_pod = event.cargo_pod
  if not (cargo_pod and cargo_pod.valid) then return end

  local surface = cargo_pod.surface
  if not (surface and surface.valid and surface.platform) then return end

  local platform = surface.platform

  -- Check if this is our hidden platform
  if platform.name ~= get_platform_name() then return end

  -- Get target Nauvis Orbit surface
  local orbit_surface = game.surfaces["nauvis-orbit"]
  if not orbit_surface then
    orbit_surface = init_nauvis_orbit()
  end

  -- Extract items from the arrived pod
  local pod_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)
  if not pod_inv then return end

  local items = pod_inv.get_contents()

  -- Create new pod from hub and send to Nauvis Orbit
  local hub = platform.hub
  if not (hub and hub.valid) then return end

  local new_pod = hub.create_cargo_pod()
  if not new_pod then
    -- Queue for retry if pod creation fails
    storage.pending_pods = storage.pending_pods or {}
    table.insert(storage.pending_pods, {
      platform = platform,
      target_surface = orbit_surface,
      force = cargo_pod.force,
      items = items
    })
    log("Failed to create cargo pod, queued for retry")
    return
  end

  -- Set destination to Nauvis Orbit surface
  new_pod.cargo_pod_destination = {
    type = defines.cargo_destination.surface,
    surface = orbit_surface
  }

  -- Transfer items to new pod
  local new_pod_inv = new_pod.get_inventory(defines.inventory.cargo_unit)
  if new_pod_inv then
    for _, item in pairs(items) do
      new_pod_inv.insert(item)
    end
  end

  -- Track this pod
  if not storage.nauvis_orbit_platforms[cargo_pod.force.name] then
    storage.nauvis_orbit_platforms[cargo_pod.force.name] = {tracked_pods = {}}
  end
  storage.nauvis_orbit_platforms[cargo_pod.force.name].tracked_pods[new_pod.unit_number] = new_pod

  -- Immediately send it
  new_pod.force_finish_ascending()

  log("Relayed cargo pod to Nauvis Orbit surface")
end)

-- Prevent manual cargo pod departures from hidden platform
script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
  local cargo_pod = event.cargo_pod
  if not (cargo_pod and cargo_pod.valid) then return end
  if not cargo_pod.surface then return end

  local surface = cargo_pod.surface
  if not (surface.valid and surface.platform) then return end

  local platform = surface.platform
  if platform.name ~= get_platform_name() then return end

  local force = cargo_pod.force

  -- Check if this pod is tracked (legitimate)
  local is_tracked = false
  if storage.nauvis_orbit_platforms and storage.nauvis_orbit_platforms[force.name] then
    local tracked_pods = storage.nauvis_orbit_platforms[force.name].tracked_pods
    if tracked_pods and tracked_pods[cargo_pod.unit_number] then
      is_tracked = true
      -- Clean up tracking
      tracked_pods[cargo_pod.unit_number] = nil
    end
  end

  -- Destroy untracked pods (manual departures)
  if not is_tracked then
    cargo_pod.destroy()
    log("Destroyed untracked cargo pod from hidden platform")
  end
end)

-- Retry pending pod deliveries every 60 ticks
script.on_nth_tick(60, function()
  if not storage.pending_pods or #storage.pending_pods == 0 then return end

  local retry_queue = {}

  for _, pod_data in ipairs(storage.pending_pods) do
    local platform = pod_data.platform
    local target_surface = pod_data.target_surface
    local force = pod_data.force
    local items = pod_data.items

    if platform and platform.valid and target_surface and target_surface.valid then
      local hub = platform.hub
      if hub and hub.valid then
        local new_pod = hub.create_cargo_pod()

        if new_pod then
          new_pod.cargo_pod_destination = {
            type = defines.cargo_destination.surface,
            surface = target_surface
          }

          local new_pod_inv = new_pod.get_inventory(defines.inventory.cargo_unit)
          if new_pod_inv then
            for _, item in pairs(items) do
              new_pod_inv.insert(item)
            end
          end

          if not storage.nauvis_orbit_platforms[force.name] then
            storage.nauvis_orbit_platforms[force.name] = {tracked_pods = {}}
          end
          storage.nauvis_orbit_platforms[force.name].tracked_pods[new_pod.unit_number] = new_pod

          new_pod.force_finish_ascending()
          log("Retry successful for pending cargo pod")
        else
          -- Still can't create pod, re-queue
          table.insert(retry_queue, pod_data)
        end
      end
    end
  end

  storage.pending_pods = retry_queue
end)

-- Register debug commands
require("scripts.commands").register_all()

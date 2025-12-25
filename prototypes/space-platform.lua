-- Space Ageploration Space Platform Prototypes
-- Defines the hidden orbital platform starter pack

data:extend({
  {
    type = "space-platform-starter-pack",
    name = "nauvis-orbit-platform-starter-pack",
    -- This starter pack creates a minimal hidden platform for Nauvis Orbit
    -- It will be invisible to players and only used for cargo relay

    tiles = {
      {position = {0, 0}, tile = "space-platform-foundation"},
      {position = {1, 0}, tile = "space-platform-foundation"},
      {position = {0, 1}, tile = "space-platform-foundation"},
      {position = {1, 1}, tile = "space-platform-foundation"},
      {position = {-1, 0}, tile = "space-platform-foundation"},
      {position = {0, -1}, tile = "space-platform-foundation"},
      {position = {-1, -1}, tile = "space-platform-foundation"},
      {position = {1, -1}, tile = "space-platform-foundation"},
      {position = {-1, 1}, tile = "space-platform-foundation"}
    },

    -- Entities placed on the platform (just the hub)
    -- The hub is required for creating cargo pods
    entities = {
      -- Additional entities can be added here if needed
      -- The hub is automatically placed by the engine
    },

    -- Starting inventory (none needed)
    initial_items = {},

    surface_create_entities = false
  }
})

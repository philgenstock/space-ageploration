-- Space Ageploration Technologies

data:extend({
  {
    type = "technology",
    name = "nauvis-orbit-discovery",
    icon = "__base__/graphics/icons/nauvis.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-space-location",
        space_location = "nauvis-orbit"
      }
    },
    prerequisites = {"rocket-silo"},
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 60
    },
    order = "c-a"
  }
})

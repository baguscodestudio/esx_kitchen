Config = {}

Config.Locale = 'en'

Config.WeightESX = true -- true for ESX v1.2

Config.Locations = {
    Hookies = {
        coords = vector3(-2190.55, 4280.59, 48.18),
        name = "Hookies Kitchen",
        sprite = 162,
        colour = 44
    }
}

Config.Recipes = {
    Bread = {
        duration = 5000, --in ms
        label = "Bread",
        count = 1,
        item = "bread",
        itemsNeeded = {
            {item = "water", count = 1},
            {item = 'alive_chicken', count = 1}
        }
    },
    TehBotol = {
        duration = 2000,
        label = "Teh Botol",
        count = 1,
        item = "tehbotol",
        itemsNeeded = {
            {item = "water", count = 1},
            {item = "packaged_plank", count = 1},
            {item = "sugar", count = 1}
        }
    }
}
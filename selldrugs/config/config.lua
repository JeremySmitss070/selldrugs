Config = {}

Config.Debug = false
Config.SellDistance = 2.0
Config.ScanInterval = 2000
Config.SellCooldown = 5000
Config.Item = 'kq_weed_bag_og_kush'
Config.Amount = { 1, 3 }
Config.MinPay = 500
Config.MaxPay = 900
Config.BlackMoney = true -- Verander dit naar false als je geen zwart geld wilt
Config.AcceptChance = 0.6
Config.AlertChance = 0.2
Config.MinPolice = 0

Config.IgnorePedTypes = {
    'S_M_Y_COP_01',
    'S_F_Y_COP_01',
    'S_M_Y_SHERIFF_01',
    'S_F_Y_SHERIFF_01',
    'S_M_M_PARAMEDIC_01',
    'S_M_Y_FIREMAN_01'
}

Config.AllowedDiscord = {
    "789243787787370547",
}

Config.NoSellZones = {
    {
        name = "Ziekenhuis",
        coords = vec3(-814.2405, -1236.6493, 6.7205),
        radius = 50.0,
    },
    {
        name = "POlititebureau", 
        coords = vec3(83.6214, -355.5029, 45.0670),
        radius = 50.0,
    }
}

Config.CityRestriction = {
    center = vec3(-136.3442, -844.3342, 44.0921),
    radius = 2500.0
}

Config.Drugs = {
    {
        category = "wiet",
        label = "Wiet",
        sellLocation = vector3(974.3757, 12.8688, 81.0410),
        heading = 246.1022, 
        npcModel = "a_m_m_farmer_01",
        cooldown = 5000,
        items = {
            {
                name = "kq_weed_bag_og_kush",
                label = "OG Kush Wiet Zakje",
                priceMin = 100,
                priceMax = 200,
                sellAmountMin = 1,
                sellAmountMax = 5
            },
            {
                name = "kq_weed_brick_og_kush",
                label = "OG Kush Wiet Blok",
                priceMin = 14000,
                priceMax = 15000,
                sellAmountMin = 1,
                sellAmountMax = 1
            },
            {
                name = "kq_weed_bag_purple_haze",
                label = "Purple Haze Wiet Zakje",
                priceMin = 120,
                priceMax = 220,
                sellAmountMin = 1,
                sellAmountMax = 4
            },
            {
                name = "kq_weed_brick_purple_haze",
                label = "Purple Haze Wiet Blok",
                priceMin = 16000,
                priceMax = 18000,
                sellAmountMin = 1,
                sellAmountMax = 1
            },
            {
                name = "kq_weed_bag_white_widow",
                label = "White Widow Wiet Zakje",
                priceMin = 120,
                priceMax = 220,
                sellAmountMin = 1,
                sellAmountMax = 4
            },
            {
                name = "kq_weed_brick_white_widow",
                label = "White Widow Wiet Blok",
                priceMin = 20000,
                priceMax = 23000,
                sellAmountMin = 1,
                sellAmountMax = 1
            },
            {
                name = "kq_weed_bag_blue_dream",
                label = "Blue Dream Wiet Zakje",
                priceMin = 220,
                priceMax = 250,
                sellAmountMin = 1,
                sellAmountMax = 4
            },
            {
                name = "kq_weed_brick_blue_dream",
                label = "Blue Dream Wiet Blok",
                priceMin = 22000,
                priceMax = 25000,
                sellAmountMin = 1,
                sellAmountMax = 3
            },
        },
        deliveryLocations = {
            vector4(965.1688, -542.0108, 59.7261, 0.0),
            vector4(1207.2357, -620.3781, 66.4386, 0.0),
            vector4(996.8872, -729.5806, 57.8155, 0.0),
            vector4(1389.0697, -569.4280, 74.4965, 112.8301),
            vector4(1338.2698, -1524.2367, 54.5816, 174.5324),
            vector4(1437.5007, -1491.8638, 63.6220, 165.5741),
            vector4(1295.0203, -1739.8595, 54.2717, 295.4128),
            vector4(1241.1862, -1725.7963, 52.0243, 27.0518),
            vector4(312.2029, -1956.1534, 24.6167, 248.8913),
            vector4(256.3759, -2023.6185, 19.2663, 234.6668),
            vector4(170.5186, -1924.0349, 21.1905, 139.0984),
            vector4(29.9827, -1854.6781, 24.0689, 54.7412),
            vector4(114.2169, -1961.1056, 21.3342, 47.0009),
            vector4(-1071.6206, -1636.7561, 8.1940, 303.0204),
            vector4(-1014.5323, -1514.3020, 6.5173, 129.8531)
        }
    }
}

Config.NotifyType = "esx"

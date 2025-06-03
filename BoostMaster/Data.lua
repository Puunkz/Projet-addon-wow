-- Data.lua
local BM = BoostMaster

-- Données simulées
BM.boostData = {
    {
        client = "Elunaria",
        type = "Donjon",
        detail = "+17 Salles de l’Imprégnation",
        prix = "300k",
        part = "60k",
        advertiser = "Malkor",
        status = "En cours",
    },
    {
        client = "Thalios",
        type = "Raid",
        detail = "Amirdrassil NM 9/9",
        prix = "1.2M",
        part = "150k",
        advertiser = "Zephia",
        status = "Validé",
    },
    {
        client = "Nyxara",
        type = "Donjon",
        detail = "+20 Caveau d’Azur",
        prix = "400k",
        part = "80k",
        advertiser = "Orion",
        status = "En attente",
    },
}

BM.applyBoosts = {
    {
        id = 1,
        type = "Donjon",
        detail = "+18 Temple du Serpent de Jade",
        advertiser = "Tyrion",
        besoin = "Tank + BL",
        inscrits = 2,
        inscrit = false
    },
    {
        id = 2,
        type = "Raid",
        detail = "Aberrus HM 8/9",
        advertiser = "Myrielle",
        besoin = "Mage + CR",
        inscrits = 1,
        inscrit = false
    },
}

BM.walletData = {
    goldPerKey = 85000,
    goldPerDay = 500000,
    goldPerWeek = 3500000,
    goldPerMonth = 14000000,
}

BM.advertisingData = {
    predefinedMessages = {
        "Tarif boost donjon : 300k par clé",
        "Tarif raid NM : 1.2M par run",
        "Contactez Zephia pour réserver votre place",
    },
    commands = {
        {
            id = 101,
            type = "Donjon",
            detail = "+17 Salles de l’Imprégnation",
            price = "300k",
            advertiser = "Zephia",
            status = "En attente",
            goldToBank = 60000,
            validated = false,
        },
        {
            id = 102,
            type = "Raid",
            detail = "Amirdrassil NM 9/9",
            price = "1.2M",
            advertiser = "Zephia",
            status = "Validé",
            goldToBank = 150000,
            validated = true,
        },
    },
}

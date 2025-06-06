local BM = BoostMaster

function BoostMaster:CreateUI()
    local f = CreateFrame("Frame", "BoostMasterMainFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 5, 0)
    f.title:SetText("BoostMaster")

    local tabs = {
        { name = "Boosters", label = "Boosters" },
        { name = "Apply", label = "Apply" },
        { name = "Wallet", label = "Wallet" },
        { name = "Advertising", label = "Advertising" },
        { name = "Credits", label = "Credits" },
    }

    f.tabs = {}
    for i, tab in ipairs(tabs) do
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(100, 24)
        b:SetText(tab.label)
        b:SetPoint("TOPLEFT", f, "TOPLEFT", 10 + (i-1)*110, -30)
        b:SetScript("OnClick", function()
            BoostMaster:ShowTab(tab.name)
        end)
        f.tabs[tab.name] = b
    end

    BM.mainFrame = f
    BM.tabs = {}
    BoostMaster:ShowTab("Boosters")
end

function BoostMaster:ShowTab(name)
    if BM.currentTab then
        BM.currentTab:Hide()
    end

    BM.currentTabName = name

    if not BM.tabs[name] then
        local tab = CreateFrame("Frame", nil, BM.mainFrame)
        tab:SetSize(580, 330)
        tab:SetPoint("TOPLEFT", BM.mainFrame, "TOPLEFT", 10, -60)
        tab.bg = tab:CreateTexture(nil, "BACKGROUND")
        tab.bg:SetAllPoints()
        tab.bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)

        local function AddText(frame, text, width, x)
            local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fs:SetPoint("LEFT", frame, "LEFT", x, 0)
            fs:SetWidth(width)
            fs:SetJustifyH("LEFT")
            fs:SetText(text or "")
            return fs
        end

        if name == "Boosters" then
            local scrollFrame = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", 10, -30)
            scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

            local content = CreateFrame("Frame", nil, scrollFrame)
            content:SetSize(1, 1)
            scrollFrame:SetScrollChild(content)

            local header = CreateFrame("Frame", nil, tab)
            header:SetSize(540, 20)
            header:SetPoint("TOPLEFT", 10, -5)

            AddText(header, "Client :", 80, 0)
            AddText(header, "Type :", 50, 90)
            AddText(header, "Détail :", 150, 145)
            AddText(header, "Prix :", 50, 300)
            AddText(header, "Part :", 50, 355)
            AddText(header, "Adv. :", 80, 410)
            AddText(header, "Statut :", 70, 495)

            BM.tabs["BoostersScroll"] = scrollFrame
            BM.tabs["BoostersContent"] = content
            BM.tabs["BoostersHeader"] = header

            local visibleBoosts = {}
            for _, boost in ipairs(BM.boostData) do
                if boost.status == "En cours" or boost.status == "Validé" then
                    table.insert(visibleBoosts, boost)
                end
            end

            local lineHeight = 24
            content:SetHeight(#visibleBoosts * lineHeight)
            content:SetWidth(540)

            local previousRow = nil
            for i, boost in ipairs(visibleBoosts) do
                local row = CreateFrame("Frame", nil, content)
                row:SetSize(540, lineHeight)
                if i == 1 then
                    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
                else
                    row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, 0)
                end

                AddText(row, boost.client, 80, 0)
                AddText(row, boost.type, 50, 90)
                AddText(row, boost.detail, 150, 145)
                AddText(row, boost.prix, 50, 300)
                AddText(row, boost.part, 50, 355)
                AddText(row, boost.advertiser, 80, 410)
                AddText(row, boost.status, 70, 495)

                row:Show()
                previousRow = row
            end

            scrollFrame:Show()

        elseif name == "Apply" then
            local scrollFrame = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", 10, -10)
            scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

            local content = CreateFrame("Frame", nil, scrollFrame)
            content:SetSize(1, 1)
            scrollFrame:SetScrollChild(content)

            local function AddText(frame, text, width, x)
                local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                fs:SetWidth(width)
                fs:SetJustifyH("LEFT")
                fs:SetText(text or "")
                fs:SetPoint("LEFT", frame, "LEFT", x, 0)
                return fs
            end

            for i, entry in ipairs(BM.applyBoosts) do
                local row = CreateFrame("Frame", nil, content)
                row:SetSize(540, 24)
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i-1)*26))

                AddText(row, entry.type, 60, 0)
                AddText(row, entry.detail, 160, 65)
                AddText(row, entry.advertiser, 80, 230)
                AddText(row, entry.besoin, 80, 315)
                AddText(row, "Inscrits: " .. entry.inscrits, 80, 400)

                local applyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                applyBtn:SetSize(60, 20)
                applyBtn:SetPoint("LEFT", row, "LEFT", 480, 0)
                applyBtn:SetText(entry.inscrit and "Inscrit" or "Postuler")
                applyBtn:SetEnabled(not entry.inscrit)
                applyBtn:SetScript("OnClick", function()
                    entry.inscrit = true
                    entry.inscrits = entry.inscrits + 1
                    applyBtn:SetText("Inscrit")
                    applyBtn:SetEnabled(false)
                    BM.SendApplyUpdate(entry.id)
                end)

                row:Show()
            end

            content:SetHeight(#BM.applyBoosts * 26)

        elseif name == "Wallet" then
            local goldData = BM.walletData or {}

            local goldStrings = {
                ("Or par clé : %s"):format(BreakUpLargeNumbers(goldData.goldPerKey or 0)),
                ("Or par jour : %s"):format(BreakUpLargeNumbers(goldData.goldPerDay or 0)),
                ("Or par semaine : %s"):format(BreakUpLargeNumbers(goldData.goldPerWeek or 0)),
                ("Or par mois : %s"):format(BreakUpLargeNumbers(goldData.goldPerMonth or 0)),
            }

            for i, text in ipairs(goldStrings) do
                local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                label:SetPoint("TOPLEFT", 20, -30 * i)
                label:SetText(text)
            end

            local barWidthMax = 400
            local barHeight = 20
            local yStart = -150

            local function CreateBar(y, value)
                local bar = CreateFrame("StatusBar", nil, tab)
                bar:SetSize(barWidthMax, barHeight)
                bar:SetPoint("TOPLEFT", 20, y)
                bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
                bar:SetStatusBarColor(0, 0.7, 0, 0.8)
                bar:SetMinMaxValues(0, goldData.goldPerMonth or 1)
                bar:SetValue(value or 0)

                local bg = bar:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0, 0, 0, 0.5)

                local label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                label:SetPoint("CENTER")
                label:SetText(BreakUpLargeNumbers(value or 0))
            end

            CreateBar(yStart, goldData.goldPerKey)
            CreateBar(yStart - 30, goldData.goldPerDay)
            CreateBar(yStart - 60, goldData.goldPerWeek)
            CreateBar(yStart - 90, goldData.goldPerMonth)

elseif name == "Advertising" then
    local tabHeight = 330
    local tabWidth = 580

    -- Header au-dessus de la liste
    local header = CreateFrame("Frame", nil, tab)
    header:SetSize(540, 20)
    header:SetPoint("TOPLEFT", 10, -5) -- en bas à gauche du tab

    local function AddHeaderText(text, width, x)
        local fs = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("LEFT", header, "LEFT", x, 0)
        fs:SetWidth(width)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
    end

    AddHeaderText("Type :", 50, 0)
    AddHeaderText("Détail :", 150, 60)
    AddHeaderText("Adv. :", 80, 210)
    AddHeaderText("Prix :", 70, 300)
    AddHeaderText("Statut :", 70, 380)

    -- ScrollFrame : liste des clés/raid en cours
    local scrollFrame = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30) -- en haut à gauche du tab
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 165) -- réduit pour laisser place en bas

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)

    BM.tabs["AdvertisingScroll"] = scrollFrame
    BM.tabs["AdvertisingContent"] = content
    BM.tabs["AdvertisingHeader"] = header

    -- Fenêtre création clé/raid en bas
    local form = CreateFrame("Frame", nil, tab)
    form:SetSize(560, 150)
    form:SetPoint("BOTTOMLEFT", 10, 10)  -- en bas à gauche
    form.bg = form:CreateTexture(nil, "BACKGROUND")
    form.bg:SetAllPoints()
    form.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

    local CreateLabel = function(parent, text, x, y)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        label:SetText(text)
        return label
    end

    -- Menus déroulants et champs de saisie
    local types = { "Donjon", "Raid" }
    local typeDropdown = CreateFrame("Frame", "TypeDropdown", form, "UIDropDownMenuTemplate")
    typeDropdown:SetPoint("TOPLEFT", form, "TOPLEFT", 330, -85)
    UIDropDownMenu_SetWidth(typeDropdown, 60)

    local donjonsSaison = { "Darkflame Cleft", "Cinderbrew Meadery", "The Rookery", "Priory of the Sacred Flame", "Operation: Floodgate", "Theater of Pain", "Operation: Mechagon - Workshop", "The MOTHERLODE!!" }
    local dungeonDropdown = CreateFrame("Frame", "DungeonDropdown", form, "UIDropDownMenuTemplate")
    dungeonDropdown:SetPoint("TOPLEFT", form, "TOPLEFT", 180, -30)
    UIDropDownMenu_SetWidth(dungeonDropdown, 120)

    local niveauxCle = {} -- Liste des niveaux de clé de 0 à ..
    for i = 0, 20 do
        table.insert(niveauxCle, "+" .. i)
    end

    local niveauDropdown = CreateFrame("Frame", "NiveauDropdown", form, "UIDropDownMenuTemplate")
    niveauDropdown:SetPoint("TOPLEFT", form, "TOPLEFT", 330, -30)
    UIDropDownMenu_SetWidth(niveauDropdown, 42)

    local raidSaison = { "Liberation of Undermine" }
    local raidDropdown = CreateFrame("Frame", "RaidDropdown", form, "UIDropDownMenuTemplate")
    raidDropdown:SetPoint("TOPLEFT", form, "TOPLEFT", -10, -85)
    UIDropDownMenu_SetWidth(raidDropdown, 150)

    local diffycultesRaid = { "Normal", "Héroïque", "Mythique" }
    local difficultyDropdown = CreateFrame("Frame", "DifficultyDropdown", form, "UIDropDownMenuTemplate")
    difficultyDropdown:SetPoint("TOPLEFT", form, "TOPLEFT", 180, -85)
    UIDropDownMenu_SetWidth(difficultyDropdown, 80)

    CreateLabel(form, "Type d'annonce :", 350, -65)
    CreateLabel(form, "Nom client :", 10, -10)
    CreateLabel(form, "Donjon :", 200, -10)
    CreateLabel(form, "Niveau clé :", 350, -10)
    CreateLabel(form, "Raid :", 10, -65)
    CreateLabel(form, "Difficulté :", 200, -65)
    CreateLabel(form, "Prix :", 430, -10)
    
    local clientInput = CreateFrame("EditBox", nil, form, "InputBoxTemplate")
    clientInput:SetSize(150, 25)
    clientInput:SetPoint("TOPLEFT", form, "TOPLEFT", 15, -30)
    clientInput:SetAutoFocus(false)

    local priceInput = CreateFrame("EditBox", nil, form, "InputBoxTemplate")
    priceInput:SetSize(80, 25)
    priceInput:SetPoint("TOPLEFT", form, "TOPLEFT", 435, -30)
    priceInput:SetAutoFocus(false)
    priceInput:SetNumeric(true)

    -- Initialisation des menus déroulants
    UIDropDownMenu_Initialize(typeDropdown, function(self, level, menuList)
        for i, typeName in ipairs(types) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = typeName
            info.checked = (UIDropDownMenu_GetText(typeDropdown) == i)
            info.func = function()
                UIDropDownMenu_SetSelectedID(typeDropdown, i)
                UpdateFormVisibility(type)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_Initialize(dungeonDropdown, function(self, level, menuList)
        for i, donjon in ipairs(donjonsSaison) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = donjon
            info.checked = (UIDropDownMenu_GetText(dungeonDropdown) == donjon)
            info.func = function()
                UIDropDownMenu_SetSelectedID(dungeonDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_Initialize(niveauDropdown, function(self, level, menuList)
        for i, niveau in ipairs(niveauxCle) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = niveau
            info.checked = (UIDropDownMenu_GetText(niveauDropdown) == niveau)
            info.func = function()
                UIDropDownMenu_SetSelectedID(niveauDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_Initialize(raidDropdown, function(self, level, menuList)
        for i, raid in ipairs(raidSaison) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = raid
            info.checked = (UIDropDownMenu_GetText(raidDropdown) == raid)
            info.func = function()
                UIDropDownMenu_SetSelectedID(raidDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_Initialize(difficultyDropdown, function(self, level, menuList)
        for i, diff in ipairs(diffycultesRaid) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = diff
            info.checked = (UIDropDownMenu_GetText(difficultyDropdown) == diff)
            info.func = function()
                UIDropDownMenu_SetSelectedID(difficultyDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- gestion de la visibilité des champs en fonction du type sélectionné
    function UpdateFormVisibility()
        local typeName = UIDropDownMenu_GetText(typeDropdown)
        if typeName == "Raid" then
            raidDropdown:Show()
            difficultyDropdown:Show()
            dungeonDropdown:Hide()
            niveauDropdown:Hide()
        else
            raidDropdown:Hide()
            difficultyDropdown:Hide()
            dungeonDropdown:Show()
            niveauDropdown:Show()
        end
    end

UIDropDownMenu_SetSelectedID(typeDropdown, 1) -- Sélectionne "Donjon" par défaut
UIDropDownMenu_SetText(typeDropdown, "Donjon") -- Définit le texte affiché par défaut

UIDropDownMenu_SetSelectedID(dungeonDropdown, 1) -- Sélectionne le premier donjon par défaut
UIDropDownMenu_SetText(dungeonDropdown, donjonsSaison[1]) -- Définit le texte affiché par défaut

UIDropDownMenu_SetSelectedID(niveauDropdown, 1) -- Sélectionne le premier niveau de clé par défaut
UIDropDownMenu_SetText(niveauDropdown, niveauxCle[1]) -- Définit le texte affiché par défaut

UIDropDownMenu_SetSelectedID(raidDropdown, 1) -- Sélectionne le premier raid par défaut
UIDropDownMenu_SetText(raidDropdown, raidSaison[1]) -- Définit le texte affiché par défaut

UIDropDownMenu_SetSelectedID(difficultyDropdown, 1) -- Sélectionne la première difficulté par défaut
UIDropDownMenu_SetText(difficultyDropdown, diffycultesRaid[1]) -- Définit le texte affiché par défaut

UpdateFormVisibility() -- Met à jour la visibilité des champs en fonction du type sélectionné

 -- Bouton pour créer une annonce
    local createButton = CreateFrame("Button", nil, form, "UIPanelButtonTemplate")
    createButton:SetSize(100, 25)
    createButton:SetPoint("TOPLEFT", form, "TOPLEFT", 220, -120)
    createButton:SetText("Créer clé/raid")

    local lignes = {}

    createButton:SetScript("OnClick", function()
        local client = clientInput:GetText()
        local prix = tonumber(priceInput:GetText())
        local typeSelection = UIDropDownMenu_GetText(typeDropdown)

    if client == "" or not prix or prix <= 0 then
        print("BoostMaster : Veuillez remplir tous les champs correctement.")
        return
    end

    local typeAnnonce, detailAnnonce

    if typeSelection == "Donjon" then
        local donjon = UIDropDownMenu_GetText(donjonDropdown)
        local niveauCle = UIDropDownMenu_GetText(niveauDropdown)
        if not donjon or not niveauCle then
            print("BoostMaster : Veuillez sélectionner un donjon et un niveau de clé.")
            return
        end
        typeAnnonce = "Donjon"
        detailAnnonce = donjon .. " " .. niveauCle

    elseif typeSelection == "Raid" then
        local raid = UIDropDownMenu_GetText(raidDropdown)
        local difficulte = UIDropDownMenu_GetText(difficultyDropdown)
        if not raid or not difficulte then
            print("BoostMaster : Veuillez sélectionner un raid et une difficulté.")
            return
        end
        typeAnnonce = "Raid"
        detailAnnonce = raid .. " " .. difficulte
    end

    -- ajout de l'annonce à la liste
    table.insert(BM.advertisingData, {
        client = client,
        type = typeAnnonce,
        detail = detailAnnonce,
        price = prix,
        status = "En attente",
    })

    print("Contenu advertisingData :")
for i, entry in ipairs(BM.advertisingData) do
    print(i, entry.client, entry.type, entry.detail, entry.price)
end

    -- Reset des champs
    clientInput:SetText("")
    priceInput:SetText("")
    UIDropDownMenu_SetSelectedID(typeDropdown, 1)
    UIDropDownMenu_SetSelectedID(dungeonDropdown, 1)
    UIDropDownMenu_SetSelectedID(niveauDropdown, 1)
    UIDropDownMenu_SetSelectedID(raidDropdown, 1)
    UIDropDownMenu_SetSelectedID(difficultyDropdown, 1)
    UpdateFormVisibility()


    BoostMaster:RefreshAdvertisingTab()
end)

    -- Conteneur pour boutons juste au-dessus du form
    local btnContainer = CreateFrame("Frame", nil, tab)
    btnContainer:SetSize(560, 60)
    btnContainer:SetPoint("BOTTOMLEFT", 450, 10) 

    -- Bouton personnaliser message
    local personalizeBtn = CreateFrame("Button", nil, btnContainer, "UIPanelButtonTemplate")
    personalizeBtn:SetSize(110, 25)
    personalizeBtn:SetPoint("TOPLEFT", btnContainer, "TOPLEFT", 0, 0)
    personalizeBtn:SetText("Personnaliser")
    personalizeBtn:SetScript("OnClick", function()
        StaticPopup_Show("BOOSTMASTER_PERSONALIZE_MESSAGE")
    end)

    -- Bouton envoyer message dans le chat
    local sendMsgBtn = CreateFrame("Button", nil, btnContainer, "UIPanelButtonTemplate")
    sendMsgBtn:SetSize(110, 25)
    sendMsgBtn:SetPoint("TOPLEFT", personalizeBtn, "BOTTOMLEFT", 0, -5)
    sendMsgBtn:SetText("Envoyer message")
    sendMsgBtn:SetScript("OnClick", function()
        local msg = BM.customMessage or "Tarifs disponibles, contactez-moi !"
        ChatEdit_InsertLink(msg)
    end)

    BoostMaster:RefreshAdvertisingTab()

        elseif name == "Credits" then
            local creditText = [[
BoostMaster Addon
Développé par Puunkz

- Gestion des boosts
- Postulation rapide
- Suivi du portefeuille
- Annonces et communication

Merci d'utiliser BoostMaster
            ]]

            local textLabel = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            textLabel:SetPoint("TOPLEFT", 20, -30)
            textLabel:SetWidth(540)
            textLabel:SetJustifyV("TOP")
            textLabel:SetJustifyH("LEFT")
            textLabel:SetText(creditText)
        end

        BM.tabs[name] = tab
    end

    BM.currentTab = BM.tabs[name]
    BM.currentTab:Show()
end

-- Fonction pour rafraîchir l'onglet Advertising
function BoostMaster:RefreshAdvertisingTab()
    local content = BM.tabs["AdvertisingContent"]
    
    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local OffsetY = -5

    for i, data in ipairs(BM.advertisingData) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(540, 24)
        row:SetPoint("TOPLEFT", 0, OffsetY)

        local function AddText(parent, text, width, x)
            local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            fs:SetWidth(width)
            fs:SetJustifyH("LEFT")
            fs:SetPoint("LEFT", parent, "LEFT", x, 0)
            fs:SetText(text)
        end

        AddText(row, data.type or "-", 50, 0)
        AddText(row, data.detail or "-", 150, 60)
        AddText(row, data.advertiser or "Alexïøs", 80, 210)
        AddText(row, data.price and tostring(data.price) or "-", 70, 300)
        AddText(row, data.status or "-", 70, 380)

        OffsetY = OffsetY - 26
    end
    content:SetHeight(-OffsetY + 5) -- Ajuste la hauteur du contenu en fonction des lignes ajoutées

        
    end
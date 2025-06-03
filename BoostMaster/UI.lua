-- UI.lua
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
    BM.tabs = {} -- initialise le cache des onglets
    BoostMaster:ShowTab("Boosters")
end

function BoostMaster:ShowTab(name)
    -- Cache l'onglet courant s'il existe
    if BM.currentTab then
        BM.currentTab:Hide()
    end

    BM.currentTabName = name

    -- Crée l'onglet s'il n'existe pas déjà
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
            -- ScrollFrame & contenu
            local scrollFrame = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", 10, -30)
            scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

            local content = CreateFrame("Frame", nil, scrollFrame)
            content:SetSize(1, 1) -- ajusté dynamiquement
            scrollFrame:SetScrollChild(content)

            -- Header fixe au-dessus du scroll
            local header = CreateFrame("Frame", nil, tab)
            header:SetSize(540, 20)
            header:SetPoint("TOPLEFT", 10, -5)

            AddText(header, "Client", 80, 0)
            AddText(header, "Type", 50, 90)
            AddText(header, "Détail", 150, 145)
            AddText(header, "Prix", 50, 300)
            AddText(header, "Part", 50, 355)
            AddText(header, "Adv.", 80, 410)
            AddText(header, "Statut", 70, 495)

            BM.tabs["BoostersScroll"] = scrollFrame
            BM.tabs["BoostersContent"] = content
            BM.tabs["BoostersHeader"] = header

            -- On affiche les boosts valides (en cours ou validé)
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
            local scrollFrame = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", 10, -10)
            scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

            local content = CreateFrame("Frame", nil, scrollFrame)
            content:SetSize(1, 1)
            scrollFrame:SetScrollChild(content)

            local header = CreateFrame("Frame", nil, tab)
            header:SetSize(540, 20)
            header:SetPoint("TOPLEFT", 10, -5)

            local function AddHeaderText(text, width, x)
                local fs = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                fs:SetPoint("LEFT", header, "LEFT", x, 0)
                fs:SetWidth(width)
                fs:SetJustifyH("LEFT")
                fs:SetText(text)
            end

            AddHeaderText("Type", 50, 0)
            AddHeaderText("Détail", 150, 60)
            AddHeaderText("Adv.", 80, 210)
            AddHeaderText("Prix", 70, 300)
            AddHeaderText("Statut", 70, 380)

            local function AddText(frame, text, width, x)
                local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                fs:SetWidth(width)
                fs:SetJustifyH("LEFT")
                fs:SetText(text or "")
                fs:SetPoint("LEFT", frame, "LEFT", x, 0)
                return fs
            end

            for i, cmd in ipairs(BM.advertisingData.commands or {}) do
                local row = CreateFrame("Frame", nil, content)
                row:SetSize(540, 20)
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i-1)*22))

                AddText(row, cmd.type, 50, 0)
                AddText(row, cmd.detail, 150, 60)
                AddText(row, cmd.advertiser, 80, 210)
                AddText(row, cmd.price, 70, 300)
                AddText(row, cmd.status, 70, 380)

                row:Show()
            end

            content:SetHeight(#(BM.advertisingData.commands or {}) * 22)

        elseif name == "Credits" then
            local creditText = [[
BoostMaster Addon
Développé par Puunkz

- Gestion des boosts
- Postulation rapide
- Suivi du portefeuille
- Annonces et communication

Merci d'utiliser BoostMaster!
            ]]
            local label = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("TOPLEFT", 20, -20)
            label:SetJustifyH("LEFT")
            label:SetWidth(540)
            label:SetText(creditText)
        end

        BM.tabs[name] = tab
    end

    -- Affiche l'onglet actif
    BM.currentTab = BM.tabs[name]
    BM.currentTab:Show()
end
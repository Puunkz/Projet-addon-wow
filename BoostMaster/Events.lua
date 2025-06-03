-- Events.lua
local BM = BoostMaster

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Event au login, on crée l'UI ici si besoin (optionnel)
        -- BoostMaster:CreateUI() -- On peut créer au slash command, donc pas obligatoire ici
    end
end)

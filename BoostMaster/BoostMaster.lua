-- BoostMaster.lua
local BM = {}
BoostMaster = BM

-- Charger les autres modules (ils s'exécutent automatiquement grâce au .toc)

-- Commande slash pour ouvrir/fermer la fenêtre
SLASH_BOOSTMASTER1 = "/boostmaster"
SLASH_BOOSTMASTER2 = "/bm"

SlashCmdList["BOOSTMASTER"] = function()
    if BM.mainFrame and BM.mainFrame:IsShown() then
        BM.mainFrame:Hide()
    else
        if not BM.mainFrame then
            BoostMaster:CreateUI()
        end
        BM.mainFrame:Show()
    end
end

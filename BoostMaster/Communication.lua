-- Communication.lua
local BM = BoostMaster

C_ChatInfo.RegisterAddonMessagePrefix("BM_APPLY")

local function SendApplyUpdate(entryId)
    local msg = "APPLY:" .. entryId
    C_ChatInfo.SendAddonMessage("BM_APPLY", msg, "GUILD")
end

local function ReceiveApplyUpdate(prefix, message, channel, sender)
    if prefix == "BM_APPLY" and message:sub(1, 6) == "APPLY:" then
        local id = tonumber(message:sub(7))
        for _, boost in ipairs(BM.applyBoosts) do
            if boost.id == id then
                boost.inscrits = boost.inscrits + 1
            end
        end
        if BM.currentTabName == "Apply" then
            BoostMaster:ShowTab("Apply")
        end
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_ADDON", function(_, _, prefix, message, channel, sender)
    ReceiveApplyUpdate(prefix, message, channel, sender)
    return false
end)

-- Exposer la fonction pour envoyer les mises à jour
BM.SendApplyUpdate = SendApplyUpdate

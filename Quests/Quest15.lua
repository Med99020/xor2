local Shared = _G.Shared

-- QUEST 15: Auto Claim Index (Codex System)
-- ✅ Scans UI for claimable items (like TestClaim.lua)
-- ✅ Claims Ores, Enemies, Equipments
-- ✅ Only claims items that have Claim button

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local Quest15Active = true
local DEBUG_MODE = false

local QUEST_CONFIG = {
    QUEST_NAME = "Auto Claim Index",
    CLAIM_DELAY = 0.3,
}

----------------------------------------------------------------
-- KNIT SETUP
----------------------------------------------------------------
local SERVICES = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")

local CLAIM_ORE_RF = nil
pcall(function()
    CLAIM_ORE_RF = SERVICES:WaitForChild("CodexService", 5):WaitForChild("RF", 3):WaitForChild("ClaimOre", 3)
end)

local CLAIM_ENEMY_RF = nil
pcall(function()
    CLAIM_ENEMY_RF = SERVICES:WaitForChild("CodexService", 5):WaitForChild("RF", 3):WaitForChild("ClaimEnemy", 3)
end)

local CLAIM_EQUIPMENT_RF = nil
pcall(function()
    CLAIM_EQUIPMENT_RF = SERVICES:WaitForChild("CodexService", 5):WaitForChild("RF", 3):WaitForChild("ClaimEquipment", 3)
end)

if DEBUG_MODE then
    print("📡 ClaimOre: " .. (CLAIM_ORE_RF and "✅" or "❌"))
    print("📡 ClaimEnemy: " .. (CLAIM_ENEMY_RF and "✅" or "❌"))
    print("📡 ClaimEquipment: " .. (CLAIM_EQUIPMENT_RF and "✅" or "❌"))
end

----------------------------------------------------------------
-- GET INDEX UI
----------------------------------------------------------------
local function getIndexUI()
    local indexUI = playerGui:FindFirstChild("Menu")
                   and playerGui.Menu:FindFirstChild("Frame")
                   and playerGui.Menu.Frame:FindFirstChild("Frame")
                   and playerGui.Menu.Frame.Frame:FindFirstChild("Menus")
                   and playerGui.Menu.Frame.Frame.Menus:FindFirstChild("Index")
    return indexUI
end

----------------------------------------------------------------
-- CLAIM FUNCTIONS
----------------------------------------------------------------
local function claimOre(oreName)
    if not CLAIM_ORE_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_ORE_RF:InvokeServer(oreName)
    end)
    
    if success then
        print(string.format("   🪨 Claimed: %s", oreName))
        return true
    end
    return false
end

local function claimEnemy(enemyName)
    if not CLAIM_ENEMY_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_ENEMY_RF:InvokeServer(enemyName)
    end)
    
    if success then
        print(string.format("   👹 Claimed: %s", enemyName))
        return true
    end
    return false
end

local function claimEquipment(equipmentName)
    if not CLAIM_EQUIPMENT_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_EQUIPMENT_RF:InvokeServer(equipmentName)
    end)
    
    if success then
        print(string.format("   ⚔️ Claimed: %s", equipmentName))
        return true
    end
    return false
end

----------------------------------------------------------------
-- MAIN CLAIM FUNCTION (UI SCANNING)
----------------------------------------------------------------
local function claimAllIndex()
    local totalClaimed = 0
    
    local indexUI = getIndexUI()
    if not indexUI then
        if DEBUG_MODE then warn("❌ Index UI not found!") end
        return false
    end
    
    local pages = indexUI:FindFirstChild("Pages")
    if not pages then
        if DEBUG_MODE then warn("❌ Pages not found!") end
        return false
    end
    
    -- 1. CLAIM ORES
    local oresPage = pages:FindFirstChild("Ores")
    if oresPage then
        for _, child in ipairs(oresPage:GetChildren()) do
            if string.find(child.Name, "List$") then
                for _, oreItem in ipairs(child:GetChildren()) do
                    if oreItem:IsA("Frame") or oreItem:IsA("GuiObject") then
                        local main = oreItem:FindFirstChild("Main")
                        if main and main:FindFirstChild("Claim") then
                            if claimOre(oreItem.Name) then
                                totalClaimed = totalClaimed + 1
                            end
                            task.wait(QUEST_CONFIG.CLAIM_DELAY)
                        end
                    end
                end
            end
        end
    end
    
    -- 2. CLAIM ENEMIES
    local enemiesPage = pages:FindFirstChild("Enemies")
    if enemiesPage then
        local scrollFrame = enemiesPage:FindFirstChild("ScrollingFrame")
        if scrollFrame then
            for _, child in ipairs(scrollFrame:GetChildren()) do
                if string.find(child.Name, "List$") then
                    for _, enemyItem in ipairs(child:GetChildren()) do
                        if enemyItem:IsA("Frame") or enemyItem:IsA("GuiObject") then
                            local main = enemyItem:FindFirstChild("Main")
                            if main and main:FindFirstChild("Claim") then
                                if claimEnemy(enemyItem.Name) then
                                    totalClaimed = totalClaimed + 1
                                end
                                task.wait(QUEST_CONFIG.CLAIM_DELAY)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- 3. CLAIM EQUIPMENTS
    local equipPage = pages:FindFirstChild("Equipments")
    if equipPage then
        local scrollFrame = equipPage:FindFirstChild("ScrollingFrame")
        if scrollFrame then
            for _, child in ipairs(scrollFrame:GetChildren()) do
                if string.find(child.Name, "List$") then
                    for _, equipItem in ipairs(child:GetChildren()) do
                        if equipItem:IsA("Frame") or equipItem:IsA("GuiObject") then
                            local main = equipItem:FindFirstChild("Main")
                            if main and main:FindFirstChild("Claim") then
                                if claimEquipment(equipItem.Name) then
                                    totalClaimed = totalClaimed + 1
                                end
                                task.wait(QUEST_CONFIG.CLAIM_DELAY)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return totalClaimed > 0
end

----------------------------------------------------------------
-- EXECUTE
----------------------------------------------------------------
print(string.rep("=", 50))
print("� QUEST 15: " .. QUEST_CONFIG.QUEST_NAME)
print("🎯 Scanning for claimable Index items...")
print(string.rep("=", 50))

local success = claimAllIndex()

if success then
    print("\n✅ Index claiming complete!")
else
    print("\n⏸️ No items to claim")
end

print(string.rep("=", 50))
Quest15Active = false

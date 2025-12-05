local Shared = _G.Shared

-- QUEST 15: Auto Claim Index (Codex System)
-- ✅ Claims ALL known ores, enemies, and equipments
-- ✅ No UI dependency - uses predefined lists
-- ✅ RemoteFunctions: ClaimOre, ClaimEnemy, ClaimEquipment

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local Quest15Active = true
local DEBUG_MODE = false  -- Set to true for verbose output

local QUEST_CONFIG = {
    QUEST_NAME = "Auto Claim Index",
    CLAIM_DELAY = 0.3,  -- Delay after each claim (seconds)
}

-- 🪨 ALL KNOWN ORES (from all maps)
local ALL_ORES = {
    -- Tutorial Area
    "Pebble",
    "Stone",
    -- Iron Valley
    "Copper",
    "Iron",
    "Tin",
    "Cardboardite",
    "Sand Stone",
    -- Forgotten Kingdom
    "Silver",
    "Gold",
    "Bananite",
    "Mushroomite",
    "Platinum",
    "Aite",
    "Cobalt",
    "Obsidian",
    "Larite",
    "Adamantite",
}

-- 👹 ALL KNOWN ENEMIES
local ALL_ENEMIES = {
    -- Tutorial
    "Zombie",
    "Walking Zombie",
    "Strong Zombie",
    -- Iron Valley
    "Slime",
    "Big Slime",
    "Mushroom",
    "Angry Mushroom",
    "Goblin",
    "Goblin Warrior",
    -- Forgotten Kingdom
    "Skeleton",
    "Skeleton Warrior",
    "Skeleton King",
    "Golem",
    "Golem King",
    "Dragon",
}

-- ⚔️ ALL KNOWN EQUIPMENT
local ALL_EQUIPMENTS = {
    -- Weapons
    "Wooden Sword",
    "Stone Sword",
    "Iron Sword",
    "Bronze Sword",
    "Silver Sword",
    "Gold Sword",
    "Colossal Sword",
    -- Pickaxes
    "Stone Pickaxe",
    "Bronze Pickaxe",
    "Iron Pickaxe",
    "Silver Pickaxe",
    "Gold Pickaxe",
    "Cobalt Pickaxe",
    -- Armor
    "Gauntlet",
    "Iron Gauntlet",
    -- Others
    "Guitar",
}

----------------------------------------------------------------
-- KNIT SETUP
----------------------------------------------------------------
local KnitPackage = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit")
local Knit = require(KnitPackage)

if not Knit.OnStart then 
    pcall(function() Knit.Start():await() end)
end

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
    if CLAIM_ORE_RF then print("✅ ClaimOre Remote Ready!") else warn("⚠️ ClaimOre Remote not found") end
    if CLAIM_ENEMY_RF then print("✅ ClaimEnemy Remote Ready!") else warn("⚠️ ClaimEnemy Remote not found") end
    if CLAIM_EQUIPMENT_RF then print("✅ ClaimEquipment Remote Ready!") else warn("⚠️ ClaimEquipment Remote not found") end
end

----------------------------------------------------------------
-- CLAIM FUNCTIONS
----------------------------------------------------------------
local function claimOre(oreName)
    if not CLAIM_ORE_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_ORE_RF:InvokeServer(oreName)
    end)
    
    if success and result then
        print(string.format("   🪨 Claimed ore: %s", oreName))
        return true
    end
    return false
end

local function claimEnemy(enemyName)
    if not CLAIM_ENEMY_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_ENEMY_RF:InvokeServer(enemyName)
    end)
    
    if success and result then
        print(string.format("   👹 Claimed enemy: %s", enemyName))
        return true
    end
    return false
end

local function claimEquipment(equipmentName)
    if not CLAIM_EQUIPMENT_RF then return false end
    
    local success, result = pcall(function()
        return CLAIM_EQUIPMENT_RF:InvokeServer(equipmentName)
    end)
    
    if success and result then
        print(string.format("   ⚔️ Claimed equipment: %s", equipmentName))
        return true
    end
    return false
end

----------------------------------------------------------------
-- MAIN CLAIM ALL FUNCTION
----------------------------------------------------------------
local function claimAllIndex()
    local totalClaimed = 0
    
    -- 1. Claim ALL Ores
    for _, oreName in ipairs(ALL_ORES) do
        if claimOre(oreName) then
            totalClaimed = totalClaimed + 1
        end
        task.wait(QUEST_CONFIG.CLAIM_DELAY)
    end
    
    -- 2. Claim ALL Enemies
    for _, enemyName in ipairs(ALL_ENEMIES) do
        if claimEnemy(enemyName) then
            totalClaimed = totalClaimed + 1
        end
        task.wait(QUEST_CONFIG.CLAIM_DELAY)
    end
    
    -- 3. Claim ALL Equipments
    for _, equipmentName in ipairs(ALL_EQUIPMENTS) do
        if claimEquipment(equipmentName) then
            totalClaimed = totalClaimed + 1
        end
        task.wait(QUEST_CONFIG.CLAIM_DELAY)
    end
    
    return totalClaimed > 0
end

----------------------------------------------------------------
-- EXECUTE
----------------------------------------------------------------
print(string.rep("=", 50))
print("🐉 QUEST 15: " .. QUEST_CONFIG.QUEST_NAME)
print("🎯 Auto claiming ALL index items...")
print(string.rep("=", 50))

local success = claimAllIndex()

if success then
    print("\n✅ Index claiming complete!")
else
    print("\n⏸️ No new items to claim")
end

print(string.rep("=", 50))
Quest15Active = false

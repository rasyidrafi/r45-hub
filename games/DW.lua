-- Check if the game is Dandy's World
local correctPlace = game.PlaceId == 16552821455
if not correctPlace then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "R45 Hub Notification",
        Text = "This game is not supported by R45 Hub.",
        Duration = 6.5
    })
    return
end

print("Loading Dandy's World features...")

-- Get From Template -------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local function createWindow(title)
    return Rayfield:CreateWindow({
        Name = title,
        LoadingTitle = "R45 Private Hub",
        LoadingSubtitle = "by R45 Community",
        ConfigurationSaving = {Enabled = true, FileName = "R45 Hub"},
        Discord = {Enabled = false},
        KeySystem = false
    })
end

local function createSection(tab, name)
    return tab:CreateSection(name)
end

local function createToggle(tab, config)
    local callback = config.callback or function(v) getgenv()[config.flag] = v end
    return tab:CreateToggle({
        Name = config.name,
        CurrentValue = config.default,
        Flag = config.flag,
        Callback = callback
    })
end
-- End Get From Template ---------

-- Initialize Variables ----------
local Lighting
local LocalPlayer
local InGamePlayers
local Player
local PlayerStats

-- global variables
local TOLERANCE = 5
local RANGE = 30

repeat
    Lighting = game:GetService("Lighting")
    LocalPlayer = game:GetService("Players").LocalPlayer
    InGamePlayers = game:GetService("Workspace").InGamePlayers
    Player = InGamePlayers and InGamePlayers:FindFirstChild(LocalPlayer.Name)
    PlayerStats = Player and Player:FindFirstChild("Stats")
    wait()
until (
    Lighting and
    LocalPlayer and
    InGamePlayers and
    Player and
    PlayerStats
)

-- Game Feature's -------------------
local Window = createWindow("Dandy's World")
local tabs = {
    Main = Window:CreateTab("Main", "menu"),
    Elevator = Window:CreateTab("Elevator", "hotel"),
    ESP = Window:CreateTab("ESP", "eye"),
    Items = Window:CreateTab("Items", "shopping-cart"),
    Machines = Window:CreateTab("Machines", "cog")
}

-- Core UI --------------------------
-- Main Tab
local noClipFunction = function(value) end
createSection(tabs.Main, "No Clip")
createToggle(tabs.Main, {
    name = "No Clip",
    flag = "noClip",
    default = false,
    callback = noClipFunction
})

createSection(tabs.Main, "Character")
createToggle(tabs.Main, {
    name = "Faster Run",
    flag = "fastRun",
    default = false
})
createToggle(tabs.Main, {
    name = "Always Run (Decrease Stamina)",
    flag = "alwaysRun",
    default = false
})
createToggle(tabs.Main, {
    name = "Allow Jump",
    flag = "alwJump",
    default = false,
    callback = function(v)
        local jumpHeight = Value and 7.3 or 0
        Player.Humanoid.JumpHeight = jumpHeight
    end
})

createSection(tabs.Main, "Distraction")
createToggle(tabs.Main, {
    name = "Distract Monster",
    flag = "distractMonster",
    default = false
})

createSection(tabs.Main, "Miscellaneous")
createToggle(tabs.Main, {
    name = "Loop Full Bright",
    flag = "loobFb",
    default = false
})


-- Elevator Tab
createSection(tabs.Elevator, "Elevator Options")
createToggle(tabs.Elevator, {
    name = "Loop TP Elevator",
    flag = "loopTpEle",
    default = false
})
createToggle(tabs.Elevator, {
    name = "Auto TP Elevator",
    flag = "autoTpEle",
    default = false
})

-- ESP Tab
createSection(tabs.ESP, "ESP Options")
local espConfig = {
    Monster = {flag = "espMonster", default = false},
    Generator = {flag = "espGenerator", default = false},
    Player = {flag = "espPlayer", default = false},
    Item = {flag = "espItem", default = false},
    Elevator = {flag = "espElevator", default = false},
}

for name, config in pairs(espConfig) do
    createToggle(tabs.ESP, {
        name = "Esp "..name,
        flag = config.flag,
        default = config.default,
    })
end

-- Items Tab
createSection(tabs.Items, "Item Options")
createToggle(tabs.Items, {
    name = "Auto Collect Items",
    flag = "itemsAura",
    default = false
})
createToggle(tabs.Items, {
    name = "Auto Use Items",
    flag = "autoUseItems",
    default = false
})

-- Machines Tab
createSection(tabs.Machines, "Machine Options")
createToggle(tabs.Machines, {
    name = "Auto Skill Check",
    flag = "autoSkillCheck",
    default = false
})

-- Core Functions -------------------
-- feature flag: noClip
local function handleNoClipSure(parent, value)
    local classNames = { "Part", "MeshPart", "UnionOperation" }
    for _, v in pairs(parent:GetDescendants()) do
        if v.ClassName == "Model" then
            handleNoClipSure(v, value)
        elseif table.find(classNames, v.ClassName) then
            v.CanCollide = value
        end
    end
end

local function handleNoClip(parent, value)
    local classNames = { "Part", "MeshPart", "UnionOperation" }
    local modelNames = { "abcblock", "astrocutout", "bag", "baking tray", "baketray stack", "ball", "bearplush", "bench", "bill", "boltcutter", "boltcutters", "bones", "book", "bookshelf", "bookshelfmedium", "box", "bucket", "bulletinboard", "burger", "cactus", "carpet", "carpet_long", "ceilinglight", "chair", "cheese1", "cloud", "computer", "cookingpot", "couch", "counter", "crouchvine", "crate", "dandy wet sign", "dandycutout", "desk", "door", "egg carton", "electricpanel", "fafelle", "fence", "flour", "flower", "flower1", "flower2", "flowercactus", "forklift", "fossil_triceratops", "fridge", "gingerbread_human", "gingerbread_pine", "gingerbread_plate", "holidaypinetree", "hotdog", "informationboard", "industrialshelf", "invisborder", "invisibleborder", "invisiblewall", "inviswall", "jackinthebox", "jukebox", "ketchup", "ladder", "lantern", "largecrate", "locker_long", "lorebench", "loveseat", "menusign", "meshes/cashcabinet", "meshes/cashcabinet_001", "meshes/cashcabinet_002", "meshes/cashcabinet_003", "meshes/cashcabinet_004", "meshes/cashcabinet_005", "meshes/cashcabinet_006", "meshes/cashcabinet_007", "meshes/cashcabinet_008", "meshes/cashcabinet_009", "meshes/cashcabinet_010", "meshes/cube_329", "meshes/cube_330", "meshes/cube_331", "meshes/cylinder_062", "meshes/giftshop (1)", "meshes/giftshop_001 (1)", "meshes/giftshop_004 (1)", "meshes/giftshop_005 (1)", "meshes/giftshop_007 (1)", "meshes/giftshop_008 (1)", "meshes/giftshop_012 (1)", "meshes/giftshop_013 (1)", "meshes/giftshop_015 (1)", "meshes/giftshop_016 (1)", "meshes/pottedplant", "meshes/pottedplant_001", "meshes/pottedplant_002", "meshes/pottedplant_003", "meshes/pottedplant_004", "milkshake", "monitor", "mustard", "napkinholder", "new_fossil__stegosaurus", "new_fossil_dinoskull", "new_fossil_roundshell", "newregister", "newspaper", "noclip", "noodles", "officechair", "ornithomimus", "oven", "paintings", "paperplate", "pillow", "plushie", "pot", "pottedplant", "present", "pretzel", "projector", "puzzlebox", "rack", "radio", "retopovan", "rolled newspaper", "rose", "shelf", "shelly wet sign", "shrub", "sink", "skillet", "smallcrate", "smalltable", "soda", "split soda", "speaker", "spraycan", "stand", "stocking", "stopsign", "table", "tableandchairs", "toolbox", "toppled flower", "trafficcone", "tree", "utahraptor", "vase", "vee wet sign", "vendingmachine", "watercooler" }

    for _, v in pairs(parent:GetDescendants()) do
        local nameLower = v.Name:lower()
        if v.ClassName == "Model" then
            if table.find(modelNames, nameLower) then
                handleNoClipSure(v, value)
            else
                handleNoClip(v, value)
            end
        elseif table.find(classNames, v.ClassName) and table.find(modelNames, nameLower) then
            v.CanCollide = value
        end
    end
end

local function handleNoClipAll(room, value)
    local childNames = {"Borders", "Walls", "FreeArea", "Objects", "GeneratedBorders"}
    
    for _, name in ipairs(childNames) do
        local child = room:FindFirstChild(name)
        if child then
            handleNoClip(child, value)
        end
    end
end
noClipFunction = function(value)
    handleNoClipAll(CurrentRoom, not value)
end
-- end feature flag: noClip

local CurrentRoom = game.Workspace:WaitForChild("CurrentRoom")
CurrentRoom.ChildAdded:Connect(function(room)
    if not room:IsA("Model") then return end

    -- feature flag: noClip
    if getgenv().noClip then
        handleNoClipAll(room, false)
    end
end)
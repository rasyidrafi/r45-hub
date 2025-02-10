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
        Icon = 0,
        LoadingTitle = "R45 Private Hub",
        LoadingSubtitle = "by R45 Community",
        Theme = "Default",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "R45", FileName = "config"},
        Discord = {Enabled = false, Invite = "noinvitelink", RememberJoins = true},
        KeySystem = false,
        KeySettings = { Title = "Untitled", Subtitle = "Key System", Note = "No method of obtaining the key is provided", FileName = "Key", SaveKey = true, GrabKeyFromSite = false, Key = {"Hello"} }
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
local CurrentRoom
local VirtualInputManager = game:GetService("VirtualInputManager")

-- global variables
local TOLERANCE = 5
local RANGE = 30

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

-- feature flag: noClip
local folderName = { "Walls", "Borders", "FreeArea", "Objects", "GeneratedBorders" }
local classNames = { "Part", "MeshPart", "UnionOperation" }
local modelNames = { "abcblock", "astrocutout", "bag", "baking tray", "baketray stack", "ball", "bearplush", "bench", "bill", "boltcutter", "boltcutters", "bones", "book", "bookshelf", "bookshelfmedium", "box", "bucket", "bulletinboard", "burger", "cactus", "carpet", "carpet_long", "ceilinglight", "chair", "cheese1", "cloud", "computer", "cookingpot", "couch", "counter", "crouchvine", "crate", "dandy wet sign", "dandycutout", "desk", "door", "egg carton", "electricpanel", "fafelle", "fence", "flour", "flower", "flower1", "flower2", "flowercactus", "forklift", "fossil_triceratops", "fridge", "gingerbread_human", "gingerbread_pine", "gingerbread_plate", "holidaypinetree", "hotdog", "informationboard", "industrialshelf", "invisborder", "invisibleborder", "invisiblewall", "inviswall", "jackinthebox", "jukebox", "ketchup", "ladder", "lantern", "largecrate", "locker_long", "lorebench", "loveseat", "menusign", "meshes/cashcabinet", "meshes/cashcabinet_001", "meshes/cashcabinet_002", "meshes/cashcabinet_003", "meshes/cashcabinet_004", "meshes/cashcabinet_005", "meshes/cashcabinet_006", "meshes/cashcabinet_007", "meshes/cashcabinet_008", "meshes/cashcabinet_009", "meshes/cashcabinet_010", "meshes/cube_329", "meshes/cube_330", "meshes/cube_331", "meshes/cylinder_062", "meshes/giftshop (1)", "meshes/giftshop_001 (1)", "meshes/giftshop_004 (1)", "meshes/giftshop_005 (1)", "meshes/giftshop_007 (1)", "meshes/giftshop_008 (1)", "meshes/giftshop_012 (1)", "meshes/giftshop_013 (1)", "meshes/giftshop_015 (1)", "meshes/giftshop_016 (1)", "meshes/pottedplant", "meshes/pottedplant_001", "meshes/pottedplant_002", "meshes/pottedplant_003", "meshes/pottedplant_004", "milkshake", "monitor", "mustard", "napkinholder", "new_fossil__stegosaurus", "new_fossil_dinoskull", "new_fossil_roundshell", "newregister", "newspaper", "noclip", "noodles", "officechair", "ornithomimus", "oven", "paintings", "paperplate", "pillow", "plushie", "pot", "pottedplant", "present", "pretzel", "projector", "puzzlebox", "rack", "radio", "retopovan", "rolled newspaper", "rose", "shelf", "shelly wet sign", "shrub", "sink", "skillet", "smallcrate", "smalltable", "soda", "split soda", "speaker", "spraycan", "stand", "stocking", "stopsign", "table", "tableandchairs", "toolbox", "toppled flower", "trafficcone", "tree", "utahraptor", "vase", "vee wet sign", "vendingmachine", "watercooler" }

local function handleNoClipSure(parent, value)
    for _, v in pairs(parent:GetChildren()) do
        if v.ClassName == "Model" then
            handleNoClipSure(v, value)
        elseif table.find(classNames, v.ClassName) then
            v.CanCollide = value
        end
    end
end

local function handleNoClipUniversal(parent, value)
    if table.find(classNames, parent.ClassName) then
        if table.find(modelNames, parent.Name:lower()) then
            parent.CanCollide = value
        end
    end

    if parent.ClassName == "Model" then
        if table.find(modelNames, parent.Name:lower()) then
            handleNoClipSure(parent, value)
        else
            for _, pChild in pairs(parent:GetChildren()) do
                handleNoClipUniversal(pChild, value)
            end
        end
    end

    if parent.ClassName == "Folder" and table.find(folderName, parent.Name) then
        for _, pChild in pairs(parent:GetChildren()) do
            handleNoClipUniversal(pChild, value)
        end
    end
end

createSection(tabs.Main, "No Clip")
createToggle(tabs.Main, {
    name = "No Clip",
    flag = "noClip",
    default = false,
    callback = function(v)
        getgenv().noClip = v
        if CurrentRoom then
            for _, room in pairs(CurrentRoom:GetChildren()) do
                handleNoClipUniversal(room, not v)
            end
        end
    end
})
-- end feature flag: noClip

createSection(tabs.Main, "Character")
createToggle(tabs.Main, {
    name = "Faster Run",
    flag = "fastRun",
    default = false,
    callback = function(v)
        getgenv().fastRun = v
        if Player then
            if v then
                Player.Humanoid.WalkSpeed = 30
            else
                game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
                wait(0.1)
                game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(false)
            end
        end
    end
})
createToggle(tabs.Main, {
    name = "Always Run (Decrease Stamina)",
    flag = "alwaysRun",
    default = false,
    callback = function(v)
        getgenv().alwaysRun = v
        if Player then
            game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(v)
        end
    end
})
createToggle(tabs.Main, {
    name = "Allow Jump",
    flag = "alwJump",
    default = false,
    callback = function(v)
        if Player then
            Player.Humanoid.JumpHeight = v and 7.3 or 0
        end
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
    default = false,
    callback = function(v)
        getgenv().loopFb = v
        if Lighting then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 1
            Lighting.FogEnd = 1e10
        end
    end
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
-- wait until all variables are initialized
repeat
    Lighting = game:GetService("Lighting")
    LocalPlayer = game:GetService("Players").LocalPlayer
    InGamePlayers = game:GetService("Workspace").InGamePlayers
    Player = InGamePlayers and InGamePlayers:FindFirstChild(LocalPlayer.Name)
    PlayerStats = Player and Player:FindFirstChild("Stats")
    CurrentRoom = game:GetService("Workspace").CurrentRoom
    wait()
until (
    Lighting and
    LocalPlayer and
    InGamePlayers and
    Player and
    PlayerStats and
    CurrentRoom
)

-- feature flag: fastRun
if getgenv().fastRun == true then
    Player.Humanoid.WalkSpeed = 30
end
-- end feature flag: fastRun

-- feature flag: alwaysRun
if getgenv().alwaysRun == true then
    game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
end
local Sprinting = PlayerStats:FindFirstChild("Sprinting")
local CurrentStamina = PlayerStats:FindFirstChild("CurrentStamina")
CurrentStamina.Changed:Connect(function(v)
    if getgenv().alwaysRun == true and Sprinting.Value == false and v > 14 then
        game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
    end
end)
-- end feature flag: alwaysRun

-- feature flag: alwJump
if getgenv().alwJump == true then
    Player.Humanoid.JumpHeight = 7.3
end
-- end feature flag: alwJump

-- feature flag: loobFb
if getgenv().loobFb == true then
    Lighting.Ambient = Color3.fromRGB(255, 255, 255);
    Lighting.Brightness = 1;
    Lighting.FogEnd = 1e10;
    for _, v in pairs(lighting:GetDescendants()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false;
        end;
    end;
end
Lighting.Changed:Connect(function()
    if getgenv().loopFb then
        lighting.Ambient = Color3.fromRGB(255, 255, 255);
        lighting.Brightness = 1;
        lighting.FogEnd = 1e10;
    end
end);
-- end feature flag: loobFb

-- listen to CurrentRoom
CurrentRoom.ChildAdded:Connect(function(room)
    print("New room detected:", room.Name)

    room.DescendantAdded:Connect(function(descendant)
        -- feature flag: noClip
        if getgenv().noClip == true then
            handleNoClipUniversal(descendant, false)
        end
        -- end feature flag: noClip
    end)
end)
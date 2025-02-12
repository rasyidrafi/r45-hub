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

local function createDropdown(tab, config)
    return tab:CreateDropdown({
        Name = config.name,
        Options = config.options,
        CurrentOption = config.currentOption,
        MultipleOptions = config.multipleOptions,
        Flag = config.flag,
        Callback = config.callback
    })
end

local function createKeybind(tab, config)
    return tab:CreateKeybind({
        Name = config.name,
        CurrentKeybind = config.default,
        HoldToInteract = config.holdToInteract,
        Flag = config.flag,
        Callback = config.callback
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
local Elevators
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- feature flag: floatMode
local floatBrick = Instance.new("Part")
floatBrick.Name = "FloatingBrick"
floatBrick.Size = Vector3.new(5, 10, 5)
floatBrick.Position = Vector3.new(0, 8, 0)
floatBrick.Anchored = true
floatBrick.CanCollide = false
floatBrick.Parent = game:GetService("Workspace")
floatBrick.Color = Color3.fromRGB(0, 0, 0)
floatBrick.Transparency = 1
createSection(tabs.Main, "Float Mode")
createToggle(tabs.Main, {
    name = "Float Mode",
    flag = "floatMode",
    default = false,
    callback = function(v)
        getgenv().floatMode = v
        if v then
            if HumanoidRootPart then
                floatBrick.Position = HumanoidRootPart.Position - Vector3.new(0, 8, 0)
            end

            floatBrick.CanCollide = true
            floatBrick.Transparency = 0

            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Float Mode is enabled",
                Text = "Press E to go up, Q to go down",
                Duration = 6.5
            })
        else
            floatBrick.CanCollide = false
            floatBrick.Transparency = 1
        end
    end
})
-- end feature flag: floatMode

createSection(tabs.Main, "Character")
createToggle(tabs.Main, {
    name = "Faster Run",
    flag = "fastRun",
    default = false,
    callback = function(v)
        getgenv().fastRun = v
        if Player then
            if v and Player.Humanoid.WalkSpeed < 30 then
                Player.Humanoid.WalkSpeed = 30
            else
                game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
                task.wait(0.1)
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
    name = "Distract Monster (Didnt Work on Long Range Monsters)",
    flag = "distractMonster",
    default = false
})
local monsterDropdown = createDropdown(tabs.Main, {
    name = "Select Monster",
    options = { "None" },
    currentOption = { "None" },
    multipleOptions = false,
    flag = "selectedMonster",
    callback = function(v)
        getgenv().selectedMonster = v[1]
    end
})

createSection(tabs.Main, "Miscellaneous")
createToggle(tabs.Main, {
    name = "Delete Vee Popup",
    flag = "deleteVeePopup",
    default = false
})
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
-- feature flag: esp
local rareItemList = {
    "Instructions", "JumperCable",
    "AirHorn", "Bandage", "PopBottle", "HealthKit", "EjectButton", "BoxOfChocolates", "SmokeBomb", "Valve" 
}

local function handleEsp(key, value)
    local flagKey = "esp" .. key
    local flagKeyLabel = flagKey .. "Label"
    if key == "Player" and InGamePlayers and LocalPlayer then
        for _, player in pairs(InGamePlayers:GetChildren()) do
            if player.Name ~= LocalPlayer.Name then
                if value then
                    if not player:FindFirstChild(flagKey) then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = flagKey
                        highlight.Parent = player
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.FillTransparency = 0.2
                        highlight.FillColor = Color3.fromRGB(85, 170, 255)
                    end

                    if not player:FindFirstChild(flagKeyLabel) then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = flagKeyLabel
                        billboard.Parent = player
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 4.5, 0)
                        billboard.AlwaysOnTop = true

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Parent = billboard
                        textLabel.Text = player.Name
                        textLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextScaled = false
                        textLabel.TextSize = 12.5
                        textLabel.Font = Enum.Font.FredokaOne

                        local uiStroke = Instance.new("UIStroke")
                        uiStroke.Thickness = 1.5
                        uiStroke.Color = Color3.fromRGB(0, 0, 0)
                        uiStroke.Parent = textLabel
                    end
                else
                    if player:FindFirstChild(flagKey) then
                        player[flagKey]:Destroy()
                    end

                    if player:FindFirstChild(flagKeyLabel) then
                        player[flagKeyLabel]:Destroy()
                    end
                end
            end
        end
    elseif CurrentRoom then
        for _, room in pairs(CurrentRoom:GetChildren()) do
            local targets = room:FindFirstChild(key)
            if targets then
                for i, target in pairs(targets:GetChildren()) do
                    local targetName = target.Name
                    
                    local outerColor = Color3.fromRGB(0, 0, 0)
                    local innerColor = Color3.fromRGB(255, 0, 0)

                    if key == "Items" then
                        outerColor = Color3.fromRGB(255, 255, 255)
                        innerColor = Color3.fromRGB(32, 32, 32)

                        if table.find(rareItemList, targetName) then
                            outerColor = Color3.fromRGB(245, 255, 68)
                            innerColor = Color3.fromRGB(155, 132, 12)
                        end

                        if targetName == "FakeCapsule" then
                            outerColor = Color3.fromRGB(0, 0, 0)
                            innerColor = Color3.fromRGB(255, 0, 0)
                        end
                    end

                    if key == "Generators" then
                        innerColor = Color3.fromRGB(0, 255, 0)

                        local stats = target:FindFirstChild("Stats")
                        local completed = stats and stats:FindFirstChild("Completed")
                        local activePlayer  = stats and stats:FindFirstChild("ActivePlayer")
                        targetName = "Machine " .. i

                        if activePlayer and activePlayer.Value then
                            targetName = targetName .. "\n(Filling...)"
                        end

                        if completed and completed.Value == true then
                            targetName = targetName .. "\n(Completed)"
                        end
                    end

                    if value then
                        if not target:FindFirstChild(flagKey) then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = flagKey
                            highlight.Parent = target
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.OutlineColor = outerColor
                            highlight.OutlineTransparency = 0
                            highlight.FillTransparency = 0.2
                            highlight.FillColor = innerColor
                        end

                        if not target:FindFirstChild(flagKeyLabel) then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = flagKeyLabel
                            billboard.Parent = target
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 4.5, 0)
                            if key == "Items" then
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                            elseif key == "Generators" then
                                billboard.StudsOffset = Vector3.new(0, -9.2, 0)
                            end
                            billboard.AlwaysOnTop = true

                            local textLabel = Instance.new("TextLabel")
                            textLabel.Parent = billboard
                            textLabel.Text = targetName
                            textLabel.TextColor3 = innerColor
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextScaled = false
                            textLabel.TextSize = 12.5
                            textLabel.Font = Enum.Font.FredokaOne

                            local uiStroke = Instance.new("UIStroke")
                            uiStroke.Thickness = 1.5
                            uiStroke.Color = outerColor
                            uiStroke.Parent = textLabel
                        elseif target:FindFirstChild(flagKeyLabel) then
                            target[flagKeyLabel].TextLabel.Text = targetName
                        end
                    else
                        if target:FindFirstChild(flagKey) then
                            target[flagKey]:Destroy()
                        end

                        if target:FindFirstChild(flagKeyLabel) then
                            target[flagKeyLabel]:Destroy()
                        end
                    end
                end
            end
        end
    end
end
-- end feature flag: esp

createSection(tabs.ESP, "ESP Options")
local espConfig = {
    Monsters = {flag = "espMonster", default = false},
    Generators = {flag = "espGenerator", default = false},
    Player = {flag = "espPlayer", default = false},
    Items = {flag = "espItem", default = false},
}

for name, config in pairs(espConfig) do
    createToggle(tabs.ESP, {
        name = "Esp "..name,
        flag = config.flag,
        default = config.default,
        callback = function(v)
            getgenv()[config.flag] = v
            handleEsp(name, v)
        end
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
    Elevators = game:GetService("Workspace").Elevators
    Player = InGamePlayers and InGamePlayers:FindFirstChild(LocalPlayer.Name)
    PlayerStats = Player and Player:FindFirstChild("Stats")
    CurrentRoom = game:GetService("Workspace").CurrentRoom
    task.wait()
until (
    Lighting and
    LocalPlayer and
    InGamePlayers and
    Elevators and
    Player and
    PlayerStats and
    CurrentRoom
)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Inventory = Character:WaitForChild("Inventory")
local HumanoidRootPart = Player:WaitForChild("HumanoidRootPart")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")
local SingleElevator = Elevators:WaitForChild("Elevator")
local SpawnZones = SingleElevator:WaitForChild("SpawnZones")
local Panic = game:GetService("Workspace").Info.Panic

local function DoTeleport(target)
    if target:IsA("Model") and target.PrimaryPart then
        local newCFrame = target.PrimaryPart.CFrame + Vector3.new(0, 2.14, 0)
        Character:SetPrimaryPartCFrame(newCFrame)
    elseif target:IsA("BasePart") then
        local newCFrame = target.CFrame + Vector3.new(0, 2.14, 0)
        Character:SetPrimaryPartCFrame(newCFrame)
    else
        warn("target is neither a Model with a PrimaryPart nor a BasePart")
    end    
end

-- feature flag: fastRun
if getgenv().fastRun == true and Player.Humanoid.WalkSpeed < 30 then
    Player.Humanoid.WalkSpeed = 30
end
Player.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if getgenv().fastRun == true and Player.Humanoid.WalkSpeed < 30 then
        Player.Humanoid.WalkSpeed = 30
    end
end)
-- end feature flag: fastRun

-- feature flag: alwaysRun
if getgenv().alwaysRun == true then
    game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
end
local Sprinting = PlayerStats:FindFirstChild("Sprinting")
local CurrentStamina = PlayerStats:FindFirstChild("CurrentStamina")
CurrentStamina.Changed:Connect(function(v)
    if not getgenv().alwaysRun then return end
    if Sprinting.Value == true then return end
    if v < 14 then return end
    game:GetService("ReplicatedStorage").Events.SprintEvent:FireServer(true)
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
    if not getgenv().loobFb then return end
    Lighting.Ambient = Color3.fromRGB(255, 255, 255);
    Lighting.Brightness = 1;
    Lighting.FogEnd = 1e10;
end);
-- end feature flag: loobFb

local healthItemList = { "HealthKit", "Bandage" }
RunService.Heartbeat:Connect(function()
    -- feature flag: distractMonster
    if getgenv().distractMonster == true and getgenv().selectedMonster ~= "None" then
        local monsterName = getgenv().selectedMonster
        monsterName = monsterName:gsub("Twisted ", "")
        monsterName = monsterName .. "Monster"

        for _, room in pairs(CurrentRoom:GetChildren()) do
            local monsters = room:FindFirstChild("Monsters")
            if monsters then
                local monster = monsters:FindFirstChild(monsterName)
                if monster then
                    local monsterHumanoidRootPart = monster:FindFirstChild("HumanoidRootPart")
                    HumanoidRootPart.CFrame = monsterHumanoidRootPart.CFrame * CFrame.new(0, 6.5, 0)
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        -- end feature flag: distractMonster
    else
        -- feature flag: loopTpEle and autoTpEle
        if SingleElevator and SpawnZones then
            if getgenv().loopTpEle == true or (Panic.Value == true and getgenv().autoTpEle == true) then
                DoTeleport(SpawnZones)
            end
        end
        -- end feature flag: loopTpEle and autoTpEle
    end

    -- feature flag: autoUseItems
    if getgenv().autoUseItems then
        for _, slot in pairs(Inventory:GetChildren()) do
            local itemName = slot.Value
            if not table.find(healthItemList, itemName) then
                game:GetService("ReplicatedStorage").Events.ItemEvent:InvokeServer(Player, slot)
            end
        end
    end
    -- end feature flag: autoUseItems

    -- feature flag: deleteVeePopup
    if getgenv().deleteVeePopup == true then
        for _, gui in pairs(ScreenGui:GetChildren()) do
            if gui.Name == "PopUp" and gui.Visible == true then
                gui.Visible = false
            end
        end
    end
    -- end feature flag: deleteVeePopup
end)

-- feature flag: floatMode
if getgenv().floatMode == true then
    floatBrick.Position = HumanoidRootPart.Position - Vector3.new(0, 8, 0)
    floatBrick.CanCollide = true
    floatBrick.Transparency = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        floatBrick.Position = floatBrick.Position + Vector3.new(0, 1, 0)
    elseif input.KeyCode == Enum.KeyCode.Q then
        floatBrick.Position = floatBrick.Position - Vector3.new(0, 1, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    floatBrick.Position = Vector3.new(HumanoidRootPart.Position.X, floatBrick.Position.Y, HumanoidRootPart.Position.Z)
end)
-- end feature flag: floatMode

-- listen to CurrentRoom
local ignoreMonsters = { "RazzleDazzleMonster", "ConnieMonster", "RodgerMonster" }
CurrentRoom.ChildAdded:Connect(function(room)
    print("New room detected:", room.Name)

    room.DescendantAdded:Connect(function(descendant)
        -- feature flag: noClip
        if getgenv().noClip == true then
            handleNoClipUniversal(descendant, false)
        end
        -- end feature flag: noClip
        -- feature flag: esp
        for name, config in pairs(espConfig) do
            if getgenv()[config.flag] == true then
                handleEsp(name, getgenv()[config.flag])
            end
        end
        -- end feature flag: esp
    end)

    -- feature flag: esp
    local generators = room:WaitForChild("Generators")
    generators.ChildAdded:Connect(function(generator)
        local stats = generator:FindFirstChild("Stats")
        local completed = stats and stats:FindFirstChild("Completed")
        local activePlayer  = stats and stats:FindFirstChild("ActivePlayer")

        completed.Changed:Connect(function()
            if not getgenv().espGenerator then return end
            handleEsp("Generators", getgenv().espGenerator)
        end)

        activePlayer.Changed:Connect(function()
            if not getgenv().espGenerator then return end
            handleEsp("Generators", getgenv().espGenerator)
        end)
    end)
    -- end feature flag: esp

    -- feature flag: distractMonster
    local monsters = room:WaitForChild("Monsters")
    local monsterList = { "None" }
    monsters.ChildAdded:Connect(function(monster)
        local monsterName = monster.Name
        if table.find(ignoreMonsters, monsterName) then return end
        monsterName = monsterName:gsub("Monster", "")
        monsterName = "Twisted " .. monsterName
        table.insert(monsterList, monsterName)
        print("Monster added:", monsterName)
        print("Current Monster List:", table.concat(monsterList, ", "))
        monsterDropdown:Refresh(monsterList)
    end)
    -- end feature flag: distractMonster
end)

-- feature flag: distractMonster
CurrentRoom.ChildRemoved:Connect(function()
    monsterDropdown:Set({"None"})
    monsterDropdown:Refresh({"None"})
end)
-- end feature flag: distractMonster

-- feature flag: esp
InGamePlayers.DescendantAdded:Connect(function()
    if getgenv().espPlayer == true then
        handleEsp("Player", getgenv().espPlayer)
    end
end)
-- end feature flag: esp

-- feature flag: itemsAura
Player.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if getgenv().itemsAura == true then
        for _, room in pairs(CurrentRoom:GetChildren()) do
            local Items = room:FindFirstChild("Items")
            for _, item in pairs(Items:GetChildren()) do
                local Prompt = item:FindFirstChild("Prompt")
                if Prompt then
                    local ProximityPrompt = Prompt:FindFirstChild("ProximityPrompt")
                    if ProximityPrompt and ProximityPrompt.Enabled then
                        local distance = (Prompt.Position - HumanoidRootPart.Position).Magnitude
                        if distance <= RANGE then
                            ProximityPrompt:InputHoldBegin()
                            if ProximityPrompt.HoldDuration > 0 then
                                task.wait(ProximityPrompt.HoldDuration)
                            end
                            ProximityPrompt:InputHoldEnd()
                        end
                    end
                end
            end
        end
    end
end)
-- end feature flag: itemsAura

-- feature flag: autoSkillCheck
local Menu = ScreenGui:FindFirstChild("Menu")
local SkillCheckFrame = Menu:FindFirstChild("SkillCheckFrame")
local Marker = SkillCheckFrame:FindFirstChild("Marker")
local GoldArea = SkillCheckFrame:FindFirstChild("GoldArea")
SkillCheckFrame.Changed:Connect(function(property)
    if not getgenv().autoSkillCheck then return end
    if property ~= "Visible" then return end
    if not SkillCheckFrame.Visible then return end
    if not Marker or not GoldArea then return end

    while SkillCheckFrame.Visible do
        local markerPosition = Marker.AbsolutePosition
        local goldAreaPosition = GoldArea.AbsolutePosition
        local goldAreaSize = GoldArea.AbsoluteSize

        if markerPosition.X >= goldAreaPosition.X and markerPosition.X <= (goldAreaPosition.X + goldAreaSize.X) + TOLERANCE then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        end

        task.wait(0.1)
    end
end)
-- end feature flag: autoSkillCheck
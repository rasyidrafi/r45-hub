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
    return tab:CreateToggle({
        Name = config.name,
        CurrentValue = config.default,
        Flag = config.flag,
        Callback = config.callback
    })
end
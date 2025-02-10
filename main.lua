local BASE_URL = "https://raw.githubusercontent.com/rasyidrafi/r45-hub/refs/heads/main/games/"

-- Configuration Tables -------
local GAME_CONFIG = {
    ["13864667823"] = {Title = "Break In 2", Code = "BI2"},
    ["14775231477"] = {Title = "Break In 2 - Lobby", Code = "BI2L"},
    ["13864661000"] = {Title = "Break In 2 - Lobby", Code = "BI2L"},
    ["16552821455"] = {Title = "Dandy's World", Code = "DW"}
}

-- Utility Functions ------------
local function Notify(Text)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "R45 Hub Notification",
		Text = Text,
		Duration = 6.5
	})
end

local function validateGame()
    local gameId = tostring(game.PlaceId)
    local gameData = GAME_CONFIG[gameId]
    
    if not gameData then
        Notify("This game is not supported by R45 Hub.")
        return false
    end
    
    return gameData
end

-- Game Handler ----------------
local gameData = validateGame()
if not gameData then return end
loadstring(game:HttpGet(BASE_URL .. gameData.Code .. ".lua"))()
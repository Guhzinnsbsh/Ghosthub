if game.CoreGui:FindFirstChild("GHOST_PASS_MENU") then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

-- Tela principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GHOST_PASS_MENU"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Blur
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 24
blur.Name = "GhostBlur"

-- Janela principal
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.2

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 16)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(148, 0, 211)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.1

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "GHOST DARK - Gamepasses"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.BackgroundTransparency = 1

-- Scrolling
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -60)
scroll.Position = UDim2.new(0, 5, 0, 55)
scroll.CanvasSize = UDim2.new(0, 0, 10, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

-- Deep Hook Universal
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if tostring(self):lower():match("userownsgamepassasync") and method == "InvokeServer" then
        return true
    end
    return oldNamecall(self, ...)
end)

-- Função para simular compra
local function forceOwn(gamepassId)
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local __namecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if tostring(self):lower():match("userownsgamepassasync") and method == "InvokeServer" then
            if args[2] == gamepassId then
                return true
            end
        end
        return __namecall(self, ...)
    end)
end

-- Função para criar botão
local function createButton(name, id)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (#scroll:GetChildren() * 45))
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        forceOwn(id)
        btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        btn.Text = name .. " [Ativado!]"
    end)
end

-- GET API Gamepasses por ID do jogo
local function getGamepasses()
    local placeId = game.PlaceId
    local success, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/game-passes")
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        for _, gpass in pairs(data.data or {}) do
            createButton(gpass.name or "Gamepass", gpass.id)
        end
    else
        local warnlbl = Instance.new("TextLabel", frame)
        warnlbl.Text = "Não foi possível carregar Gamepasses."
        warnlbl.Size = UDim2.new(1, 0, 0, 50)
        warnlbl.Position = UDim2.new(0, 0, 1, -50)
        warnlbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        warnlbl.BackgroundTransparency = 1
        warnlbl.Font = Enum.Font.GothamBold
        warnlbl.TextScaled = true
    end
end

getGamepasses()
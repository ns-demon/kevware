-- This is KevWare V2, coded by me (1.sm. on Discord). I spent a couple of months working on this project, adding features, fixing bugs, and improving it over time. I decided to make it open source so others can check it out, learn from it, and contribute if they want. Hope you enjoy it and have fun with the project.
--[[ features and description  KEVWARE is an open-source Roblox Lua utility script primarily focused on Da Hood-style games and copies such as Zel Hood, Des Hood, and Hood Modded. It features a customizable UI, ESP tools, movement options, configuration saving, multiple themes, trolling utilities, horror effects, and many customization options. Built with a modular design, KEVWARE is made for learning, experimenting, and community development. 

 Features Below! 



** 🎯 Combat / Aim Features





Camlock system



Custom prediction settings



Custom aim part selection (Head / UpperTorso)



Smoothness adjustment



Wall check support



Target selection based on closest player



Configurable aim settings

👁️ ESP Features





Player ESP



Boxes



Names



Distance display



Health display



Tracers



ESP update optimization system

🏃 Movement Features





Noclip



WalkSpeed changer



Infinite jump



Fly mode



Custom fly speed



Movement settings saved in config

📍 Teleport Features





Teleport to players



Player targeting system



Saved teleport references



Rejoin on death option



Join official game option

😈 Troll Features





Spin bot



Chat spam



Sound spam



Mass fling



Invisible mode



Giant mode



Rainbow mode



Float mode



Explosion effects



Throw players



Freeze players



Screen shake



Spam parts



Gravity changes



Flash effects



Clone spam



Lag effects



Slow motion



Random teleport



Camera effects



Speed boost



Effect spam

👻 Creepy / Horror Mode





Jump scares



Screen flashes



Ghost mode



Possession effects



Dark sky mode



Ghost spawning



Creepy sounds



Creepy messages



Color inversion



Shadow clones



Creepy music



Flickering lights



Randomized character parts



Possession all players mode

🎨 UI Features





Custom KEVWARE interface



Multiple themes:





Purple



Rainbow



Aurora



Neon



Ocean



Fire



Ice



Matrix



Custom theme



Adjustable:





Accent colors



Background colors



Transparency



Glow effects



Borders



Corner radius



Fonts

💾 Configuration System





Saves settings automatically



Loads previous configuration



JSON-based config storage



Custom theme persistence



Universal clipboard support



Universal file support for executors

⚙️ Extra Utilities





Performance optimizer



Notification system



Error protection with safe pcall wrappers



Customization panels



Command system support



Chat Spy support setting



Executor compatibility helpers **
]]

getgenv().Prediction = 0.094
getgenv().AimPart = "Head"

local CONFIG = {
    FILE_NAME = "kevware_config",
    OFFICIAL_GAME_ID = 111862645293891,
    ESP_UPDATE_INTERVAL = 0.025,
    NOTIFICATION_DURATION = 6,
    TELEPORT_UPDATE_INTERVAL = 0.70,
    FLING_UPDATE_INTERVAL = 0.70,
    COMMAND_PREFIX = ";"
}

local Settings = {
    Camlock = {
        Enabled = false,
        Smoothness = 2,
        WallCheck = false,
        Prediction = 0.094,
        AimPart = "Head"
    },
    Movement = {
        Noclip = false,
        WalkSpeed = {
            Enabled = false,
            Value = 16
        },
        InfiniteJump = false,
        Fly = {
            Enabled = false,
            Speed = 50
        }
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false
    },
    ChatSpy = false,
    RejoinOnDeath = false,
    JoinOfficialGame = false,
    Troll = {
        Enabled = false,
        SpinSpeed = 50,
        ChatSpamMessages = {"KEVWARE ON TOP", "GET FLOORED", "SKILL ISSUE", "L RATIO", "YOU GOT TROLLED"},
        ChatSpamDelay = 0.5,
        FlingPower = 100,
        ExplosionPower = 50,
        SoundVolume = 10,
        SpamRate = 0.3
    },
    Creepy = {
        Enabled = false,
        FlingDuration = 10,
        JumpScareEnabled = false,
        ScreenFlashEnabled = false,
        GhostModeEnabled = false,
        PossessionEnabled = false,
        DarkSkyEnabled = false,
        GhostsEnabled = false,
        CreepySoundsEnabled = false,
        TeleportAllEnabled = false,
        CreepyTextEnabled = false,
        InvertColorsEnabled = false,
        ShadowCloneEnabled = false,
        CreepyMusicEnabled = false,
        FlickerLightsEnabled = false,
        RandomizePartsEnabled = false,
        PossessionAllEnabled = false
    },
    UI = {
        Theme = "Purple",
        AccentColor = Color3.fromRGB(150, 0, 255),
        BackgroundColor = Color3.fromRGB(16, 16, 18),
        TextColor = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        GlowEffect = true,
        BorderThickness = 2,
        CornerRadius = 12,
        Font = "Gotham"
    },
    Commands = {
        Prefix = ";",
        Enabled = true
    }
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local State = {
    Victim = nil,
    Locked = false,
    EspCache = {},
    CharacterParts = {},
    IsFlying = false,
    MenuVisible = true,
    RejoinCooldown = false,
    TeleportPageRef = nil,
    FlingPageRef = nil,
    ChatMessages = {},
    ChatWindowVisible = false,
    ChatSpyWindow = nil,
    MessageContainer = nil,
    AddChatMessage = nil,
    OriginalPosition = nil,
    IsFlinging = false,
    IsTrolling = false,
    TrollThreads = {},
    SpinSpeed = 50,
    CurrentAngle = 0,
    CurrentTheme = "Purple",
    UIReferences = {},
    CustomizingFeature = nil,
    FlingingTarget = nil,
    Commands = {},
    IsMenuLoaded = false,
    CreepyActive = false,
    GhostParts = {},
    IsUserScrolling = false,
    CreepyThreads = {}
}

local function safePCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[KEVWARE] Error: " .. tostring(result))
        return nil
    end
    return result
end

local function universalClipboard(text)
    if type(setclipboard) == "function" then
        return safePCall(setclipboard, text)
    elseif type(toclipboard) == "function" then
        return safePCall(toclipboard, text)
    end
    return false
end

local function universalWriteFile(name, data)
    if type(writefile) == "function" then
        return safePCall(writefile, name, data)
    end
    return false
end

local function universalReadFile(name)
    if type(readfile) == "function" and type(isfile) == "function" and isfile(name) then
        return safePCall(readfile, name)
    end
    return nil
end

local function mergeTables(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            mergeTables(target[k], v)
        else
            target[k] = v
        end
    end
end

local function saveConfiguration()
    if not (type(writefile) == "function") then return end
    local encoded = HttpService:JSONEncode(Settings)
    universalWriteFile(CONFIG.FILE_NAME, encoded)
end

local function loadConfiguration()
    if not (type(readfile) == "function" and type(isfile) == "function") then return end
    local data = universalReadFile(CONFIG.FILE_NAME)
    if data then
        safePCall(function()
            local decoded = HttpService:JSONDecode(data)
            if type(decoded) == "table" then
                mergeTables(Settings, decoded)
            end
        end)
    end
end

loadConfiguration()

local Themes = {
    Purple = {
        Primary = Color3.fromRGB(150, 0, 255),
        Secondary = Color3.fromRGB(100, 0, 200),
        Background = Color3.fromRGB(16, 16, 18),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(200, 100, 255),
        Glow = Color3.fromRGB(150, 0, 255),
        DarkBg = Color3.fromRGB(22, 22, 28)
    },
    Rainbow = {
        Primary = Color3.fromRGB(255, 0, 0),
        Secondary = Color3.fromRGB(0, 255, 0),
        Background = Color3.fromRGB(10, 10, 12),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 255, 0),
        Glow = Color3.fromRGB(255, 0, 255),
        DarkBg = Color3.fromRGB(18, 10, 18)
    },
    Aurora = {
        Primary = Color3.fromRGB(0, 255, 200),
        Secondary = Color3.fromRGB(100, 200, 255),
        Background = Color3.fromRGB(5, 10, 20),
        Text = Color3.fromRGB(200, 255, 255),
        Accent = Color3.fromRGB(0, 255, 150),
        Glow = Color3.fromRGB(0, 200, 255),
        DarkBg = Color3.fromRGB(8, 15, 25)
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 100),
        Secondary = Color3.fromRGB(0, 200, 255),
        Background = Color3.fromRGB(8, 8, 12),
        Text = Color3.fromRGB(0, 255, 200),
        Accent = Color3.fromRGB(255, 0, 200),
        Glow = Color3.fromRGB(0, 255, 100),
        DarkBg = Color3.fromRGB(12, 8, 16)
    },
    Ocean = {
        Primary = Color3.fromRGB(0, 100, 255),
        Secondary = Color3.fromRGB(0, 200, 255),
        Background = Color3.fromRGB(5, 10, 25),
        Text = Color3.fromRGB(100, 200, 255),
        Accent = Color3.fromRGB(0, 255, 200),
        Glow = Color3.fromRGB(0, 100, 255),
        DarkBg = Color3.fromRGB(8, 12, 30)
    },
    Fire = {
        Primary = Color3.fromRGB(255, 100, 0),
        Secondary = Color3.fromRGB(255, 50, 0),
        Background = Color3.fromRGB(20, 8, 5),
        Text = Color3.fromRGB(255, 200, 100),
        Accent = Color3.fromRGB(255, 200, 0),
        Glow = Color3.fromRGB(255, 100, 0),
        DarkBg = Color3.fromRGB(28, 10, 6)
    },
    Ice = {
        Primary = Color3.fromRGB(150, 255, 255),
        Secondary = Color3.fromRGB(100, 200, 255),
        Background = Color3.fromRGB(10, 15, 25),
        Text = Color3.fromRGB(200, 255, 255),
        Accent = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(150, 255, 255),
        DarkBg = Color3.fromRGB(12, 18, 30)
    },
    Matrix = {
        Primary = Color3.fromRGB(0, 255, 0),
        Secondary = Color3.fromRGB(0, 200, 0),
        Background = Color3.fromRGB(5, 8, 5),
        Text = Color3.fromRGB(0, 255, 100),
        Accent = Color3.fromRGB(0, 255, 200),
        Glow = Color3.fromRGB(0, 255, 0),
        DarkBg = Color3.fromRGB(8, 12, 8)
    },
    Custom = {
        Primary = Settings.UI.AccentColor or Color3.fromRGB(150, 0, 255),
        Secondary = Settings.UI.AccentColor or Color3.fromRGB(100, 0, 200),
        Background = Settings.UI.BackgroundColor or Color3.fromRGB(16, 16, 18),
        Text = Settings.UI.TextColor or Color3.fromRGB(255, 255, 255),
        Accent = Settings.UI.AccentColor or Color3.fromRGB(200, 100, 255),
        Glow = Settings.UI.AccentColor or Color3.fromRGB(150, 0, 255),
        DarkBg = Settings.UI.BackgroundColor or Color3.fromRGB(22, 22, 28)
    }
}

local function applyTheme(themeName)
    local theme = Themes[themeName] or Themes.Purple
    Settings.UI.Theme = themeName
    Settings.UI.AccentColor = theme.Primary
    Settings.UI.BackgroundColor = theme.Background
    Settings.UI.TextColor = theme.Text
    saveConfiguration()
    updateUI()
    showNotification("Theme", "Applied " .. themeName .. " theme!")
end

local function updateUI()
    safePCall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        local mainGui = playerGui:FindFirstChild("kevware_Replica")
        if not mainGui then return end
        local theme = Themes[Settings.UI.Theme] or Themes.Purple
        for _, obj in ipairs(mainGui:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                if obj.Name ~= "Title" and obj.Name ~= "TitleBar" and obj.Name ~= "MessageContainer" then
                    if obj:FindFirstChild("UIStroke") then
                        obj.UIStroke.Color = theme.Primary
                        obj.UIStroke.Thickness = Settings.UI.BorderThickness or 2
                    end
                    if obj:IsA("Frame") and obj.BackgroundColor3 then
                        if obj.Name ~= "ChatSpyWindow" and obj.Name ~= "CustomizationPanel" then
                            obj.BackgroundColor3 = theme.DarkBg or theme.Background
                            obj.BackgroundTransparency = Settings.UI.Transparency or 0
                        end
                    end
                    if obj:FindFirstChild("UICorner") then
                        obj.UICorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 12)
                    end
                end
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if obj.Name ~= "Title" and obj.Name ~= "TitleLabel" then
                    if obj.TextColor3 then
                        if obj.Text:match("KEVWARE") or obj.Text:match("Theme") then
                            obj.TextColor3 = theme.Primary
                        else
                            obj.TextColor3 = theme.Text
                        end
                    end
                    if obj.Font then
                        local fontMap = {
                            Gotham = Enum.Font.Gotham,
                            SourceSans = Enum.Font.SourceSans,
                            SourceSansBold = Enum.Font.SourceSansBold,
                            Arial = Enum.Font.Arial,
                            Roboto = Enum.Font.Roboto
                        }
                        obj.Font = fontMap[Settings.UI.Font] or Enum.Font.Gotham
                    end
                end
            end
        end
        local mainFrame = mainGui:FindFirstChildWhichIsA("Frame")
        if mainFrame and mainFrame:FindFirstChild("UIStroke") then
            mainFrame.UIStroke.Color = theme.Primary
            mainFrame.UIStroke.Thickness = Settings.UI.BorderThickness or 2
        end
        if mainFrame and mainFrame:FindFirstChild("UICorner") then
            mainFrame.UICorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 12)
        end
        if Settings.UI.GlowEffect then
            local glow = mainFrame:FindFirstChild("Glow")
            if glow then
                glow.BackgroundColor3 = theme.Primary
                glow.BackgroundTransparency = 0.75
            end
        end
    end)
end

local function showNotification(title, content, duration)
    duration = duration or CONFIG.NOTIFICATION_DURATION
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local mainGui = playerGui:FindFirstChild("kevware_Replica")
    if not mainGui then return end
    local theme = Themes[Settings.UI.Theme] or Themes.Purple
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 320, 0, 70)
    notifFrame.Position = UDim2.new(1, -340, 0, 10)
    notifFrame.BackgroundColor3 = theme.DarkBg or theme.Background
    notifFrame.BackgroundTransparency = 0
    notifFrame.Parent = mainGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
    corner.Parent = notifFrame
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1.5
    stroke.Parent = notifFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 22)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.TextColor3 = theme.Primary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Text = content
    contentLabel.Size = UDim2.new(1, -20, 0, 35)
    contentLabel.Position = UDim2.new(0, 10, 0, 28)
    contentLabel.TextColor3 = theme.Text
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextSize = 13
    contentLabel.BackgroundTransparency = 1
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notifFrame
    notifFrame.Position = UDim2.new(1, 0, 0, 10)
    local tween = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, -340, 0, 10)
    })
    tween:Play()
    Debris:AddItem(notifFrame, duration + 0.5)
end

local function boostPerformance()
    safePCall(function()
        local ignored = workspace:FindFirstChild("Ignored")
        if ignored then
            local toDestroy = {"PoliceSpawn", "SecurityCameraVideo", "SecurityCamera", "MovieProjector"}
            for _, name in ipairs(toDestroy) do
                local obj = ignored:FindFirstChild(name)
                if obj then obj:Destroy() end
            end
        end
        if settings and settings().Rendering then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        showNotification("Performance", "Optimizations applied!")
    end)
end

local function isTargetVisible(targetPart)
    if not Settings.Camlock.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.IgnoreWater = true
    return not workspace:Raycast(origin, direction, params)
end

local function getClosestTarget()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer
    local shortestDistance = math.huge
    local aimPartName = Settings.Camlock.AimPart or "Head"
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        local character = player.Character
        if not character then
            continue
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            continue
        end
        local aimPart = character:FindFirstChild(aimPartName)
        if not aimPart then 
            aimPart = character:FindFirstChild("HumanoidRootPart")
            if not aimPart then
                continue
            end
        end
        if not isTargetVisible(aimPart) then
            continue
        end
        local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then
            continue
        end
        local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
        if magnitude < shortestDistance then
            closestPlayer = player
            shortestDistance = magnitude
        end
    end
    return closestPlayer
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer then
        showNotification("Error", "No target selected!")
        return false
    end
    local myChar = LocalPlayer.Character
    if not myChar then
        showNotification("Error", "Your character not found!")
        return false
    end
    local targetChar = targetPlayer.Character
    if not targetChar then
        showNotification("Error", "Target player not in game!")
        return false
    end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then
        showNotification("Error", "Could not find root parts!")
        return false
    end
    local targetPos = targetRoot.Position
    local success = safePCall(function()
        local offset = Vector3.new(math.random(-3, 3), 5, math.random(-3, 3))
        myRoot.CFrame = CFrame.new(targetPos + offset)
        return true
    end)
    if success then
        showNotification("Teleport", "Teleported to " .. targetPlayer.Name .. "!")
        return true
    else
        showNotification("Error", "Teleport failed!")
        return false
    end
end

-- FIXED FLING - Spams teleport and spins super fast
local function flingPlayer(targetPlayer)
    if State.IsFlinging then
        showNotification("Fling", "Already flinging someone!")
        return
    end
    if not targetPlayer or not targetPlayer.Character then
        showNotification("Fling", "Target player not found!")
        return
    end
    local myChar = LocalPlayer.Character
    if not myChar then
        showNotification("Fling", "Your character not found!")
        return
    end
    local targetChar = targetPlayer.Character
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not targetRoot or not targetHumanoid then
        showNotification("Fling", "Invalid target!")
        return
    end
    
    State.OriginalPosition = myRoot.CFrame
    State.IsFlinging = true
    State.FlingingTarget = targetPlayer
    
    showNotification("Fling", "Flinging " .. targetPlayer.Name .. " for 10 seconds!")
    
    local flingPower = Settings.Troll.FlingPower or 100
    local duration = Settings.Creepy.FlingDuration or 10
    
    safePCall(function()
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    local thread = task.spawn(function()
        local startTime = tick()
        local angle = 0
        
        while tick() - startTime < duration do
            if not myRoot.Parent or not targetRoot.Parent then
                break
            end
            
            -- Super fast spinning
            angle = angle + math.rad(flingPower * 5)
            
            -- Rapid teleport to target with offset
            local radius = 2 + math.sin(tick() * 10) * 1.5
            local offset = Vector3.new(
                math.cos(angle) * radius,
                math.sin(tick() * 12) * 4 + 2,
                math.sin(angle) * radius
            )
            
            -- Teleport my character to target position with offset
            myRoot.CFrame = CFrame.new(targetRoot.Position + offset)
            
            -- Extreme angular velocity for spinning
            myRoot.AssemblyAngularVelocity = Vector3.new(
                flingPower * 1000,
                flingPower * 1000,
                flingPower * 1000
            )
            
            -- High linear velocity
            myRoot.AssemblyLinearVelocity = Vector3.new(
                math.random(-flingPower * 10, flingPower * 10),
                math.random(flingPower * 5, flingPower * 20),
                math.random(-flingPower * 10, flingPower * 10)
            )
            
            -- Also apply force to target
            targetRoot.AssemblyAngularVelocity = Vector3.new(
                math.random(-flingPower * 500, flingPower * 500),
                math.random(-flingPower * 500, flingPower * 500),
                math.random(-flingPower * 500, flingPower * 500)
            )
            
            targetRoot.AssemblyLinearVelocity = Vector3.new(
                math.random(-flingPower * 15, flingPower * 15),
                math.random(flingPower * 10, flingPower * 30),
                math.random(-flingPower * 15, flingPower * 15)
            )
            
            -- Fling all body parts
            for _, part in ipairs(targetChar:GetChildren()) do
                if part:IsA("BasePart") and part ~= targetRoot then
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-flingPower * 5, flingPower * 5),
                        math.random(flingPower * 3, flingPower * 12),
                        math.random(-flingPower * 5, flingPower * 5)
                    )
                end
            end
            
            task.wait(0.016)
        end
        
        -- Final massive burst
        if targetRoot and targetRoot.Parent then
            targetRoot.AssemblyAngularVelocity = Vector3.new(
                flingPower * 2000,
                flingPower * 2000,
                flingPower * 2000
            )
            targetRoot.AssemblyLinearVelocity = Vector3.new(
                math.random(-flingPower * 30, flingPower * 30),
                math.random(flingPower * 25, flingPower * 50),
                math.random(-flingPower * 30, flingPower * 30)
            )
            targetHumanoid.PlatformStand = true
            task.wait(0.2)
            targetHumanoid.PlatformStand = false
        end
    end)
    
    table.insert(State.TrollThreads, thread)
    
    task.wait(duration + 0.5)
    
    safePCall(function()
        if State.OriginalPosition and myRoot and myRoot.Parent then
            myRoot.AssemblyAngularVelocity = Vector3.zero
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.CFrame = State.OriginalPosition
        end
    end)
    
    safePCall(function()
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)
    
    State.IsFlinging = false
    State.OriginalPosition = nil
    State.FlingingTarget = nil
    
    showNotification("Fling", "Fling complete! Returned to original position!")
end

local function spinBot(speed)
    speed = speed or State.SpinSpeed or 50
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local originalCFrame = root.CFrame
    local angle = State.CurrentAngle or 0
    
    local thread = task.spawn(function()
        while State.IsTrolling do
            if root and root.Parent then
                angle = angle + math.rad(speed)
                State.CurrentAngle = angle
                
                root.CFrame = CFrame.new(originalCFrame.Position) * CFrame.Angles(0, angle, 0)
                
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        local partCF = part.CFrame
                        local offset = partCF - root.CFrame
                        local newPos = root.CFrame * (root.CFrame:Inverse() * partCF)
                        part.CFrame = CFrame.new(newPos.Position) * CFrame.Angles(0, angle, 0)
                    end
                end
            end
            task.wait(0.016)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

local function stopTrollThreads()
    for _, thread in ipairs(State.TrollThreads) do
        if thread then
            task.cancel(thread)
        end
    end
    State.TrollThreads = {}
    State.CurrentAngle = 0
end

local function stopCreepyThreads()
    for _, thread in ipairs(State.CreepyThreads) do
        if thread then
            task.cancel(thread)
        end
    end
    State.CreepyThreads = {}
end

local function getRandomTarget()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(targets, player)
        end
    end
    return targets[math.random(1, #targets)]
end

-- CREEPY FEATURES WITH TOGGLES
local CreepyFeatures = {}

function CreepyFeatures.JumpScare(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        showNotification("Creepy", "Target not found!")
        return
    end
    safePCall(function()
        local targetChar = targetPlayer.Character
        local targetHead = targetChar:FindFirstChild("Head")
        if targetHead then
            local face = Instance.new("BillboardGui")
            face.Size = UDim2.new(0, 200, 0, 200)
            face.Adornee = targetHead
            face.Parent = targetHead
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            frame.BackgroundTransparency = 0.2
            frame.Parent = face
            local scaryText = Instance.new("TextLabel")
            scaryText.Size = UDim2.new(1, 0, 1, 0)
            scaryText.Text = "BOO!"
            scaryText.TextColor3 = Color3.fromRGB(255, 255, 255)
            scaryText.Font = Enum.Font.GothamBold
            scaryText.TextSize = 72
            scaryText.BackgroundTransparency = 1
            scaryText.Parent = frame
            Debris:AddItem(face, 2)
            local flash = Instance.new("Frame")
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            flash.BackgroundTransparency = 0.5
            flash.Parent = targetPlayer.PlayerGui
            Debris:AddItem(flash, 0.5)
        end
    end)
end

function CreepyFeatures.ScreenFlash()
    safePCall(function()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flash.BackgroundTransparency = 0.7
        flash.Parent = LocalPlayer.PlayerGui
        local tween = TweenService:Create(flash, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
            BackgroundTransparency = 0
        })
        tween:Play()
        tween.Completed:Wait()
        local tween2 = TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
            BackgroundTransparency = 1
        })
        tween2:Play()
        tween2.Completed:Wait()
        flash:Destroy()
    end)
end

function CreepyFeatures.GhostMode()
    safePCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.6
                part.Color = Color3.fromRGB(150, 200, 255)
                part.Material = Enum.Material.Neon
            end
        end
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Color = ColorSequence.new(Color3.fromRGB(150, 200, 255))
        emitter.Rate = 50
        emitter.Lifetime = NumberRange.new(1, 2)
        emitter.SpreadAngle = Vector2.new(360, 360)
        emitter.VelocityInheritance = 0.1
        emitter.Parent = char:FindFirstChild("HumanoidRootPart") or char
        Debris:AddItem(emitter, 5)
    end)
end

function CreepyFeatures.Possession(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        return
    end
    safePCall(function()
        local targetChar = targetPlayer.Character
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            local root = targetChar:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyAngularVelocity = Vector3.new(1000, 1000, 1000)
                root.AssemblyLinearVelocity = Vector3.new(
                    math.random(-200, 200),
                    math.random(100, 300),
                    math.random(-200, 200)
                )
            end
            for i = 1, 10 do
                targetHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.2)
            end
        end
    end)
end

function CreepyFeatures.DarkenSky()
    safePCall(function()
        local originalBrightness = Lighting.Brightness
        local originalAmbient = Lighting.OutdoorAmbient
        Lighting.Brightness = 0.1
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20)
        task.wait(3)
        Lighting.Brightness = originalBrightness
        Lighting.OutdoorAmbient = originalAmbient
    end)
end

function CreepyFeatures.SpawnGhosts()
    safePCall(function()
        for i = 1, 5 do
            local ghost = Instance.new("Part")
            ghost.Size = Vector3.new(2, 6, 1)
            ghost.Position = Vector3.new(
                math.random(-50, 50),
                math.random(5, 20),
                math.random(-50, 50)
            )
            ghost.Color = Color3.fromRGB(200, 220, 255)
            ghost.Material = Enum.Material.Neon
            ghost.Transparency = 0.5
            ghost.Anchored = true
            ghost.CanCollide = false
            ghost.Parent = workspace
            local shape = Instance.new("SpecialMesh")
            shape.MeshType = Enum.MeshType.Head
            shape.Parent = ghost
            task.spawn(function()
                local startY = ghost.Position.Y
                for j = 1, 30 do
                    ghost.Position = Vector3.new(
                        ghost.Position.X,
                        startY + math.sin(j * 0.1) * 2,
                        ghost.Position.Z
                    )
                    ghost.Transparency = 0.3 + math.sin(j * 0.05) * 0.2
                    task.wait(0.1)
                end
                ghost:Destroy()
            end)
            Debris:AddItem(ghost, 5)
            task.wait(0.5)
        end
    end)
end

function CreepyFeatures.CreepySounds()
    safePCall(function()
        local sounds = {
            "rbxassetid://9113083740",
            "rbxassetid://9124373969",
            "rbxassetid://9124373980",
            "rbxassetid://9113083750"
        }
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local sound = Instance.new("Sound")
                sound.SoundId = sounds[math.random(1, #sounds)]
                sound.Volume = 5
                sound.Parent = player.Character
                sound:Play()
                Debris:AddItem(sound, 3)
            end
        end
    end)
end

function CreepyFeatures.TeleportRandomAll()
    safePCall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(
                        math.random(-500, 500),
                        math.random(10, 100),
                        math.random(-500, 500)
                    )
                end
            end
        end
    end)
end

function CreepyFeatures.CreepyText()
    safePCall(function()
        local texts = {
            "I see you...",
            "Behind you...",
            "You are not alone...",
            "They are watching...",
            "Do you feel it?",
            "The darkness is coming...",
            "There is something in the shadows..."
        }
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local msg = texts[math.random(1, #texts)]
                if TextChatService.ChatInputBarConfiguration then
                    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if channel then
                        channel:SendAsync(msg)
                    end
                end
            end
        end
    end)
end

function CreepyFeatures.InvertColors()
    safePCall(function()
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then
            cc = Instance.new("ColorCorrection")
            cc.Parent = Lighting
        end
        cc.Saturation = -1
        cc.Contrast = 1
        cc.Brightness = 0.5
        task.wait(5)
        cc.Saturation = 0
        cc.Contrast = 0
        cc.Brightness = 0
    end)
end

function CreepyFeatures.ShadowClone()
    safePCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local clone = char:Clone()
        clone.Name = "ShadowClone_" .. tostring(os.time())
        clone.Parent = workspace
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.fromRGB(0, 0, 0)
                part.Transparency = 0.5
                part.Material = Enum.Material.Neon
            end
        end
        Debris:AddItem(clone, 5)
    end)
end

function CreepyFeatures.CreepyMusic()
    safePCall(function()
        local music = Instance.new("Sound")
        music.SoundId = "rbxassetid://1847843540"
        music.Volume = 3
        music.Looped = true
        music.Parent = workspace
        music:Play()
        task.wait(10)
        music:Stop()
        music:Destroy()
    end)
end

function CreepyFeatures.FlickerLights()
    safePCall(function()
        for i = 1, 10 do
            Lighting.Brightness = math.random(0, 2)
            task.wait(0.1)
        end
        Lighting.Brightness = 1
    end)
end

function CreepyFeatures.RandomizeParts()
    safePCall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = Vector3.new(
                            math.random(1, 5),
                            math.random(1, 5),
                            math.random(1, 5)
                        )
                        part.Color = Color3.fromHSV(math.random(), 1, 1)
                    end
                end
            end
        end
    end)
end

function CreepyFeatures.PossessionAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            task.spawn(function()
                CreepyFeatures.Possession(player)
            end)
            task.wait(0.3)
        end
    end
end

-- Creepy Toggle Functions
local function toggleCreepyFeature(feature, enabled)
    Settings.Creepy[feature] = enabled
    saveConfiguration()
    
    if enabled then
        local thread = task.spawn(function()
            while Settings.Creepy[feature] do
                if feature == "JumpScareEnabled" then
                    local target = getRandomTarget()
                    if target then
                        CreepyFeatures.JumpScare(target)
                    end
                    task.wait(3)
                elseif feature == "ScreenFlashEnabled" then
                    CreepyFeatures.ScreenFlash()
                    task.wait(2)
                elseif feature == "GhostModeEnabled" then
                    CreepyFeatures.GhostMode()
                    task.wait(5)
                elseif feature == "PossessionEnabled" then
                    local target = getRandomTarget()
                    if target then
                        CreepyFeatures.Possession(target)
                    end
                    task.wait(3)
                elseif feature == "DarkSkyEnabled" then
                    CreepyFeatures.DarkenSky()
                    task.wait(3)
                elseif feature == "GhostsEnabled" then
                    CreepyFeatures.SpawnGhosts()
                    task.wait(5)
                elseif feature == "CreepySoundsEnabled" then
                    CreepyFeatures.CreepySounds()
                    task.wait(3)
                elseif feature == "TeleportAllEnabled" then
                    CreepyFeatures.TeleportRandomAll()
                    task.wait(3)
                elseif feature == "CreepyTextEnabled" then
                    CreepyFeatures.CreepyText()
                    task.wait(3)
                elseif feature == "InvertColorsEnabled" then
                    CreepyFeatures.InvertColors()
                    task.wait(5)
                elseif feature == "ShadowCloneEnabled" then
                    CreepyFeatures.ShadowClone()
                    task.wait(5)
                elseif feature == "CreepyMusicEnabled" then
                    CreepyFeatures.CreepyMusic()
                    task.wait(10)
                elseif feature == "FlickerLightsEnabled" then
                    CreepyFeatures.FlickerLights()
                    task.wait(3)
                elseif feature == "RandomizePartsEnabled" then
                    CreepyFeatures.RandomizeParts()
                    task.wait(5)
                elseif feature == "PossessionAllEnabled" then
                    CreepyFeatures.PossessionAll()
                    task.wait(5)
                end
                task.wait(1)
            end
        end)
        table.insert(State.CreepyThreads, thread)
    else
        stopCreepyThreads()
    end
end

local function createCustomizationUI(featureName, currentValue, callback, options)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end
    local mainGui = playerGui:FindFirstChild("kevware_Replica")
    if not mainGui then
        return
    end
    local existing = mainGui:FindFirstChild("CustomizationPanel")
    if existing then
        existing:Destroy()
    end
    local theme = Themes[Settings.UI.Theme] or Themes.Purple
    local panel = Instance.new("Frame")
    panel.Name = "CustomizationPanel"
    panel.Size = UDim2.new(0, 300, 0, 200)
    panel.Position = UDim2.new(0.5, -150, 0.5, -100)
    panel.BackgroundColor3 = theme.DarkBg or theme.Background
    panel.BackgroundTransparency = 0
    panel.Parent = mainGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 12)
    corner.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Primary
    stroke.Thickness = Settings.UI.BorderThickness or 2
    stroke.Parent = panel
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.Text = "Customize: " .. featureName
    title.TextColor3 = theme.Primary
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18
    closeBtn.Parent = panel
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
    end)
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -20, 0, 25)
    valueLabel.Position = UDim2.new(0, 10, 0, 40)
    valueLabel.Text = "Current: " .. tostring(currentValue)
    valueLabel.TextColor3 = theme.Text
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 14
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = panel
    if options and type(options) == "table" then
        local yPos = 70
        for _, option in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.8, 0, 0, 30)
            btn.Position = UDim2.new(0.1, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            btn.Text = tostring(option)
            btn.TextColor3 = theme.Text
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.Parent = panel
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
            btnCorner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                callback(option)
                valueLabel.Text = "Current: " .. tostring(option)
                showNotification(featureName, "Set to: " .. tostring(option))
                panel:Destroy()
            end)
            yPos = yPos + 35
        end
    else
        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0.8, 0, 0, 10)
        slider.Position = UDim2.new(0.1, 0, 0, 80)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        slider.Text = ""
        slider.Parent = panel
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
        sliderCorner.Parent = slider
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(currentValue / 100, 0, 1, 0)
        fill.BackgroundColor3 = theme.Primary
        fill.Parent = slider
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
        fillCorner.Parent = fill
        local dragging = false
        local currentVal = currentValue
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                currentVal = math.floor(pos * 100)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = "Current: " .. tostring(currentVal)
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                callback(currentVal)
                valueLabel.Text = "Current: " .. tostring(currentVal)
                showNotification(featureName, "Set to: " .. tostring(currentVal))
                panel:Destroy()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                currentVal = math.floor(pos * 100)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = "Current: " .. tostring(currentVal)
            end
        end)
    end
end

local TrollFeatures = {}

function TrollFeatures.SpinBot(speed)
    speed = speed or State.SpinSpeed or 50
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    spinBot(speed)
    showNotification("Troll", "Spin bot activated!")
end

function TrollFeatures.SpamChat()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local messages = Settings.Troll.ChatSpamMessages or {"KEVWARE ON TOP", "GET FLOORED"}
    local delay = Settings.Troll.ChatSpamDelay or 0.5
    createCustomizationUI("Chat Spam Delay", delay * 10, function(val)
        Settings.Troll.ChatSpamDelay = val / 10
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        while State.IsTrolling do
            local msg = messages[math.random(1, #messages)]
            safePCall(function()
                if TextChatService.ChatInputBarConfiguration then
                    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if channel then
                        channel:SendAsync(msg)
                    end
                end
            end)
            task.wait(delay)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SoundSpam()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local volume = Settings.Troll.SoundVolume or 10
    createCustomizationUI("Sound Volume", volume, function(val)
        Settings.Troll.SoundVolume = val
        saveConfiguration()
    end)
    local sounds = {
        "rbxassetid://9113083740",
        "rbxassetid://9113083750",
        "rbxassetid://9113083760",
        "rbxassetid://9124373969",
        "rbxassetid://9124373980"
    }
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = sounds[math.random(1, #sounds)]
                sound.Volume = volume
                sound.Parent = workspace
                sound:Play()
                Debris:AddItem(sound, 5)
            end)
            task.wait(0.3)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.MassFling()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    createCustomizationUI("Fling Power", Settings.Troll.FlingPower, function(val)
        Settings.Troll.FlingPower = val
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                task.spawn(function()
                    flingPlayer(player)
                end)
                task.wait(0.3)
            end
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.InvisibleMode()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.GiantMode()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Size = part.Size * 1.01
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.RainbowMode()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        local hue = 0
        while State.IsTrolling do
            hue = (hue + 0.01) % 1
            safePCall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.FloatMode()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.ExplodePlayers()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local power = Settings.Troll.ExplosionPower or 50
    createCustomizationUI("Explosion Power", power, function(val)
        Settings.Troll.ExplosionPower = val
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.AssemblyLinearVelocity = Vector3.new(
                                math.random(-power * 10, power * 10),
                                math.random(power * 4, power * 12),
                                math.random(-power * 10, power * 10)
                            )
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.ThrowPlayers()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local power = Settings.Troll.FlingPower or 100
    createCustomizationUI("Throw Power", power, function(val)
        Settings.Troll.FlingPower = val
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.AssemblyLinearVelocity = Vector3.new(
                                math.random(-power * 2, power * 2),
                                math.random(power, power * 3),
                                math.random(-power * 2, power * 2)
                            )
                        end
                    end)
                end
            end
            task.wait(0.3)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SpinOthers()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local speed = State.SpinSpeed or 50
    createCustomizationUI("Spin Speed", speed, function(val)
        State.SpinSpeed = val
        Settings.Troll.SpinSpeed = val
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        local angle = 0
        while State.IsTrolling do
            angle = angle + math.rad(speed)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, angle, 0)
                        end
                    end)
                end
            end
            task.wait(0.016)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.WallhackESP()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local char = player.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 0.3
                                    part.Color = Color3.fromRGB(255, 0, 255)
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.KillAll()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                safePCall(function()
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                end)
                task.wait(0.5)
            end
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.FreezePlayers()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.ScreenShake()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local shake = math.random(1, 5)
                Camera.CFrame = Camera.CFrame + Vector3.new(
                    math.random(-shake, shake),
                    math.random(-shake, shake),
                    math.random(-shake, shake)
                )
            end)
            task.wait(0.05)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SpamParts()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local parts = {"Block", "Sphere", "Cylinder", "Wedge"}
    createCustomizationUI("Part Spam Rate", Settings.Troll.SpamRate * 10, function(val)
        Settings.Troll.SpamRate = val / 10
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local part = Instance.new(parts[math.random(1, #parts)])
                part.Size = Vector3.new(5, 5, 5)
                part.Position = Vector3.new(
                    math.random(-100, 100),
                    math.random(10, 50),
                    math.random(-100, 100)
                )
                part.Anchored = true
                part.BrickColor = BrickColor.Random()
                part.Parent = workspace
                Debris:AddItem(part, 5)
            end)
            task.wait(Settings.Troll.SpamRate or 0.3)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.InvertGravity()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            workspace.Gravity = -workspace.Gravity
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.Flashbang()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            Lighting.Brightness = 5
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            task.wait(0.1)
            Lighting.Brightness = 1
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.StrobeLights()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                Lighting.ColorCorrection.Brightness = math.random(0, 2)
                Lighting.ColorCorrection.Contrast = math.random(0, 2)
            end)
            task.wait(0.05)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.CloneYourself()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    createCustomizationUI("Clone Spam Rate", Settings.Troll.SpamRate * 10, function(val)
        Settings.Troll.SpamRate = val / 10
        saveConfiguration()
    end)
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local char = LocalPlayer.Character
                if char then
                    local clone = char:Clone()
                    clone.Parent = workspace
                    clone.Name = "Clone_" .. tostring(os.time())
                    Debris:AddItem(clone, 3)
                end
            end)
            task.wait(Settings.Troll.SpamRate or 0.3)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.LagMachine()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                for i = 1, 10 do
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(1, 1, 1)
                    part.Position = Vector3.new(
                        math.random(-100, 100),
                        math.random(0, 50),
                        math.random(-100, 100)
                    )
                    part.Anchored = true
                    part.Material = Enum.Material.Neon
                    part.BrickColor = BrickColor.Random()
                    part.Parent = workspace
                    Debris:AddItem(part, 2)
                end
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.RainbowLightning()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local lightning = Instance.new("Part")
                lightning.Size = Vector3.new(1, 50, 1)
                lightning.Position = Vector3.new(
                    math.random(-100, 100),
                    25,
                    math.random(-100, 100)
                )
                lightning.Anchored = true
                lightning.Material = Enum.Material.Neon
                lightning.Color = Color3.fromHSV(math.random(), 1, 1)
                lightning.Parent = workspace
                Debris:AddItem(lightning, 1)
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SlowMotion()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.WalkSpeed = 5
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.EveryoneDance()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.Sit = true
                            task.wait(0.1)
                            humanoid.Sit = false
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.FloorPlayers()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(root.Position.X, 0, root.Position.Z)
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SpamTools()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local tools = {"Sword", "Gun", "Rocket", "Firework"}
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local tool = Instance.new("Tool")
                tool.Name = tools[math.random(1, #tools)]
                tool.Parent = LocalPlayer.Backpack
                Debris:AddItem(tool, 3)
            end)
            task.wait(0.2)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.VoiceSpam()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local volume = Settings.Troll.SoundVolume or 10
    createCustomizationUI("Voice Volume", volume, function(val)
        Settings.Troll.SoundVolume = val
        saveConfiguration()
    end)
    local voiceLines = {
        "rbxassetid://9113083740",
        "rbxassetid://9124373969",
        "rbxassetid://9124373980",
        "rbxassetid://9113083750"
    }
    local thread = task.spawn(function()
        while State.IsTrolling do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    safePCall(function()
                        local sound = Instance.new("Sound")
                        sound.SoundId = voiceLines[math.random(1, #voiceLines)]
                        sound.Volume = volume
                        sound.Parent = player.Character or workspace
                        sound:Play()
                        Debris:AddItem(sound, 5)
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.RandomTeleportSelf()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(
                        math.random(-500, 500),
                        math.random(10, 100),
                        math.random(-500, 500)
                    )
                end
            end)
            task.wait(1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.ZoomCamera()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            Camera.FieldOfView = math.random(1, 120)
            task.wait(0.5)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SpeedBoostSelf()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 100
                end
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.TeleportToRandom()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local thread = task.spawn(function()
        while State.IsTrolling do
            local target = getRandomTarget()
            if target then
                teleportToPlayer(target)
            end
            task.wait(1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

function TrollFeatures.SpamEffects()
    if not State.IsTrolling then
        showNotification("Troll", "Enable Troll Mode first!")
        return
    end
    local effects = {"Fire", "Smoke", "Sparkles"}
    local thread = task.spawn(function()
        while State.IsTrolling do
            safePCall(function()
                local effect = Instance.new("ParticleEmitter")
                effect.Texture = "rbxasset://textures/particles/" .. effects[math.random(1, #effects)] .. ".png"
                effect.Parent = workspace
                effect.Enabled = true
                Debris:AddItem(effect, 1)
            end)
            task.wait(0.1)
        end
    end)
    table.insert(State.TrollThreads, thread)
end

local function createMainGUI()
    safePCall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return
        end
        local guisToRemove = {"kevware_Replica", "CustomEngine_EspStorage", "ChatSpyWindow", "CustomizationPanel"}
        for _, name in ipairs(guisToRemove) do
            local gui = playerGui:FindFirstChild(name)
            if gui then
                gui:Destroy()
            end
        end
    end)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "kevware_Replica"
    mainGui.ResetOnSpawn = false
    mainGui.Parent = playerGui
    return mainGui
end

local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextColor3 = Themes[Settings.UI.Theme].Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 26)
    button.Position = UDim2.new(1, -60, 0.5, -13)
    button.BackgroundColor3 = default and Themes[Settings.UI.Theme].Primary or Color3.fromRGB(50, 50, 55)
    button.Text = ""
    button.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 13)
    btnCorner.Parent = button
    
    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Themes[Settings.UI.Theme].Primary or Color3.fromRGB(50, 50, 55)
        callback(state)
        saveConfiguration()
    end)
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. " (" .. tostring(default) .. ")"
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.TextColor3 = Themes[Settings.UI.Theme].Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 0, 32)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    sliderBar.Text = ""
    sliderBar.Parent = frame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = sliderBar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Themes[Settings.UI.Theme].Primary
    fill.Parent = sliderBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local snapping = false
    local currentValue = default
    local function updateSlider(input)
        local position = input.Position.X - sliderBar.AbsolutePosition.X
        local percentage = math.clamp(position / sliderBar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        currentValue = math.floor(min + (percentage * (max - min)))
        label.Text = text .. " (" .. tostring(currentValue) .. ")"
        callback(currentValue)
    end
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            snapping = true
            updateSlider(input)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            snapping = false
            saveConfiguration()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if snapping and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

local function createButton(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 1, -4)
    button.Position = UDim2.new(0, 2, 0, 2)
    button.BackgroundColor3 = Themes[Settings.UI.Theme].Primary
    button.BackgroundTransparency = 0.15
    button.Text = text
    button.TextColor3 = Themes[Settings.UI.Theme].Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.05
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0.15
    end)
end

local function createTextBoxLabel(parent, labelText, valueText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0.55, 0, 1, 0)
    value.Position = UDim2.new(0.42, 0, 0, 0)
    value.Text = valueText
    value.TextColor3 = Themes[Settings.UI.Theme].Text
    value.Font = Enum.Font.Gotham
    value.TextSize = 14
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.BackgroundTransparency = 1
    value.Parent = frame
end

local function createAimPartDropdown(parent, labelText, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.45, 0, 0, 28)
    dropdown.Position = UDim2.new(0.52, 0, 0.5, -14)
    dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    dropdown.Text = default
    dropdown.TextColor3 = Themes[Settings.UI.Theme].Text
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 13
    dropdown.Parent = frame
    local ddCorner = Instance.new("UICorner")
    ddCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
    ddCorner.Parent = dropdown
    
    local selected = default
    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = 0
        for i, option in ipairs(options) do
            if option == selected then
                currentIndex = i
                break
            end
        end
        currentIndex = currentIndex % #options + 1
        selected = options[currentIndex]
        dropdown.Text = selected
        callback(selected)
        saveConfiguration()
    end)
end

local function createColorPicker(parent, labelText, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 40, 0, 28)
    colorBtn.Position = UDim2.new(0.88, 0, 0.5, -14)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Text = ""
    colorBtn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
    btnCorner.Parent = colorBtn
    
    local hueSlider = Instance.new("TextButton")
    hueSlider.Size = UDim2.new(0.35, 0, 0, 10)
    hueSlider.Position = UDim2.new(0.48, 0, 0.5, -5)
    hueSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    hueSlider.Text = ""
    hueSlider.Parent = frame
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 5)
    hueCorner.Parent = hueSlider
    
    local hueFill = Instance.new("Frame")
    hueFill.Size = UDim2.new(0.5, 0, 1, 0)
    hueFill.BackgroundColor3 = defaultColor
    hueFill.Parent = hueSlider
    local hueFillCorner = Instance.new("UICorner")
    hueFillCorner.CornerRadius = UDim.new(0, 5)
    hueFillCorner.Parent = hueFill
    
    local dragging = false
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            hueFill.Size = UDim2.new(pos, 0, 1, 0)
            local color = Color3.fromHSV(pos, 1, 1)
            colorBtn.BackgroundColor3 = color
            callback(color)
        end
    end)
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            saveConfiguration()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            hueFill.Size = UDim2.new(pos, 0, 1, 0)
            local color = Color3.fromHSV(pos, 1, 1)
            colorBtn.BackgroundColor3 = color
            callback(color)
        end
    end)
end

local function createFontDropdown(parent, labelText, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Themes[Settings.UI.Theme].Primary
    stroke.Thickness = Settings.UI.BorderThickness or 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.45, 0, 0, 28)
    dropdown.Position = UDim2.new(0.52, 0, 0.5, -14)
    dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    dropdown.Text = default
    dropdown.TextColor3 = Themes[Settings.UI.Theme].Text
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 13
    dropdown.Parent = frame
    local ddCorner = Instance.new("UICorner")
    ddCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
    ddCorner.Parent = dropdown
    
    local selected = default
    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = 0
        for i, option in ipairs(options) do
            if option == selected then
                currentIndex = i
                break
            end
        end
        currentIndex = currentIndex % #options + 1
        selected = options[currentIndex]
        dropdown.Text = selected
        callback(selected)
        saveConfiguration()
    end)
end

local function createChatSpyWindow()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local mainGui = playerGui:FindFirstChild("kevware_Replica")
    if not mainGui then
        return
    end
    local existing = mainGui:FindFirstChild("ChatSpyWindow")
    if existing then
        existing:Destroy()
    end
    local theme = Themes[Settings.UI.Theme] or Themes.Purple
    local chatWindow = Instance.new("Frame")
    chatWindow.Name = "ChatSpyWindow"
    chatWindow.Size = UDim2.new(0, 400, 0, 300)
    chatWindow.Position = UDim2.new(0.5, -200, 0.5, -150)
    chatWindow.BackgroundColor3 = theme.DarkBg or theme.Background
    chatWindow.BackgroundTransparency = 0
    chatWindow.Visible = false
    chatWindow.Active = true
    chatWindow.Draggable = true
    chatWindow.Parent = mainGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 12)
    corner.Parent = chatWindow
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Primary
    stroke.Thickness = Settings.UI.BorderThickness or 2
    stroke.Parent = chatWindow
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = theme.DarkBg or theme.Background
    titleBar.BackgroundTransparency = 0
    titleBar.Parent = chatWindow
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 12)
    titleCorner.Parent = titleBar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = "Chat Spy"
    titleLabel.TextColor3 = theme.Primary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        chatWindow.Visible = false
        State.ChatWindowVisible = false
        Settings.ChatSpy = false
        saveConfiguration()
    end)
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 50, 0, 25)
    clearBtn.Position = UDim2.new(1, -95, 0, 5)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    clearBtn.Text = "Clear"
    clearBtn.TextColor3 = theme.Text
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 12
    clearBtn.Parent = titleBar
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 6)
    clearCorner.Parent = clearBtn
    local messageContainer = Instance.new("ScrollingFrame")
    messageContainer.Name = "MessageContainer"
    messageContainer.Size = UDim2.new(1, -10, 1, -45)
    messageContainer.Position = UDim2.new(0, 5, 0, 40)
    messageContainer.BackgroundTransparency = 1
    messageContainer.BorderSizePixel = 0
    messageContainer.ScrollBarThickness = 4
    messageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    messageContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    messageContainer.Parent = chatWindow
    local msgLayout = Instance.new("UIListLayout")
    msgLayout.Padding = UDim.new(0, 2)
    msgLayout.Parent = messageContainer
    
    local isUserScrolling = false
    local scrollTimer = nil
    
    messageContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isUserScrolling = true
            if scrollTimer then
                scrollTimer:Disconnect()
                scrollTimer = nil
            end
        end
    end)
    
    messageContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            scrollTimer = RunService.Heartbeat:Connect(function()
                isUserScrolling = false
                if scrollTimer then
                    scrollTimer:Disconnect()
                    scrollTimer = nil
                end
            end)
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        State.ChatMessages = {}
        for _, child in ipairs(messageContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end)
    
    local function addChatMessage(sender, message, isPrivate)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(1, 0, 0, 25)
        msgFrame.BackgroundColor3 = isPrivate and Color3.fromRGB(30, 20, 40) or Color3.fromRGB(25, 25, 30)
        msgFrame.BackgroundTransparency = 0
        msgFrame.Parent = messageContainer
        local msgCorner = Instance.new("UICorner")
        msgCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 4)
        msgCorner.Parent = msgFrame
        local prefix = isPrivate and "PRIVATE " or ""
        local color = isPrivate and Color3.fromRGB(255, 200, 100) or theme.Primary
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 80, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.Text = prefix .. sender
        nameLabel.TextColor3 = color
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = msgFrame
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -90, 1, 0)
        msgLabel.Position = UDim2.new(0, 85, 0, 0)
        msgLabel.Text = message
        msgLabel.TextColor3 = theme.Text
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 12
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.BackgroundTransparency = 1
        msgLabel.TextWrapped = true
        msgLabel.Parent = msgFrame
        
        task.wait(0.05)
        if not isUserScrolling then
            messageContainer.CanvasPosition = Vector2.new(0, messageContainer.CanvasSize.Y.Offset)
        end
    end
    return chatWindow, messageContainer, addChatMessage
end

local function buildMenu()
    local mainGui = createMainGUI()
    if not mainGui then
        return
    end
    local theme = Themes[Settings.UI.Theme] or Themes.Purple
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 580, 0, 720)
    mainFrame.Position = UDim2.new(0.5, -290, 0.5, -360)
    mainFrame.BackgroundColor3 = theme.DarkBg or theme.Background
    mainFrame.BackgroundTransparency = Settings.UI.Transparency or 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = mainGui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 14)
    mainCorner.Parent = mainFrame
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = theme.Primary
    mainStroke.Thickness = Settings.UI.BorderThickness or 2
    mainStroke.Parent = mainFrame
    if Settings.UI.GlowEffect then
        local glow = Instance.new("Frame")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1.02, 0, 1.02, 0)
        glow.Position = UDim2.new(-0.01, 0, -0.01, 0)
        glow.BackgroundColor3 = theme.Primary
        glow.BackgroundTransparency = 0.8
        glow.Parent = mainFrame
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 15)
        glowCorner.Parent = glow
    end
    local execName = "Universal"
    if getexecutorname then
        execName = getexecutorname()
    end
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "KEVWARE v3.0 [" .. execName .. "]"
    title.TextColor3 = theme.Primary
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.Parent = mainFrame
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 140, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = mainFrame
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = sidebar
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -155, 1, -40)
    container.Position = UDim2.new(0, 145, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    local pages = {}
    local tabButtons = {}
    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Parent = container
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = page
        
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 125, 0, 30)
        tabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 12
        tabButton.Parent = sidebar
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
        btnCorner.Parent = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do
                p.Visible = false
            end
            for _, btn in pairs(tabButtons) do
                btn.TextColor3 = Color3.fromRGB(160, 160, 160)
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
            end
            page.Visible = true
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabButton.BackgroundColor3 = theme.Primary
        end)
        table.insert(pages, page)
        table.insert(tabButtons, tabButton)
        return page
    end
    local aimPage = createPage("Aim")
    local visualPage = createPage("Visual")
    local movementPage = createPage("Movement")
    local teleportPage = createPage("Teleport")
    local flingPage = createPage("Fling")
    local trollPage = createPage("Troll")
    local creepyPage = createPage("Creepy")
    local uiPage = createPage("UI")
    local cmdPage = createPage("Commands")
    local perfPage = createPage("Performance")
    local utilsPage = createPage("Utilities")
    local creditsPage = createPage("Credits")
    State.TeleportPageRef = teleportPage
    State.FlingPageRef = flingPage
    if tabButtons[1] then
        tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButtons[1].BackgroundColor3 = theme.Primary
        pages[1].Visible = true
    end
    local chatWindow, messageContainer, addChatMessage = createChatSpyWindow()
    State.ChatSpyWindow = chatWindow
    State.MessageContainer = messageContainer
    State.AddChatMessage = addChatMessage
    
    createToggle(aimPage, "Enable Camlock", Settings.Camlock.Enabled, function(v) 
        Settings.Camlock.Enabled = v
        if not v then
            State.Victim = nil
            State.Locked = false
        end
        saveConfiguration()
    end)
    createAimPartDropdown(aimPage, "Aim Part", {"Head", "UpperTorso", "Torso"}, Settings.Camlock.AimPart or "Head", function(v)
        Settings.Camlock.AimPart = v
        getgenv().AimPart = v
        saveConfiguration()
    end)
    createSlider(aimPage, "Smoothness", 1, 10, Settings.Camlock.Smoothness, function(v) 
        Settings.Camlock.Smoothness = v 
        saveConfiguration()
    end)
    createSlider(aimPage, "Prediction", 0, 300, math.floor(getgenv().Prediction * 1000), function(v) 
        getgenv().Prediction = v / 1000
        Settings.Camlock.Prediction = v / 1000
        saveConfiguration()
    end)
    createToggle(aimPage, "Wall Check", Settings.Camlock.WallCheck, function(v) 
        Settings.Camlock.WallCheck = v 
        saveConfiguration()
    end)
    
    createToggle(visualPage, "Enable ESP", Settings.ESP.Enabled, function(v) 
        Settings.ESP.Enabled = v 
        saveConfiguration()
    end)
    createToggle(visualPage, "Box ESP", Settings.ESP.Boxes, function(v) 
        Settings.ESP.Boxes = v 
        saveConfiguration()
    end)
    createToggle(visualPage, "Name ESP", Settings.ESP.Names, function(v) 
        Settings.ESP.Names = v 
        saveConfiguration()
    end)
    createToggle(visualPage, "Distance ESP", Settings.ESP.Distance, function(v) 
        Settings.ESP.Distance = v 
        saveConfiguration()
    end)
    createToggle(visualPage, "Health ESP", Settings.ESP.Health, function(v) 
        Settings.ESP.Health = v 
        saveConfiguration()
    end)
    createToggle(visualPage, "Tracers", Settings.ESP.Tracers, function(v) 
        Settings.ESP.Tracers = v 
        saveConfiguration()
    end)
    
    createToggle(movementPage, "Noclip", Settings.Movement.Noclip, function(v) 
        Settings.Movement.Noclip = v 
        saveConfiguration()
    end)
    createToggle(movementPage, "WalkSpeed", Settings.Movement.WalkSpeed.Enabled, function(v) 
        Settings.Movement.WalkSpeed.Enabled = v 
        saveConfiguration()
    end)
    createSlider(movementPage, "WalkSpeed Value", 16, 120, Settings.Movement.WalkSpeed.Value, function(v) 
        Settings.Movement.WalkSpeed.Value = v 
        saveConfiguration()
    end)
    createToggle(movementPage, "Infinite Jump", Settings.Movement.InfiniteJump, function(v) 
        Settings.Movement.InfiniteJump = v 
        saveConfiguration()
    end)
    createToggle(movementPage, "Fly", Settings.Movement.Fly.Enabled, function(v) 
        Settings.Movement.Fly.Enabled = v 
        if not v then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
        saveConfiguration()
    end)
    createSlider(movementPage, "Fly Speed", 10, 150, Settings.Movement.Fly.Speed, function(v) 
        Settings.Movement.Fly.Speed = v 
        saveConfiguration()
    end)
    
    local function updateTeleportList()
        if not State.TeleportPageRef then
            return
        end
        local teleportPage = State.TeleportPageRef
        for _, child in ipairs(teleportPage:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -10, 0, 38)
                frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                frame.BackgroundTransparency = 0
                frame.Parent = teleportPage
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
                corner.Parent = frame
                local stroke = Instance.new("UIStroke")
                stroke.Color = theme.Primary
                stroke.Thickness = Settings.UI.BorderThickness or 1
                stroke.Transparency = 0.5
                stroke.Parent = frame
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -4, 1, -4)
                button.Position = UDim2.new(0, 2, 0, 2)
                button.BackgroundTransparency = 1
                button.Text = "TP " .. player.DisplayName .. " (" .. player.Name .. ")"
                button.TextColor3 = theme.Text
                button.Font = Enum.Font.Gotham
                button.TextSize = 13
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = frame
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
                btnCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    teleportToPlayer(player)
                end)
            end
        end
    end
    task.spawn(function()
        while task.wait(CONFIG.TELEPORT_UPDATE_INTERVAL) do
            if State.TeleportPageRef and State.TeleportPageRef.Visible then
                updateTeleportList()
            end
        end
    end)
    Players.PlayerAdded:Connect(updateTeleportList)
    Players.PlayerRemoving:Connect(updateTeleportList)
    updateTeleportList()
    
    local function updateFlingList()
        if not State.FlingPageRef then
            return
        end
        local flingPage = State.FlingPageRef
        for _, child in ipairs(flingPage:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -10, 0, 38)
                frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                frame.BackgroundTransparency = 0
                frame.Parent = flingPage
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 10)
                corner.Parent = frame
                local stroke = Instance.new("UIStroke")
                stroke.Color = theme.Primary
                stroke.Thickness = Settings.UI.BorderThickness or 1
                stroke.Transparency = 0.5
                stroke.Parent = frame
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -4, 1, -4)
                button.Position = UDim2.new(0, 2, 0, 2)
                button.BackgroundTransparency = 1
                button.Text = "FLING " .. player.DisplayName .. " (" .. player.Name .. ")"
                button.TextColor3 = theme.Text
                button.Font = Enum.Font.Gotham
                button.TextSize = 13
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = frame
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
                btnCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    flingPlayer(player)
                end)
            end
        end
    end
    task.spawn(function()
        while task.wait(CONFIG.FLING_UPDATE_INTERVAL) do
            if State.FlingPageRef and State.FlingPageRef.Visible then
                updateFlingList()
            end
        end
    end)
    Players.PlayerAdded:Connect(updateFlingList)
    Players.PlayerRemoving:Connect(updateFlingList)
    updateFlingList()
    
    createToggle(trollPage, "Enable Troll Mode", false, function(v)
        State.IsTrolling = v
        if not v then
            stopTrollThreads()
            showNotification("Troll", "Troll mode deactivated!")
        else
            showNotification("Troll", "Troll mode activated!")
        end
    end)
    createSlider(trollPage, "Spin Speed", 1, 100, Settings.Troll.SpinSpeed or 50, function(v)
        Settings.Troll.SpinSpeed = v
        State.SpinSpeed = v
        saveConfiguration()
    end)
    createButton(trollPage, "Customize Chat Spam", function()
        local messages = Settings.Troll.ChatSpamMessages or {"KEVWARE ON TOP", "GET FLOORED"}
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -20, 0, 60)
        input.Position = UDim2.new(0, 10, 0, 5)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        input.TextColor3 = Themes[Settings.UI.Theme].Text
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        input.MultiLine = true
        input.Text = table.concat(messages, "\n")
        input.Parent = trollPage
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.5, -5, 0, 30)
        saveBtn.Position = UDim2.new(0.25, 0, 0, 70)
        saveBtn.BackgroundColor3 = theme.Primary
        saveBtn.Text = "Save Messages"
        saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextSize = 14
        saveBtn.Parent = trollPage
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
        btnCorner.Parent = saveBtn
        saveBtn.MouseButton1Click:Connect(function()
            local newMessages = {}
            for line in input.Text:gmatch("[^\r\n]+") do
                if line ~= "" then
                    table.insert(newMessages, line)
                end
            end
            if #newMessages > 0 then
                Settings.Troll.ChatSpamMessages = newMessages
                saveConfiguration()
                showNotification("Chat Spam", "Messages updated! (" .. #newMessages .. " messages)")
                input:Destroy()
                saveBtn:Destroy()
            else
                showNotification("Error", "Please enter at least one message!")
            end
        end)
    end)
    local trollButtons = {
        {"Spin Bot", function() TrollFeatures.SpinBot(State.SpinSpeed) end},
        {"Spin Others", function() TrollFeatures.SpinOthers() end},
        {"Chat Spam", function() TrollFeatures.SpamChat() end},
        {"Sound Spam", function() TrollFeatures.SoundSpam() end},
        {"Mass Fling All", function() TrollFeatures.MassFling() end},
        {"Invisible Mode", function() TrollFeatures.InvisibleMode() end},
        {"Giant Mode", function() TrollFeatures.GiantMode() end},
        {"Rainbow Mode", function() TrollFeatures.RainbowMode() end},
        {"Float Mode", function() TrollFeatures.FloatMode() end},
        {"Explode Players", function() TrollFeatures.ExplodePlayers() end},
        {"Throw Players", function() TrollFeatures.ThrowPlayers() end},
        {"Wallhack ESP", function() TrollFeatures.WallhackESP() end},
        {"Kill All", function() TrollFeatures.KillAll() end},
        {"Freeze Players", function() TrollFeatures.FreezePlayers() end},
        {"Screen Shake", function() TrollFeatures.ScreenShake() end},
        {"Spam Parts", function() TrollFeatures.SpamParts() end},
        {"Invert Gravity", function() TrollFeatures.InvertGravity() end},
        {"Flashbang", function() TrollFeatures.Flashbang() end},
        {"Strobe Lights", function() TrollFeatures.StrobeLights() end},
        {"Clone Yourself", function() TrollFeatures.CloneYourself() end},
        {"Lag Machine", function() TrollFeatures.LagMachine() end},
        {"Rainbow Lightning", function() TrollFeatures.RainbowLightning() end},
        {"Slow Motion", function() TrollFeatures.SlowMotion() end},
        {"Everyone Dance", function() TrollFeatures.EveryoneDance() end},
        {"Floor Players", function() TrollFeatures.FloorPlayers() end},
        {"Spam Tools", function() TrollFeatures.SpamTools() end},
        {"Voice Spam", function() TrollFeatures.VoiceSpam() end},
        {"Random Teleport Self", function() TrollFeatures.RandomTeleportSelf() end},
        {"Zoom Camera", function() TrollFeatures.ZoomCamera() end},
        {"Speed Boost Self", function() TrollFeatures.SpeedBoostSelf() end},
        {"Teleport To Random", function() TrollFeatures.TeleportToRandom() end},
        {"Spam Effects", function() TrollFeatures.SpamEffects() end}
    }
    for _, buttonData in ipairs(trollButtons) do
        createButton(trollPage, buttonData[1], buttonData[2])
    end
    
    -- CREEPY TAB WITH TOGGLES
    createToggle(creepyPage, "Enable Creepy Mode", false, function(v)
        Settings.Creepy.Enabled = v
        if not v then
            stopCreepyThreads()
            showNotification("Creepy", "Creepy mode deactivated!")
        else
            showNotification("Creepy", "Creepy mode activated!")
        end
        saveConfiguration()
    end)
    
    createSlider(creepyPage, "Fling Duration", 1, 15, Settings.Creepy.FlingDuration or 10, function(v)
        Settings.Creepy.FlingDuration = v
        saveConfiguration()
    end)
    
    createToggle(creepyPage, "Jump Scare", Settings.Creepy.JumpScareEnabled or false, function(v)
        toggleCreepyFeature("JumpScareEnabled", v)
    end)
    
    createToggle(creepyPage, "Screen Flash", Settings.Creepy.ScreenFlashEnabled or false, function(v)
        toggleCreepyFeature("ScreenFlashEnabled", v)
    end)
    
    createToggle(creepyPage, "Ghost Mode", Settings.Creepy.GhostModeEnabled or false, function(v)
        toggleCreepyFeature("GhostModeEnabled", v)
    end)
    
    createToggle(creepyPage, "Possession", Settings.Creepy.PossessionEnabled or false, function(v)
        toggleCreepyFeature("PossessionEnabled", v)
    end)
    
    createToggle(creepyPage, "Possession All", Settings.Creepy.PossessionAllEnabled or false, function(v)
        toggleCreepyFeature("PossessionAllEnabled", v)
    end)
    
    createToggle(creepyPage, "Darken Sky", Settings.Creepy.DarkSkyEnabled or false, function(v)
        toggleCreepyFeature("DarkSkyEnabled", v)
    end)
    
    createToggle(creepyPage, "Spawn Ghosts", Settings.Creepy.GhostsEnabled or false, function(v)
        toggleCreepyFeature("GhostsEnabled", v)
    end)
    
    createToggle(creepyPage, "Creepy Sounds", Settings.Creepy.CreepySoundsEnabled or false, function(v)
        toggleCreepyFeature("CreepySoundsEnabled", v)
    end)
    
    createToggle(creepyPage, "Teleport All", Settings.Creepy.TeleportAllEnabled or false, function(v)
        toggleCreepyFeature("TeleportAllEnabled", v)
    end)
    
    createToggle(creepyPage, "Creepy Text", Settings.Creepy.CreepyTextEnabled or false, function(v)
        toggleCreepyFeature("CreepyTextEnabled", v)
    end)
    
    createToggle(creepyPage, "Invert Colors", Settings.Creepy.InvertColorsEnabled or false, function(v)
        toggleCreepyFeature("InvertColorsEnabled", v)
    end)
    
    createToggle(creepyPage, "Shadow Clone", Settings.Creepy.ShadowCloneEnabled or false, function(v)
        toggleCreepyFeature("ShadowCloneEnabled", v)
    end)
    
    createToggle(creepyPage, "Creepy Music", Settings.Creepy.CreepyMusicEnabled or false, function(v)
        toggleCreepyFeature("CreepyMusicEnabled", v)
    end)
    
    createToggle(creepyPage, "Flicker Lights", Settings.Creepy.FlickerLightsEnabled or false, function(v)
        toggleCreepyFeature("FlickerLightsEnabled", v)
    end)
    
    createToggle(creepyPage, "Randomize Parts", Settings.Creepy.RandomizePartsEnabled or false, function(v)
        toggleCreepyFeature("RandomizePartsEnabled", v)
    end)
    
    createButton(uiPage, "Purple Theme", function() applyTheme("Purple") end)
    createButton(uiPage, "Rainbow Theme", function() applyTheme("Rainbow") end)
    createButton(uiPage, "Aurora Theme", function() applyTheme("Aurora") end)
    createButton(uiPage, "Neon Theme", function() applyTheme("Neon") end)
    createButton(uiPage, "Ocean Theme", function() applyTheme("Ocean") end)
    createButton(uiPage, "Fire Theme", function() applyTheme("Fire") end)
    createButton(uiPage, "Ice Theme", function() applyTheme("Ice") end)
    createButton(uiPage, "Matrix Theme", function() applyTheme("Matrix") end)
    createButton(uiPage, "Custom Theme", function() applyTheme("Custom") end)
    createColorPicker(uiPage, "Accent Color", Settings.UI.AccentColor or Color3.fromRGB(150, 0, 255), function(v)
        Settings.UI.AccentColor = v
        Themes.Custom.Primary = v
        Themes.Custom.Secondary = v
        Themes.Custom.Accent = v
        Themes.Custom.Glow = v
        applyTheme("Custom")
        updateUI()
        saveConfiguration()
    end)
    createColorPicker(uiPage, "Background Color", Settings.UI.BackgroundColor or Color3.fromRGB(16, 16, 18), function(v)
        Settings.UI.BackgroundColor = v
        Themes.Custom.Background = v
        Themes.Custom.DarkBg = v
        applyTheme("Custom")
        updateUI()
        saveConfiguration()
    end)
    createColorPicker(uiPage, "Text Color", Settings.UI.TextColor or Color3.fromRGB(255, 255, 255), function(v)
        Settings.UI.TextColor = v
        Themes.Custom.Text = v
        applyTheme("Custom")
        updateUI()
        saveConfiguration()
    end)
    createSlider(uiPage, "Transparency", 0, 100, Settings.UI.Transparency * 100, function(v)
        Settings.UI.Transparency = v / 100
        updateUI()
        saveConfiguration()
    end)
    createSlider(uiPage, "Border Thickness", 1, 5, Settings.UI.BorderThickness or 2, function(v)
        Settings.UI.BorderThickness = v
        updateUI()
        saveConfiguration()
    end)
    createSlider(uiPage, "Corner Radius", 4, 20, Settings.UI.CornerRadius or 12, function(v)
        Settings.UI.CornerRadius = v
        updateUI()
        saveConfiguration()
    end)
    createFontDropdown(uiPage, "Font", {"Gotham", "SourceSans", "SourceSansBold", "Arial", "Roboto"}, Settings.UI.Font or "Gotham", function(v)
        Settings.UI.Font = v
        updateUI()
        saveConfiguration()
    end)
    createToggle(uiPage, "Glow Effect", Settings.UI.GlowEffect, function(v)
        Settings.UI.GlowEffect = v
        updateUI()
        saveConfiguration()
        showNotification("UI", "Glow effect " .. (v and "enabled" or "disabled"))
    end)
    createButton(uiPage, "Refresh UI", function()
        updateUI()
        showNotification("UI", "UI refreshed!")
    end)
    
    createToggle(cmdPage, "Enable Commands", Settings.Commands.Enabled or true, function(v)
        Settings.Commands.Enabled = v
        saveConfiguration()
    end)
    
    local prefixLabel = Instance.new("TextLabel")
    prefixLabel.Size = UDim2.new(1, -20, 0, 30)
    prefixLabel.Position = UDim2.new(0, 10, 0, 5)
    prefixLabel.Text = "Current Prefix: " .. (Settings.Commands.Prefix or ";")
    prefixLabel.TextColor3 = theme.Primary
    prefixLabel.Font = Enum.Font.GothamBold
    prefixLabel.TextSize = 16
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
    prefixLabel.Parent = cmdPage
    
    createButton(cmdPage, "Change Prefix", function()
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.8, 0, 0, 30)
        input.Position = UDim2.new(0.1, 0, 0, 40)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        input.TextColor3 = Themes[Settings.UI.Theme].Text
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        input.Text = Settings.Commands.Prefix or ";"
        input.Parent = cmdPage
        
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.4, 0, 0, 30)
        saveBtn.Position = UDim2.new(0.3, 0, 0, 75)
        saveBtn.BackgroundColor3 = theme.Primary
        saveBtn.Text = "Save Prefix"
        saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextSize = 14
        saveBtn.Parent = cmdPage
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, Settings.UI.CornerRadius or 8)
        btnCorner.Parent = saveBtn
        
        saveBtn.MouseButton1Click:Connect(function()
            local newPrefix = input.Text
            if newPrefix and newPrefix ~= "" then
                Settings.Commands.Prefix = newPrefix
                CONFIG.COMMAND_PREFIX = newPrefix
                saveConfiguration()
                prefixLabel.Text = "Current Prefix: " .. newPrefix
                showNotification("Commands", "Prefix changed to: " .. newPrefix)
                input:Destroy()
                saveBtn:Destroy()
            else
                showNotification("Error", "Please enter a valid prefix!")
            end
        end)
    end)
    
    local commandList = {
        "=== COMMANDS LIST ===",
        " ",
        "GENERAL:",
        "  " .. (Settings.Commands.Prefix or ";") .. "help - Shows this command list",
        "  " .. (Settings.Commands.Prefix or ";") .. "settings - Shows current settings",
        "  " .. (Settings.Commands.Prefix or ";") .. "toggle <feature> - Toggle features",
        " ",
        "MOVEMENT:",
        "  " .. (Settings.Commands.Prefix or ";") .. "fly - Toggle fly mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "noclip - Toggle noclip mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "speed <value> - Set walk speed",
        "  " .. (Settings.Commands.Prefix or ";") .. "jump - Toggle infinite jump",
        " ",
        "COMBAT:",
        "  " .. (Settings.Commands.Prefix or ";") .. "tp <player> - Teleport to a player",
        "  " .. (Settings.Commands.Prefix or ";") .. "fling <player> - Fling a player (10 seconds)",
        "  " .. (Settings.Commands.Prefix or ";") .. "flingall - Mass fling all players",
        "  " .. (Settings.Commands.Prefix or ";") .. "killall - Kill all players",
        "  " .. (Settings.Commands.Prefix or ";") .. "freeze - Freeze all players",
        "  " .. (Settings.Commands.Prefix or ";") .. "explode - Explode all players",
        "  " .. (Settings.Commands.Prefix or ";") .. "throw - Throw all players",
        " ",
        "TROLL:",
        "  " .. (Settings.Commands.Prefix or ";") .. "spin - Toggle spin bot",
        "  " .. (Settings.Commands.Prefix or ";") .. "spinothers - Spin other players",
        "  " .. (Settings.Commands.Prefix or ";") .. "invis - Toggle invisible",
        "  " .. (Settings.Commands.Prefix or ";") .. "giant - Toggle giant mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "rainbow - Toggle rainbow mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "float - Toggle float mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "chatspam - Toggle chat spam",
        "  " .. (Settings.Commands.Prefix or ";") .. "soundspam - Toggle sound spam",
        "  " .. (Settings.Commands.Prefix or ";") .. "wallhack - Toggle wallhack ESP",
        "  " .. (Settings.Commands.Prefix or ";") .. "strobe - Toggle strobe lights",
        "  " .. (Settings.Commands.Prefix or ";") .. "gravity - Invert gravity",
        "  " .. (Settings.Commands.Prefix or ";") .. "lag - Lag machine",
        "  " .. (Settings.Commands.Prefix or ";") .. "dance - Everyone dance",
        "  " .. (Settings.Commands.Prefix or ";") .. "floor - Floor all players",
        " ",
        "CREEPY:",
        "  " .. (Settings.Commands.Prefix or ";") .. "jumpscare - Jump scare a player",
        "  " .. (Settings.Commands.Prefix or ";") .. "flash - Flash everyone's screen",
        "  " .. (Settings.Commands.Prefix or ";") .. "ghost - Ghost mode",
        "  " .. (Settings.Commands.Prefix or ";") .. "possess - Possess a player",
        "  " .. (Settings.Commands.Prefix or ";") .. "darken - Darken the sky",
        "  " .. (Settings.Commands.Prefix or ";") .. "ghosts - Spawn ghosts",
        "  " .. (Settings.Commands.Prefix or ";") .. "creepysound - Play creepy sounds",
        "  " .. (Settings.Commands.Prefix or ";") .. "teleportall - Teleport all players",
        "  " .. (Settings.Commands.Prefix or ";") .. "creepytext - Send creepy text",
        "  " .. (Settings.Commands.Prefix or ";") .. "invert - Invert colors",
        "  " .. (Settings.Commands.Prefix or ";") .. "shadow - Shadow clone",
        "  " .. (Settings.Commands.Prefix or ";") .. "music - Creepy music",
        "  " .. (Settings.Commands.Prefix or ";") .. "flicker - Flicker lights",
        " ",
        "TELEPORT:",
        "  " .. (Settings.Commands.Prefix or ";") .. "teleportrandom - Random teleport",
        "  " .. (Settings.Commands.Prefix or ";") .. "randomteleportself - Random self teleport",
        "  " .. (Settings.Commands.Prefix or ";") .. "rejoin - Rejoin game",
        " ",
        "UI:",
        "  " .. (Settings.Commands.Prefix or ";") .. "theme <name> - Change theme",
        "  " .. (Settings.Commands.Prefix or ";") .. "refreshui - Refresh UI",
        " ",
        "EXAMPLES:",
        "  " .. (Settings.Commands.Prefix or ";") .. "toggle esp - Turns ESP on/off",
        "  " .. (Settings.Commands.Prefix or ";") .. "speed 50 - Sets speed to 50",
        "  " .. (Settings.Commands.Prefix or ";") .. "tp PlayerName - Teleports to PlayerName",
        "  " .. (Settings.Commands.Prefix or ";") .. "theme Rainbow - Changes theme",
        " ",
        "TIP: Use " .. (Settings.Commands.Prefix or ";") .. "help anytime!"
    }
    for _, cmd in ipairs(commandList) do
        local cmdLabel = Instance.new("TextLabel")
        cmdLabel.Size = UDim2.new(1, -20, 0, 20)
        cmdLabel.Position = UDim2.new(0, 10, 0, #cmdLabel:GetChildren() * 22 + 5)
        cmdLabel.Text = cmd
        cmdLabel.TextColor3 = cmd:match("===") and theme.Primary or cmd:match("GENERAL:") and theme.Primary or cmd:match("MOVEMENT:") and theme.Primary or cmd:match("COMBAT:") and theme.Primary or cmd:match("TROLL:") and theme.Primary or cmd:match("CREEPY:") and theme.Primary or cmd:match("TELEPORT:") and theme.Primary or cmd:match("UI:") and theme.Primary or cmd:match("EXAMPLES:") and theme.Primary or cmd:match("TIP:") and theme.Primary or theme.Text
        cmdLabel.Font = cmd:match("===") and Enum.Font.GothamBold or cmd:match("GENERAL:") and Enum.Font.GothamBold or cmd:match("MOVEMENT:") and Enum.Font.GothamBold or cmd:match("COMBAT:") and Enum.Font.GothamBold or cmd:match("TROLL:") and Enum.Font.GothamBold or cmd:match("CREEPY:") and Enum.Font.GothamBold or cmd:match("TELEPORT:") and Enum.Font.GothamBold or cmd:match("UI:") and Enum.Font.GothamBold or cmd:match("EXAMPLES:") and Enum.Font.GothamBold or cmd:match("TIP:") and Enum.Font.GothamBold or Enum.Font.Gotham
        cmdLabel.TextSize = cmd:match("===") and 16 or 12
        cmdLabel.BackgroundTransparency = 1
        cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
        cmdLabel.Parent = cmdPage
    end
    
    createButton(perfPage, "Boost Performance", function()
        boostPerformance()
        showNotification("Performance", "Optimizations applied!")
    end)
    createButton(perfPage, "Clear ESP Cache", function()
        for _, data in pairs(State.EspCache) do
            if data.Folder then
                data.Folder:Destroy()
            end
        end
        State.EspCache = {}
        showNotification("Cache", "ESP cache cleared!")
    end)
    
    createToggle(utilsPage, "Chat Spy", Settings.ChatSpy, function(v) 
        Settings.ChatSpy = v 
        if v and chatWindow then
            chatWindow.Visible = true
            State.ChatWindowVisible = true
            showNotification("Chat Spy", "Chat spy enabled! Window opened.")
        elseif not v and chatWindow then
            chatWindow.Visible = false
            State.ChatWindowVisible = false
        end
        saveConfiguration()
    end)
    createToggle(utilsPage, "Rejoin on Death", Settings.RejoinOnDeath, function(v) 
        Settings.RejoinOnDeath = v 
        saveConfiguration()
    end)
    createToggle(utilsPage, "Join Official Game", Settings.JoinOfficialGame, function(v) 
        Settings.JoinOfficialGame = v 
        if v then
            TeleportService:Teleport(CONFIG.OFFICIAL_GAME_ID, LocalPlayer)
        end
        saveConfiguration()
    end)
    createButton(utilsPage, "Rejoin Game", function()
        showNotification("Rejoin", "Rejoining...")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    createButton(utilsPage, "Copy Discord Profile", function()
        universalClipboard("https://discord.com/users/1525402840577867803")
        showNotification("Clipboard", "Discord link copied!")
    end)
    
    createTextBoxLabel(creditsPage, "Developer", "1.sm.")
    createTextBoxLabel(creditsPage, "Discord", "1525402840577867803")
    createTextBoxLabel(creditsPage, "Executor", execName)
    createTextBoxLabel(creditsPage, "Version", "3.0")
    createTextBoxLabel(creditsPage, "Theme", Settings.UI.Theme)
    createButton(creditsPage, "Copy Executor Info", function()
        local info = "KEVWARE v3.0\nDeveloper: 1.sm.\nDiscord: 1525402840577867803\nExecutor: " .. execName .. "\nTheme: " .. Settings.UI.Theme
        universalClipboard(info)
        showNotification("Copied", "Full info copied to clipboard!")
    end)
    return mainFrame, chatWindow, messageContainer, addChatMessage
end

local function setupChatSpy()
    if not State.AddChatMessage then
        return
    end
    local function handleIncomingMessage(sender, message, isPrivate)
        if not Settings.ChatSpy or not sender or sender == LocalPlayer then
            return
        end
        if not message or message == "" then
            return
        end
        if State.AddChatMessage then
            State.AddChatMessage(sender.Name, message, isPrivate or false)
        end
        local prefix = isPrivate and "[PRIVATE SPY]" or "[SPY]"
        print(string.format("%s [%s]: %s", prefix, sender.Name, message))
    end
    TextChatService.MessageReceived:Connect(function(chatMessage)
        if chatMessage.TextSource then
            local sender = Players:GetPlayerByUserId(chatMessage.TextSource.UserId)
            if sender and sender ~= LocalPlayer then
                handleIncomingMessage(sender, chatMessage.Text, false)
            end
        end
    end)
    local function hookPlayer(player)
        if player ~= LocalPlayer then
            player.Chatted:Connect(function(msg)
                handleIncomingMessage(player, msg, false)
            end)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        hookPlayer(player)
    end
    Players.PlayerAdded:Connect(hookPlayer)
    safePCall(function()
        local textChannels = TextChatService:FindFirstChild("TextChannels")
        if textChannels then
            for _, channel in ipairs(textChannels:GetChildren()) do
                if channel.Name:match("[Pp]rivate") then
                    local msgReceived = channel:FindFirstChild("MessageReceived")
                    if msgReceived then
                        msgReceived:Connect(function(message)
                            if message.Metadata and message.Metadata.SenderName then
                                local sender = Players:FindFirstChild(message.Metadata.SenderName)
                                if sender and sender ~= LocalPlayer then
                                    handleIncomingMessage(sender, message.Text, true)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)
end

local function setupCommands()
    local prefix = Settings.Commands.Prefix or ";"
    local function executeCommand(msg)
        if not Settings.Commands.Enabled then
            return
        end
        if not msg:sub(1, 1) == prefix then
            return
        end
        local args = {}
        for word in msg:gmatch("%S+") do
            table.insert(args, word)
        end
        local command = args[1]:sub(2):lower()
        table.remove(args, 1)
        if command == "help" then
            showNotification("Commands", "Type " .. prefix .. "help for full command list")
            return
        end
        if command == "settings" then
            local info = "Settings:\nCamlock: " .. tostring(Settings.Camlock.Enabled) .. "\nESP: " .. tostring(Settings.ESP.Enabled) .. "\nFly: " .. tostring(Settings.Movement.Fly.Enabled) .. "\nNoclip: " .. tostring(Settings.Movement.Noclip) .. "\nChat Spy: " .. tostring(Settings.ChatSpy) .. "\nTroll Mode: " .. tostring(State.IsTrolling)
            showNotification("Settings", info)
            return
        end
        if command == "toggle" then
            local feature = args[1]
            if feature == "camlock" then
                Settings.Camlock.Enabled = not Settings.Camlock.Enabled
                showNotification("Camlock", Settings.Camlock.Enabled and "Enabled" or "Disabled")
            elseif feature == "esp" then
                Settings.ESP.Enabled = not Settings.ESP.Enabled
                showNotification("ESP", Settings.ESP.Enabled and "Enabled" or "Disabled")
            elseif feature == "fly" then
                Settings.Movement.Fly.Enabled = not Settings.Movement.Fly.Enabled
                showNotification("Fly", Settings.Movement.Fly.Enabled and "Enabled" or "Disabled")
            elseif feature == "noclip" then
                Settings.Movement.Noclip = not Settings.Movement.Noclip
                showNotification("Noclip", Settings.Movement.Noclip and "Enabled" or "Disabled")
            elseif feature == "jump" then
                Settings.Movement.InfiniteJump = not Settings.Movement.InfiniteJump
                showNotification("Infinite Jump", Settings.Movement.InfiniteJump and "Enabled" or "Disabled")
            elseif feature == "spin" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.SpinBot(State.SpinSpeed)
                else
                    stopTrollThreads()
                end
                showNotification("Spin Bot", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "invis" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.InvisibleMode()
                else
                    stopTrollThreads()
                end
                showNotification("Invisible", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "giant" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.GiantMode()
                else
                    stopTrollThreads()
                end
                showNotification("Giant", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "rainbow" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.RainbowMode()
                else
                    stopTrollThreads()
                end
                showNotification("Rainbow", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "float" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.FloatMode()
                else
                    stopTrollThreads()
                end
                showNotification("Float", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "chatspam" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.SpamChat()
                else
                    stopTrollThreads()
                end
                showNotification("Chat Spam", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "soundspam" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.SoundSpam()
                else
                    stopTrollThreads()
                end
                showNotification("Sound Spam", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "wallhack" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.WallhackESP()
                else
                    stopTrollThreads()
                end
                showNotification("Wallhack", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "strobe" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.StrobeLights()
                else
                    stopTrollThreads()
                end
                showNotification("Strobe", State.IsTrolling and "Enabled" or "Disabled")
            elseif feature == "gravity" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.InvertGravity()
                else
                    stopTrollThreads()
                end
                showNotification("Gravity", State.IsTrolling and "Inverted" or "Normal")
            elseif feature == "dance" then
                State.IsTrolling = not State.IsTrolling
                if State.IsTrolling then
                    TrollFeatures.EveryoneDance()
                else
                    stopTrollThreads()
                end
                showNotification("Dance", State.IsTrolling and "Enabled" or "Disabled")
            else
                showNotification("Error", "Feature not found! Use: camlock, esp, fly, noclip, jump, spin, invis, giant, rainbow, float, chatspam, soundspam, wallhack, strobe, gravity, dance")
            end
            return
        end
        if command == "fling" then
            local target = args[1]
            if target then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Name:lower():match(target:lower()) or player.DisplayName:lower():match(target:lower()) then
                        flingPlayer(player)
                        return
                    end
                end
                showNotification("Error", "Player not found! Use: " .. prefix .. "fling <playername>")
            else
                showNotification("Error", "Usage: " .. prefix .. "fling <playername>")
            end
            return
        end
        if command == "tp" then
            local target = args[1]
            if target then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Name:lower():match(target:lower()) or player.DisplayName:lower():match(target:lower()) then
                        teleportToPlayer(player)
                        return
                    end
                end
                showNotification("Error", "Player not found! Use: " .. prefix .. "tp <playername>")
            else
                showNotification("Error", "Usage: " .. prefix .. "tp <playername>")
            end
            return
        end
        if command == "speed" then
            local value = tonumber(args[1])
            if value then
                if value >= 16 and value <= 120 then
                    Settings.Movement.WalkSpeed.Value = value
                    Settings.Movement.WalkSpeed.Enabled = true
                    showNotification("Speed", "Set to " .. value)
                    saveConfiguration()
                else
                    showNotification("Error", "Speed must be between 16 and 120!")
                end
            else
                showNotification("Error", "Usage: " .. prefix .. "speed <value> (16-120)")
            end
            return
        end
        if command == "killall" then
            TrollFeatures.KillAll()
            return
        end
        if command == "freeze" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.FreezePlayers()
                showNotification("Freeze", "Enabled")
            else
                stopTrollThreads()
                showNotification("Freeze", "Disabled")
            end
            return
        end
        if command == "explode" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.ExplodePlayers()
                showNotification("Explode", "Enabled")
            else
                stopTrollThreads()
                showNotification("Explode", "Disabled")
            end
            return
        end
        if command == "throw" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.ThrowPlayers()
                showNotification("Throw", "Enabled")
            else
                stopTrollThreads()
                showNotification("Throw", "Disabled")
            end
            return
        end
        if command == "flingall" then
            TrollFeatures.MassFling()
            return
        end
        if command == "rejoin" then
            showNotification("Rejoin", "Rejoining...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
            return
        end
        if command == "theme" then
            local themeName = args[1]
            if themeName then
                local formattedName = themeName:gsub("^%l", string.upper)
                if Themes[formattedName] then
                    applyTheme(formattedName)
                else
                    showNotification("Error", "Theme not found! Available: Purple, Rainbow, Aurora, Neon, Ocean, Fire, Ice, Matrix, Custom")
                end
            else
                showNotification("Error", "Usage: " .. prefix .. "theme <name>")
            end
            return
        end
        if command == "teleportrandom" then
            TrollFeatures.TeleportToRandom()
            return
        end
        if command == "randomteleportself" then
            TrollFeatures.RandomTeleportSelf()
            return
        end
        if command == "spinothers" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.SpinOthers()
                showNotification("Spin Others", "Enabled")
            else
                stopTrollThreads()
                showNotification("Spin Others", "Disabled")
            end
            return
        end
        if command == "flashbang" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.Flashbang()
                showNotification("Flashbang", "Enabled")
            else
                stopTrollThreads()
                showNotification("Flashbang", "Disabled")
            end
            return
        end
        if command == "lag" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.LagMachine()
                showNotification("Lag Machine", "Enabled")
            else
                stopTrollThreads()
                showNotification("Lag Machine", "Disabled")
            end
            return
        end
        if command == "floor" then
            State.IsTrolling = not State.IsTrolling
            if State.IsTrolling then
                TrollFeatures.FloorPlayers()
                showNotification("Floor", "Enabled")
            else
                stopTrollThreads()
                showNotification("Floor", "Disabled")
            end
            return
        end
        if command == "refreshui" then
            updateUI()
            showNotification("UI", "UI refreshed!")
            return
        end
        
        if command == "jumpscare" then
            local target = getRandomTarget()
            if target then
                CreepyFeatures.JumpScare(target)
            else
                showNotification("Creepy", "No target found!")
            end
            return
        end
        if command == "flash" then
            CreepyFeatures.ScreenFlash()
            return
        end
        if command == "ghost" then
            CreepyFeatures.GhostMode()
            return
        end
        if command == "possess" then
            local target = getRandomTarget()
            if target then
                CreepyFeatures.Possession(target)
            else
                showNotification("Creepy", "No target found!")
            end
            return
        end
        if command == "darken" then
            CreepyFeatures.DarkenSky()
            return
        end
        if command == "ghosts" then
            CreepyFeatures.SpawnGhosts()
            return
        end
        if command == "creepysound" then
            CreepyFeatures.CreepySounds()
            return
        end
        if command == "teleportall" then
            CreepyFeatures.TeleportRandomAll()
            return
        end
        if command == "creepytext" then
            CreepyFeatures.CreepyText()
            return
        end
        if command == "invert" then
            CreepyFeatures.InvertColors()
            return
        end
        if command == "shadow" then
            CreepyFeatures.ShadowClone()
            return
        end
        if command == "music" then
            CreepyFeatures.CreepyMusic()
            return
        end
        if command == "flicker" then
            CreepyFeatures.FlickerLights()
            return
        end
        
        showNotification("Unknown Command", "Type " .. prefix .. "help for command list")
    end
    TextChatService.MessageReceived:Connect(function(chatMessage)
        if chatMessage.TextSource then
            local sender = Players:GetPlayerByUserId(chatMessage.TextSource.UserId)
            if sender and sender == LocalPlayer then
                executeCommand(chatMessage.Text)
            end
        end
    end)
end

local function setupESP()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local espScreen = Instance.new("ScreenGui")
    espScreen.Name = "CustomEngine_EspStorage"
    espScreen.ResetOnSpawn = false
    espScreen.Parent = playerGui
    task.spawn(function()
        while task.wait(CONFIG.ESP_UPDATE_INTERVAL) do
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then
                    continue
                end
                local data = State.EspCache[player]
                if not data then
                    local folder = Instance.new("Folder")
                    folder.Parent = espScreen
                    local box = Instance.new("Frame")
                    box.BackgroundTransparency = 1
                    box.BorderColor3 = Themes[Settings.UI.Theme].Primary
                    box.BorderSizePixel = 1.5
                    box.Visible = false
                    box.Parent = folder
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 13
                    nameLabel.Text = player.Name
                    nameLabel.Visible = false
                    nameLabel.Parent = folder
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.TextColor3 = Color3.fromRGB(215, 215, 215)
                    distanceLabel.Font = Enum.Font.Gotham
                    distanceLabel.TextSize = 11
                    distanceLabel.Visible = false
                    distanceLabel.Parent = folder
                    local healthBar = Instance.new("Frame")
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    healthBar.Size = UDim2.new(0, 50, 0, 3)
                    healthBar.Visible = false
                    healthBar.Parent = folder
                    data = {
                        Folder = folder,
                        Box = box,
                        Name = nameLabel,
                        Distance = distanceLabel,
                        Health = healthBar
                    }
                    State.EspCache[player] = data
                end
                local character = player.Character
                if not character then
                    data.Box.Visible = false
                    data.Name.Visible = false
                    data.Distance.Visible = false
                    data.Health.Visible = false
                    continue
                end
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not (Settings.ESP.Enabled and rootPart and head and humanoid and humanoid.Health > 0) then
                    data.Box.Visible = false
                    data.Name.Visible = false
                    data.Distance.Visible = false
                    data.Health.Visible = false
                    continue
                end
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if not onScreen then
                    data.Box.Visible = false
                    data.Name.Visible = false
                    data.Distance.Visible = false
                    data.Health.Visible = false
                    continue
                end
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local footPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - footPos.Y)
                local width = height * 0.6
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                if Settings.ESP.Boxes then
                    data.Box.Size = UDim2.new(0, width, 0, height)
                    data.Box.Position = UDim2.new(0, rootPos.X - width/2, 0, rootPos.Y - height/2)
                    data.Box.BorderColor3 = healthColor
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                end
                if Settings.ESP.Names then
                    data.Name.Position = UDim2.new(0, rootPos.X - 150, 0, (rootPos.Y - height/2) - 16)
                    data.Name.Size = UDim2.new(0, 300, 0, 14)
                    data.Name.Visible = true
                else
                    data.Name.Visible = false
                end
                if Settings.ESP.Distance then
                    local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                    data.Distance.Text = distance .. " studs"
                    data.Distance.Position = UDim2.new(0, rootPos.X - 150, 0, (rootPos.Y + height/2) + 2)
                    data.Distance.Size = UDim2.new(0, 300, 0, 12)
                    data.Distance.Visible = true
                else
                    data.Distance.Visible = false
                end
                if Settings.ESP.Health then
                    data.Health.Size = UDim2.new(0, width, 0, 3)
                    data.Health.Position = UDim2.new(0, rootPos.X - width/2, 0, rootPos.Y + height/2 + 5)
                    data.Health.BackgroundColor3 = healthColor
                    data.Health.Visible = true
                else
                    data.Health.Visible = false
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if State.EspCache[player] then
            State.EspCache[player].Folder:Destroy()
            State.EspCache[player] = nil
        end
    end)
end

local function setupInputHandling(mainFrame)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == Enum.KeyCode.RightShift and mainFrame then
            State.MenuVisible = not State.MenuVisible
            mainFrame.Visible = State.MenuVisible
        end
        if input.KeyCode == Enum.KeyCode.Q and Settings.Camlock.Enabled then
            State.Locked = not State.Locked
            if State.Locked then
                State.Victim = getClosestTarget()
                if State.Victim then
                    showNotification("Lock", "Tracking: " .. State.Victim.Name)
                else
                    State.Locked = false
                    showNotification("Lock", "No target found")
                end
            else
                State.Victim = nil
                showNotification("Lock", "Released")
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Settings.Movement.InfiniteJump and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function setupMovementSystems()
    local function updateCharacterCache(character)
        State.CharacterParts = {}
        if not character then
            return
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(State.CharacterParts, part)
            end
        end
        character.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then
                table.insert(State.CharacterParts, part)
            end
        end)
    end
    LocalPlayer.CharacterAdded:Connect(updateCharacterCache)
    if LocalPlayer.Character then
        updateCharacterCache(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(function()
        if Settings.RejoinOnDeath then
            safePCall(function()
                local char = LocalPlayer.Character
                if char then
                    char:WaitForChild("Humanoid").Died:Connect(function()
                        task.wait(1)
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            end)
        end
    end)
end

local function setupMainLoop()
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local aimPartName = Settings.Camlock.AimPart or "Head"
        if Settings.Camlock.Enabled and State.Locked and State.Victim and State.Victim.Character then
            local targetPart = State.Victim.Character:FindFirstChild(aimPartName)
            if targetPart then
                local targetPos = targetPart.Position + (targetPart.Velocity * getgenv().Prediction)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), (11 - Settings.Camlock.Smoothness) * 0.045)
            end
        end
        if Settings.Movement.Noclip then
            for _, part in ipairs(State.CharacterParts) do
                part.CanCollide = false
            end
        end
        if Settings.Movement.WalkSpeed.Enabled and hum then
            hum.WalkSpeed = Settings.Movement.WalkSpeed.Value
        end
        if Settings.Movement.Fly.Enabled and root and hum then
            local moveDirection = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                moveDirection = moveDirection + Camera.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                moveDirection = moveDirection - Camera.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                moveDirection = moveDirection - Camera.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                moveDirection = moveDirection + Camera.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                moveDirection = moveDirection + Vector3.new(0, 1, 0) 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                moveDirection = moveDirection - Vector3.new(0, 1, 0) 
            end
            if moveDirection ~= Vector3.zero then
                root.AssemblyLinearVelocity = moveDirection.Unit * Settings.Movement.Fly.Speed
            else
                root.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)
            end
            hum:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)
end

local function initialize()
    safePCall(function()
        local mainFrame, chatWindow, messageContainer, addChatMessage = buildMenu()
        State.ChatSpyWindow = chatWindow
        State.MessageContainer = messageContainer
        State.AddChatMessage = addChatMessage
        State.SpinSpeed = Settings.Troll.SpinSpeed or 50
        State.CurrentTheme = Settings.UI.Theme or "Purple"
        setupESP()
        setupChatSpy()
        setupCommands()
        setupInputHandling(mainFrame)
        setupMovementSystems()
        setupMainLoop()
        applyTheme(Settings.UI.Theme or "Purple")
        updateUI()
        local execName = "Universal"
        if getexecutorname then
            execName = getexecutorname()
        end
        showNotification("KEVWARE v3.0", "Loaded!\n[Right Shift] menu\n[Q] Camlock\nPrefix: " .. (Settings.Commands.Prefix or ";") .. "\nExecutor: " .. execName, 8)
        print("[KEVWARE] Loaded successfully!")
        print("[KEVWARE] Right Shift = menu, Q = camlock")
        print("[KEVWARE] Command prefix: " .. (Settings.Commands.Prefix or ";"))
    end)
end

safePCall(initialize)

safePCall(function()
    local coreGui = game:GetService("CoreGui")
    local robloxGui = coreGui:FindFirstChild("RobloxGui")
    if robloxGui then
        local message = robloxGui:FindFirstChild("Message")
        if message then
            message:Destroy()
        end
    end
end)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character
local humanoid
local rootPart
local animator
local humanoidStateChangedConnection
local seatChangedConnection

local isFlying = false
local isVehicleFlying = false
local currentFlySpeed = 50
local currentVehicleFlySpeed = 30 
local flyAnimationID = "rbxassetid://180435571" 
local flyAnimationTrack

local currentVehicleRoot 
local lvAttachmentPlayer
local linearVelocityPlayer
local alignOrientationPlayer

local lvAttachmentVehicle
local linearVelocityVehicle
local alignOrientationVehicle

local flightUpdateConnection

local isAscendingTouch = false
local isDescendingTouch = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperFlyUI_Diurmio"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global 
screenGui.DisplayOrder = 999 
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "FlightControlFrame_Diurmio"
mainFrame.Size = UDim2.new(0, 250, 0, 200) 
mainFrame.Position = UDim2.new(0.02, 0, 0.5, -mainFrame.Size.Y.Offset / 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(70, 130, 180) 
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255) 
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true 
mainFrame.ZIndex = 10 
mainFrame.Parent = screenGui

local uiCorner_MainFrame = Instance.new("UICorner")
uiCorner_MainFrame.CornerRadius = UDim.new(0, 15)
uiCorner_MainFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title_Diurmio"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Text = "✨ Flight Controls ✨"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.ZIndex = 11
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleFlyButton_Diurmio"
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 45)
toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) 
toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BorderSizePixel = 1
toggleButton.Font = Enum.Font.FredokaOne
toggleButton.Text = "Fly: OFF 🚀"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.ZIndex = 11
toggleButton.Parent = mainFrame

local uiCorner_Button = Instance.new("UICorner")
uiCorner_Button.CornerRadius = UDim.new(0, 8)
uiCorner_Button.Parent = toggleButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel_Diurmio"
speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
speedLabel.Position = UDim2.new(0.1, 0, 0, 95)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.SourceSansSemibold
speedLabel.Text = "Speed Power:"
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240) 
speedLabel.TextSize = 16
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.ZIndex = 11
speedLabel.Parent = mainFrame

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedInput_Diurmio"
speedTextBox.Size = UDim2.new(0.8, 0, 0, 30)
speedTextBox.Position = UDim2.new(0.1, 0, 0, 115)
speedTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
speedTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
speedTextBox.BorderSizePixel = 1
speedTextBox.Font = Enum.Font.SourceSans
speedTextBox.PlaceholderText = "e.g. 50"
speedTextBox.Text = tostring(currentFlySpeed)
speedTextBox.TextColor3 = Color3.fromRGB(30, 30, 30) 
speedTextBox.TextSize = 16
speedTextBox.ClearTextOnFocus = false
speedTextBox.ZIndex = 11
speedTextBox.Parent = mainFrame

local uiCorner_TextBox = Instance.new("UICorner")
uiCorner_TextBox.CornerRadius = UDim.new(0, 8)
uiCorner_TextBox.Parent = speedTextBox

local ascendButton = Instance.new("TextButton")
ascendButton.Name = "AscendButton_Diurmio"
ascendButton.Size = UDim2.new(0.35, 0, 0, 35)
ascendButton.Position = UDim2.new(0.1, 0, 0, 155)
ascendButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113) 
ascendButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ascendButton.BorderSizePixel = 1
ascendButton.Font = Enum.Font.FredokaOne
ascendButton.Text = "UP ▲"
ascendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ascendButton.TextSize = 16
ascendButton.ZIndex = 11
ascendButton.Parent = mainFrame
local uiCorner_Ascend = Instance.new("UICorner"); uiCorner_Ascend.CornerRadius = UDim.new(0,8); uiCorner_Ascend.Parent = ascendButton

local descendButton = Instance.new("TextButton")
descendButton.Name = "DescendButton_Diurmio"
descendButton.Size = UDim2.new(0.35, 0, 0, 35)
descendButton.Position = UDim2.new(0.55, 0, 0, 155)
descendButton.BackgroundColor3 = Color3.fromRGB(255, 99, 71) 
descendButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
descendButton.BorderSizePixel = 1
descendButton.Font = Enum.Font.FredokaOne
descendButton.Text = "DOWN ▼"
descendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
descendButton.TextSize = 16
descendButton.ZIndex = 11
descendButton.Parent = mainFrame
local uiCorner_Descend = Instance.new("UICorner"); uiCorner_Descend.CornerRadius = UDim.new(0,8); uiCorner_Descend.Parent = descendButton

local toggleUIVisibilityButton = Instance.new("TextButton")
toggleUIVisibilityButton.Name = "ToggleUIVisibility_Diurmio"
toggleUIVisibilityButton.Size = UDim2.new(0, 100, 0, 30)
toggleUIVisibilityButton.Position = UDim2.new(0.01, 0, 0.01, 0) 
toggleUIVisibilityButton.AnchorPoint = Vector2.new(0,0)
toggleUIVisibilityButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleUIVisibilityButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleUIVisibilityButton.BorderSizePixel = 1
toggleUIVisibilityButton.Font = Enum.Font.SourceSansSemibold
toggleUIVisibilityButton.Text = "Hide UI"
toggleUIVisibilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIVisibilityButton.TextSize = 14
toggleUIVisibilityButton.Active = true 
toggleUIVisibilityButton.Draggable = true 
toggleUIVisibilityButton.ZIndex = 100 
toggleUIVisibilityButton.Parent = screenGui
local uiCorner_ToggleUI = Instance.new("UICorner"); uiCorner_ToggleUI.CornerRadius = UDim.new(0,8); uiCorner_ToggleUI.Parent = toggleUIVisibilityButton

local function getVehicleRoot(seat)
    if not seat then return nil end
    local parentModel = seat:FindFirstAncestorWhichIsA("Model")
    if parentModel then
        return parentModel.PrimaryPart or parentModel:FindFirstChildWhichIsA("BasePart") 
    end
    return seat 
end

local function updateFlySpeedFromTextBox()
    local num = tonumber(speedTextBox.Text)
    if num and num > 0 then
        if humanoid and humanoid.Sit then
            currentVehicleFlySpeed = num
        else
            currentFlySpeed = num
        end
    else
        if humanoid and humanoid.Sit then
            speedTextBox.Text = tostring(currentVehicleFlySpeed)
        else
            speedTextBox.Text = tostring(currentFlySpeed)
        end
    end
end

local function cleanupFlyMovers(isPlayerMovers)
    if isPlayerMovers then
        if linearVelocityPlayer and linearVelocityPlayer.Parent then linearVelocityPlayer:Destroy() end
        if alignOrientationPlayer and alignOrientationPlayer.Parent then alignOrientationPlayer:Destroy() end
        linearVelocityPlayer = nil
        alignOrientationPlayer = nil
        if flyAnimationTrack and flyAnimationTrack.Parent then
            flyAnimationTrack:Stop(0.1)
            task.delay(0.15, function() 
                if flyAnimationTrack and flyAnimationTrack.Parent then flyAnimationTrack:Destroy() end
                flyAnimationTrack = nil
            end)
        elseif flyAnimationTrack then
             flyAnimationTrack = nil
        end
    else 
        if linearVelocityVehicle and linearVelocityVehicle.Parent then linearVelocityVehicle:Destroy() end
        if alignOrientationVehicle and alignOrientationVehicle.Parent then alignOrientationVehicle:Destroy() end
        linearVelocityVehicle = nil
        alignOrientationVehicle = nil
    end
end

local function disableAllFlight(isCharacterRemovingOrDead)
    if not isFlying and not isVehicleFlying and not isCharacterRemovingOrDead then return end

    local wasPlayerFlying = isFlying
    local wasVehicleFlying = isVehicleFlying

    isFlying = false 
    isVehicleFlying = false
    isAscendingTouch = false
    isDescendingTouch = false
    
    if wasPlayerFlying or wasVehicleFlying then
        if humanoid and humanoid.Sit then
            toggleButton.Text = "vFly: OFF 🚗"
            speedTextBox.Text = tostring(currentVehicleFlySpeed)
        else
            toggleButton.Text = "Fly: OFF 🚀"
            speedTextBox.Text = tostring(currentFlySpeed)
        end
         toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) 
    end

    if flightUpdateConnection then
        flightUpdateConnection:Disconnect()
        flightUpdateConnection = nil
    end

    cleanupFlyMovers(true)  
    cleanupFlyMovers(false) 
    
    if humanoid and humanoid.Parent and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false 
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Running) 
        if not isCharacterRemovingOrDead then
            if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                task.wait(0.1) 
                if humanoid and humanoid.Parent and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    elseif humanoid then 
        humanoid.PlatformStand = false 
        humanoid.AutoRotate = true
    end
    currentVehicleRoot = nil
end

local function setupMovers(targetPart, isPlayerSetup)
    local attachment, linearVel, alignOrient
    local speed = isPlayerSetup and currentFlySpeed or currentVehicleFlySpeed
    local responsiveness = isPlayerSetup and 200 or 15 
    local maxTorque = isPlayerSetup and 2000000 or 10000000 

    if isPlayerSetup then
        if not lvAttachmentPlayer or not lvAttachmentPlayer.Parent then
            if lvAttachmentPlayer then lvAttachmentPlayer:Destroy() end
            lvAttachmentPlayer = Instance.new("Attachment", targetPart)
            lvAttachmentPlayer.Name = "PlayerFlyAttachment_Diurmio"
        end
        attachment = lvAttachmentPlayer
        attachment.CFrame = CFrame.new() 
    else 
        if not lvAttachmentVehicle or not lvAttachmentVehicle.Parent or lvAttachmentVehicle.Parent ~= targetPart then
            if lvAttachmentVehicle then lvAttachmentVehicle:Destroy() end
            lvAttachmentVehicle = Instance.new("Attachment", targetPart)
            lvAttachmentVehicle.Name = "VehicleFlyAttachment_Diurmio"
        end
        attachment = lvAttachmentVehicle
        attachment.CFrame = CFrame.Angles(0, math.rad(90), 0) 
    end
    
    if isPlayerSetup then
        if linearVelocityPlayer then linearVelocityPlayer:Destroy() end
        linearVelocityPlayer = Instance.new("LinearVelocity", targetPart)
        linearVelocityPlayer.Name = "FlightLinearVelocityPlayer_Diurmio"
        linearVelocityPlayer.Attachment0 = attachment
        linearVel = linearVelocityPlayer
    else
        if linearVelocityVehicle then linearVelocityVehicle:Destroy() end
        linearVelocityVehicle = Instance.new("LinearVelocity", targetPart)
        linearVelocityVehicle.Name = "FlightLinearVelocityVehicle_Diurmio"
        linearVelocityVehicle.Attachment0 = attachment
        linearVel = linearVelocityVehicle
    end
    linearVel.MaxForce = math.huge 
    linearVel.VectorVelocity = Vector3.new(0, 0, 0)
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.Enabled = true

    if isPlayerSetup then
        if alignOrientationPlayer then alignOrientationPlayer:Destroy() end
        alignOrientationPlayer = Instance.new("AlignOrientation", targetPart)
        alignOrientationPlayer.Name = "FlightAlignOrientationPlayer_Diurmio"
        alignOrientationPlayer.Attachment0 = attachment
        alignOrient = alignOrientationPlayer
    else
        if alignOrientationVehicle then alignOrientationVehicle:Destroy() end
        alignOrientationVehicle = Instance.new("AlignOrientation", targetPart)
        alignOrientationVehicle.Name = "FlightAlignOrientationVehicle_Diurmio"
        alignOrientationVehicle.Attachment0 = attachment
        alignOrient = alignOrientationVehicle
    end
    alignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrient.Responsiveness = responsiveness
    alignOrient.MaxAngularVelocity = math.huge
    alignOrient.MaxTorque = maxTorque
    alignOrient.PrimaryAxisOnly = false 
    alignOrient.Enabled = true

    return linearVel, alignOrient
end

local function activateFlight()
    if not character or not humanoid or not rootPart or not animator then return end
    if isFlying or isVehicleFlying then return end 

    local currentSpeedToUse
    local targetForMovers

    if humanoid.Sit and humanoid.SeatPart then
        isVehicleFlying = true
        toggleButton.Text = "vFly: ON ✈️"
        speedTextBox.Text = tostring(currentVehicleFlySpeed)
        currentVehicleRoot = getVehicleRoot(humanoid.SeatPart)
        if not currentVehicleRoot then
            isVehicleFlying = false 
            return
        end
        targetForMovers = currentVehicleRoot
        currentSpeedToUse = currentVehicleFlySpeed
        linearVelocityVehicle, alignOrientationVehicle = setupMovers(targetForMovers, false)
    else 
        isFlying = true
        toggleButton.Text = "Fly: ON ✨"
        speedTextBox.Text = tostring(currentFlySpeed)
        humanoid.PlatformStand = true 
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid:ChangeState(Enum.HumanoidStateType.Physics) 
                
        targetForMovers = rootPart
        currentSpeedToUse = currentFlySpeed
        linearVelocityPlayer, alignOrientationPlayer = setupMovers(targetForMovers, true)
        
        if flyAnimationTrack then flyAnimationTrack:Stop(); flyAnimationTrack:Destroy() end
        local anim = Instance.new("Animation")
        anim.AnimationId = flyAnimationID
        flyAnimationTrack = animator:LoadAnimation(anim)
        anim:Destroy()
        flyAnimationTrack.Priority = Enum.AnimationPriority.Action 
        flyAnimationTrack.Looped = true
        flyAnimationTrack:Play(0.1)
    end
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) 

    if flightUpdateConnection then flightUpdateConnection:Disconnect() end
    flightUpdateConnection = RunService.RenderStepped:Connect(function(deltaTime)
        local activeLinearVel = isVehicleFlying and linearVelocityVehicle or linearVelocityPlayer
        local activeAlignOrient = isVehicleFlying and alignOrientationVehicle or alignOrientationPlayer
        local activeSpeed = isVehicleFlying and currentVehicleFlySpeed or currentFlySpeed
        local currentTarget = isVehicleFlying and currentVehicleRoot or rootPart

        if not (isFlying or isVehicleFlying) or not character or not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead or not currentTarget or not currentTarget.Parent or not camera or not activeLinearVel or not activeAlignOrient or not activeLinearVel.Parent or not activeAlignOrient.Parent then
            if isFlying or isVehicleFlying then disableAllFlight(character and humanoid:GetState() == Enum.HumanoidStateType.Dead) end
            return
        end
        
        if humanoid.Sit and not isVehicleFlying and isFlying then 
            disableAllFlight(false) 
            activateFlight() 
            return
        elseif not humanoid.Sit and isVehicleFlying then
            disableAllFlight(false) 
            currentVehicleRoot = nil 
            updateButtonAndSpeedText()
            return 
        end

        activeAlignOrient.CFrame = CFrame.lookAt(Vector3.zero, camera.CFrame.LookVector)

        local finalMoveVector = Vector3.new()
        local cameraCF = camera.CFrame
        local cameraLook = cameraCF.LookVector
        local cameraRight = cameraCF.RightVector
        local worldUp = Vector3.new(0,1,0)

        local hasKeyboardDirectionalInput = false
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then finalMoveVector = finalMoveVector + cameraLook; hasKeyboardDirectionalInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then finalMoveVector = finalMoveVector - cameraLook; hasKeyboardDirectionalInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then finalMoveVector = finalMoveVector - cameraRight; hasKeyboardDirectionalInput = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then finalMoveVector = finalMoveVector + cameraRight; hasKeyboardDirectionalInput = true end

        if not hasKeyboardDirectionalInput and humanoid then
            local moveDirFromJoystick = humanoid.MoveDirection 
            if moveDirFromJoystick.Magnitude > 0.05 then 
                local relativeJoystickIntent = cameraCF:VectorToObjectSpace(moveDirFromJoystick)
                finalMoveVector = finalMoveVector + (cameraLook * -relativeJoystickIntent.Z) 
                finalMoveVector = finalMoveVector + (cameraRight * relativeJoystickIntent.X)
            end
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) or isAscendingTouch then
            finalMoveVector = finalMoveVector + worldUp
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or isDescendingTouch then
            finalMoveVector = finalMoveVector - worldUp
        end
        
        if finalMoveVector.Magnitude > 0.01 then
            activeLinearVel.VectorVelocity = finalMoveVector.Unit * activeSpeed
        else
            activeLinearVel.VectorVelocity = Vector3.new(0,0,0)
        end
    end)
end

local function updateButtonAndSpeedText()
    if not humanoid then return end
    if humanoid.Sit and humanoid.SeatPart then
        if isVehicleFlying then
            toggleButton.Text = "vFly: ON ✈️"
            toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        else
            toggleButton.Text = "vFly: OFF 🚗"
            toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        end
        speedTextBox.Text = tostring(currentVehicleFlySpeed)
    else
        if isFlying then
            toggleButton.Text = "Fly: ON ✨"
            toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        else
            toggleButton.Text = "Fly: OFF 🚀"
            toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        end
        speedTextBox.Text = tostring(currentFlySpeed)
    end
end

local function setupCharacterRelatedLogic(newChar)
    if character then
        disableAllFlight(true) 
    end

    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    animator = humanoid:WaitForChild("Animator")

    if lvAttachmentPlayer and lvAttachmentPlayer.Parent then lvAttachmentPlayer:Destroy() end
    lvAttachmentPlayer = Instance.new("Attachment")
    lvAttachmentPlayer.Name = "PlayerFlyAttachment_Diurmio"
    lvAttachmentPlayer.CFrame = CFrame.new() 
    lvAttachmentPlayer.Parent = rootPart

    if humanoidStateChangedConnection then humanoidStateChangedConnection:Disconnect() end
    humanoidStateChangedConnection = humanoid.Died:Connect(function()
        disableAllFlight(true)
    end)

    if seatChangedConnection then seatChangedConnection:Disconnect() end
    seatChangedConnection = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if humanoid.Sit then 
            if isFlying then disableAllFlight(false) end 
        else 
            if isVehicleFlying then disableAllFlight(false) end
            currentVehicleRoot = nil
        end
        updateButtonAndSpeedText() 
    end)
    
    updateButtonAndSpeedText() 
end

toggleButton.MouseButton1Click:Connect(function()
    if not character or not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
        titleLabel.Text = "Wait for character! 🤔"
        task.delay(1.5, function() if titleLabel and titleLabel.Parent then titleLabel.Text = "✨ Flight Controls ✨" end end)
        return
    end
    
    if isFlying or isVehicleFlying then
        disableAllFlight(false)
    else
        activateFlight()
    end
    updateButtonAndSpeedText() 
end)

speedTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        updateFlySpeedFromTextBox()
    else 
        updateFlySpeedFromTextBox() 
    end
end)

local function handleUpDownButtonInput(input, buttonType, isBeginning)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if buttonType == "ascend" then
            isAscendingTouch = isBeginning
        elseif buttonType == "descend" then
            isDescendingTouch = isBeginning
        end
    end
end

ascendButton.InputBegan:Connect(function(input) handleUpDownButtonInput(input, "ascend", true) end)
ascendButton.InputEnded:Connect(function(input) handleUpDownButtonInput(input, "ascend", false) end)

descendButton.InputBegan:Connect(function(input) handleUpDownButtonInput(input, "descend", true) end)
descendButton.InputEnded:Connect(function(input) handleUpDownButtonInput(input, "descend", false) end)

toggleUIVisibilityButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        toggleUIVisibilityButton.Text = "Hide UI"
    else
        toggleUIVisibilityButton.Text = "Show UI"
    end
end)

local function onCharacterAdded(newChar)
    setupCharacterRelatedLogic(newChar)
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterRemoving:Connect(function(charBeingRemoved)
    if charBeingRemoved == character then
        disableAllFlight(true) 
    end
end)

print("Diurmio's Flight UI is ready for liftoff! 🚀")
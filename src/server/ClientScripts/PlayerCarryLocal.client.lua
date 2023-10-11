local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local AnimationClass = require(script.Parent.AnimationClass)

-- folders
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local BindableFunctions = ReplicatedStorage:WaitForChild("BindableFunctions")

-- remote events
local carryRequest = RemoteEvents:WaitForChild("CarryRequest")
local carryResponse = RemoteEvents:WaitForChild("CarryResponse")
local responseToCarry = RemoteEvents:WaitForChild("ResponseToCarry")
local updateAnimation = RemoteEvents:WaitForChild("UpdateAnimation")

-- bindable events/ signals
local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local playerCarryMneuActivated = BindableEvents:WaitForChild("PlayerCarryMenuActivated")

-- bindable functions
local respondToCarry = BindableFunctions:WaitForChild("RespondToCarry")

local SHOULDERS_ID = 8586038771
local BACK_ID = 8534837656
local HAND_ID = 8534789996
local CARRYING_ID = 8534933555

local TWEEN_TIME = 0.5
local TWEEN_EASING_STYLE = Enum.EasingStyle.Linear
local TWEEN_INFO = TweenInfo.new(TWEEN_TIME, TWEEN_EASING_STYLE)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PlayerCarryMenu = playerGui:WaitForChild("PlayerCarryMenu")
local carryButtonsHolder = PlayerCarryMenu:WaitForChild("Frame")
local backButton = carryButtonsHolder:WaitForChild("BACK")
local handButton = carryButtonsHolder:WaitForChild("HAND")
local shouldersButton = carryButtonsHolder:WaitForChild("SHOULDER")

local tweenGoal = {}
tweenGoal.StudOffset = Vector2.new(0, 0.4)

local animationInstances = {
	SHOULDERS = AnimationClass.new(SHOULDERS_ID),
	BACK = AnimationClass.new(BACK_ID),
	HAND = AnimationClass.new(HAND_ID),
	CARRYING = AnimationClass.new(CARRYING_ID),
}

-- set animation tracks for all animation instances
for animationNameKey, animationClassValue in animationInstances do
	animationClassValue:setTrack(player)

	print("SetTrackFor:  ", animationNameKey)
end

local function onRespondToCarry(buttonText)
	local response = buttonText == "Yes"
	responseToCarry:FireServer(response)
end

local function onCarryResponse()
	PlayerCarryMenu.Adornee = nil
end

local function onUpdateAnimation(carryType, playerCarryingName, stopping)
	if stopping then
		animationInstances[carryType]:stop(player)
	else
		local playerIsCarrying = playerCarryingName == player.Name
		local carryTypeIsHand = carryType == "HAND"
		if playerIsCarrying and carryTypeIsHand then
			carryType = "CARRYING"
		end

		animationInstances[carryType]:play(player)
	end

	print("OnUpdateAnimation:  animation complete.")
end

local function onCarrySignal(playerToCarryName, carryType)
	print("Signal:  called activate carry signal.")
	
	carryRequest:FireServer(playerToCarryName, carryType)
end

local function onPlayerCarryMenuActivated(otherPlayer)
	local otherPlayerName = nil
	for _, plr in Players:GetPlayers() do
		if plr.Name == otherPlayerName then
			local otherCharacter = otherPlayer.Character
			if not otherCharacter then
				return warn("onPlayerCarryMenuActivated:  attempt to index nil with other character.")
			end

			local otherHumanoidRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
			if not otherHumanoidRootPart then
				return warn("onPlayerCarryMenuActivated:  attempt to index nil with other humanoidRootPart.")
			end

			PlayerCarryMenu.Adornee = otherHumanoidRootPart

			local tween = TweenService:Create(PlayerCarryMenu, TWEEN_INFO, tweenGoal)
			tween:Play()
		end
	end
end

local function onCarryButtonActivated(button)
	local playerToCarryName = PlayerCarryMenu.Adornee

	carryRequest:FireServer(playerToCarryName, button.Name)

	PlayerCarryMenu.Adornee = nil
	
end

-- bindings
carryResponse.OnClientEvent:Connect(onCarryResponse)
updateAnimation.OnClientEvent:Connect(onUpdateAnimation)

carrySignal.Event:Connect(onCarrySignal)
playerCarryMneuActivated.Event:Connect(onPlayerCarryMenuActivated)

respondToCarry.OnInvoke = onRespondToCarry

shouldersButton.Activated:Connect(onCarryButtonActivated)
handButton.Activated:Connect(onCarryButtonActivated)
backButton.Activated:Connect(onCarryButtonActivated)
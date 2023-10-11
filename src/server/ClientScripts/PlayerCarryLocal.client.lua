local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- bindable functions
local respondToCarry = BindableFunctions:WaitForChild("RespondToCarry")

local SHOULDERS_ID = 8586038771
local BACK_ID = 8534837656
local HAND_ID = 8534789996
local CARRYING_ID = 8534933555

local player = Players.LocalPlayer

local animationInstances = {
	SHOULDERS = AnimationClass.new(SHOULDERS_ID),
	BACK = AnimationClass.new(BACK_ID),
	HAND = AnimationClass.new(HAND_ID),
	CARRYING = AnimationClass.new(CARRYING_ID),
}

-- set animation tracks for all animation instances
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")

	for animationNameKey, animationClassValue in animationInstances do
		animationClassValue:setTrack(player)
	
		print("SetTrackFor:  ", animationNameKey)
	end
end)

local function onRespondToCarry(buttonText)
	local response = buttonText == "Yes"
	responseToCarry:FireServer(response)
end

local function onCarryResponse()

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

-- bindings
carryResponse.OnClientEvent:Connect(onCarryResponse)
updateAnimation.OnClientEvent:Connect(onUpdateAnimation)
carrySignal.Event:Connect(onCarrySignal)
respondToCarry.OnInvoke = onRespondToCarry
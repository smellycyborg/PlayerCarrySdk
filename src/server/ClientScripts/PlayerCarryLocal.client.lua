local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local AnimationClass = require(script.Parent.AnimationClass)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local BindableFunctions = ReplicatedStorage:WaitForChild("BindableFunctions")

local carryRequest = RemoteEvents:WaitForChild("CarryRequest")
local carryResponse = RemoteEvents:WaitForChild("CarryResponse")
local responseToCarry = RemoteEvents:WaitForChild("ResponseToCarry")
local updateAnimation = RemoteEvents:WaitForChild("UpdateAnimation")
local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local respondToCarry = BindableFunctions:WaitForChild("RespondToCarry")

local SHOULDERS_ID = nil
local BACK_ID = nil
local HAND_ID = nil

local player = Players.LocalPlayer

local animationInstances = {
	SHOULDERS = AnimationClass.new(SHOULDERS_ID),
	BACK = AnimationClass.new(BACK_ID),
	HAND = AnimationClass.new(HAND_ID),
}

for animationNameKey, animationClassValue in animationInstances do
	animationClassValue:setTrack(player)
end

local function onRespondToCarry(buttonText)
	local response = buttonText == "Yes"
	responseToCarry:FireServer(response)
end

local function onCarryResponse()

end

local function onUpdateAnimation(carryType, stopping)
	if stopping then
		animationInstances[carryType]:stop()
	else
		animationInstances[carryType]:play()
	end
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
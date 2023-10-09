local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local BindableFunctions = ReplicatedStorage:WaitForChild("BindableFunctions")

local carryRequest = RemoteEvents:WaitForChild("CarryRequest")
local carryRequested = RemoteEvents:WaitForChild("CarryRequested")
local carryResponse = RemoteEvents:WaitForChild("CarryResponse")
local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local respondToCarry = BindableFunctions:WaitForChild("RespondToCarry")
local responseToCarry = RemoteEvents:WaitForChild("ResponseToCarry")

local function onRespondToCarry(buttonText)
	local response = buttonText == "Yes"
	responseToCarry:FireServer(response)
end

local function onCarryResponse()

end

local function onCarrySignal(playerToCarryName, carryType)
	print("Signal:  called activate carry signal.")
	
	carryRequest:FireServer(playerToCarryName, carryType)
end

carryResponse.OnClientEvent:Connect(onCarryResponse)
carrySignal.Event:Connect(onCarrySignal)
respondToCarry.OnInvoke = onRespondToCarry
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")

local carryRequest = RemoteEvents:WaitForChild("CarryRequest")
local carryResponse = RemoteEvents:WaitForChild("CarryResponse")
local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local requestSignal = BindableEvents:WaitForChild("RequestSignal")

local isTesting = true

local function onCarryResponse()
	
end

local function onCarrySignal(playerToCarryName, carryType)
	print("Signal:  called activate carry signal.")
	
	carryRequest:FireServer(playerToCarryName, carryType)
end

carryResponse.OnClientEvent:Connect(onCarryResponse)
carrySignal.Event:Connect(onCarrySignal)
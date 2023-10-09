local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")

local carryRequest = RemoteEvents:WaitForChild("CarryRequest")
local carryRequested = RemoteEvents:WaitForChild("CarryRequested")
local carryResponse = RemoteEvents:WaitForChild("CarryResponse")
local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local requestSignal = BindableEvents:WaitForChild("RequestSignal")

local isTesting = true

local function onCarryRequested(args)
	StarterGui:SetCore("SendNotification")
end

local function onCarryResponse()
	
end

local function onCarrySignal(playerToCarryName, carryType)
	print("Signal:  called activate carry signal.")
	
	carryRequest:FireServer(playerToCarryName, carryType)
end

carryRequested.OnClientEvent:Connect(onCarryRequested)
carryResponse.OnClientEvent:Connect(onCarryResponse)
carrySignal.Event:Connect(onCarrySignal)
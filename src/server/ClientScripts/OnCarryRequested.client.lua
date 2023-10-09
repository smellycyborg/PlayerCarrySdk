local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BindableFunctions = ReplicatedStorage:WaitForChild("BindableFunctions")

local carryRequested = RemoteEvents:WaitForChild("CarryRequested")
local respondToCarry = BindableFunctions:WaitForChild("RespondToCarry")

local function onCarryRequested(args)
	print("OnCarryRequested:  should send notification.")
	
	StarterGui:SetCore("SendNotification", {
		Title = "Carry Request",
		Text = args.playerCarryingName .. " would like to carry you.",
		Callback = respondToCarry,
		Button1 = "Yes",
		Button2 = "No",
	})
end

carryRequested.OnClientEvent:Connect(onCarryRequested)


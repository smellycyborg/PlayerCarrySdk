local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local carrySignal = BindableEvents:WaitForChild("CarrySignal")
local carryRequested = RemoteEvents:WaitForChild("CarryRequested")
local responseToCarry = RemoteEvents:WaitForChild("ResponseToCarry")

local TEST_RESPONSE = true

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TestUi = playerGui:WaitForChild("TestUi")
local scrollingFrame = TestUi:WaitForChild("ScrollingFrame")

task.spawn(function()
	while task.wait(5) do
		print("PlayerAdded:  local script.")

		for _, plr in Players:GetPlayers() do
			if plr == game.Players.LocalPlayer then
				continue
			else
				if scrollingFrame:FindFirstChild(plr.Name) then
					continue
				end

				local carryButton = Instance.new("TextButton")
				carryButton.Name = plr.Name .. "Button"
				carryButton.Size = UDim2.fromScale(1, 0.2)
				carryButton.Text = "Carry " .. plr.name
				carryButton.Parent = scrollingFrame

				carryButton.Activated:Connect(function()
					carrySignal:Fire(plr.Name, "SHOULDERS")
				end)
			end
		end
	end
end)

carryRequested.OnClientEvent:Connect(function(args)
	local approveButton = Instance.new("TextButton")
	approveButton.Name = "ApproveButton"
	approveButton.AnchorPoint = Vector2.new(0.5, 0)
	approveButton.Position = UDim2.fromScale(0.5, 0)
	approveButton.Size = UDim2.fromScale(1, 0.2)
	approveButton.Text = "Approve " .. args.playerCarryingName
	approveButton.Parent = TestUi

	approveButton.Activated:Connect(function()
		responseToCarry:FireServer(TEST_RESPONSE, "SHOULDERS")
	end)
end)
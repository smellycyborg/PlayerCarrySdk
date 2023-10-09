local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BindableEvents = ReplicatedStorage:WaitForChild("BindableEvents")

local carrySignal = BindableEvents:WaitForChild("CarrySignal")

local TEST_RESPONSE = true
local TEST_CARRY = "SHOULDERS"

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
					carrySignal:Fire(plr.Name, TEST_CARRY)
				end)
			end
		end
	end
end)
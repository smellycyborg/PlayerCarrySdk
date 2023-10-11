local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local PLAYER_LEFT_THE_GAME_MESSAGE = "The player requested to carry has left the game."
local STOPPING = true

local isTesting = true

local PlayerCarrySdk = {
	pendingRequests = {},
	playersActive = {},
	statePerPlayer = {},
}

local function _activateCarry(playerCarrying, playerToCarry, cFrame)
	local humanoidToCarry = playerToCarry.Character:FindFirstChild("Humanoid")
	humanoidToCarry.PlatformStand = true
	
	playerToCarry.Character.HumanoidRootPart.CFrame = cFrame
	
	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = playerToCarry.Character.HumanoidRootPart
	weld.Part1 = playerCarrying.Character.HumanoidRootPart
	weld.Parent = playerToCarry.Character
	
	playerCarrying.Character.HumanoidRootPart:SetNetworkOwner(playerCarrying)
end

local carryTypes = {
	SHOULDERS = {
		name = "Shoulder Carry",
		callback = function(playerCarrying, playerToCarry)
			local cFrame = playerCarrying.Character.HumanoidRootPart.CFrame * 
			CFrame.new(1, 1, 0) *
			CFrame.fromEulerAnglesXYZ(math.pi / 2, 0, 0)

			_activateCarry(playerCarrying, playerToCarry, cFrame)
		end,
	},
	BACK = {
		name = "Back Carry",
		callback = function(playerCarrying, playerToCarry)
			local cFrame = playerCarrying.Character.HumanoidRootPart.CFrame * 
			CFrame.new(1, 1, 0) *
			CFrame.fromEulerAnglesXYZ(math.pi / 2, 0, 0)

			_activateCarry(playerCarrying, playerToCarry, cFrame)
		end,
	},
	HAND = {
		name = "Hand Carry",
		callback = function(playerCarrying, playerToCarry)
			local cFrame = playerCarrying.Character.HumanoidRootPart.CFrame * 
			CFrame.new(1, 1, 0) *
			CFrame.fromEulerAnglesXYZ(math.pi / 2, 0, 0)

			_activateCarry(playerCarrying, playerToCarry, cFrame)
		end,
	}
}

-- checks to see if player's character exists
local function _doesPlayerExist(player)
	local character = player.Character
	if not player.Character 
		or not player.Character:FindFirstChild("Humanoid")
		or not player.Character:FindFirstChild("HumanoidRootPart") then

		return false
	end

	return true
end

local function _carry(playerCarrying, playerToCarry, carryType)
	if not _doesPlayerExist(playerCarrying) or not _doesPlayerExist(playerToCarry) then
		return warn("_carry:  player does not exist.")
	end
	
	carryTypes[carryType].callback(playerCarrying, playerToCarry)
	
	print("_carry:  completed.")
end

local function _getInfoForRemoving(player, arrey)
	local foundPlayer, otherPlayer, isCarrier
	
	for _, players in arrey do
		if players.playerToCarry == player then
			foundPlayer = true
			otherPlayer = players.playerCarrying
			isCarrier = true
		elseif players.playerCarrying == player then
			foundPlayer = true
			otherPlayer = players.playerToCarry
			isCarrier = false
		end
	end
	
	return foundPlayer, otherPlayer, isCarrier
end

local function characterRemoving(character)
	local player = Players:GetPlayerFromCharacter(character)

	for index, players in PlayerCarrySdk.pendingRequests do
		for _, plr in players do
			if plr == player then
				players.playerToCarry.Character:FindFirstChild("CarryWeld"):Destroy()

				updateAnimation:FireClient(players.playerToCarry, players.carryType, players.playerCarrying.Name, STOPPING)
				updateAnimation:FireClient(players.playerCarrying, players.carryType, players.playerCarrying.Name, STOPPING)

				table.remove(PlayerCarrySdk.playersActive, index)
			end
		end
	end
end

local function playerAdded(player)
	if isTesting then
		local testUiClone = script.Parent.TestUi:Clone()
		testUiClone.Parent = player:WaitForChild("PlayerGui")
	end

	PlayerCarrySdk.statePerPlayer[player] = "NONE"

	player.CharacterRemoving:Connect(characterRemoving)
end

local function playerRemoving(player)
	if not next(PlayerCarrySdk.pendingRequests) and not next(PlayerCarrySdk.playersActive) then
		return
	end
	
	for index, players in PlayerCarrySdk.pendingRequests do
		local foundPlayer, otherPlayer, isCarrier = _getInfoForRemoving(player, PlayerCarrySdk.pendingRequests)
		
		if not foundPlayer then
			continue
		elseif foundPlayer then
			carryResponse:FireClient(otherPlayer, isCarrier)
			
			table.remove(PlayerCarrySdk.pendingRequests, index)
			
			return
		end
	end
	
	for index, players in PlayerCarrySdk.playersActive do
		local foundPlayer, otherPlayer, isCarrier = _getInfoForRemoving(player, PlayerCarrySdk.playersActive)
		
		if not foundPlayer then
			continue
		elseif foundPlayer then
			-- TODO:  get rid of weld and take action based off isCarrier variable
		end
	end
end

local function onCarryRequest(playerCarrying, playerToCarryName, carryType)
	-- defense so the player cannot request again
	for _, players in PlayerCarrySdk.pendingRequests do
		for _, player in players do
			if player == playerCarrying then
				return
			end
		end
	end

	local playerToCarry
	for _, player in Players:GetPlayers() do
		if player.Name == playerToCarryName then
			playerToCarry = player
		end
	end
	if not playerToCarry then
		return warn("OnCarryResponse:  player to carry did not exist in game.")
	end
	
	local playerExists = _doesPlayerExist(playerToCarry)
	if not playerExists then
		carryResponse:FireClient(playerCarrying, PLAYER_LEFT_THE_GAME_MESSAGE)
		
		return warn("CarryRequest:  a player's character or humanoid or humanoidRootPart does not exist.  Result -> ", playerExists)
	end
	
	table.insert(PlayerCarrySdk.pendingRequests, {
		playerCarrying = playerCarrying,
		playerToCarry = playerToCarry,
		carryType = carryType
	})
	
	carryRequested:FireClient(playerToCarry, {
		playerCarryingName = playerCarrying.Name,
		carryType = carryType,
		carryingTypeName = carryTypes[carryType].name,
	})
	
	print("CarryRequest:  completed.")
end

local function onResponseToCarry(playerToCarry, response, _carryType)
	if PlayerCarrySdk.statePerPlayer[playerToCarry] == "RESPONDING" then
		return warn("ResponseToCarry:  player's state is already responding.")
	end
	
	PlayerCarrySdk.statePerPlayer[playerToCarry] = "RESPONDING"
	
	for index, players in PlayerCarrySdk.pendingRequests do
		if players.playerToCarry == playerToCarry then
			if not response then
				table.remove(PlayerCarrySdk.pendingRequests, index)
			elseif response == true then
				carryResponse:FireClient(players.playerCarrying, response)
				
				_carry(players.playerCarrying, players.playerToCarry, players.carryType)

				updateAnimation:FireClient(players.playerToCarry, players.carryType, players.playerCarrying.Name)
				updateAnimation:FireClient(players.playerCarrying, players.carryType, players.playerCarrying.Name)

				table.insert(PlayerCarrySdk.playersActive, players)
				table.remove(PlayerCarrySdk.pendingRequests, index)
				
				print("CarryResponse:  called _carry()")
			end

			PlayerCarrySdk.statePerPlayer[playerToCarry] = "NONE"
			
			print("CarryResponse:  completed.")
			
			return
		end
	end
end

local function onStopCarry(player)
	if PlayerCarrySdk.statePerPlayer[player] == "STOPPING" then
		return warn("ResponseToCarry:  player's state is already stopping.")
	end

	PlayerCarrySdk.statePerPlayer[player] = "STOPPING"

	for index, players in PlayerCarrySdk.playersActive do
		-- loop through players and find the matching table of players that are active
		for key, value in players do
			if value == player then
				players.playerToCarry.Character:FindFirstChild("CarryWeld"):Destroy()

				updateAnimation:FireClient(players.playerToCarry, players.carryType, players.playerCarrying.Name, STOPPING)
				updateAnimation:FireClient(players.playerCarrying, players.carryType, players.playerCarrying.Name, STOPPING)

				table.remove(PlayerCarrySdk.playersActive, index)

				PlayerCarrySdk.statePerPlayer[player] = "NONE"
			end
		end
	end
end

function PlayerCarrySdk.init()
	-- parenting client scripts
	local ClientScripts = script.Parent.ClientScripts
	ClientScripts.Parent = StarterPlayer.StarterPlayerScripts
	
	-- folders
	local remoteEvents = Instance.new("Folder", ReplicatedStorage)
	remoteEvents.Name = "RemoteEvents"
	local bindableEvents = Instance.new("Folder", ReplicatedStorage)
	bindableEvents.Name = "BindableEvents"
	local bindableFunctions = Instance.new("Folder", ReplicatedStorage)
	bindableFunctions.Name = "BindableFunctions"
	
	-- remote events
	local carryRequest = Instance.new("RemoteEvent", remoteEvents)
	carryRequest.Name = "CarryRequest"
	carryRequested = Instance.new("RemoteEvent", remoteEvents)
	carryRequested.Name = "CarryRequested"
	carryResponse = Instance.new("RemoteEvent", remoteEvents)
	carryResponse.Name = "CarryResponse"
	local responseToCarry = Instance.new("RemoteEvent", remoteEvents)
	responseToCarry.Name = "ResponseToCarry"
	local stopCarry = Instance.new("RemoteEvent", remoteEvents)
	stopCarry.Name = "StopCarry"
	updateAnimation = Instance.new("RemoteEvent", remoteEvents)
	updateAnimation.Name = "UpdateAnimation"
	
	-- bindable events
	local carrySignal = Instance.new("BindableEvent", bindableEvents)
	carrySignal.Name = "CarrySignal"
	local requestSignal = Instance.new("BindableEvent", bindableEvents)
	requestSignal.Name = "RequestSignal"

	-- bindable functons
	local respondToCarry = Instance.new("BindableFunction", bindableFunctions)
	respondToCarry.Name = "RespondToCarry"
	
	-- bindings
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
	carryRequest.OnServerEvent:Connect(onCarryRequest)
	responseToCarry.OnServerEvent:Connect(onResponseToCarry)
	stopCarry.OnServerEvent:Connect(onStopCarry)
	
end

return PlayerCarrySdk
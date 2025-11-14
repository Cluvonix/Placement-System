local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementController = require(ReplicatedStorage.Systems.PlacementSystem.PlacementController)

local player = Players.LocalPlayer

local function onCharacterAdded(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and ReplicatedStorage.Assets:FindFirstChild(child.Name) then
			PlacementController:BindPlacement(child)
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local PlacementController = {}
PlacementController.__index = PlacementController

-- client side systems for placementsystem.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local ClientPreview = require(ReplicatedStorage.Systems.PlacementSystem.ClientPreview)

local assets = ReplicatedStorage.Assets
local network = ReplicatedStorage.Network
local placement = network.Placement
local placeEvent = placement.PlaceEvent

local preview
local PLACE_ACTION = "PlaceObject"
local ROTATE_ACTION = "RotateObject"

function PlacementController:BindPlacement(tool)
	local modelClone = assets:FindFirstChild(tool.Name):Clone()
	
	local preview = ClientPreview.new(modelClone)
	preview:EnablePlacement()
	
	-- Bind place input
	ContextActionService:BindAction(
		PLACE_ACTION,
		function(_, inputState)
			if inputState ~= Enum.UserInputState.Begin then return end
			if not preview then return end

			if preview:CheckValidLocation() then
				local cf = preview.model:GetPivot()
				placeEvent:FireServer(tool.Name, cf)

				preview:DisablePlacement()
				ContextActionService:UnbindAction(PLACE_ACTION)
			end
		end,
		true,
		Enum.UserInputType.MouseButton1,
		Enum.KeyCode.ButtonR2,
		Enum.KeyCode.ButtonA,
		Enum.UserInputType.Touch
	)
	
	-- Bind rotate input
	ContextActionService:BindAction(
		ROTATE_ACTION,
		function(_, inputState)
			if inputState ~= Enum.UserInputState.Begin then return end
			if not preview then return end
			
			if preview:CheckValidLocation() then
				preview:Rotate()

			end
		end,
		true,
		Enum.KeyCode.R,
		Enum.KeyCode.ButtonR1
	)
	
	tool.Unequipped:Connect(function()
		preview:DisablePlacement()
		ContextActionService:UnbindAction(PLACE_ACTION)
		ContextActionService:UnbindAction(ROTATE_ACTION)
	end)
end

return PlacementController

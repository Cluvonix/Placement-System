local ClientPreview = {}
ClientPreview.__index = ClientPreview

-- client side systems for placementsystem.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local network = ReplicatedStorage.Network
local placementRemotes = network.Placement
local getPlotEvent = placementRemotes.GetPlotEvent

local preview
local PLACE_ACTION = "PlaceObject"

function ClientPreview.new(model)
	-- base appearance and logic
	local self = setmetatable({}, ClientPreview)
	
	self.name = model.Name
	self.model = model
	self.active = false
	self.connection = nil
	self.rotationY = 0
	
	for i, basePart in self.model:GetChildren() do
		if basePart:IsA("BasePart") then
			basePart.Transparency = 0.5
			basePart.BrickColor = BrickColor.new("Lime green")
			basePart.CanCollide = false -- CHANGE TO COLLISSION GROUPS
		end
	end
	
	return self
end

function ClientPreview:SetModelStyle(canPlace)
	-- change color depending on if canplace
	for i, basePart in self.model:GetChildren() do
		if basePart:IsA("BasePart") then
			basePart.BrickColor = BrickColor.new(canPlace and "Lime green" or "Really red")
		end
	end
end

function ClientPreview:CheckValidLocation()
	local plot = getPlotEvent:InvokeServer()
	local plotBase = plot:FindFirstChild("Base")
	
	-- check if model parts overlap others
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {self.model, plotBase, player.Character} -- EXAMPLE ITEMS HERE CHANGE TO COLLISSION GROUPS
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local cf, size = self.model:GetBoundingBox()
	local touching = workspace:GetPartBoundsInBox(cf, size, params)
	if #touching > 0 then
		return false
	end

	-- check if model is inside plot (X/Z only)
	local _, modelSize = self.model:GetBoundingBox()
	local modelPos = self.model:GetPivot().Position
	local halfModel = modelSize / 2

	local plotPos = plotBase.Position
	local halfPlot = plotBase.Size / 2

	local minX, maxX = modelPos.X - halfModel.X, modelPos.X + halfModel.X
	local minZ, maxZ = modelPos.Z - halfModel.Z, modelPos.Z + halfModel.Z

	local bMinX, bMaxX = plotPos.X - halfPlot.X, plotPos.X + halfPlot.X
	local bMinZ, bMaxZ = plotPos.Z - halfPlot.Z, plotPos.Z + halfPlot.Z

	local xInside = minX >= bMinX and maxX <= bMaxX
	local zInside = minZ >= bMinZ and maxZ <= bMaxZ

	if xInside == false or zInside == false then
		return false
	end
	
	-- if none are false then checks are complete
	return true
end

function ClientPreview:ModelToMouse(modelOffset)
		-- raycast from mouse
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character or player.CharacterAdded:Wait(), self.model}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(mouse.UnitRay.Origin,mouse.UnitRay.Direction * 1000, params)
	if result then
		-- move model to racast position and take into account rotation
		local pos = result.Position + Vector3.new(0, modelOffset, 0)
		local rotation = CFrame.Angles(0, math.rad(self.rotationY), 0)
		self.model:PivotTo(CFrame.new(pos) * rotation)
	end
end

function ClientPreview:EnablePlacement()
	if self.active == true then return end
	self.active = true
	
	-- gives a offset to keep model leveled with floor
	local cf, size = self.model:GetBoundingBox()
	local modelOffset = size.Y / 2
	
	-- racast from mouse
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character or player.CharacterAdded:Wait(), self.model}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(mouse.UnitRay.Origin,mouse.UnitRay.Direction * 1000, params)
	if result then
		-- move model to racast position
		self.model:PivotTo(CFrame.new(result.Position + Vector3.new(0, modelOffset, 0)))
	end
	
	self.model.Parent = workspace
	
	-- model runservice updates
	self.connection = RunService.Heartbeat:Connect(function()
		if not self.active or not self.model or not self.model.Parent then
			-- model was destroyed or placement cancelled
			self.connection:Disconnect()
			self.connection = nil
			return
		end
		
		self:ModelToMouse(modelOffset)
		
		local success, inValidLocation = pcall(function()
			return self:CheckValidLocation()
		end)

		if success then
			self:SetModelStyle(inValidLocation)
		end
	end)
end

function ClientPreview:Rotate()
	if self.active == false then return end
	self.rotationY = (self.rotationY + 45) % 360
end

function ClientPreview:DisablePlacement()
	if self.active == false then return end
	self.active = false
	
	-- destroy model
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	
	-- disconnect runservice
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

return ClientPreview

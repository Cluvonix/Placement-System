local LoadPlot = {}

-- load units onto plot

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ServerScriptService.Systems.DataSystem.DataManager)
local PlotManager = require(ServerScriptService.Systems.PlotSystem.PlotManager)

local Assets = ReplicatedStorage.Assets


function LoadPlot:Load(player)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	local plotData = profile.Data.PlotData
	
	local plot = PlotManager:RetrievePlot(player)
	local plotBase = plot:FindFirstChild("Base")
	
	for unit, relativePosTable in pairs(plotData) do
		for i, relativePos in pairs(relativePosTable) do
			local unitAsset = Assets:FindFirstChild(unit)
			if unitAsset then
				local clone = unitAsset:Clone()
				local worldPos = plotBase.CFrame:PointToWorldSpace(Vector3.new(relativePos.X, relativePos.Y, relativePos.Z))
				local rotation = CFrame.Angles(relativePos.RX, relativePos.RY, relativePos.RZ)
				clone:PivotTo(CFrame.new(worldPos) * rotation)
				clone.Parent = plot:FindFirstChild("PlacedObjects")
			end
		end
	end
end


return LoadPlot

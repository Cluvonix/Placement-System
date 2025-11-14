local PlotManager = {}

-- assign joined players to the avaible plot

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local plotsFolder = workspace.Plots
local network = ReplicatedStorage.Network
local placementRemotes = network.Placement
local getPlotEvent = placementRemotes.GetPlotEvent
local WipePlot = require(ServerScriptService.Systems.PlotSystem.WipePlot)

local plotsInfo = {}

-- return available plot
function PlotManager:GetAvailablePlot()
	for plot, assignedPlayer in pairs(plotsInfo) do
		if assignedPlayer == "None" then
			return plot
		end
	end
end

-- change available plot to player
function PlotManager:Assign(player: Player)
	local availablePlot = PlotManager:GetAvailablePlot()
	
	plotsInfo[availablePlot] = player.UserId
end

-- wipe plot info
function PlotManager:RealeasePlot(player: Player)
	for plot, assignedPlayer in pairs(plotsInfo) do
		if assignedPlayer == player.UserId then
			WipePlot:Wipe(PlotManager:RetrievePlot(player))
			plot = "None"
		end
	end
end

function PlotManager:RetrievePlot(player: Player)
	for plot, assignedPlayer in pairs(plotsInfo) do
		if assignedPlayer == player.UserId then
			local physicalPlot = plotsFolder:FindFirstChild(plot)
			
			if physicalPlot then
				return physicalPlot
			end
		end
	end
end

function PlotManager.Init()
	Players.PlayerAdded:Connect(function(player)
		PlotManager:Assign(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlotManager:RealeasePlot(player)
	end)

	getPlotEvent.OnServerInvoke = function(player)
		return PlotManager:RetrievePlot(player)
	end
	
	-- add plots to plotsinfo table
	for i, plot in plotsFolder:GetChildren() do
		plotsInfo[plot.Name] = "None"
	end
	
	-- add player to plot if they joined before function connected
	for i, player in Players:GetChildren() do
		PlotManager:Assign(player)
	end
end

return PlotManager

local WipePlot = {}


-- clears plot for new users
function WipePlot:Wipe(plot)
	local placedObjectFolder = plot:FindFirstChild("PlacedObjects")
	
	if placedObjectFolder then
		for i, object in placedObjectFolder:GetChildren() do
			object:Destroy()
		end
	end
end


return WipePlot

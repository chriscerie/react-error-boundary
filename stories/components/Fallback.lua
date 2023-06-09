--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)

local e = React.createElement

local Fallback: React.FC<ReactErrorBoundary.FallbackProps> = function(_props)
	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "This is the fallback component.",
	})
end

return Fallback

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local useErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary.useErrorBoundary)

local e = React.createElement

local Fallback: React.FC<ReactErrorBoundary.FallbackProps> = function()
	local errorBoundary = useErrorBoundary()

	return e("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "Errored! Click me to retry.",
		[React.Event.MouseButton1Click] = function()
			errorBoundary.resetBoundary()
		end,
	})
end

return Fallback

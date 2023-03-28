--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local function FallbackAndReset(props)
	React.useEffect(function()
		task.delay(1, function()
			props.resetErrorBoundary()
		end)
	end, { props.resetErrorBoundary })

	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "This is the fallback component. Resetting error boundary in 1 second.",
	})
end

return FallbackAndReset

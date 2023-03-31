--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)

local e = React.createElement

local FallbackAndReset: React.FC<ReactErrorBoundary.FallbackProps> = function(props)
	React.useEffect(function()
		local shouldReset = true

		task.delay(2, function()
			if shouldReset then
				props.resetErrorBoundary()
			end
		end)

		return function()
			shouldReset = false
		end
	end, { props.resetErrorBoundary })

	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "Error caught! Reverting state in 2 seconds.",
	})
end

return FallbackAndReset

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local function WillError()
	local shouldError, setShouldError = React.useState(false)

	if shouldError then
		error("Error")
	end

	React.useEffect(function()
		task.delay(1, function()
			setShouldError(true)
		end)
	end, { setShouldError })

	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "Erroring in 1 second.",
	})
end

return WillError

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local Fallback = require(ReplicatedStorage.Stories.components.Fallback)

local e = React.createElement

local function WillErrorInEventHandler()
	local errorBoundary = ReactErrorBoundary.useErrorBoundary()

	React.useEffect(function()
		task.delay(1, function()
			errorBoundary.showBoundary("Errored in event handler")
		end)
	end)

	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "Erroring in event handler in 1 second.",
	})
end

local Component: React.FC<{}> = function(_props)
	return e(ReactErrorBoundary.ErrorBoundary, {
		fallback = e(Fallback),
	}, {
		WillErrorInEventHandler = e(WillErrorInEventHandler),
	})
end

return function(target)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal({
		App = e(Component),
	}, target))

	return function()
		root:unmount()
	end
end

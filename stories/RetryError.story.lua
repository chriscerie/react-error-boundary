--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local FallbackWithRetryButton = require(ReplicatedStorage.Stories.components.FallbackWithRetryButton)
local WillError = require(ReplicatedStorage.Stories.components.WillError)

local e = React.createElement

-- After erroring, the fallback component renders a button that calls `resetBoundary()` when pressed, which renders the
-- `WillError` component again, which will error and render the fallback button again, and so on.
local function Component(_)
	return e(ReactErrorBoundary.ErrorBoundary, {
		FallbackComponent = FallbackWithRetryButton,
	}, {
		WillError = e(WillError),
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

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local FallbackWithRetryButton = require(ReplicatedStorage.Stories.components.FallbackWithRetryButton)
local WillError = require(ReplicatedStorage.Stories.components.WillError)

local e = React.createElement

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

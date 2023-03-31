--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local WillError = require(ReplicatedStorage.Stories.components.WillError)
local Fallback = require(ReplicatedStorage.Stories.components.Fallback)

local e = React.createElement

local Component: React.FC<{}> = function(_props)
	return e(ReactErrorBoundary.ErrorBoundary, {
		FallbackComponent = Fallback,
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

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local FallbackAndReset = require(ReplicatedStorage.Stories.components.FallbackAndReset)

local e = React.createElement

local Counter: React.FC<{ count: number, increment: () -> () }> = function(props)
	if props.count >= 5 then
		error(`Erroring at count: {props.count}`)
	end

	return e("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = `Count: {props.count}\nClick me to increment. Errors at 5, which resets counter to 0.`,
		[React.Event.Activated] = props.increment,
	})
end

local function Component(_)
	local count, setCount = React.useState(0)

	return e(ReactErrorBoundary.ErrorBoundary, {
		FallbackComponent = FallbackAndReset,
		onReset = function(_details)
			setCount(0)
		end,
		onError = function(_error, _info)
			print("Error caught! Resetting count to 0.")
		end,
	}, {
		Counter = e(Counter, {
			count = count,
			increment = function()
				setCount(function(prevCount: number)
					return prevCount + 1
				end)
			end,
		}),
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

--!strict
local React = require(script.Parent.Parent.React)
local Collections = require(script.Parent.Parent.Collections)
local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)
local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)
local types = require(script.Parent.types)

type ErrorBoundaryState = {
	didCatch: boolean,
	error: { LuauPolyfill.Error }?,
}

local initialState: ErrorBoundaryState = {
	didCatch = false,
	error = nil,
}

local function hasArrayChanged(a: { any }?, b: { any }?)
	a = a or {}
	b = b or {}

	if a and b then
		return #a ~= #b
			or Collections.Array.some(a, function(item, index)
				return not Collections.Object.is(item, b[index])
			end)
	end
	return false
end

--[=[
	This is a React component. Wrap an `ErrorBoundary` around other React components to "catch" errors
	and render a fallback UI. The component supports several ways to render a fallback (shown below).

	First, create a fallback component.
	```lua
		local e = React.createElement
		local Fallback: React.FC<ReactErrorBoundary.FallbackProps> = function(_props)
			return e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Text = "An error was encountered!.",
			})
		end
	```

	Next, in your other components, wrap in an `ErrorBoundary` where needed. When an error is encountered somewhere in your app,
	the nearest `ErrorBoundary` will catch and handle it. You don't need to wrap every component in an `ErrorBoundary`. Consider
	the [granularity of error boundaries](https://aweary.dev/fault-tolerance-react/) and where it makes sense to display an error
	message or revert states.

	#### Using FallbackComponent prop
	See [ErrorIn1SecondFallbackComponent](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ErrorIn1SecondFallbackComponent.story.lua) for a full example.
	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			FallbackComponent = Fallback,
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```

	#### Using fallbackRender prop
	[Render prop](https://react.dev/reference/react/Children#calling-a-render-prop-to-customize-rendering) function that returns the fallback UI.
	This is helpful if you want to handle errors differently based on the error.

	See [ErrorIn1SecondFallbackComponent](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ErrorIn1SecondFallbackRender.story.lua) for a full example.
	
	:::caution
	Render prop functions are normal functions and are not React components. Attempting to use hooks in them will error!
	:::

	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			fallbackRender = function(props: ReactErrorBoundary.FallbackProps)
				return e(Fallback)
			end,
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```

	#### Using fallback prop
	See [ErrorIn1SecondFallback](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ErrorIn1SecondFallback.story.lua) for a full example.

	:::caution
	This creates the fallback element even when it's not needed.
	:::

	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			fallback = e(Fallback),
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```

	#### onError
	When passed, `onError` gets called when an error is caught. This is useful for logging errors.
	
	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			FallbackComponent = Fallback,
			onError = function(error: LuauPolyfill.Error, info: { componentStack: string })
				warn("Caught error:", error, info)
			end,
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```

	### onReset
	When passed, `onReset` gets called when the error boundary is reset by a call to `resetErrorBoundary` or when the `resetKeys` change.
	This is useful for reverting state.

	See [ResetCount](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ResetCount.story.lua) for a full example.
	
	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			FallbackComponent = Fallback,
			onReset = function(
				details: { reason: "imperative-api",
				args: { any } } | { reason: "keys", prev: { any }?, next: { any }? }
			)
				warn("Error boundary was reset:", details)
			end,
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```
	@function ErrorBoundary
	@within ReactErrorBoundary
]=]
local ErrorBoundary = React.Component:extend("ErrorBoundary")

function ErrorBoundary:init()
	self.state = initialState

	self.resetErrorBoundary = function(...: any)
		local args = { ... }
		local error = self.state.error

		if error then
			if self.props.onReset then
				self.props.onReset({
					args = args,
					reason = "imperative-api",
				})
			end

			self:setState(initialState)
		end
	end
end

function ErrorBoundary.getDerivedStateFromError(error)
	return {
		didCatch = true,
		error = error,
	}
end

function ErrorBoundary:componentDidCatch(
	error,
	info: {
		componentStack: string,
	}
)
	if self.props.onError then
		self.props.onError(error, info)
	end
end

function ErrorBoundary:componentDidUpdate(prevProps: types.ErrorBoundaryProps, prevState: ErrorBoundaryState)
	local didCatch = self.state.didCatch
	local resetKeys = self.props.resetKeys

	-- There's an edge case where if the thing that triggered the error happens to *also* be in the resetKeys array,
	-- we'd end up resetting the error boundary immediately.
	-- This would likely trigger a second error to be thrown.
	-- So we make sure that we don't check the resetKeys on the first call of cDU after the error is set.

	if didCatch and prevState.error and hasArrayChanged(prevProps.resetKeys, resetKeys) then
		if self.props.onReset then
			self.props.onReset({
				next = resetKeys,
				prev = prevProps.resetKeys,
				reason = "keys",
			})
		end

		self:setState(initialState)
	end
end

function ErrorBoundary:render()
	local children = self.props.children
	local fallbackRender = self.props.fallbackRender
	local FallbackComponent = self.props.FallbackComponent
	local fallback = self.props.fallback

	local didCatch = self.state.didCatch
	local error = self.state.error

	local childToRender = children

	if didCatch then
		local props: types.FallbackProps = {
			error = error,
			resetErrorBoundary = self.resetErrorBoundary,
		}

		if React.isValidElement(fallback) then
			childToRender = fallback
		elseif typeof(fallbackRender) == "function" then
			childToRender = fallbackRender(props)
		elseif FallbackComponent then
			childToRender = React.createElement(FallbackComponent, props)
		else
			error("react-error-boundary requires either a fallback, fallbackRender, or FallbackComponent prop")
		end
	end

	return React.createElement(ErrorBoundaryContext.Provider, {
		value = {
			didCatch = didCatch,
			error = error,
			resetErrorBoundary = self.resetErrorBoundary,
		},
	}, childToRender)
end

return ErrorBoundary

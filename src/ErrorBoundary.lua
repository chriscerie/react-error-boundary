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
			error("roact-error-boundary requires either a fallback, fallbackRender, or FallbackComponent prop")
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

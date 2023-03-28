--!strict
local React = require(script.Parent.Parent.React)
local Sift = require(script.Parent.Parent.Sift)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
local types = require(script.Parent.types)

--[=[
	TODO: Undocumented
	@function withErrorBoundary
	@within ReactErrorBoundary
]=]
local function withErrorBoundary<Props>(component: React.ComponentType<Props>, errorBoundaryProps: types.ErrorBoundaryProps)
	local Wrapped = React.forwardRef(function(props: Props, ref)
		return React.createElement(ErrorBoundary, errorBoundaryProps, {
			component = React.createElement(component, Sift.Dictionary.merge(props, { ref = ref })),
		})
	end)

	return Wrapped
end

return withErrorBoundary

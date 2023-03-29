--!strict
local React = require(script.Parent.Parent.React)
local Sift = require(script.Parent.Parent.Sift)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
local types = require(script.Parent.types)

--[=[
	This is a higher-order component that makes it easy to add an error boundary to an existing component. See
    [ErrorIn1SecondHOC](https://github.com/chriscerie/roact-error-boundary/blob/main/stories/ErrorIn1SecondHOC.story.lua) for a full example.

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

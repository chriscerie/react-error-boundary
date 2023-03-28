--!strict
local React = require(script.Parent.Parent.React)
local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)
local assertErrorBoundaryContext = require(script.Parent.assertErrorBoundaryContext)

export type UseErrorBoundaryApi<Error> = {
	resetBoundary: () -> (),
	showBoundary: (error: Error) -> (),
}

local function useErrorBoundary<Error>(): UseErrorBoundaryApi<Error>
	local context = assertErrorBoundaryContext(React.useContext(ErrorBoundaryContext))

	local state, setState = React.useState({
		error = nil :: Error?,
		hasError = false,
	})

	local memoized = React.useMemo(function()
		return {
			resetBoundary = function()
				context.resetErrorBoundary()
				setState({ hasError = false })
			end,
			showBoundary = function(error: Error)
				setState({
					error = error,
					hasError = true,
				})
				return
			end,
		}
	end, { context, context.resetErrorBoundary } :: { any })

	if state.hasError then
		error(state.error)
	end

	return memoized
end

return useErrorBoundary

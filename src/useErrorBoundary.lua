--!strict
local React = require(script.Parent.Parent.React)
local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)
local assertErrorBoundaryContext = require(script.Parent.assertErrorBoundaryContext)

--[=[
	@interface UseErrorBoundaryApi<E>
	@within ReactErrorBoundary
	.resetBoundary () -> ()
	.showBoundary (error: E) -> ()
]=]
export type UseErrorBoundaryApi<Error> = {
	resetBoundary: () -> (),
	showBoundary: (error: Error) -> (),
}

--[=[
	Convenient hook for imperatively invoking or resetting error boundaries.

	#### Invoking the nearest error boundary from an event handler

	React only handles errors thrown during render or during component lifecycle methods (e.g., useEffect, componentDidMount).
	Error thrown in event handlers or in separate lua threads will not be automatically caught.

	A convenient pattern is to invoke the nearest error boundary when an error occurs in event handlers or in separate lua threads.

	```lua
		local Example: React.FC<{}> = function()
			local errorBoundary = useErrorBoundary()

			useEffect(function()
				-- Using promises
				fetchPlayerData(name):andThen(function(res)
					-- Set data in state to rerender
				end):catch(function(error)
					-- Our promise failed, so invoke the nearest error boundary to handle the error
					errorBoundary.showBoundary(error)
				end)

				-- Using pcall
				task.defer(function()
					local success, res = pcall(function()
						-- Do something that might throw an error
					end)

					if not success then
						errorBoundary.showBoundary(res)
					end
				end)
			end)

			-- Render ...
		end
	```

	#### Resetting the nearest error boundary

	`resetBoundary()` requests the nearest boundary to retry the render that originally failed and if passed,
	invokes the boundary's `onReset` callback.

	A pattern is to just retry the render blindly and hope it succeeds on the second try. See
	[RetryError](https://github.com/chriscerie/react-error-boundary/blob/main/stories/RetryError.story.lua) for a full example.

	A more common pattern is to revert some state and retry the render with the reverted state. See
	[ResetCount](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ResetCount.story.lua) for a full example.

	@within ReactErrorBoundary
]=]
local function useErrorBoundary<E>(): UseErrorBoundaryApi<E>
	local context = assertErrorBoundaryContext(React.useContext(ErrorBoundaryContext))

	local state, setState = React.useState({
		error = nil :: E?,
		hasError = false,
	})

	local memoized = React.useMemo(function()
		return table.freeze({
			resetBoundary = function()
				context.resetErrorBoundary()
				setState({ hasError = false })
			end,
			showBoundary = function(error: E)
				setState({
					error = error,
					hasError = true,
				})
				return
			end,
		})
	end, { context, context.resetErrorBoundary } :: { any })

	if state.hasError then
		error(state.error)
	end

	return memoized
end

return useErrorBoundary

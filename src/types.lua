local React = require(script.Parent.Parent.React)
local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)

-- DEVIATION: For some reason, fallbackRender in withErrorBoundary could not resolve to React.ReactNode return
-- without type casting, so use `any` for now to avoid user needing to type cast
type FallbackRender = (props: FallbackProps) -> any

--[=[
	A [LuauPolyFill.Error](https://github.com/grilme99/CorePackages/tree/main/modules/LuauPolyfill-2fca3173-1.1.0)
	object to represent errors caught by React. Note that this does not apply to errors imperatively thrown by `showBoundary`.
	```lua
	{
		message: string,
		name: string,
		stack: string,
	}
	```
	@class Error
]=]

--[=[
	Props for fallback components. Fallback components should be typed like:
	```lua
		local Fallback: React.FC<ReactErrorBoundary.FallbackProps> = function(props)
			-- ...
		end
	```
	@interface FallbackProps
	@within ReactErrorBoundary
	.error Error
	.resetErrorBoundary (...any) -> () -- Resets the error boundary and calls `onReset` if provided. This is useful for reverting state or retrying the render.
]=]
export type FallbackProps = {
	error: LuauPolyfill.Error,
	resetErrorBoundary: (...any) -> (),
}

--[=[
	@interface ErrorBoundarySharedProps
	@within ErrorBoundary
	.onError (error: Error, info: { componentStack: string }) -> ()?
	.onReset (details: { reason: "imperative-api", args: { any } } | { reason: "keys", prev: { any }?, next: { any }? }) -> ()?
	.resetKeys { any }?
]=]
type ErrorBoundarySharedProps = {
	onError: (error: LuauPolyfill.Error, info: { componentStack: string }) -> ()?,
	onReset: (
		details: { reason: "imperative-api", args: { any } } | { reason: "keys", prev: { any }?, next: { any }? }
	) -> ()?,
	resetKeys: { any }?,
}

--[=[
	One of 3 types of fallback that can be provided to an error boundary.

	See [ErrorIn1SecondFallbackComponent](https://github.com/chriscerie/react-error-boundary/blob/main/stories/ErrorIn1SecondFallbackComponent.story.lua) for a full example.
	```lua
		return e(ReactErrorBoundary.ErrorBoundary, {
			FallbackComponent = Fallback,
		}, {
			ComponentThatErrors = e(ComponentThatErrors),
		})
	```

	@interface ErrorBoundaryPropsWithComponent
	@within ErrorBoundary
	.fallback never?
	.FallbackComponent React.ComponentType<FallbackProps>
	.fallbackRender never?
]=]
export type ErrorBoundaryPropsWithComponent = ErrorBoundarySharedProps & {
	fallback: never?,
	FallbackComponent: React.ComponentType<FallbackProps>,
	fallbackRender: never?,
}

--[=[
	One of 3 types of fallback that can be provided to an error boundary.

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

	@interface ErrorBoundaryPropsWithRender
	@within ErrorBoundary
	.fallback never?
	.FallbackComponent never?
	.fallbackRender FallbackRender
]=]
export type ErrorBoundaryPropsWithRender = ErrorBoundarySharedProps & {
	fallback: never?,
	FallbackComponent: never?,
	fallbackRender: FallbackRender,
}

--[=[
	One of 3 types of fallback that can be provided to an error boundary.
	
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

	@interface ErrorBoundaryPropsWithFallback
	@within ErrorBoundary
	.fallback React.ReactNode
	.FallbackComponent never?
	.fallbackRender never?
]=]
export type ErrorBoundaryPropsWithFallback = ErrorBoundarySharedProps & {
	fallback: React.ReactElement<any, any>,
	FallbackComponent: never?,
	fallbackRender: never?,
}

--[=[
	@type ErrorBoundaryProps ErrorBoundarySharedProps & (ErrorBoundaryPropsWithComponent | ErrorBoundaryPropsWithRender | ErrorBoundaryPropsWithFallback)
	@within ErrorBoundary
]=]
export type ErrorBoundaryProps =
	ErrorBoundaryPropsWithFallback
	| ErrorBoundaryPropsWithComponent
	| ErrorBoundaryPropsWithRender

return {}

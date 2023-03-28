local React = require(script.Parent.Parent.React)
local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)

-- DEVIATION: For some reason, fallbackRender in withErrorBoundary could not resolve to React.ReactNode return
-- without type casting, so use `any` for now to avoid user needing to type cast
type FallbackRender = (props: FallbackProps) -> any

export type FallbackProps = {
	error: LuauPolyfill.Error,
	resetErrorBoundary: (...any) -> (),
}

type ErrorBoundarySharedProps = {
	onError: (error: LuauPolyfill.Error, info: { componentStack: string }) -> ()?,
	onReset: (
		details: { reason: "imperative-api", args: { any } } | { reason: "keys", prev: { any }?, next: { any }? }
	) -> ()?,
	resetKeys: { any }?,
}

export type ErrorBoundaryPropsWithComponent = ErrorBoundarySharedProps & {
	fallback: never?,
	FallbackComponent: React.ComponentType<FallbackProps>,
	fallbackRender: never?,
}

export type ErrorBoundaryPropsWithRender = ErrorBoundarySharedProps & {
	fallback: never?,
	FallbackComponent: never?,
	fallbackRender: FallbackRender,
}

export type ErrorBoundaryPropsWithFallback = ErrorBoundarySharedProps & {
	-- DEVIATION: `any` for now due to error using withErrorBoundary
	-- Cannot cast 'ReactElement<FallbackProps, a>' into 'ReactElement<unknown, any>' because the types are unrelated
	fallback: any,
	FallbackComponent: never?,
	fallbackRender: never?,
}

export type ErrorBoundaryProps =
	ErrorBoundaryPropsWithFallback
	| ErrorBoundaryPropsWithComponent
	| ErrorBoundaryPropsWithRender

return {}

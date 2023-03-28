local React = require(script.Parent.Parent.React)
local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)

type FallbackRender = (props: FallbackProps) -> React.ReactNode

export type FallbackProps = {
	error: LuauPolyfill.Error,
	resetErrorBoundary: (args: { any }) -> (),
}

type ErrorBoundarySharedProps = {
	onError: (error: LuauPolyfill.Error, info: { componentStack: string }) -> ()?,
	onReset: (
		details: { reason: "imperative-api", args: { any } } | { reason: "keys", prev: { any }?, next: { any }? }
	) -> (),
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
	fallback: React.ReactElement<unknown, string | React.ComponentType<any>>?,
	FallbackComponent: never?,
	fallbackRender: never?,
}

export type ErrorBoundaryProps =
	ErrorBoundaryPropsWithFallback
	| ErrorBoundaryPropsWithComponent
	| ErrorBoundaryPropsWithRender

return {}

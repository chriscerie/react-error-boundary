--!strict

-- Upstream: https://github.com/bvaughn/react-error-boundary/tree/7213c5416a70997bf24efe07de973b88b148902b

local types = require(script.types)
local ErrorBoundaryContext = require(script.ErrorBoundaryContext)
local useErrorBoundary = require(script.useErrorBoundary)

export type FallbackProps = types.FallbackProps
export type ErrorBoundaryProps = types.ErrorBoundaryProps
export type ErrorBoundaryContextType = ErrorBoundaryContext.ErrorBoundaryContextType
export type UseErrorBoundaryApi<Error> = useErrorBoundary.UseErrorBoundaryApi<Error>

--[=[
	Robust error boundary library for Lua React based on react-error-boundary.
	See [ErrorBoundary](/api/ErrorBoundary) for the main component usage.
	@class ReactErrorBoundary
]=]
return {
	ErrorBoundary = require(script.ErrorBoundary),
	ErrorBoundaryContext = require(script.ErrorBoundaryContext),
	useErrorBoundary = useErrorBoundary,
	withErrorBoundary = require(script.withErrorBoundary),
}

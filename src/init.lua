--!strict

-- Upstream: https://github.com/bvaughn/react-error-boundary/tree/7213c5416a70997bf24efe07de973b88b148902b

local types = require(script.types)

export type FallbackProps = types.FallbackProps

return {
	ErrorBoundary = require(script.ErrorBoundary),
	ErrorBoundaryContext = require(script.ErrorBoundaryContext),
	useErrorBoundary = require(script.useErrorBoundary),
	withErrorBoundary = require(script.withErrorBoundary),
}

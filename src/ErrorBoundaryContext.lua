--!strict
local React = require(script.Parent.Parent.React)

--[=[
	@interface ErrorBoundaryContextType
	@within ReactErrorBoundary
	.didCatch boolean
	.error any
	.resetErrorBoundary (...any) -> ()
]=]
export type ErrorBoundaryContextType = {
	didCatch: boolean,
	error: any,
	resetErrorBoundary: (...any) -> (),
}

return React.createContext(nil :: ErrorBoundaryContextType?)

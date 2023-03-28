--!strict
local React = require(script.Parent.Parent.React)

export type ErrorBoundaryContextType = {
	didCatch: boolean,
	error: any,
	resetErrorBoundary: (...any) -> (),
}

return React.createContext(nil :: ErrorBoundaryContextType?)

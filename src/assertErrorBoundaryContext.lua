--!strict

local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)

local function assertErrorBoundaryContext(value: any): ErrorBoundaryContext.ErrorBoundaryContextType
	if not value or typeof(value.didCatch) ~= "boolean" or typeof(value.resetErrorBoundary) ~= "function" then
		error("ErrorBoundaryContext not found")
	end

	-- DEVIATION: Since luau doesn't support type guards, we can narrow down the type by setting the variable to this
	return value
end

return assertErrorBoundaryContext

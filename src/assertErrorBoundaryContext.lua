local function assertErrorBoundaryContext(value)
	if not value or typeof(value.didCatch) ~= "boolean" or typeof(value.resetErrorBoundary) ~= "function" then
		error("ErrorBoundaryContext not found")
	end

	return true
end

return assertErrorBoundaryContext

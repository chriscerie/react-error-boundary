local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
local types = require(script.Parent.types)

local e = React.createElement

local act = function(callback)
	callback()
	task.wait()
end

return function()
	describe("ErrorBoundary", function()
		local container: Folder
		local root: ReactRoblox.RootType
		local shouldThrow = true
		local valueToThrow: any

		local MaybeThrows: React.FC<{
			children: any,
		}> = function(props)
			if shouldThrow then
				error(valueToThrow)
			end
			return props.children
		end

		beforeEach(function()
			container = Instance.new("Folder")
			root = ReactRoblox.createRoot(container)
			shouldThrow = false
			valueToThrow = "💥💥💥"
		end)

		it("should render children", function()
			act(function()
				root:render(e(ErrorBoundary, {}, {
					Content = e("TextLabel"),
				}))
			end)

			expect(container:FindFirstChild("Content")).to.be.ok()
		end)

		describe("callback props", function()
			local errorBoundaryRef

			beforeEach(function()
				errorBoundaryRef = React.createRef()
			end)

			local function render(props)
				act(function()
					root:render(e(
						ErrorBoundary,
						Sift.Dictionary.merge(props, {
							fallback = e("TextLabel", {
								Text = "Error",
							}),
							ref = errorBoundaryRef,
						}),
						{
							MaybeThrows = e(MaybeThrows, nil, {
								Content = e("Frame"),
							}),
						}
					))
				end)
			end

			it('should call "onError" prop if one is provided', function()
				shouldThrow = true
				local timesCalledOnError = 0
				local onErrorMessage

				render({
					onError = function(error)
						timesCalledOnError += 1
						onErrorMessage = error
					end,
				})

				expect(timesCalledOnError).to.equal(1)
				expect(onErrorMessage.message).to.equal("💥💥💥")
			end)

			it('should call "onReset" when boundary reset via imperative API', function()
				shouldThrow = true
				local timesCalledOnReset = 0

				local function onReset()
					timesCalledOnReset += 1
				end

				render({
					onReset = onReset,
				})
				expect(timesCalledOnReset).to.equal(0)

				errorBoundaryRef.current.resetErrorBoundary("abc", 123)
				expect(timesCalledOnReset).to.equal(1)
			end)

			it('should call "onReset" when boundary reset via "resetKeys"', function()
				shouldThrow = false
				local timesCalledOnReset = 0

				local function onReset()
					timesCalledOnReset += 1
				end

				render({
					onReset = onReset,
					resetKeys = { 1 },
				})
				expect(timesCalledOnReset).to.equal(0)

				-- It should not be called if the keys change without an error
				render({
					onReset = onReset,
					resetKeys = { 2 },
				})
				expect(timesCalledOnReset).to.equal(0)

				shouldThrow = true

				render({
					onReset = onReset,
					resetKeys = { 2 },
				})
				expect(timesCalledOnReset).to.equal(0)

				shouldThrow = false

				render({
					onReset = onReset,
					resetKeys = { 3 },
				})
				expect(timesCalledOnReset).to.equal(1)
			end)
		end)

		describe('"fallback" element', function()
			local function render(props)
				act(function()
					props = props or {}
					root:render(e(
						ErrorBoundary,
						Sift.Dictionary.merge(props, {
							fallback = e("TextLabel", {
								key = "Fallback",
							}),
						}),
						{
							MaybeThrows = e(MaybeThrows, nil, {
								Content = e("Frame"),
							}),
						}
					))
				end)
			end

			it("should render fallback in the event of an error", function()
				shouldThrow = true
				render()

				expect(container:FindFirstChild("Fallback")).to.be.ok()
			end)

			it("should re-render children if boundary is reset by reset keys", function()
				shouldThrow = true
				render({
					resetKeys = { 1 },
				})
				expect(container:FindFirstChild("Fallback")).to.be.ok()

				shouldThrow = false
				render({
					resetKeys = { 2 },
				})
				expect(container:FindFirstChild("Content")).to.be.ok()
			end)
		end)

		describe('"FallbackComponent"', function()
			local fallbackComponent: React.FC<types.FallbackProps>
			local lastRenderedError
			local lastRenderedResetErrorBoundary: (() -> any)?

			local function render(props)
				act(function()
					props = props or {
						FallbackComponent = nil,
					}
					root:render(e(
						ErrorBoundary,
						Sift.Dictionary.merge(props, {
							FallbackComponent = fallbackComponent,
						}),
						{
							MaybeThrows = e(MaybeThrows, nil, {
								Content = e("Frame"),
							}),
						}
					))
				end)
			end

			beforeEach(function()
				lastRenderedError = nil
				lastRenderedResetErrorBoundary = nil

				fallbackComponent = function(props)
					lastRenderedError = props.error
					lastRenderedResetErrorBoundary = props.resetErrorBoundary

					return e("Frame", {
						key = "Fallback",
					})
				end
			end)

			it("should render fallback in the event of an error", function()
				shouldThrow = true
				render()
				expect(lastRenderedError.message).to.equal("💥💥💥")
				expect(container:FindFirstChild("Fallback")).to.be.ok()
			end)

			it("should re-render children if boundary is reset via prop", function()
				shouldThrow = true
				render()
				expect(container:FindFirstChild("Fallback")).to.be.ok()

				expect(lastRenderedResetErrorBoundary).to.be.ok()

				act(function()
					shouldThrow = false
					if not lastRenderedResetErrorBoundary then
						error("lastRenderedResetErrorBoundary is nil")
					end
					lastRenderedResetErrorBoundary()
				end)

				expect(container:FindFirstChild("Content")).to.be.ok()
			end)

			it("should re-render children if boundary is reset by reset keys", function()
				shouldThrow = true
				render({
					resetKeys = { 1 },
				})
				expect(container:FindFirstChild("Fallback")).to.be.ok()

				shouldThrow = false
				render({
					resetKeys = { 2 },
				})
				expect(container:FindFirstChild("Content")).to.be.ok()
			end)
		end)

		describe('"fallbackRender" render prop', function()
			local lastRenderedError
			local lastRenderedResetErrorBoundary: (() -> any)?
			local fallbackRender: React.FC<types.FallbackProps>
			local timesFallbackRenderCalled = 0

			local function render(props)
				act(function()
					props = props or {
						FallbackComponent = nil,
					}
					root:render(e(
						ErrorBoundary,
						Sift.Dictionary.merge(props, {
							fallbackRender = fallbackRender,
						}),
						{
							MaybeThrows = e(MaybeThrows, nil, {
								Content = e("Frame"),
							}),
						}
					))
				end)
			end

			beforeEach(function()
				lastRenderedError = nil
				lastRenderedResetErrorBoundary = nil
				timesFallbackRenderCalled = 0

				fallbackRender = function(props)
					lastRenderedError = props.error
					lastRenderedResetErrorBoundary = props.resetErrorBoundary
					timesFallbackRenderCalled += 1

					return e("Frame", {
						key = "Fallback",
					})
				end
			end)

			it("should render fallback in the event of an error", function()
				shouldThrow = true
				render()
				expect(lastRenderedError.message).to.equal("💥💥💥")
				expect(timesFallbackRenderCalled).never.to.equal(0)
				expect(container:FindFirstChild("Fallback")).to.be.ok()
			end)

			it("should re-render children if boundary is reset via prop", function()
				shouldThrow = true
				render()
				expect(lastRenderedError.message).to.equal("💥💥💥")
				expect(timesFallbackRenderCalled).never.to.equal(0)
				expect(container:FindFirstChild("Fallback")).to.be.ok()

				act(function()
					shouldThrow = false
					if not lastRenderedResetErrorBoundary then
						error("lastRenderedResetErrorBoundary is nil")
					end
					lastRenderedResetErrorBoundary()
				end)

				expect(container:FindFirstChild("Content")).to.be.ok()
			end)

			it("should re-render children if boundary is reset reset keys", function()
				shouldThrow = true
				render({ resetKeys = { 1 } })
				expect(lastRenderedError.message).to.equal("💥💥💥")
				expect(timesFallbackRenderCalled).never.to.equal(0)
				expect(container:FindFirstChild("Fallback")).to.be.ok()

				shouldThrow = false
				render({ resetKeys = { 2 } })
				expect(container:FindFirstChild("Content")).to.be.ok()
			end)
		end)

		describe("thrown value", function()
			local lastRenderedError
			local fallbackRender: React.FC<types.FallbackProps>
			local onError: (() -> any)?
			local timesCalledOnError = 0

			local function render()
				act(function()
					root:render(e(ErrorBoundary, {
						fallbackRender = fallbackRender,
						onError = onError,
					}, {
						MaybeThrows = e(MaybeThrows, nil, {
							Content = e("Frame"),
						}),
					}))
				end)
			end

			beforeEach(function()
				lastRenderedError = nil

				timesCalledOnError = 0
				onError = function()
					timesCalledOnError += 1
				end

				fallbackRender = function(props)
					lastRenderedError = props.error

					return e("Frame", {
						key = "Fallback",
					})
				end
			end)

			it("should support thrown strings", function()
				shouldThrow = true
				valueToThrow = "String error"

				render()

				expect(lastRenderedError.message).to.equal("String error")
				expect(timesCalledOnError).to.equal(1)
				expect(container:FindFirstChild("Fallback")).to.be.ok()
			end)
		end)
	end)
end

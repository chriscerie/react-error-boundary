local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
local useErrorBoundary = require(script.Parent.useErrorBoundary)

local e = React.createElement

local act = function(callback)
	callback()
	task.wait()
end

return function()
	describe("ErrorBoundary", function()
		local container: Folder
		local lastRenderedUseErrorBoundaryApi: useErrorBoundary.UseErrorBoundaryApi<any>?

		beforeEach(function()
			container = Instance.new("Folder")
			lastRenderedUseErrorBoundaryApi = nil
		end)

		local function render()
			local Child: React.FC<{}> = function()
				lastRenderedUseErrorBoundaryApi = useErrorBoundary()

				return e("Frame", {
					key = "Child",
				})
			end

			local root = ReactRoblox.createRoot(container)
			act(function()
				root:render(e(ErrorBoundary, {
					fallback = e("Frame", {
						key = "Fallback",
					}),
				}, {
					Content = e(Child),
				}))
			end)
		end

		it("should activate an error boundary", function()
			render()
			expect(container:FindFirstChild("Child")).to.be.ok()

			act(function()
				assert(lastRenderedUseErrorBoundaryApi)
				lastRenderedUseErrorBoundaryApi.showBoundary("Error")
			end)
			expect(container:FindFirstChild("Fallback")).to.be.ok()
		end)

		it("should reset an active error boundary", function()
			render()

			act(function()
				assert(lastRenderedUseErrorBoundaryApi)
				lastRenderedUseErrorBoundaryApi.showBoundary("Error")
			end)
			expect(container:FindFirstChild("Fallback")).to.be.ok()

			act(function()
				assert(lastRenderedUseErrorBoundaryApi)
				lastRenderedUseErrorBoundaryApi.resetBoundary()
			end)
			expect(container:FindFirstChild("Child")).to.be.ok()
		end)

		it("should work within a fallback component", function()
			local resetBoundary
			local showBoundary

			local function FallbackComponent()
				resetBoundary = useErrorBoundary().resetBoundary
				return e("Frame", {
					key = "Fallback",
				})
			end

			local Child: React.FC<{}> = function()
				showBoundary = useErrorBoundary().showBoundary
				return e("Frame", {
					key = "Child",
				})
			end

			local root = ReactRoblox.createRoot(container)
			act(function()
				root:render(e(ErrorBoundary, {
					FallbackComponent = FallbackComponent,
				}, {
					Child = e(Child),
				}))
			end)
			expect(container:FindFirstChild("Child")).to.be.ok()

			act(function()
				assert(showBoundary)
				showBoundary("Error")
			end)
			expect(container:FindFirstChild("Fallback")).to.be.ok()

			act(function()
				assert(resetBoundary)
				resetBoundary()
			end)
			expect(container:FindFirstChild("Child")).to.be.ok()
		end)
	end)
end

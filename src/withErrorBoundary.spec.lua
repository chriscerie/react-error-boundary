--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local withErrorBoundary = require(script.Parent.withErrorBoundary)

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

		beforeEach(function()
			container = Instance.new("Folder")
			root = ReactRoblox.createRoot(container)
			shouldThrow = false
			valueToThrow = "💥💥💥"
		end)

		local MaybeThrows: React.FC<{
			children: any,
		}> = function(props)
			if shouldThrow then
				error(valueToThrow)
			end
			return props.children or e("Frame", {
				key = "Content",
			})
		end

		local function render()
			local ErrorBoundary = withErrorBoundary(MaybeThrows, {
				fallback = e("Frame", {
					key = "Fallback",
				}),
			})

			act(function()
				root:render(e(ErrorBoundary))
			end)
		end

		it("should render children within the created HOC", function()
			render()
			expect(container:FindFirstChild("Content")).to.be.ok()
		end)

		it("should catch errors with the created HOC", function()
			shouldThrow = true
			render()
			expect(container:FindFirstChild("Fallback")).to.be.ok()
		end)

		it("should forward refs", function()
			local Inner = React.forwardRef(function(props: {}, ref)
				return e("Frame", {
					key = "Content",
					ref = ref,
				})
			end)

			local Wrapped = withErrorBoundary(Inner :: any, {
				fallback = e("Frame", {
					key = "Fallback",
				}),
			})

			local ref = React.createRef()

			act(function()
				root:render(e(Wrapped, {
					ref = ref,
				}))
			end)

			expect(ref.current).to.be.ok()
		end)
	end)
end

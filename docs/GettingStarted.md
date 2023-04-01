---
sidebar_position: 2
---

# Getting Started

Getting started with react-error-boundary is simple. First, create a fallback component.

```lua
local e = React.createElement
local Fallback: React.FC<ReactErrorBoundary.FallbackProps> = function(_props)
    return e("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Text = "An error was encountered!.",
    })
end
```

Next, in your app, wrap an `ErrorBoundary` where needed.

```lua
local App: React.FC<{}> = function(_props)
    return e(ReactErrorBoundary.ErrorBoundary, {
        FallbackComponent = Fallback,
    }, {
        ComponentThatMightError = e(ComponentThatMightError),
    })
end
```

Now when `ComponentThatMightError` or any of its descendant errors, the error boundary will catch it and render the fallback component. When an error is encountered somewhere in your app, the nearest `ErrorBoundary` will catch and handle it. You don't need to wrap every component in an `ErrorBoundary`. Consider the [granularity of error boundaries](https://aweary.dev/fault-tolerance-react/) and where it makes sense to display an error message or revert states.

This was a very basic example. In a real application, you might want the fallback component to render a "go back" button that reverts state, or you might want to do that immediately after encountering an error.

## Next steps

Check out the [API reference](/api). First, read the usage of the main [ErrorBoundary](/api/ErrorBoundary) component.
Then learn the [useErrorBoundary](/api/ReactErrorBoundary#useErrorBoundary) hook.

<a href="https://www.chrisc.dev/react-error-boundary/">
  <p align="center">
    <img src="https://i.imgur.com/1Ta6WRv.png" width="200" />
  </p>
</a>

<h1 align="center">react-error-boundary</h1>
<h3 align="center">A robust error boundary library for [Lua React](https://github.com/grilme99/CorePackages).</h3>

<br>

<div align="center">
  <a href="https://github.com/chriscerie/react-error-boundary/actions/workflows/docs.yml">
    <img src="https://github.com/chriscerie/react-error-boundary/workflows/docs/badge.svg" alt="Deploy Docs Status"/>
  </a>
</div>

<br>

## Why react-error-boundary

By design, React unmounts the entire tree when it encounters an unhandled error. This leaves the application in an ususable state unless the user refreshes the application. In the context of a video game, the player would need to leave and rejoin the game. Error boundaries provide a way to recover from errors to greatly improve user experience.

### Use cases

- Rendering fallback components upon errors (e.g., error screen)
- Reverting state to a known good state
- Retrying render with reverted state
- Logging errors in an external database

## Installation

### Wally

Add the latest version of react-error-boundary to your wally.toml (e.g., `ReactErrorBoundary = "chriscerie/react-error-boundary@<version>"`)

## Getting Started

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

This was a very basic example. In a real application, you might want the fallback component to render a "go back" button that reverts state, or you might want to do that immediately after encountering an error. More advanced usage is detailed in react-error-boundary's official [documentation](https://www.chrisc.dev/react-error-boundary/).

## License

`react-error-boundary` is available under the MIT license. See [LICENSE](LICENSE) for details.

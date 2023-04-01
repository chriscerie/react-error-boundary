---
sidebar_position: 1
---

# Introduction

**react-error-boundary** is a robust error boundary library for [Lua React](https://github.com/grilme99/CorePackages). It makes error logging, reverting states, and displaying fallback components incredibly easy to implement.

## Installation

### Wally

Add the latest version of react-error-boundary to your `wally.toml`:

```console
ReactErrorBoundary = "chriscerie/react-error-boundary@<version>"
```

## Why react-error-boundary

By design, React unmounts the entire tree when it encounters an unhandled error. This leaves the application in an ususable state unless the user refreshes the application. In the context of a video game, the player would need to leave and rejoin the game. Error boundaries provide a way to recover from errors to greatly improve user experience.

### Use cases

- Rendering fallback components upon errors (e.g., error screen)
- Reverting state to a known good state
- Retrying render with reverted state
- Logging errors in an external database

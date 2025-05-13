# LivexDemo

This is a demo application for [Livex](https://github.com/u2i/livex), a library that enhances Phoenix LiveView with additional features.

## Getting Started

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies (this will also setup the database)
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  (see note below)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing Reconnect Behavior

To test the reconnect behavior of Livex, press `Ctrl+C` to stop the running server and restart it.
And to ensure that dev-time asset management doesn't trigger full page reloads use the following to
start it.

```
LIVE_RELOAD=0 iex -S mix phx.server
```

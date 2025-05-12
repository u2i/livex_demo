# LivexDemo

This is a demo application for [LiveX](https://github.com/u2i/livex), a library that enhances Phoenix LiveView with additional features.

## Getting Started

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies (this will also setup the database)
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing Reconnect Behavior

To test the reconnect behavior of LiveX, use:

```
LIVE_RELOAD=0 iex -S mix phx.server
```

This disables live reloading and allows you to observe how LiveX handles reconnections.

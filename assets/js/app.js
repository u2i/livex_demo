// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const csrfToken = document
	.querySelector("meta[name='csrf-token']")
	.getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
	longPollFallbackMs: 2500,
	params: { _csrf_token: csrfToken },
	logger: (kind, msg, data) => console.log(`[LiveSocket ${kind}] ${msg}`, data),
});

// --- expose a little helper so we don’t reach into private APIs everywhere
liveSocket.pushPatchUrl = (href, linkState = {}) => {
	// historyPatch will bump LiveSocket.currentHistoryPosition,
	// call Browser.pushState, and fire phx:navigate
	liveSocket.historyPatch(href, linkState);
};

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// // now listen for update_url and delegate to our helper
// window.addEventListener("phx:update_url", ({ detail }) => {
// 	if (detail && detail.uri) {
// 		// you can pass detail.linkState if you emit it server-side
// 		console.log(detail);
// 		liveSocket.pushPatchUrl(detail.uri, detail.linkState || { a: "b" });
// 	}
// });

window.addEventListener("phx:update_url", ({ detail }) => {
	if (detail && detail.uri) {
		// 1) change the browser URL
		const newUrl = detail.uri;
		history.pushState({ patch: true }, "", newUrl);

		// 2) teach LiveSocket about the new location
		liveSocket.href = window.location.href;
		liveSocket.currentLocation = {
			pathname: window.location.pathname,
			search: window.location.search,
			hash: window.location.hash,
		};

		// 3) update the main View’s stored href
		liveSocket.main.setHref(newUrl);
	}
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
	window.addEventListener(
		"phx:live_reload:attached",
		({ detail: reloader }) => {
			// Enable server log streaming to client.
			// Disable with reloader.disableServerLogs()
			reloader.enableServerLogs();

			// Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
			//
			//   * click with "c" key pressed to open at caller location
			//   * click with "d" key pressed to open at function component definition location
			let keyDown;
			window.addEventListener("keydown", (e) => (keyDown = e.key));
			window.addEventListener("keyup", (e) => (keyDown = null));
			window.addEventListener(
				"click",
				(e) => {
					if (keyDown === "c") {
						e.preventDefault();
						e.stopImmediatePropagation();
						reloader.openEditorAtCaller(e.target);
					} else if (keyDown === "d") {
						e.preventDefault();
						e.stopImmediatePropagation();
						reloader.openEditorAtDef(e.target);
					}
				},
				true,
			);

			window.liveReloader = reloader;
		},
	);
}

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
const { JS } = require("phoenix_live_view");

import topbar from "../vendor/topbar";
import buildLvPageUrls from "./uri.js";

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

let Hooks = {};
Hooks.AfterPatch = {
	updated() {},
};
Hooks.LivexView = {
	updated() {},
};

const csrfToken = document
	.querySelector("meta[name='csrf-token']")
	.getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
	longPollFallbackMs: 2500,
	params: { _csrf_token: csrfToken },

	// params: (el) => {
	// 	console.log(el);
	// // compute or read your desired URL here:
	// // e.g. read a data attribute, or use window.location
	// const desiredUrl =
	// 	el.getAttribute("data-mount-url") ||
	// 	window.location.pathname + window.location.search;
	//
	// return {
	// 	_csrf_token: csrfToken,
	// 	// override the built‑in `uri` param that LiveView will see
	// 	// 			uri: "http://localhost:4000/locations?foo=bar",
	// 	foo: "bar",
	// 	location_id: 123,
	// };
	//},
	logger: (kind, msg, data) => console.log(`[LiveSocket ${kind}] ${msg}`, data),
	hooks: Hooks,
});

liveSocket.domCallbacks.onPatchEnd = function (el) {
	const uris = buildLvPageUrls();
	// const currentPath = window.location.pathname + window.location.search;
	//
	// console.log(uris);
	// console.log(currentPath);
	//
	// // // Only update history if the URL has changed
	// // if (uris.primaryUrl !== currentPath) {
	// // 	// Update URL in browser history
	// // 	history.pushState({ patch: true }, "", uris.primaryUrl);
	// // }
	// //
	// // Always update LiveSocket's knowledge of the current location
	// // liveSocket.href = window.location.href;
	//
	// // Parse the primaryUrl to get pathname and search
	//
	//
	const url1 = new URL(uris.primaryUrl, window.location.origin);
	const url = new URL(uris.combinedUrl, window.location.origin);
	// liveSocket.currentLocation = {
	// 	pathname: url.pathname,
	// 	search: url.search,
	// 	hash: window.location.hash,
	// };
	//
	// liveSocket.main.setHref();
	// // Always update the main View's stored href if available
	// if (liveSocket.main && typeof liveSocket.main.setHref === "function") {
	// 	// Use the full URL with origin but with the primary URL's path and query
	// 	const fullCombinedUrl =[48;57;214;1596;2996]
	// 		window.location.origin + url.pathname + url.search + window.location.hash;
	// 	liveSocket.main.setHref(fullCombinedUrl);
	// }
	console.log("updating view href");

	// liveSocket.currentHistoryPosition++;
	// liveSocket.sessionStorage.setItem(
	// 	"phx:nav-history-position",
	// 	liveSocket.currentHistoryPosition.toString(),
	// );
	//
	// // store the type for back navigation
	// Browser.updateCurrentState((state) => ({ ...state, backType: "patch" }));
	//
	// Browser.pushState(
	// 	"push",
	// 	{
	// 		type: "patch",
	// 		id: liveSocket.main.id,
	// 		position: liveSocket.currentHistoryPosition,
	// 	},
	// 	url1.href,
	// );

	console.log("before " + window.liveSocket.href);
	console.log("after " + url1.href);

	liveSocket.historyPatch(url1.href, "push");

	// update the global href too (for fallback reloads)
	window.liveSocket.href = url1.href;

	// update only the main LiveView’s href
	if (window.liveSocket.main) {
		window.liveSocket.main.setHref(url.href);
	}
};
// --- expose a little helper so we don't reach into private APIs everywhere
liveSocket.pushPatchUrl = (href, linkState = {}) => {
	// historyPatch will bump LiveSocket.currentHistoryPosition,
	// call Browser.pushState, and fire phx:navigate
	liveSocket.historyPatch(href, linkState);
};

// const origJSPush = JS.push;
//
// JS.push = function (el, event, payload = {}) {
// 	if (event === "__assign_data" && payload.target == null) {
// 		const comp = el.closest("[data-phx-component]");
// 		if (comp) {
// 			payload = { ...payload, target: comp.getAttribute("data-phx-component") };
// 		}
// 	}
// 	return origJSPush(el, event, payload);
// };
//
liveSocket.connect();

window.addEventListener("phx:js-execute", ({ detail }) => {
	console.log("js-execute");
	console.log(detail.ops);
	liveSocket.execJS(document.body, detail.ops);
	//	this.execJS(document.getElementById("lv-container"), JS.push("close_modal"));
});

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

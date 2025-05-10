/**
 * Builds two URLs from LiveView page and component params:
 *
 * 1. Primary URL: uses only `lv-url-<prop>` attributes.
 * 2. Combined URL: uses both `lv-url-<prop>` and `lv-data-<prop>` attributes.
 *
 * - Reads `lv-route` attribute as a Phoenix-style route (e.g. "/foos/:id/edit").
 * - Reads `lv-url-<prop>` and `lv-data-<prop>` attributes on #lv-page-param.
 * - Substitutes matching `:vars` in the route with encoded `lv-url-`/`lv-data-` values.
 * - Finds all `<div data-phx-component>` elements, reads their `lv-url-<prop>` and
 *   `lv-data-<prop>` attributes, grouping under underscored DOM ids (e.g. `_<domId>`).
 * - Serializes remaining params into a query string using PHP-style brackets (e.g. `foo[bar]=baz`).
 *
 * @returns {{ primaryUrl: string, combinedUrl: string }}
 */
function safeEncode(str) {
	return encodeURIComponent(str).replace(/%5B/g, "[").replace(/%5D/g, "]");
}

/**
 * Given a route and params object, substitute path vars and serialize query.
 * @param {string} route
 * @param {Object} attrs - flat or nested object of values
 * @returns {string}
 */
function buildUrl(route, attrs) {
	let url = route;
	const remaining = {};

	// Substitute any :vars in path
	Object.entries(attrs).forEach(([key, val]) => {
		const varPattern = new RegExp(`:${key}(?=/|$)`, "g");
		if (varPattern.test(url)) {
			url = url.replace(varPattern, encodeURIComponent(String(val)));
		} else {
			remaining[key] = val;
		}
	});

	// Serialize as query string
	const parts = [];
	function serialize(obj, prefix) {
		if (obj == null) return;
		if (typeof obj === "object" && !Array.isArray(obj)) {
			Object.entries(obj).forEach(([k, v]) => serialize(v, `${prefix}[${k}]`));
		} else if (Array.isArray(obj)) {
			obj.forEach((v, i) => serialize(v, `${prefix}[${i}]`));
		} else {
			parts.push(`${safeEncode(prefix)}=${encodeURIComponent(String(obj))}`);
		}
	}

	Object.entries(remaining).forEach(([key, value]) => serialize(value, key));
	return parts.length ? `${url}?${parts.join("&")}` : url;
}

export default function buildLvPageUrls() {
	// Grab page element and route
	const pageEl = document.getElementById("lv-page-params");
	if (!pageEl) throw new Error('Element with id "lv-page-params" not found.');
	const route = pageEl.getAttribute("lv-route");
	if (!route) throw new Error('Attribute "lv-route" not found.');

	// Collect page-level attrs
	const urlAttrs = {};
	const dataAttrs = {};
	Array.from(pageEl.attributes).forEach(({ name, value }) => {
		if (name.startsWith("lv-url-")) {
			const key = name.slice("lv-url-".length);
			urlAttrs[key] = JSON.parse(value);
		} else if (name.startsWith("lv-data-")) {
			const key = name.slice("lv-data-".length);
			dataAttrs[key] = JSON.parse(value);
		}
	});

	// Collect component-level attrs
	document.querySelectorAll("div[data-phx-component]").forEach((comp) => {
		const compId = comp.id;
		if (!compId) return;
		const compKey = `_${compId}`;
		Array.from(comp.attributes).forEach(({ name, value }) => {
			if (name.startsWith("lv-url-")) {
				const key = name.slice("lv-url-".length);
				urlAttrs[compKey] = urlAttrs[compKey] || {};
				urlAttrs[compKey][key] = JSON.parse(value);
			} else if (name.startsWith("lv-data-")) {
				const key = name.slice("lv-data-".length);
				dataAttrs[compKey] = dataAttrs[compKey] || {};
				dataAttrs[compKey][key] = JSON.parse(value);
			}
		});
	});

	// Build primary URL (only lv-url)
	const primaryUrl = buildUrl(route, urlAttrs);

	// Merge urlAttrs + dataAttrs for combined
	const combined = {};
	Object.keys(urlAttrs).forEach((k) => (combined[k] = urlAttrs[k]));
	Object.entries(dataAttrs).forEach(([k, v]) => {
		if (
			combined[k] &&
			typeof combined[k] === "object" &&
			typeof v === "object"
		) {
			combined[k] = { ...combined[k], ...v };
		} else {
			combined[k] = v;
		}
	});
	const combinedUrl = buildUrl(route, combined);

	return { primaryUrl, combinedUrl };
}

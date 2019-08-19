## [1.5.2](https://github.com/puppetlabs/apisprout/compare/v1.5.1...v1.5.2) (2019-08-19)


### Fix

* Correct parsing of application/json, application/yaml, and text/yaml media types ([e80268d7311214901f1964d63e54891381a2344e](https://github.com/puppetlabs/apisprout/commit/e80268d7311214901f1964d63e54891381a2344e))

## [1.5.1](https://github.com/puppetlabs/apisprout/compare/v1.5.0...v1.5.1) (2019-08-18)


### Fix

* Use the correct version number in releases ([873e042b6c3d455613dbfe21eee32e7094048b83](https://github.com/puppetlabs/apisprout/commit/873e042b6c3d455613dbfe21eee32e7094048b83))

# [1.5.0](https://github.com/puppetlabs/apisprout/compare/v1.4.0...v1.5.0) (2019-08-18)


### New

* Add support for allOf, anyOf, and oneOf ([4a95528cadbd174f1b4d32dc28d4ce98ef738d1e](https://github.com/puppetlabs/apisprout/commit/4a95528cadbd174f1b4d32dc28d4ce98ef738d1e))

# [1.4.0](https://github.com/puppetlabs/apisprout/compare/v1.3.0...v1.4.0) (2019-08-18)


### Build

* Automatically release ([5ba016737ed1e3cd3feae19540e2f396b9b63533](https://github.com/puppetlabs/apisprout/commit/5ba016737ed1e3cd3feae19540e2f396b9b63533))

### Update

* Match all relevant JSON and YAML media types ([e046dd2a99faffd5b3d365459c980393913f610b](https://github.com/puppetlabs/apisprout/commit/e046dd2a99faffd5b3d365459c980393913f610b))

# [1.3.0] - 2019-03-18
- Add `--add-server` to add a custom server when using `--validate-server`.
  This allows quickly adding a custom domain or base path that will properly
  validate.
- Add `--header` (short `-H`) option to specify a custom header when fetching
  the API document. This allows you to pass custom auth info.
- Add `readOnly` and `writeOnly` support to the example generator.
- Revamped support for `--validate-server` (short `-s`)
  - Requires the use of server base path(s) on the client.
  - Localhost is now always allowed on all known base paths.
  - Support for proxy headers (e.g. `X-Forwarded-Host`).
- Better support for resolving relative path references.
- Be more resilient to parser panics when using `--watch`
- Update Docker build to use Go 1.12 and Go modules.
- Enhance example-from-schema generation code. Support enums, string formats,
  array and object examples, min/max and min items.

# [1.2.0] - 2019-02-27
- Add support for reloading OpenAPI URLs via `/__reload` on the server.
- Support external references in OpenAPI loader.
- Update dependencies, simplify file loading.
- Support jsonapi.org content type (`application/vnd.api+json`).
- Switch from `dep` to Go modules.

# [1.1.1] - 2019-01-30
- Fix `OPTIONS` request to also include CORS headers.

# [1.1.0] - 2019-01-29
- Added the `--watch` (short `-w`) parameter to reload whenever the input file
  changes. This currently only works when using files on disk.
- Update Docker build to use Go 1.11.
- Generate examples from schema when no example is available.
- Fix path parameter validation.
- Add CORS headers. Disable with `--disable-cors`.
- Documentation updates.

# [1.0.1] - 2018-10-03
- Dependency updates, fixes string format validation bug.

# [1.0.0] - 2018-07-24
- Initial release.

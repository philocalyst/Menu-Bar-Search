# Changelog

All notable changes to this project are documented in this changelog.  
This project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.2] – 2025-05-12

### Added
- Add `@retroactive @unchecked Sendable` conformance for `AXUIElement` to silence Swift concurrency warnings.

### Changed
- Optimize menu-bar retrieval in `MenuGetter.load` by pre-filtering top-level bar items before spawning tasks, reserving result capacity, and reducing per-item overhead.
- Change CLI `--pid` option and `RuntimeArgs.pid` from `Int` to `Int32` to match process identifier types.

### Removed
- Remove internal `loadAsync` property from `RuntimeArgs` and its CLI assignment, deprecating the `--async` flag integration.

---

[Unreleased]: https://github.com/philocalyst/Menu-Bar-Search/compare/v1.2.2...HEAD  
[1.2.2]:    https://github.com/philocalyst/Menu-Bar-Search/compare/v1.2.1...v1.2.2  

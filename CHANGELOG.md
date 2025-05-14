# Changelog

All notable changes to this project are documented in this changelog.  
This project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.3.1] – 2025-05-13

### Added
- Support customisable search and settings keywords via `SEARCH_KEYWORD` and
  `SETTINGS_KEYWORD` workflow variables.

### Changed
- Update workflow icon to avoid visual conflicts with earlier versions.
- Improve asset images with a refreshed color scheme.

### Removed
- Remove redundant second‐example screenshot from the README.

### Fixed
- Fix asset image paths in the README to point to the `Assets` directory.

## [1.3.0] – 2025-05-13

### Added
- Integrate Fuse.swift v1.4.0 for fuzzy matching (`fastMatch` now powered by Fuse).  
- Standardize all code under a top-level `source/` directory.  
- Include Alfred workflow metadata and assets:  
  - Icons (`apple-icon.png`, `icon.png`, `icon.settings.png`, `icon.error.png`)  
  - `info.plist` with workflow configuration  
  - Sample `settings.txt` for per-app overrides  

### Changed
- Revamped README: updated title, description, setup instructions, usage examples and contribution links.  
- Restructured repository:  
  - Moved `Package.swift`, `Package.resolved` and `.gitignore` to project root  
  - Eliminated old nested `source/` tree in favor of a single `source/` folder  
- Replaced bespoke fuzzy-matching algorithm with Fuse-based implementation for better accuracy and maintainability.  

## [1.2.2] – 2025-05-12

### Added
- Add `@retroactive @unchecked Sendable` conformance for `AXUIElement` to silence Swift concurrency warnings.

### Changed
- Optimize menu-bar retrieval in `MenuGetter.load` by pre-filtering top-level bar items before spawning tasks, reserving result capacity, and reducing per-item overhead.
- Change CLI `--pid` option and `RuntimeArgs.pid` from `Int` to `Int32` to match process identifier types.

### Removed
- Remove internal `loadAsync` property from `RuntimeArgs` and its CLI assignment, deprecating the `--async` flag integration.

## [1.2.1] – 2025-04-19

### Added
- New CLI entrypoint `@main struct Menu: AsyncParsableCommand` powered by  
  [swift-argument-parser], replacing custom `RuntimeArgs.parse()`.  
- Async/await actor-based `MenuGetter` using `withTaskGroup` for  
  concurrent menu traversal and safe aggregation.  
- Conformance of `AXUIElement` and `MenuGetterOptions` to `@unchecked Sendable`.  
- Comprehensive set of flags and options:  
  `--query`, `--pid`, `--max-depth`, `--max-children`,  
  `--reorder-apple-menu`, `--learning`, `--click`, `--async`,  
  `--cache`, `--show-disabled`, `--show-apple-menu`, `--recache`,  
  `--dump`, `--show-folders`, and `--only`.  
- Require macOS 10.15+ in the package manifest for Swift concurrency support.  
- Bump Swift Protobuf to v1.29.0 and add swift-argument-parser v1.5.0;  
  update `swift-tools-version` to 6.1.  
- Rename `main.swift` → `MenuSearch.swift` and refactor entry in code.  
- Switch Protobuf cache logic from `serializedData()` to `serializedBytes()`.

### Changed
- Refactor all GCD-based queues/`DispatchGroup` to modern Swift concurrency.  
- Default `learning` mode is now off (`false`) instead of on.  
- Simplify cache timeout logic by sliding window forward on near-expiry.  
- Clean up `IndexParser` and code formatting for consistency.

### Removed
- Delete legacy `MenuItem.proto` and all commented-out AX attribute debug helpers.  
- Strip dead code in `RuntimeArgs.swift` and remove redundant manual `main()` calls.

### Fixed
- Preserve all passed-in arguments when invoking the new CLI (no more accidental  
  overwrite).

---

[Unreleased]: https://github.com/philocalyst/Menu-Bar-Search/compare/v1.3.1...HEAD
[1.3.1]: https://github.com/philocalyst/Menu-Bar-Search/compare/v1.2.2...v1.3.1
[1.3.0]: https://github.com/philocalyst/Menu-Bar-Search/compare/v1.2.2...v1.3.0  
[1.2.2]:    https://github.com/philocalyst/Menu-Bar-Search/compare/v1.2.1...v1.2.2  
[1.2.1]: https://github.com/your-org/menu/compare/...v1.2.1  

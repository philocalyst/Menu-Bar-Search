# <img src='assets/icon.png' width='35' align='center' alt='Menu Bar Search icon'> Menu Bar Search - An Alfred Workflow

Quickly search through menu options of the front-most application. [↓ Download](https://github.com/philocalyst/Menu-Bar-Search/releases/tag/v1.2.1)

<p align="center">
  <img src='assets/finder.png' width='32%' alt='Finder menu search example'> 
  <img src='assets/photos.png' width='32%' alt='Photos menu search example'> 
  <img src='assets/music.png' width='32%' alt='Music menu search example'>
  <img src='assets/search.png' width='32%' alt='General search example' align='top'>
</p>

## Usage

- Type `m` in Alfred to list menu bar items for the front-most application.
- You can filter menu items by name, or use fuzzy searching.
- Alternatively, you can set a hotkey to trigger the workflow.


**Examples:**

- Typing `m new tab` will match the menu item **New Tab**.
- Typing `m cw` will match the menu item **Close Window**.

## Building
You need to be on SPM 6+.

`swift build -c release -Xswiftc "-whole-module-optimization"`


## Change Log

- **1.0:** Initial Release.
- **1.1:**  Added Fuzzy Text Matching for Menus.
- **1.1.1:** Changed run behaviour to terminate the previous script, making the experience slightly faster.
- **1.2:** Completely native menu clicking, removed reliance on AppleScript.
  - **1.2.1:** Performance improvements when generating menus using direct JSON encoding.
  - **1.2.2:** More performance improvements while filtering menu items.
- **1.3:** Added `-async` flag to allow threaded scanning and populating of menus.
- **1.4:** Added `-cache` setting to enable menu result caching and also set a timeout for cache invalidation.
  - **1.4.1:** Invalidate cache (if present) after actioning a menu press.
  - **1.4.2:** Slide the cache invalidation window forward in case of a near miss.
  - **1.4.3:** Speed improvements to caching, text search, and fuzzy matching.
  - **1.4.4:** Added `-no-apple-menu` flag that will skip Apple menu items.
  - **1.4.5:** Tuned fuzzy matcher to allow non-continuous anchor token search.
- **1.5:** Faster caching using protocol buffers.
  - **1.5.1:** Reduced file creation for cache storage.
  - **1.5.2:** Better support for command line apps that create menu bar owning applications.
  - **1.5.3:** Protocol buffer everything - microscopic speed improvements.
  - **1.5.4:** Added various environment variables to fine-tune menu listings.
  - **1.5.5:** Tweaked ranking of search results for better menu listings.
- **1.6:** Added per-app customization via a `Settings.txt` configuration file.
- **1.7:** Universal build for M1 and Intel.
- **1.8:** Fixed the universal build.
- **1.9:** Changed to user configuration and signed executable (exported using Alfred 5).
- **2.0:** Alfred workflow gallery support! Includes added shortcut search, brand-new configuration settings, tweaks to caching behaviour, and brand-new icons.
- **2.1:** Updated to Swift concurrency and migrated argument parsing logic to the Swift Argument Parser library. **NEW MAINTAINER: Philocalyst**

## Credits

- Based on ctwise's ObjC implementation of [Menu Bar Search](https://www.alfredforum.com/topic/1993-menu-search/), which has been ported to Swift and enhanced with caching and per-app configuration for improved performance.

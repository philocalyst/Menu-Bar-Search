import ArgumentParser
import Foundation

@main
struct Menu: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Search & action macOS app menu‑bar items via Alfred"
	)

	@Option(
		name: [.short, .long],
		help: "Filter menu items by query (use # prefix for shortcuts).")
	var query: String?

	@Option(
		name: .long,
		help: "PID of the target application (default: frontmost).")
	var pid: Int?

	@Option(name: .long, help: "Max menu depth (default: 10).")
	var maxDepth: Int = 10

	@Option(name: .long, help: "Max children per submenu (default: 40).")
	var maxChildren: Int = 40

	@Flag(
		name: .long,
		help: "Reorder Apple menu items to the end")
	var reorderAppleMenuToLast: Bool = false

	@Flag(
		name: .long,
		help:
			"Enable learning mode, which will remember selections and make better recomendations as time goes on"
	)
	var learning: Bool = false

	@Option(
		name: .long,
		help: "Click the menu item at this JSON index‑path (e.g. \"0,3,1\").")
	var click: String?

	@Flag(
		name: .long,
		help: "Use async loading of submenus.")
	var async = false

	@Option(
		name: .long,
		help: "Enable caching with given timeout (seconds).")
	var cache: Double?

	@Flag(name: .long, help: "Show disabled menu items.")
	var showDisabled = false

	@Flag(name: .long, help: "Include the Apple menu in results.")
	var showAppleMenu = false

	@Flag(
		name: .long,
		help: "Invalidate cache if query is empty.")
	var recache = false

	@Flag(name: .long, help: "Dump debug info instead of Alfred JSON.")
	var dump = false

	@Flag(
		name: .long,
		help: "Show your Settings & Cache folders as Alfred results.")
	var showFolders = false

	@Option(
		name: .long,
		help: "Only traverse this top‑level menu (case‑insensitive).")
	var only: String?

	func run() async throws {
		// --show‑folders shortcut
		if showFolders {
			let a = Alfred()
			let icon = AlfredResultItemIcon.with { $0.path = "icon.settings.png" }
			// settings folder
			a.add(
				.with {
					$0.title = "Settings Folder"
					$0.arg = Alfred.data()
					$0.icon = icon
				})
			if !FileManager.default
				.fileExists(atPath: Alfred.data(path: "settings.txt"))
			{
				a.add(
					.with {
						$0.title = "View a sample Settings file"
						$0.subtitle = "Use this to customise per‑app settings"
						$0.arg = "sample settings.txt"
						$0.icon = icon
					})
			}
			// cache folder
			a.add(
				.with {
					$0.title = "Cache Folder"
					$0.arg = Alfred.cache()
					$0.icon = icon
				})

			let now = Date()
			for ctrl in Cache.getCachedMenuControls() {
				let expiry = Date(timeIntervalSince1970: ctrl.control.timeout)
				let expired = expiry <= now
				let prefix = expired ? "expired" : "expires in"
				if #available(macOS 10.15, *) {
					let fmt = RelativeDateTimeFormatter()
					let rel = fmt.localizedString(for: expiry, relativeTo: now)
					a.add(
						.with {
							$0.title = ctrl.appBundleId
							$0.subtitle = "\(prefix) \(rel)"
						})
				} else {
					a.add(
						.with {
							$0.title = ctrl.appBundleId
							$0.subtitle = "\(prefix) \(expiry)"
						})
				}
			}
			print(a.resultsJson)
			return
		}

		// build old RuntimeArgs to interoperate
		let runtime = RuntimeArgs()
		runtime.query = query ?? ""
		runtime.pid = Int32(pid ?? -1)
		runtime.options.maxDepth = maxDepth
		runtime.options.maxChildren = maxChildren
		runtime.reorderAppleMenuToLast = reorderAppleMenuToLast
		runtime.learning = learning
		runtime.loadAsync = async
		if let t = cache {
			runtime.cachingEnabled = true
			runtime.cacheTimeout = t
		}
		runtime.options.appFilter.showDisabledMenuItems = showDisabled
		runtime.options.appFilter.showAppleMenu = showAppleMenu
		runtime.options.recache = recache
		runtime.options.dumpInfo = dump
		runtime.options.specificMenuRoot = only
		if let clickJSON = click {
			runtime.clickIndices = IndexParser.parse(clickJSON)
		}

		// call your existing async main logic
		await MenuSearch.run(with: runtime)
	}
}

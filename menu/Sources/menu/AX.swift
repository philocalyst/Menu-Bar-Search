//
//  AX.swift
//  Menu
//
//  Created by Benzi on 23/04/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import ApplicationServices
import Foundation

#if swift(>=5.5) && canImport(_Concurrency)
    // SAFETY: A promise, from us to the compiler, to never mututate from mulitple threads.
    extension AXUIElement: @unchecked Sendable {}
    extension MenuGetterOptions: @unchecked Sendable {}
#endif

let virtualKeys = [
    0x24: "↩",  // kVK_Return
    0x4c: "⌤",  // kVK_ANSI_KeypadEnter
    0x47: "⌧",  // kVK_ANSI_KeypadClear
    0x30: "⇥",  // kVK_Tab
    0x31: "␣",  // kVK_Space
    0x33: "⌫",  // kVK_Delete
    0x35: "⎋",  // kVK_Escape
    0x39: "⇪",  // kVK_CapsLock
    0x3f: "fn",  // kVK_Function
    0x7a: "F1",  // kVK_F1
    0x78: "F2",  // kVK_F2
    0x63: "F3",  // kVK_F3
    0x76: "F4",  // kVK_F4
    0x60: "F5",  // kVK_F5
    0x61: "F6",  // kVK_F6
    0x62: "F7",  // kVK_F7
    0x64: "F8",  // kVK_F8
    0x65: "F9",  // kVK_F9
    0x6d: "F10",  // kVK_F10
    0x67: "F11",  // kVK_F11
    0x6f: "F12",  // kVK_F12
    0x69: "F13",  // kVK_F13
    0x6b: "F14",  // kVK_F14
    0x71: "F15",  // kVK_F15
    0x6a: "F16",  // kVK_F16
    0x40: "F17",  // kVK_F17
    0x4f: "F18",  // kVK_F18
    0x50: "F19",  // kVK_F19
    0x5a: "F20",  // kVK_F20
    0x73: "↖",  // kVK_Home
    0x74: "⇞",  // kVK_PageUp
    0x75: "⌦",  // kVK_ForwardDelete
    0x77: "↘",  // kVK_End
    0x79: "⇟",  // kVK_PageDown
    0x7b: "◀︎",  // kVK_LeftArrow
    0x7c: "▶︎",  // kVK_RightArrow
    0x7d: "▼",  // kVK_DownArrow
    0x7e: "▲",  // kVK_UpArrow
]

// let halfWidthSpace = " " // "🌐"
let halfWidthSpace = ""

func decode(modifiers: Int) -> String {
    if modifiers == 0x18 { return "fn" }
    var result = [String]()
    if (modifiers & 0x04) > 0 { result.append("⌃") }
    if (modifiers & 0x02) > 0 { result.append("⌥") }
    if (modifiers & 0x01) > 0 { result.append("⇧") }
    if (modifiers & 0x08) == 0 { result.append("⌘") }
    return result.joined(separator: halfWidthSpace)
}

func getShortcut(_ cmd: String?, _ modifiers: Int, _ virtualKey: Int) -> String {
    var shortcut: String? = cmd
    if let s = shortcut {
        if s.unicodeScalars[s.unicodeScalars.startIndex].value == 0x7f {
            shortcut = "⌦"
        }
    } else if virtualKey > 0 {
        if let lookup = virtualKeys[virtualKey] {
            shortcut = lookup
        }
    }
    let mods = decode(modifiers: modifiers)
    if let s = shortcut {
        shortcut = mods + halfWidthSpace + s
    }
    return shortcut ?? ""
}

func getAttribute(element: AXUIElement, name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    AXUIElementCopyAttributeValue(element, name as CFString, &value)
    return value
}

func clickMenu(menu element: AXUIElement, pathIndices: [Int], currentIndex: Int) {
    guard
        let menuBarItems = getAttribute(element: element, name: kAXChildrenAttribute)
            as? [AXUIElement], menuBarItems.count > 0
    else { return }
    let itemIndex = pathIndices[currentIndex]
    guard itemIndex >= menuBarItems.startIndex, itemIndex < menuBarItems.endIndex else { return }
    let child = menuBarItems[itemIndex]
    if currentIndex == pathIndices.count - 1 {
        AXUIElementPerformAction(child, kAXPressAction as CFString)
        return
    }
    guard let menuBar = getAttribute(element: child, name: kAXChildrenAttribute) as? [AXUIElement]
    else { return }
    clickMenu(menu: menuBar[0], pathIndices: pathIndices, currentIndex: currentIndex + 1)
}

func getMenuItems(
    forElement element: AXUIElement,
    menuItems: inout [MenuItem],
    path: [String] = [],
    pathIndices: String = "",
    depth: Int = 0,
    options: MenuGetterOptions
) {
    // print(String(repeating: ".", count: depth), "🟢 getMenuItems for", path)
    guard depth < options.maxDepth else { return }
    guard
        let children = getAttribute(element: element, name: kAXChildrenAttribute) as? [AXUIElement],
        children.count > 0
    else { return }
    var processedChildrenCount = 0
    for i in children.indices {
        let child = children[i]

        guard let enabled = getAttribute(element: child, name: kAXEnabledAttribute) as? Bool else {
            continue
        }

        // print(String(repeating: ".", count: depth + 1), "🔴 getMenuItems name:", getAttribute(element: child, name: kAXTitleAttribute))
        guard let title = getAttribute(element: child, name: kAXTitleAttribute) as? String else {
            continue
        }
        guard !title.isEmpty else { continue }
        let name = title.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(
            in: CharacterSet.whitespaces)
        guard
            let children = getAttribute(element: child, name: kAXChildrenAttribute)
                as? [AXUIElement]
        else { continue }

        if options.dumpInfo {
            dumpInfo(element: child, name: name, depth: depth)
        }

        let menuPath = path + [name]
        if options.canIgnorePath(path: menuPath) { continue }

        if children.count == 1, enabled {
            // sub-menu item, scan children
            getMenuItems(
                forElement: children[0],
                menuItems: &menuItems,
                path: menuPath,
                pathIndices: pathIndices.isEmpty ? "\(i)" : pathIndices + ",\(i)",
                depth: depth + 1,
                options: options
            )
        } else {
            // if !options.appFilter.showDisabledMenuItems, !enabled { continue }
            guard options.appFilter.showDisabledMenuItems || enabled else {
                if options.dumpInfo {
                    print("➖ ignoring ", menuPath)
                }
                continue
            }

            if options.dumpInfo {
                print("➕ adding ", menuPath)
            }

            // not a sub menu, if we have a path to this item
            let cmd = getAttribute(element: child, name: kAXMenuItemCmdCharAttribute) as? String
            var modifiers = 0
            var virtualKey = 0
            if let m = getAttribute(element: child, name: kAXMenuItemCmdModifiersAttribute) {
                CFNumberGetValue((m as! CFNumber), CFNumberType.longType, &modifiers)
            }
            if let v = getAttribute(element: child, name: kAXMenuItemCmdVirtualKeyAttribute) {
                CFNumberGetValue((v as! CFNumber), CFNumberType.longType, &virtualKey)
            }

            var menuItem = MenuItem()
            menuItem.path = menuPath
            menuItem.pathIndices = pathIndices.isEmpty ? "\(i)" : pathIndices + ",\(i)"
            menuItem.shortcut = getShortcut(cmd, modifiers, virtualKey)
            menuItem.searchPath = menuItem.path.map {
                $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            }
            menuItems.append(menuItem)

            processedChildrenCount += 1
            if processedChildrenCount > options.maxChildren {
                break
            }
        }
    }
}

func dumpInfo(element: AXUIElement, name: String, depth: Int) {
    let padding = " " + String(repeating: " |", count: depth - 1)
    print(padding, ":::", name, ":::")
    print(padding, "   ", element)
    func printAttributeInfo(_ header: String, _ attributes: [String]) {
        let values = attributes.compactMap { (name: String) -> (String, CFTypeRef)? in
            if let a = getAttribute(element: element, name: name) {
                return (name, a)
            }
            return nil
        }
        guard values.count > 0 else { return }
        print(padding, "    ", header)
        values.forEach { print(padding, "        ", $0.0, $0.1) }
    }

    printAttributeInfo(
        "- informational attributes",
        [
            kAXRoleAttribute,
            kAXSubroleAttribute,
            kAXRoleDescriptionAttribute,
            kAXTitleAttribute,
            kAXDescriptionAttribute,
            kAXHelpAttribute,
        ])

    printAttributeInfo(
        "- hierarchy or relationship attributes",
        [
            kAXParentAttribute,
            kAXChildrenAttribute,
            kAXSelectedChildrenAttribute,
            kAXVisibleChildrenAttribute,
            kAXWindowAttribute,
            kAXTopLevelUIElementAttribute,
            kAXTitleUIElementAttribute,
            kAXServesAsTitleForUIElementsAttribute,
            kAXLinkedUIElementsAttribute,
            kAXSharedFocusElementsAttribute,
        ])

    printAttributeInfo(
        "- visual state attributes",
        [
            kAXEnabledAttribute,
            kAXFocusedAttribute,
            kAXPositionAttribute,
            kAXSizeAttribute,
        ])

    printAttributeInfo(
        "- value attributes",
        [
            kAXValueAttribute,
            kAXValueDescriptionAttribute,
            kAXMinValueAttribute,
            kAXMaxValueAttribute,
            kAXValueIncrementAttribute,
            kAXValueWrapsAttribute,
            kAXAllowedValuesAttribute,
        ])

    printAttributeInfo(
        "- text-specific attributes",
        [
            kAXSelectedTextAttribute,
            kAXSelectedTextRangeAttribute,
            kAXSelectedTextRangesAttribute,
            kAXVisibleCharacterRangeAttribute,
            kAXNumberOfCharactersAttribute,
            kAXSharedTextUIElementsAttribute,
            kAXSharedCharacterRangeAttribute,
        ])

    printAttributeInfo(
        "- window, sheet, or drawer-specific attributes",
        [
            kAXMainAttribute,
            kAXMinimizedAttribute,
            kAXCloseButtonAttribute,
            kAXZoomButtonAttribute,
            kAXMinimizeButtonAttribute,
            kAXToolbarButtonAttribute,
            kAXProxyAttribute,
            kAXGrowAreaAttribute,
            kAXModalAttribute,
            kAXDefaultButtonAttribute,
            kAXCancelButtonAttribute,
        ])

    printAttributeInfo(
        "- menu or menu item-specific attributes",
        [
            kAXMenuItemCmdCharAttribute,
            kAXMenuItemCmdVirtualKeyAttribute,
            kAXMenuItemCmdGlyphAttribute,
            kAXMenuItemCmdModifiersAttribute,
            kAXMenuItemMarkCharAttribute,
            kAXMenuItemPrimaryUIElementAttribute,
        ])

    printAttributeInfo(
        "- application element-specific attributes",
        [
            kAXMenuBarAttribute,
            kAXWindowsAttribute,
            kAXFrontmostAttribute,
            kAXHiddenAttribute,
            kAXMainWindowAttribute,
            kAXFocusedWindowAttribute,
            kAXFocusedUIElementAttribute,
            kAXExtrasMenuBarAttribute,
        ])

    printAttributeInfo(
        "- date/time-specific attributes",
        [
            kAXHourFieldAttribute,
            kAXMinuteFieldAttribute,
            kAXSecondFieldAttribute,
            kAXAMPMFieldAttribute,
            kAXDayFieldAttribute,
            kAXMonthFieldAttribute,
            kAXYearFieldAttribute,
        ])

    printAttributeInfo(
        "- table, outline, or browser-specific attributes",
        [
            kAXRowsAttribute,
            kAXVisibleRowsAttribute,
            kAXSelectedRowsAttribute,
            kAXColumnsAttribute,
            kAXVisibleColumnsAttribute,
            kAXSelectedColumnsAttribute,
            kAXSortDirectionAttribute,
            kAXColumnHeaderUIElementsAttribute,
            kAXIndexAttribute,
            kAXDisclosingAttribute,
            kAXDisclosedRowsAttribute,
            kAXDisclosedByRowAttribute,
        ])

    printAttributeInfo(
        "- matte-specific attributes",
        [
            kAXMatteHoleAttribute,
            kAXMatteContentUIElementAttribute,
        ])

    printAttributeInfo(
        "- ruler-specific attributes",
        [
            kAXMarkerUIElementsAttribute,
            kAXUnitsAttribute,
            kAXUnitDescriptionAttribute,
            kAXMarkerTypeAttribute,
            kAXMarkerTypeDescriptionAttribute,
        ])

    printAttributeInfo(
        "- miscellaneous or role-specific attributes",
        [
            kAXHorizontalScrollBarAttribute,
            kAXVerticalScrollBarAttribute,
            kAXOrientationAttribute,
            kAXHeaderAttribute,
            kAXEditedAttribute,
            kAXTabsAttribute,
            kAXOverflowButtonAttribute,
            kAXFilenameAttribute,
            kAXExpandedAttribute,
            kAXSelectedAttribute,
            kAXSplittersAttribute,
            kAXContentsAttribute,
            kAXNextContentsAttribute,
            kAXPreviousContentsAttribute,
            kAXDocumentAttribute,
            kAXIncrementorAttribute,
            kAXDecrementButtonAttribute,
            kAXIncrementButtonAttribute,
            kAXColumnTitleAttribute,
            kAXURLAttribute,
            kAXLabelUIElementsAttribute,
            kAXLabelValueAttribute,
            kAXShownMenuUIElementAttribute,
            kAXIsApplicationRunningAttribute,
            kAXFocusedApplicationAttribute,
            kAXElementBusyAttribute,
            kAXAlternateUIVisibleAttribute,
        ])
}

struct MenuGetterOptions {
    var maxDepth = 10
    var maxChildren = 20
    var specificMenuRoot: String?
    var dumpInfo = false
    var appFilter = AppFilter()
    var recache = false
    init() {}

    func canIgnorePath(path: [String]) -> Bool {
        if appFilter.ignoreMenuPaths.firstIndex(where: { $0.path == path }) != nil {
            // print("ignoring \(path)")
            return true
        }
        // print("not ignoring \(path)")
        return false
    }
}

actor MenuGetter {
    /// Walks the menu bar *concurrently*, yet safely aggregates into a single array.
    func load(
        menuBar: AXUIElement,
        options: MenuGetterOptions
    ) async -> [MenuItem] {
        // grab the top‐level bar entries
        guard
            let bars = getAttribute(element: menuBar, name: kAXChildrenAttribute)
                as? [AXUIElement], !bars.isEmpty
        else { return [] }

        return await withTaskGroup(of: [MenuItem].self) { group in
            for (i, barItem) in bars.enumerated() {
                // pull out its title
                guard
                    let name = getAttribute(element: barItem, name: kAXTitleAttribute)
                        as? String
                else { continue }
                // skip Apple menu?
                if !options.appFilter.showAppleMenu, name == "Apple" { continue }
                if options.canIgnorePath(path: [name]) { continue }
                if let only = options.specificMenuRoot,
                    name.lowercased() != only.lowercased()
                {
                    continue
                }

                // child must have a submenu
                guard
                    let children = getAttribute(element: barItem, name: kAXChildrenAttribute)
                        as? [AXUIElement], !children.isEmpty
                else { continue }

                // spin off a task per top‐level bar item
                group.addTask {
                    var items = [MenuItem]()
                    getMenuItems(
                        forElement: children[0],
                        menuItems: &items,
                        path: [name],
                        pathIndices: "\(i)",
                        depth: 1,
                        options: options
                    )
                    return items
                }
            }

            // collect them all
            var all = [MenuItem]()
            for await chunk in group {
                all.append(contentsOf: chunk)
            }
            return all
        }
    }
}

//
//  MenuBar.swift
//
//
//  Created by Benzi  on 20/12/2022.
//

import Cocoa
import Foundation

class MenuBar {
  var menuBar: AXUIElement?
  let initState: AXError

  init(for app: NSRunningApplication) {
    let axApp = AXUIElementCreateApplication(app.processIdentifier)
    var menuBarValue: CFTypeRef?
    self.initState = AXUIElementCopyAttributeValue(
      axApp, kAXMenuBarAttribute as CFString, &menuBarValue)
    if self.initState == .success {
      self.menuBar = (menuBarValue as! AXUIElement)
    }
  }

  func click(pathIndices: [Int]) {
    guard let menuBar = self.menuBar else {
      return
    }
    clickMenu(menu: menuBar, pathIndices: pathIndices, currentIndex: 0)
  }

  func load(_ options: MenuGetterOptions) async -> [MenuItem] {
    guard let menuBar = self.menuBar else {
      return []
    }
    return await MenuGetter().load(menuBar: menuBar, options: options)
  }

}

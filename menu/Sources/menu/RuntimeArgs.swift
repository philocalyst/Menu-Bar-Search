//
//  RuntimeArgs.swift
//
//
//  Created by Benzi  on 20/12/2022.
//

import Foundation

class RuntimeArgs {
  var query = ""
  var pid: Int32 = -1
  var reorderAppleMenuToLast = true
  var learning = false
  var clickIndices: [Int]?
  var loadAsync = false
  var cachingEnabled = false
  var cacheTimeout = 0.0

  var options = MenuGetterOptions()
}

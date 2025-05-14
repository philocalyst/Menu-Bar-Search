//
//  TextSearch.swift
//  Menu
//
//  Created by Benzi on 23/04/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import Foundation
@preconcurrency import Fuse

extension String {
  /// A shared Fuse instance to avoid re-allocating on every call.
  private static let fuse = Fuse()

  /// Fuzzy-matches `query` against `self` using fuse-swift.
  /// Returns (matched, score) where score is in 0…8192 (higher = better).
  func fastMatch(_ query: String) -> (matched: Bool, score: Int) {
    guard !query.isEmpty else { return (true, 8192) }
    // Perform the fuzzy search
    if let result = String.fuse.search(query, in: self) {
      // result.score ∈ [0.0 … 1.0], where 0.0 is exact match
      // Map to Int scale: 0.0 → 8192, 1.0 → 0
      let mapped = Int(((1.0 - result.score) * 8192.0).rounded())
      return (true, mapped)
    }
    return (false, 0)
  }
}

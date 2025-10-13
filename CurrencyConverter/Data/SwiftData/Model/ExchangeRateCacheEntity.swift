//
//  ExchangeRateCacheEntity.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import SwiftData

@Model
final class ExchangeRateCacheEntity {
  @Attribute(.unique) var base: String
  var lastUpdatedAt: Date
  var snapshot: Data

  init(base: String, lastUpdatedAt: Date, snapshot: Data) {
    self.base = base
    self.lastUpdatedAt = lastUpdatedAt
    self.snapshot = snapshot
  }
}

//
//  LastViewedScreenEntity.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation
import SwiftData

@Model
final class LastViewedScreenEntity {
  @Attribute(.unique) var key: String
  var screenTypeRawValue: String
  var currencyCode: String?
  var updatedAt: Date

  init(
    key: String = LastViewedScreenEntity.storageKey,
    screenTypeRawValue: String,
    currencyCode: String? = nil,
    updatedAt: Date = Date()
  ) {
    self.key = key
    self.screenTypeRawValue = screenTypeRawValue
    self.currencyCode = currencyCode
    self.updatedAt = updatedAt
  }
}

extension LastViewedScreenEntity {
  static let storageKey = "last_viewed_screen"
}

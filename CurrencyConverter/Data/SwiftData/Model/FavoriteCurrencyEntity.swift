//
//  FavoriteCurrencyEntity.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import SwiftData

@Model
final class FavoriteCurrencyEntity {
  @Attribute(.unique) var code: String
  @Attribute var updatedAt: Date

  init(code: String, updatedAt: Date = Date()) {
    self.code = code
    self.updatedAt = updatedAt
  }
}

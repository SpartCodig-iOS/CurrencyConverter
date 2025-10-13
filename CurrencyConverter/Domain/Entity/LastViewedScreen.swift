//
//  LastViewedScreen.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation

public enum LastViewedScreenType: String, Equatable, Sendable {
  case list
  case calculator
}

public struct LastViewedScreen: Equatable, Sendable {
  public let type: LastViewedScreenType
  public let currencyCode: String?

  public init(type: LastViewedScreenType, currencyCode: String? = nil) {
    self.type = type
    self.currencyCode = currencyCode
  }
}

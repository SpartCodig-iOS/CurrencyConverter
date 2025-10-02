//
//  CurrencyCode.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public struct CurrencyCode: RawRepresentable, Hashable, Sendable, Equatable {
  public let rawValue: String
  public init(
    rawValue: String
  ) {
    self.rawValue = rawValue.uppercased()
  }
}


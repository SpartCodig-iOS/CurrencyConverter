//
//  CurrencyAPI.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public enum ExchangeRateAPI {
  case latest(base: String)

  nonisolated var description: String {
    switch self {
      case .latest(let base):
        return "/latest/\(base)"
    }
  }
}

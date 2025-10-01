//
//  CurrencyRateItem.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

struct CurrencyRateItem: Equatable, Hashable {
  let code: String
  let rate: Double

  init(code: String, rate: Double) {
    self.code = code
    self.rate = rate
  }
}

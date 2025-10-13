//
//  MockExchangeRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

final class MockExchangeRepositoryImpl: ExchangeRateInterface {
  nonisolated public init() {}

  func getExchangeRates(currency: String) async throws -> ExchangeRates? {
    return nil
  }
}

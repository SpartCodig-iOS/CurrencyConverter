//
//  MockExchangeRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

final class MockExchangeRepositoryImpl: ExchangeRateInterface {
  /// Currency-specific results to return from `getExchangeRates`.
  var responses: [String: Result<ExchangeRates?, Error>] = [:]
  /// Fallback result used when a currency-specific response is not provided.
  var defaultResponse: Result<ExchangeRates?, Error> = .success(nil)

  nonisolated public init() {}

  func getExchangeRates(currency: String) async throws -> ExchangeRates? {
    let response = responses[currency] ?? defaultResponse
    switch response {
      case .success(let value):
        return value
      case .failure(let error):
        throw error
    }
  }
}

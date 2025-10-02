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

// MARK: - Sample Data Helpers

extension MockExchangeRepositoryImpl {
  static func sampleRepository(
    base: String = "USD",
    timestamp: Date = Date(timeIntervalSince1970: 1_704_000_000),
    nextUpdateInterval: TimeInterval = 3600,
    rates: [String: Double] = [
      "KRW": 1_350.25,
      "JPY": 148.56,
      "EUR": 0.91
    ]
  ) -> MockExchangeRepositoryImpl {
    MockExchangeRepositoryImpl()
      .preloading(
        currency: base,
        exchangeRates: ExchangeRates.sample(
          base: base,
          rates: rates,
          timestamp: timestamp,
          nextUpdateInterval: nextUpdateInterval
        )
      )
  }

  @discardableResult
  func preloading(
    currency: String,
    exchangeRates: ExchangeRates
  ) -> MockExchangeRepositoryImpl {
    responses[currency] = .success(exchangeRates)
    return self
  }

  @discardableResult
  func preloading(
    currency: String,
    rates: [String: Double],
    timestamp: Date = Date(timeIntervalSince1970: 1_704_000_000),
    nextUpdateInterval: TimeInterval = 3600
  ) -> MockExchangeRepositoryImpl {
    preloading(
      currency: currency,
      exchangeRates: ExchangeRates.sample(
        base: currency,
        rates: rates,
        timestamp: timestamp,
        nextUpdateInterval: nextUpdateInterval
      )
    )
  }
}

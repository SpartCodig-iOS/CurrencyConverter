//
//  ExchangeRates.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public struct ExchangeRates: Sendable, Equatable {
  public let base: CurrencyCode
  public let lastUpdatedAt: Date
  public let nextUpdateAt: Date
  public let provider: URL?
  public let documentation: URL?
  public let termsOfUse: URL?
  public var rates: [CurrencyCode: Double]

  public init(
    base: CurrencyCode,
    lastUpdatedAt: Date,
    nextUpdateAt: Date,
    provider: URL?,
    documentation: URL?,
    termsOfUse: URL?,
    rates: [CurrencyCode: Double]
  ) {
    self.base = base
    self.lastUpdatedAt = lastUpdatedAt
    self.nextUpdateAt = nextUpdateAt
    self.provider = provider
    self.documentation = documentation
    self.termsOfUse = termsOfUse
    self.rates = rates
  }

  /// 금액 변환 유틸(도메인 편의 메서드)
  public func convert(_ amount: Double, to target: CurrencyCode) -> Double? {
    guard let rate = rates[target] else { return nil }
    return amount * rate
  }
}

// MARK: - Mock Data Helpers

public extension ExchangeRates {

  /// Creates a reusable mock instance for testing or previews.
  static func sample(
    base: String = "USD",
    rates: [String: Double] = [
      "KRW": 1_350.25,
      "JPY": 148.56,
      "EUR": 0.91
    ],
    timestamp: Date = Date(timeIntervalSince1970: 1_704_000_000),
    nextUpdateInterval: TimeInterval = 3600,
    provider: URL? = nil,
    documentation: URL? = nil,
    termsOfUse: URL? = nil
  ) -> ExchangeRates {
    ExchangeRates(
      base: CurrencyCode(rawValue: base),
      lastUpdatedAt: timestamp,
      nextUpdateAt: timestamp.addingTimeInterval(nextUpdateInterval),
      provider: provider,
      documentation: documentation,
      termsOfUse: termsOfUse,
      rates: rates.reduce(into: [CurrencyCode: Double]()) { partialResult, entry in
        partialResult[CurrencyCode(rawValue: entry.key)] = entry.value
      }
    )
  }

  /// Returns a copy of the exchange rates replacing the provided properties.
  func updating(
    base: String? = nil,
    rates: [String: Double]? = nil,
    lastUpdatedAt: Date? = nil,
    nextUpdateAt: Date? = nil,
    provider: URL?? = nil,
    documentation: URL?? = nil,
    termsOfUse: URL?? = nil
  ) -> ExchangeRates {
    ExchangeRates(
      base: base.map { CurrencyCode(rawValue: $0) } ?? self.base,
      lastUpdatedAt: lastUpdatedAt ?? self.lastUpdatedAt,
      nextUpdateAt: nextUpdateAt ?? self.nextUpdateAt,
      provider: provider ?? self.provider,
      documentation: documentation ?? self.documentation,
      termsOfUse: termsOfUse ?? self.termsOfUse,
      rates: (rates?.reduce(into: [CurrencyCode: Double]()) { partialResult, entry in
        partialResult[CurrencyCode(rawValue: entry.key)] = entry.value
      }) ?? self.rates
    )
  }
}


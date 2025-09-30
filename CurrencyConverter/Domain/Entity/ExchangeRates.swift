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
  public let rates: [CurrencyCode: Double]

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

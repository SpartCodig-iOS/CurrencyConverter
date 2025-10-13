//
//  ExchangeRateCacheInterface.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

public struct ExchangeRateSnapshot: Equatable, Sendable {
  public let base: String
  public let lastUpdatedAt: Date
  public let rates: [String: Double]

  public init(base: String, lastUpdatedAt: Date, rates: [String: Double]) {
    self.base = base
    self.lastUpdatedAt = lastUpdatedAt
    self.rates = rates
  }
}

public protocol ExchangeRateCacheInterface: Sendable {
  func loadSnapshot() async throws -> ExchangeRateSnapshot?
  func saveSnapshot(_ snapshot: ExchangeRateSnapshot) async throws
  func clearSnapshot() async throws
}

//
//  MockExchangeRateCacheRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

final class MockExchangeRateCacheRepositoryImpl: ExchangeRateCacheInterface {
  private var snapshot: ExchangeRateSnapshot?

  nonisolated public init() {}

  func loadSnapshot() async throws -> ExchangeRateSnapshot? {
    snapshot
  }

  func saveSnapshot(_ snapshot: ExchangeRateSnapshot) async throws {
    self.snapshot = snapshot
  }

  func clearSnapshot() async throws {
    snapshot = nil
  }
}

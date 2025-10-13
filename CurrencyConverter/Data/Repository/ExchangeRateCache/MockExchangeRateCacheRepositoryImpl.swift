//
//  MockExchangeRateCacheRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

final class MockExchangeRateCacheRepositoryImpl: ExchangeRateCacheInterface {
  var snapshot: ExchangeRateSnapshot?

  nonisolated public init(initialSnapshot: ExchangeRateSnapshot? = nil) {
    self.snapshot = initialSnapshot
  }

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

extension MockExchangeRateCacheRepositoryImpl {
  static func sampleSnapshot() -> ExchangeRateCacheSnapshotBuilder {
    ExchangeRateCacheSnapshotBuilder()
  }
}

struct ExchangeRateCacheSnapshotBuilder {
  private var base: String = "USD"
  private var date: Date = Date(timeIntervalSince1970: 1_704_000_000)
  private var rates: [String: Double] = ["JPY": 133.25]

  func with(base: String) -> ExchangeRateCacheSnapshotBuilder {
    var copy = self
    copy.base = base
    return copy
  }

  func with(date: Date) -> ExchangeRateCacheSnapshotBuilder {
    var copy = self
    copy.date = date
    return copy
  }

  func with(rates: [String: Double]) -> ExchangeRateCacheSnapshotBuilder {
    var copy = self
    copy.rates = rates
    return copy
  }

  func makeRepository() -> MockExchangeRateCacheRepositoryImpl {
    let snapshot = ExchangeRateSnapshot(base: base, lastUpdatedAt: date, rates: rates)
    return MockExchangeRateCacheRepositoryImpl(initialSnapshot: snapshot)
  }
}

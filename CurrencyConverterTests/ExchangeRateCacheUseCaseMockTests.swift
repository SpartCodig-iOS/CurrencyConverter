import Foundation
import Testing
@testable import CurrencyConverter

@MainActor
struct ExchangeRateCacheUseCaseMockTests {
  @Test(.tags(.useCase, .cache, .mock))
  func useCasePersistsSnapshotsThroughRepository_스냅샷_유지() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl()
    let useCase = ExchangeRateCacheUseCaseImpl(repository: repository)

    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let snapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: now,
      rates: ["EUR": 0.94]
    )

    try await useCase.saveSnapshot(snapshot)
    let loaded = try await useCase.loadSnapshot()
    #expect(loaded == snapshot)
  }
}

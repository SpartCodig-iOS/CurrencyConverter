import Foundation
import Testing
import WeaveDI
@testable import CurrencyConverter


@MainActor
struct ExchangeRateCacheRepositoryMockTests {

  // MARK: - Basic Mock Repository Tests

  @Test(.tags(.mock, .repository, .cache))
  func saveAndClearSnapshotPersistsInMemory_스냅샷_저장_삭제_메모리_영속성() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl()

    let initial = try await repository.loadSnapshot()
    #expect(initial == nil)

    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let snapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: now,
      rates: ["JPY": 133.25]
    )

    try await repository.saveSnapshot(snapshot)

    let loaded = try await repository.loadSnapshot()
    #expect(loaded == snapshot)

    try await repository.clearSnapshot()
    let cleared = try await repository.loadSnapshot()
    #expect(cleared == nil)
  }

  @Test(.tags(.mock, .repository, .cache))
  func seededSnapshotLoadsImmediately_시드_스냅샷_즉시_로드() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl.sampleSnapshot()
      .with(base: "EUR")
      .with(rates: ["USD": 1.08])
      .makeRepository()

    let snapshot = try await repository.loadSnapshot()
    #expect(snapshot?.base == "EUR")
    #expect(snapshot?.rates == ["USD": 1.08])
  }

  @Test(.tags(.mock, .repository, .cache))
  func mockExchangeRateCacheRepositoryReturnsNilByDefault_기본값_nil_반환() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl()
    let result = try await repository.loadSnapshot()
    #expect(result == nil)
  }

  @Test(.tags(.mock, .repository, .cache))
  func mockExchangeRateCacheRepositoryOverwritesSnapshot_스냅샷_덮어쓰기() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl()

    let firstSnapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: Date(timeIntervalSince1970: 1_704_000_000),
      rates: ["KRW": 1300.0]
    )

    let secondSnapshot = ExchangeRateSnapshot(
      base: "EUR",
      lastUpdatedAt: Date(timeIntervalSince1970: 1_704_003_600),
      rates: ["USD": 1.08, "GBP": 0.86]
    )

    try await repository.saveSnapshot(firstSnapshot)
    let loaded1 = try await repository.loadSnapshot()
    #expect(loaded1 == firstSnapshot)

    try await repository.saveSnapshot(secondSnapshot)
    let loaded2 = try await repository.loadSnapshot()
    #expect(loaded2 == secondSnapshot)
    #expect(loaded2 != firstSnapshot)
  }

  @Test(.tags(.mock, .repository, .cache))
  func mockExchangeRateCacheRepositoryBuilderPattern_빌더패턴_동작() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl.sampleSnapshot()
      .with(base: "KRW")
      .with(date: Date(timeIntervalSince1970: 1_700_000_000))
      .with(rates: ["USD": 0.00075, "JPY": 0.11])
      .makeRepository()

    let snapshot = try await repository.loadSnapshot()
    #expect(snapshot?.base == "KRW")
    #expect(snapshot?.lastUpdatedAt == Date(timeIntervalSince1970: 1_700_000_000))
    #expect(snapshot?.rates == ["USD": 0.00075, "JPY": 0.11])
  }

  // MARK: - @Injected testValue Tests

  @Test(.tags(.mock, .useCase, .cache, .testValue))
  func testInjectedTestValueUsesDefaultMockRepository_testValue_기본_Mock() async throws {
    // testValue를 직접 사용하여 Mock이 제대로 작동하는지 확인
    let testUseCase = ExchangeRateCacheUseCaseImpl.testValue
    let result = try await testUseCase.loadSnapshot()
    #expect(result == nil) // 기본값은 nil
  }

  @Test(.tags(.mock, .useCase, .cache))
  func testInjectedTestValueSaveAndLoadSnapshot_스냅샷_저장_로드() async throws {
    let customMock = MockExchangeRateCacheRepositoryImpl()
    let customUseCase = ExchangeRateCacheUseCaseImpl(repository: customMock)

    let testSnapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: Date(timeIntervalSince1970: 1_704_000_000),
      rates: [
        "KRW": 1350.0,
        "EUR": 0.85,
        "JPY": 150.0
      ]
    )

    try await customUseCase.saveSnapshot(testSnapshot)

    let loadedSnapshot = try await customUseCase.loadSnapshot()
    #expect(loadedSnapshot == testSnapshot)
  }

  @Test(.tags(.mock, .useCase, .cache))
  func testInjectedTestValueClearSnapshot_스냅샷_초기화() async throws {
    let customMock = MockExchangeRateCacheRepositoryImpl()
    let customUseCase = ExchangeRateCacheUseCaseImpl(repository: customMock)

    let testSnapshot = ExchangeRateSnapshot(
      base: "EUR",
      lastUpdatedAt: Date(),
      rates: ["USD": 1.08]
    )

    try await customUseCase.saveSnapshot(testSnapshot)

    let beforeClear = try await customUseCase.loadSnapshot()
    #expect(beforeClear != nil)

    try await customUseCase.clearSnapshot()

    let afterClear = try await customUseCase.loadSnapshot()
    #expect(afterClear == nil)
  }

  @Test(.tags(.mock, .useCase, .cache))
  func testInjectedTestValueWithPreSeededData_시드데이터_적용() async throws {
    let preSeededSnapshot = ExchangeRateSnapshot(
      base: "GBP",
      lastUpdatedAt: Date(timeIntervalSince1970: 1_703_000_000),
      rates: ["USD": 1.26, "EUR": 1.15]
    )

    let customMock = MockExchangeRateCacheRepositoryImpl(initialSnapshot: preSeededSnapshot)
    let customUseCase = ExchangeRateCacheUseCaseImpl(repository: customMock)

    let loadedSnapshot = try await customUseCase.loadSnapshot()
    #expect(loadedSnapshot == preSeededSnapshot)

    // 새로운 스냅샷으로 업데이트
    let newSnapshot = ExchangeRateSnapshot(
      base: "JPY",
      lastUpdatedAt: Date(),
      rates: ["USD": 0.0067]
    )

    try await customUseCase.saveSnapshot(newSnapshot)

    let updatedSnapshot = try await customUseCase.loadSnapshot()
    #expect(updatedSnapshot == newSnapshot)
    #expect(updatedSnapshot != preSeededSnapshot)
  }

  @Test(.tags(.mock, .useCase, .cache))
  func testInjectedTestValueBuilderPatternWithUseCase_빌더패턴_적용() async throws {
    let repository = MockExchangeRateCacheRepositoryImpl.sampleSnapshot()
      .with(base: "CAD")
      .with(date: Date(timeIntervalSince1970: 1_705_000_000))
      .with(rates: ["USD": 0.74, "EUR": 0.68])
      .makeRepository()

    let customUseCase = ExchangeRateCacheUseCaseImpl(repository: repository)

    let snapshot = try await customUseCase.loadSnapshot()
    #expect(snapshot?.base == "CAD")
    #expect(snapshot?.rates["USD"] == 0.74)
    #expect(snapshot?.rates["EUR"] == 0.68)
  }
}

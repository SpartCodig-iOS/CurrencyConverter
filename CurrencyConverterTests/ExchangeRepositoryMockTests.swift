import Foundation
import Testing
import ComposableArchitecture
import WeaveDI
@testable import CurrencyConverter

@MainActor
struct ExchangeRepositoryMockTests {

  // MARK: - Basic Mock Repository Tests

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryReturnsNilByDefault_기본값_nil_반환() async throws {
    let repository = MockExchangeRepositoryImpl()
    let result = try await repository.getExchangeRates(currency: "USD")
    #expect(result == nil)
  }

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryReturnsConfiguredResponse_설정된_응답_반환() async throws {
    let repository = MockExchangeRepositoryImpl()
    let expectedRates = ExchangeRates.sample(
      base: "USD",
      rates: [
        "KRW": 1_300.0,
        "JPY": 150.0
      ],
      timestamp: Date(timeIntervalSince1970: 1_704_000_100)
    )

    repository.preloading(currency: "USD", exchangeRates: expectedRates)

    let result = try await repository.getExchangeRates(currency: "USD")
    #expect(result == expectedRates)
  }

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryThrowsConfiguredError_설정된_오류_던지기() async throws {
    let repository = MockExchangeRepositoryImpl()
    let expectedError = DomainError.networkUnavailable

    repository.responses["USD"] = .failure(expectedError)

    await #expect(throws: DomainError.self) {
      try await repository.getExchangeRates(currency: "USD")
    }
  }

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryReturnsDefaultForUnknownCurrency_알수없는_통화_기본값_반환() async throws {
    let repository = MockExchangeRepositoryImpl()
    let result = try await repository.getExchangeRates(currency: "UNKNOWN")
    #expect(result == nil)
  }

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryHandlesMultipleCurrencies_여러_통화_처리() async throws {
    let repository = MockExchangeRepositoryImpl()

    let usdRates = ExchangeRates.sample(
      base: "USD",
      rates: ["KRW": 1_300.0]
    )

    let eurRates = ExchangeRates.sample(
      base: "EUR",
      rates: ["USD": 1.1]
    )

    repository
      .preloading(currency: "USD", exchangeRates: usdRates)
      .preloading(currency: "EUR", exchangeRates: eurRates)

    let usdResult = try await repository.getExchangeRates(currency: "USD")
    let eurResult = try await repository.getExchangeRates(currency: "EUR")

    #expect(usdResult == usdRates)
    #expect(eurResult == eurRates)
  }

  @Test(.tags(.mock, .repository))
  func mockExchangeRepositoryProvidesSampleData_샘플데이터_제공() async throws {
    let repository = MockExchangeRepositoryImpl.sampleRepository(
      base: "USD",
      rates: [
        "KRW": 1_321.11,
        "JPY": 149.32
      ]
    )

    let result = try await repository.getExchangeRates(currency: "USD")

    #expect(result != nil)
    #expect(result?.base == CurrencyCode(rawValue: "USD"))
    #expect(result?.rates[CurrencyCode(rawValue: "KRW")] == 1_321.11)
    #expect(result?.rates[CurrencyCode(rawValue: "JPY")] == 149.32)
  }

  @Test(.tags(.mock, .repository))
  func exchangeRatesSampleUtilityGeneratesMockData_샘플유틸_생성() throws {
    let timestamp = Date(timeIntervalSince1970: 1_704_100_000)
    let snapshot = ExchangeRates.sample(
      base: "EUR",
      rates: [
        "USD": 1.08,
        "KRW": 1_430.5
      ],
      timestamp: timestamp,
      nextUpdateInterval: 7200
    )

    #expect(snapshot.base == CurrencyCode(rawValue: "EUR"))
    #expect(snapshot.lastUpdatedAt == timestamp)
    #expect(snapshot.nextUpdateAt == timestamp.addingTimeInterval(7200))
    #expect(snapshot.rates[CurrencyCode(rawValue: "USD")] == 1.08)
    #expect(snapshot.rates[CurrencyCode(rawValue: "KRW")] == 1_430.5)
  }

  // MARK: - UseCase with Mock Repository Tests

  @Test(.tags(.useCase, .mock))
  func testUseCaseWithDefaultMockRepository_기본_Mock_UseCase_테스트() async throws {
    // 직접 Mock Repository를 주입한 UseCase 생성
    let mockRepository = MockExchangeRepositoryImpl()
    let useCase = ExchangeUseCaseImpl(repository: mockRepository)

    let result = try await useCase.getExchangeRates(currency: "USD")
    #expect(result == nil) // 기본값은 nil
  }

  @Test(.tags(.useCase, .mock))
  func testUseCaseWithCustomMockConfiguration_커스텀_Mock_설정_테스트() async throws {
    // 커스텀 Mock Repository 설정
    let customMock = MockExchangeRepositoryImpl()
    let testRates = ExchangeRates.sample(
      base: "USD",
      rates: [
        "KRW": 1_350.0,
        "EUR": 0.85
      ]
    )
    customMock.preloading(currency: "USD", exchangeRates: testRates)

    let customUseCase = ExchangeUseCaseImpl(repository: customMock)

    let result = try await customUseCase.getExchangeRates(currency: "USD")
    #expect(result == testRates)
  }

  @Test(.tags(.useCase, .mock))
  func testUseCaseWithMockErrorHandling_Mock_오류_처리_테스트() async throws {
    let customMock = MockExchangeRepositoryImpl()
    customMock.responses["USD"] = .failure(DomainError.unknown)

    let customUseCase = ExchangeUseCaseImpl(repository: customMock)

    await #expect(throws: DomainError.self) {
      try await customUseCase.getExchangeRates(currency: "USD")
    }
  }

  @Test(.tags(.testValue, .mock))
  func testValueFromExchangeUseCaseImplGivesCorrectMock_testValue에서_올바른_Mock_반환() async throws {
    // testValue가 실제로 Mock을 반환하는지 확인
    let testUseCase = ExchangeUseCaseImpl.testValue

    let result = try await testUseCase.getExchangeRates(currency: "USD")
    #expect(result == nil) // Mock의 기본값은 nil
  }

  // MARK: - @Injected testValue Tests

  @Test(.tags(.testValue, .mock))
  func testInjectedTestValueDirectUsage_testValue_직접_사용_테스트() async throws {
    // testValue를 직접 사용하여 Mock이 제대로 작동하는지 확인
    let testUseCase = ExchangeUseCaseImpl.testValue

    let result = try await testUseCase.getExchangeRates(currency: "USD")
    #expect(result == nil) // Mock의 기본값은 nil
  }
}

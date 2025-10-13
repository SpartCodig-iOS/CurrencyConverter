import Foundation
import Testing
@testable import CurrencyConverter

struct ExchangeUseCaseMockTests {
  @Test(.tags(.useCase, .mock, .repository))
  func useCaseReturnsDataProvidedByRepository_리포지토리_데이터_반환() async throws {
    let base = await CurrencyCode(rawValue: "USD")
    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let exchangeRates = await ExchangeRates(
      base: base,
      lastUpdatedAt: now,
      nextUpdateAt: now.addingTimeInterval(3600),
      provider: nil,
      documentation: nil,
      termsOfUse: nil,
      rates: [CurrencyCode(rawValue: "JPY"): 133.25]
    )

    let repository = StubExchangeRepository(result: exchangeRates)
    let useCase = ExchangeUseCaseImpl(repository: repository)

    let response = try await useCase.getExchangeRates(currency: "USD")
    #expect(response == exchangeRates)
  }
}

private struct StubExchangeRepository: ExchangeRateInterface {
  let result: ExchangeRates?

  func getExchangeRates(currency: String) async throws -> ExchangeRates? {
    result
  }
}

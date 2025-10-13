import Foundation
import Testing
@testable import CurrencyConverter

@MainActor
struct LastViewedScreenUseCaseMockTests {
  @Test(.tags(.useCase, .mock, .repository))
  func useCasePersistsLastScreenThroughRepository_마지막화면_유지() async throws {
    let repository = MockLastViewedScreenRepositoryImpl()
    let useCase = LastViewedScreenUseCaseImpl(repository: repository)

    let screen = LastViewedScreen(type: .list, currencyCode: "KRW")
    try await useCase.updateLastViewedScreen(screen)

    let loaded = try await useCase.loadLastViewedScreen()
    #expect(loaded == screen)
  }
}

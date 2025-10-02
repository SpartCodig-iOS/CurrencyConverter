import Foundation
import Testing
@testable import CurrencyConverter

@MainActor
struct FavoriteCurrencyUseCaseMockTests {
  @Test(.tags(.useCase, .mock, .favoriteCurrency))
  func useCaseProxiesFavoriteChanges_즐겨찾기_변경_위임() async throws {
    let repository = MockFavoriteCurrencyRepositoryImpl()
    let useCase = FavoriteCurrencyUseCaseImpl(repository: repository)

    let favorites = try await useCase.toggleFavorite(currencyCode: "EUR")
    #expect(favorites == ["EUR"])

    let cleared = try await useCase.toggleFavorite(currencyCode: "EUR")
    #expect(cleared.isEmpty)
  }
}

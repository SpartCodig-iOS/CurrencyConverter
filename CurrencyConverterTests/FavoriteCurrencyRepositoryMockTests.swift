import Foundation
import Testing
import ComposableArchitecture
import WeaveDI
@testable import CurrencyConverter

// MARK: - Test Tags

@MainActor
struct FavoriteCurrencyRepositoryMockTests {

  // MARK: - Basic Mock Repository Tests

  @Test(.tags(.mock, .repository, .favoriteCurrency))
  func toggleFavoriteInsertsAndRemovesCode_즐겨찾기_토글_추가_제거() async throws {
    let repository = MockFavoriteCurrencyRepositoryImpl()

    let initial = try await repository.fetchFavorites()
    #expect(initial.isEmpty)

    let afterInsert = try await repository.toggleFavorite(currencyCode: "USD")
    #expect(afterInsert == ["USD"])

    let afterRemoval = try await repository.toggleFavorite(currencyCode: "USD")
    #expect(afterRemoval.isEmpty)
  }

  @Test(.tags(.mock, .repository, .favoriteCurrency))
  func seededFavoritesAreReturned_시드_즐겨찾기_반환() async throws {
    let repository = MockFavoriteCurrencyRepositoryImpl(initial: ["USD", "KRW"])
    let favorites = try await repository.fetchFavorites()
    #expect(favorites == ["KRW", "USD"])
  }

  @Test(.tags(.mock, .repository, .favoriteCurrency))
  func mockFavoriteCurrencyRepositoryToggleMultipleCurrencies_여러_통화_토글() async throws {
    let repository = MockFavoriteCurrencyRepositoryImpl()

    // 여러 통화 추가
    _ = try await repository.toggleFavorite(currencyCode: "USD")
    _ = try await repository.toggleFavorite(currencyCode: "EUR")
    _ = try await repository.toggleFavorite(currencyCode: "KRW")

    let result = try await repository.fetchFavorites()
    #expect(Set(result) == ["USD", "EUR", "KRW"])

    // 하나 제거
    let afterRemoval = try await repository.toggleFavorite(currencyCode: "EUR")
    #expect(Set(afterRemoval) == ["USD", "KRW"])
  }

  @Test(.tags(.mock, .repository, .favoriteCurrency))
  func mockFavoriteCurrencyRepositorySampleFavorites_샘플_즐겨찾기_테스트() async throws {
    let repository = MockFavoriteCurrencyRepositoryImpl.sampleFavorites()

    let result = try await repository.fetchFavorites()
    #expect(Set(result) == ["USD", "KRW"])
  }

  // MARK: - UseCase with Mock Repository Tests

  @Test(.tags(.useCase, .mock, .favoriteCurrency))
  func testUseCaseWithDefaultMockRepository_기본_Mock_UseCase_테스트() async throws {
    // 직접 Mock Repository를 주입한 UseCase 생성
    let mockRepository = MockFavoriteCurrencyRepositoryImpl()
    let useCase = FavoriteCurrencyUseCaseImpl(repository: mockRepository)

    let result = try await useCase.fetchFavorites()
    #expect(result.isEmpty) // 기본값은 빈 배열
  }

  @Test(.tags(.useCase, .mock, .favoriteCurrency))
  func testUseCaseWithCustomConfiguration_커스텀_설정_UseCase_테스트() async throws {
    // 커스텀 Mock Repository 설정
    let customMock = MockFavoriteCurrencyRepositoryImpl(initial: ["EUR", "JPY", "GBP"])
    let customUseCase = FavoriteCurrencyUseCaseImpl(repository: customMock)

    let result = try await customUseCase.fetchFavorites()
    #expect(Set(result) == ["EUR", "JPY", "GBP"])
  }

  @Test(.tags(.useCase, .mock, .favoriteCurrency))
  func testUseCaseToggleFunctionality_UseCase_토글_기능_테스트() async throws {
    let customMock = MockFavoriteCurrencyRepositoryImpl(initial: ["USD"])
    let customUseCase = FavoriteCurrencyUseCaseImpl(repository: customMock)

    // 기존 즐겨찾기 제거
    let afterRemoval = try await customUseCase.toggleFavorite(currencyCode: "USD")
    #expect(afterRemoval.isEmpty)

    // 새로운 즐겨찾기 추가
    let afterAddition = try await customUseCase.toggleFavorite(currencyCode: "KRW")
    #expect(afterAddition == ["KRW"])
  }

  @Test(.tags(.useCase, .mock, .favoriteCurrency))
  func testUseCasePersistenceAcrossOperations_UseCase_영속성_테스트() async throws {
    let customMock = MockFavoriteCurrencyRepositoryImpl()
    let customUseCase = FavoriteCurrencyUseCaseImpl(repository: customMock)

    // 순차적으로 즐겨찾기 조작
    _ = try await customUseCase.toggleFavorite(currencyCode: "USD")
    _ = try await customUseCase.toggleFavorite(currencyCode: "EUR")

    let currentFavorites = try await customUseCase.fetchFavorites()
    #expect(Set(currentFavorites) == ["USD", "EUR"])

    _ = try await customUseCase.toggleFavorite(currencyCode: "USD") // USD 제거

    let finalFavorites = try await customUseCase.fetchFavorites()
    #expect(finalFavorites == ["EUR"])
  }

  @Test(.tags(.testValue, .mock, .favoriteCurrency))
  func testValueFromFavoriteCurrencyUseCaseImplGivesCorrectMock_testValue에서_올바른_Mock_반환() async throws {
    // testValue가 실제로 Mock을 반환하는지 확인
    let testUseCase = FavoriteCurrencyUseCaseImpl.testValue

    let result = try await testUseCase.fetchFavorites()
    #expect(result.isEmpty) // Mock의 기본값은 빈 배열
  }

  // MARK: - @Injected testValue Tests

  @Test(.tags(.testValue, .mock, .favoriteCurrency))
  func testInjectedTestValueDirectUsage_testValue_직접_사용_테스트() async throws {
    // testValue를 직접 사용하여 Mock이 제대로 작동하는지 확인
    let testUseCase = FavoriteCurrencyUseCaseImpl.testValue

    let result = try await testUseCase.fetchFavorites()
    #expect(result.isEmpty) // Mock의 기본값은 빈 배열
  }
}

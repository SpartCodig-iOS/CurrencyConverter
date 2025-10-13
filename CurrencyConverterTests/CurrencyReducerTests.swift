import Foundation
import Testing
import ComposableArchitecture
@testable import CurrencyConverter

@MainActor
struct CurrencyReducerTests {

  @Test(.tags(.currencyReducer, .testValue))
  func onAppearTriggersInitialFetches_onAppear_초기요청() async throws {
    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )

    let store = TestStore(initialState: CurrencyReducer.State()) {
      reducer
    }

    await store.send(.view(.onAppear))
    await store.receive(.async(.loadCachedSnapshot))
    await store.receive(.async(.fetchExchangeRates))
    await store.receive(.async(.fetchFavorites))
    await store.receive(.inner(.onCachedSnapshotLoaded(nil)))
    await store.receive(.inner(.updateDisplayedRates))
    await store.receive(.inner(.onFavoritesUpdated(Set<String>())))
    await store.receive(.inner(.updateDisplayedRates))
    await store.finish()
  }

  @Test(.tags(.currencyReducer, .testValue))
  func setPendingRestorationStoresScreen_복원대기값_저장() async throws {
    let screen = LastViewedScreen(type: .calculator, currencyCode: "JPY")
    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )
    let store = TestStore(initialState: CurrencyReducer.State()) {
      reducer
    }

    await store.send(.inner(.setPendingRestoration(screen))) {
      $0.pendingRestoration = screen
    }
  }

  @Test(.tags(.currencyReducer, .testValue))
  func searchTextChangedFiltersRatesAndUpdatesDisplay_검색필터_적용() async throws {
    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )

    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let exchangeRates = ExchangeRates(
      base: CurrencyCode(rawValue: "USD"),
      lastUpdatedAt: now,
      nextUpdateAt: now.addingTimeInterval(3600),
      provider: nil,
      documentation: nil,
      termsOfUse: nil,
      rates: [
        CurrencyCode(rawValue: "JPY"): 133.25,
        CurrencyCode(rawValue: "KRW"): 1300.12
      ]
    )

    var initialState = CurrencyReducer.State()
    initialState.exchangeRateModel = exchangeRates
    initialState.filteredRates = [
      "JPY": 133.25,
      "KRW": 1300.12
    ]
    initialState.rateTrends = [
      "JPY": .none,
      "KRW": .none
    ]

    let store = TestStore(initialState: initialState) {
      reducer
    }

    await store.send(.view(.searchTextChanged("jpy"))) {
      $0.searchText = "jpy"
      $0.currentPage = 1
      $0.filteredRates = ["JPY": 133.25]
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [
        CurrencyRateItem(code: "JPY", rate: 133.25, trend: .none)
      ]
    }
    await store.finish()
  }

  @Test(.tags(.currencyReducer, .testValue))
  func restorationNavigatesWhenRatesArrive_복원시_네비게이션() async throws {
    let restoration = LastViewedScreen(type: .calculator, currencyCode: "JPY")
    var state = CurrencyReducer.State()
    state.pendingRestoration = restoration

    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )

    let store = TestStore(initialState: state) {
      reducer
    }

    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let base = CurrencyCode(rawValue: "USD")
    let rates: [CurrencyCode: Double] = [CurrencyCode(rawValue: "JPY"): 133.25]
    let exchangeRates = ExchangeRates(
      base: base,
      lastUpdatedAt: now,
      nextUpdateAt: now.addingTimeInterval(3600),
      provider: nil,
      documentation: nil,
      termsOfUse: nil,
      rates: rates
    )

    await store.send(.inner(.onFetchExchangeRatesResponse(.success(exchangeRates)))) {
      $0.exchangeRateModel = exchangeRates
      $0.baseCurrencyCode = base.rawValue
      $0.filteredRates = ["JPY": 133.25]
      $0.rateTrends = ["JPY": .none]
      $0.previousRates = ["JPY": 133.25]
      $0.lastCachedAt = now
      $0.pendingRestoration = nil
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [
        CurrencyRateItem(code: "JPY", rate: 133.25, trend: .none)
      ]
    }

    let snapshot = ExchangeRateSnapshot(
      base: base.rawValue,
      lastUpdatedAt: now,
      rates: ["JPY": 133.25]
    )
    await store.receive(.async(.saveSnapshot(snapshot)))
    await store.receive(.navigation(.navigateToCalculator(currencyCode: "JPY", currencyRate: 133.25)))
  }

  @Test(.tags(.currencyReducer, .mock, .repository, .cache))
  func fetchExchangeRatesSuccessUpdatesStateAndCachesSnapshot_환율성공_상태업데이트() async throws {
    let now = Date(timeIntervalSince1970: 1_704_000_000)
    let rates: [CurrencyCode: Double] = [CurrencyCode(rawValue: "JPY"): 133.25]
    let exchangeRates = ExchangeRates(
      base: CurrencyCode(rawValue: "USD"),
      lastUpdatedAt: now,
      nextUpdateAt: now.addingTimeInterval(3600),
      provider: nil,
      documentation: nil,
      termsOfUse: nil,
      rates: rates
    )

    let exchangeRepository = MockExchangeRepositoryImpl()
    let favoriteRepository = MockFavoriteCurrencyRepositoryImpl()
    let cacheRepository = MockExchangeRateCacheRepositoryImpl()

    exchangeRepository.responses["USD"] = .success(exchangeRates)

    let store = TestStore(initialState: CurrencyReducer.State()) {
      CurrencyReducer(
        exchangeUseCase: ExchangeUseCaseImpl(repository: exchangeRepository),
        favoriteUseCase: FavoriteCurrencyUseCaseImpl(repository: favoriteRepository),
        cacheUseCase: ExchangeRateCacheUseCaseImpl(repository: cacheRepository)
      )
    }

    await store.send(.async(.fetchExchangeRates))

    await store.receive(.inner(.onFetchExchangeRatesResponse(.success(exchangeRates)))) {
      $0.exchangeRateModel = exchangeRates
      $0.baseCurrencyCode = "USD"
      $0.filteredRates = ["JPY": 133.25]
      $0.rateTrends = ["JPY": .none]
      $0.previousRates = ["JPY": 133.25]
      $0.lastCachedAt = now
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [
        CurrencyRateItem(code: "JPY", rate: 133.25, trend: .none)
      ]
    }

    let snapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: now,
      rates: ["JPY": 133.25]
    )
    await store.receive(.async(.saveSnapshot(snapshot)))
    await store.finish()

    #expect(cacheRepository.snapshot == snapshot)
  }

  @Test(.tags(.currencyReducer, .testValue))
  func loadMoreDataAppendsNextPage_더보기_다음페이지() async throws {
    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )

    var initialState = CurrencyReducer.State()
    initialState.filteredRates = [
      "AUD": 1.1,
      "CAD": 1.3,
      "EUR": 0.92
    ]
    initialState.rateTrends = [
      "AUD": .none,
      "CAD": .none,
      "EUR": .none
    ]
    initialState.displayedRates = [
      CurrencyRateItem(code: "AUD", rate: 1.1, trend: .none),
      CurrencyRateItem(code: "CAD", rate: 1.3, trend: .none)
    ]
    initialState.itemsPerPage = 2
    initialState.currentPage = 1

    let store = TestStore(initialState: initialState) {
      reducer
    }

    await store.send(.view(.loadMoreData)) {
      $0.isLoadingMore = true
    }

    try await Task.sleep(for: .milliseconds(600))

    await store.receive(.inner(.loadMoreCompleted(2))) {
      $0.currentPage = 2
      $0.isLoadingMore = false
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [
        CurrencyRateItem(code: "AUD", rate: 1.1, trend: .none),
        CurrencyRateItem(code: "CAD", rate: 1.3, trend: .none),
        CurrencyRateItem(code: "EUR", rate: 0.92, trend: .none)
      ]
    }
    await store.finish()
  }

  @Test(.tags(.currencyReducer, .mock, .repository))
  func fetchExchangeRatesFailureClearsStateAndShowsAlert_환율실패_상태초기화() async throws {
    enum StubError: Error { case failure }

    let exchangeRepository = MockExchangeRepositoryImpl()
    exchangeRepository.defaultResponse = .failure(StubError.failure)
    let favoriteRepository = MockFavoriteCurrencyRepositoryImpl()
    let cacheRepository = MockExchangeRateCacheRepositoryImpl()

    let store = TestStore(initialState: CurrencyReducer.State()) {
      CurrencyReducer(
        exchangeUseCase: ExchangeUseCaseImpl(repository: exchangeRepository),
        favoriteUseCase: FavoriteCurrencyUseCaseImpl(repository: favoriteRepository),
        cacheUseCase: ExchangeRateCacheUseCaseImpl(repository: cacheRepository)
      )
    }

    await store.send(.async(.fetchExchangeRates))

    await store.receive(.inner(.onFetchExchangeRatesResponse(.failure(.notFound)))) {
      $0.exchangeRateModel = nil
      $0.baseCurrencyCode = ""
      $0.filteredRates = [:]
      $0.displayedRates = []
      $0.rateTrends = [:]
      $0.previousRates = [:]
      $0.lastCachedAt = nil
      $0.alertMessage = "데이터를 불러올 수 없습니다 요청한 데이터를 찾을 수 없습니다."
    }

    #expect(store.state.alertMessage?.contains("데이터를 불러올 수 없습니다") == true)

    await store.receive(.inner(.updateDisplayedRates))
    await store.finish()
  }

  @Test(.tags(.currencyReducer, .mock, .repository, .favoriteCurrency))
  func toggleFavoriteUpdatesFavoriteSet_즐겨찾기토글_갱신() async throws {
    let exchangeRepository = MockExchangeRepositoryImpl()
    let favoriteRepository = MockFavoriteCurrencyRepositoryImpl()
    let cacheRepository = MockExchangeRateCacheRepositoryImpl()
    favoriteRepository.storage = []

    var initialState = CurrencyReducer.State()
    initialState.filteredRates = ["USD": 1.0]

    let store = TestStore(initialState: initialState) {
      CurrencyReducer(
        exchangeUseCase: ExchangeUseCaseImpl(repository: exchangeRepository),
        favoriteUseCase: FavoriteCurrencyUseCaseImpl(repository: favoriteRepository),
        cacheUseCase: ExchangeRateCacheUseCaseImpl(repository: cacheRepository)
      )
    }

    await store.send(.async(.toggleFavorite("USD")))

    await store.receive(.inner(.onFavoritesUpdated(Set(["USD"])))) {
      $0.favoriteCodes = ["USD"]
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [
        CurrencyRateItem(code: "USD", rate: 1.0, trend: .none)
      ]
    }
    await store.finish()

    let favorites = try await favoriteRepository.fetchFavorites()
    #expect(favorites == ["USD"])
  }

  @Test(.tags(.currencyReducer, .mock, .repository, .cache))
  func loadCachedSnapshotPrefillsState_캐시스냅샷_미리채움() async throws {
    let exchangeRepository = MockExchangeRepositoryImpl()
    let favoriteRepository = MockFavoriteCurrencyRepositoryImpl()
    let cacheRepository = MockExchangeRateCacheRepositoryImpl()
    let now = Date(timeIntervalSince1970: 1_704_000_000)
    cacheRepository.snapshot = ExchangeRateSnapshot(
      base: "USD",
      lastUpdatedAt: now,
      rates: ["EUR": 0.93]
    )

    let store = TestStore(initialState: CurrencyReducer.State()) {
      CurrencyReducer(
        exchangeUseCase: ExchangeUseCaseImpl(repository: exchangeRepository),
        favoriteUseCase: FavoriteCurrencyUseCaseImpl(repository: favoriteRepository),
        cacheUseCase: ExchangeRateCacheUseCaseImpl(repository: cacheRepository)
      )
    }

    await store.send(.async(.loadCachedSnapshot))

    await store.receive(.inner(.onCachedSnapshotLoaded(cacheRepository.snapshot))) {
      $0.previousRates = ["EUR": 0.93]
      $0.lastCachedAt = now
      $0.filteredRates = ["EUR": 0.93]
      $0.baseCurrencyCode = "USD"
      $0.rateTrends = ["EUR": .none]
    }

    await store.receive(.inner(.updateDisplayedRates)) {
      $0.displayedRates = [CurrencyRateItem(code: "EUR", rate: 0.93, trend: .none)]
    }

    await store.finish()
  }
}

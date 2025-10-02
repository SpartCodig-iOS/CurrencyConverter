import Foundation
import Testing
import ComposableArchitecture
@testable import CurrencyConverter

@MainActor
struct RootReducerTests {

  @MainActor
  private func makeCurrencyReducerSystem() -> (
    reducer: CurrencyReducer,
    exchangeRepository: MockExchangeRepositoryImpl,
    favoriteRepository: MockFavoriteCurrencyRepositoryImpl,
    cacheRepository: MockExchangeRateCacheRepositoryImpl
  ) {
    let exchangeRepository = MockExchangeRepositoryImpl()
    let favoriteRepository = MockFavoriteCurrencyRepositoryImpl()
    let cacheRepository = MockExchangeRateCacheRepositoryImpl()

    let reducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl(repository: exchangeRepository),
      favoriteUseCase: FavoriteCurrencyUseCaseImpl(repository: favoriteRepository),
      cacheUseCase: ExchangeRateCacheUseCaseImpl(repository: cacheRepository)
    )

    return (reducer, exchangeRepository, favoriteRepository, cacheRepository)
  }

  @Test(.tags(.currencyReducer))
  func onAppearPersistsListScreen_온어피어_리스트저장() async throws {
    let lastViewedRepository = MockLastViewedScreenRepositoryImpl()
    let lastViewedUseCase = LastViewedScreenUseCaseImpl(repository: lastViewedRepository)
    let (currencyReducer, _, _, _) = makeCurrencyReducerSystem()

    let store = TestStore(
      initialState: RootReducer.State(currency: CurrencyReducer.State())
    ) {
      RootReducer(
        currencyReducer: currencyReducer,
        lastViewedUseCase: lastViewedUseCase
      )
    }

    // 비동기 액션들로 인한 복잡성을 피하기 위해 exhaustivity 끄기
    store.exhaustivity = .off

    await store.send(RootReducer.Action.currency(CurrencyReducer.Action.view(.onAppear)))

    // 액션들이 처리될 시간을 주기
    await store.skipReceivedActions()
    await store.finish()

    #expect(lastViewedRepository.storage == LastViewedScreen(type: .list))
  }

  @Test(.tags(.currencyReducer, .calculatorReducer))
  func navigationPersistsCalculatorScreen_네비게이션_계산기저장() async throws {
    let lastViewedRepository = MockLastViewedScreenRepositoryImpl()
    let lastViewedUseCase = LastViewedScreenUseCaseImpl(repository: lastViewedRepository)
    let currencyReducer = CurrencyReducer(
      exchangeUseCase: ExchangeUseCaseImpl.testValue,
      favoriteUseCase: FavoriteCurrencyUseCaseImpl.testValue,
      cacheUseCase: ExchangeRateCacheUseCaseImpl.testValue
    )

    let store = TestStore(
      initialState: RootReducer.State(currency: CurrencyReducer.State())
    ) {
      RootReducer(
        currencyReducer: currencyReducer,
        lastViewedUseCase: lastViewedUseCase
      )
    }

    // 비동기 액션들로 인한 복잡성을 피하기 위해 exhaustivity 끄기
    store.exhaustivity = .off

    await store.send(
      RootReducer.Action.currency(
        CurrencyReducer.Action.navigation(.navigateToCalculator(currencyCode: "JPY", currencyRate: 133.25))
      )
    ) {
      $0.path.append(
        RootReducer.Path.State.calculator(
          CalculatorReducer.State(
            currencyCode: "JPY",
            exchangeRate: 133.25,
            baseCurrencyCode: "USD"
          )
        )
      )
    }

    await store.finish()

    #expect(
      lastViewedRepository.storage == LastViewedScreen(type: .calculator, currencyCode: "JPY")
    )
  }
}

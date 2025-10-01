//
//  CurrencyReducer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation
import ComposableArchitecture
import WeaveDI

@MainActor
@Reducer
public struct CurrencyReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {

    var exchangeRateModel: ExchangeRates?  = nil
    var baseCurrencyCode: String = ""
    var filteredRates: [String: Double] = [:]
    var displayedRates: [CurrencyRateItem] = []
    var alertMessage: String? = nil
    var searchText: String = ""
    var currentPage: Int = 1
    var itemsPerPage: Int = 20
    var isLoadingMore: Bool = false
    var favoriteCodes: Set<String> = []
    var rateTrends: [String: RateTrend] = [:]
    var previousRates: [String: Double] = [:]
    var lastCachedAt: Date? = nil

    public init() {

    }

    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.exchangeRateModel == rhs.exchangeRateModel &&
      lhs.baseCurrencyCode == rhs.baseCurrencyCode &&
      lhs.filteredRates == rhs.filteredRates &&
      lhs.displayedRates == rhs.displayedRates &&
      lhs.alertMessage == rhs.alertMessage &&
      lhs.searchText == rhs.searchText &&
      lhs.currentPage == rhs.currentPage &&
      lhs.itemsPerPage == rhs.itemsPerPage &&
      lhs.isLoadingMore == rhs.isLoadingMore &&
      lhs.favoriteCodes == rhs.favoriteCodes &&
      lhs.rateTrends == rhs.rateTrends &&
      lhs.previousRates == rhs.previousRates &&
      lhs.lastCachedAt == rhs.lastCachedAt
    }
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }

  //MARK: - ViewAction
  
  public enum View {
    case onAppear
    case clearAlert
    case searchTextChanged(String)
    case loadMoreData
    case favoriteTapped(String)
  }


  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchExchangeRates
    case searchCurrency(String)
    case fetchFavorites
    case toggleFavorite(String)
    case loadCachedSnapshot
    case saveSnapshot(ExchangeRateSnapshot)

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case onFetchExchangeRatesResponse(Result<ExchangeRates, DomainError>)
    case loadMoreCompleted(Int)
    case updateDisplayedRates
    case onFavoritesUpdated(Set<String>)
    case favoriteOperationFailed(DomainError)
    case onCachedSnapshotLoaded(ExchangeRateSnapshot?)
    case cacheOperationFailed(DomainError)
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case navigateToCalculator(currencyCode: String, currencyRate: Double)
  }

  @Injected(ExchangeUseCaseImpl.self) var exchangeUseCase
  @Injected(FavoriteCurrencyUseCaseImpl.self) var favoriteUseCase
  @Injected(ExchangeRateCacheUseCaseImpl.self) var cacheUseCase

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .binding(_):
          return .none

        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .async(let asyncAction):
          return handleAsyncAction(state: &state, action: asyncAction)

        case .inner(let innerAction):
          return handleInnerAction(state: &state, action: innerAction)

        case .navigation(let navigationAction):
          return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .concatenate(
          .send(.async(.loadCachedSnapshot)),
          .merge(
            .send(.async(.fetchExchangeRates)),
            .send(.async(.fetchFavorites))
          )
        )

      case .clearAlert:
        state.alertMessage = nil
        return .none

      case .searchTextChanged(let searchText):
        state.searchText = searchText
        state.currentPage = 1 // 검색 시 페이지 초기화

        // 검색어가 비어있으면 전체 리스트 표시
        if searchText.isEmpty {
          state.filteredRates = Dictionary(uniqueKeysWithValues:
            state.exchangeRateModel?.rates.map { ($0.key.rawValue, $0.value) } ?? []
          )
        } else {
          // 통화 코드 또는 국가명으로 필터링
          let locale = Locale(identifier: "ko_KR")
          let searchLower = searchText.lowercased()

          let filtered = state.exchangeRateModel?.rates.filter { code, rate in
            let currencyCode = code.rawValue.lowercased()
            let currencyName = locale.currencyDisplayName(for: code.rawValue).lowercased()
            return currencyCode.contains(searchLower) || currencyName.contains(searchLower)
          }

          state.filteredRates = Dictionary(uniqueKeysWithValues:
            filtered?.map { ($0.key.rawValue, $0.value) } ?? []
          )
        }

        return .send(.inner(.updateDisplayedRates))

      case .loadMoreData:
        guard state.displayedRates.count < state.filteredRates.count,
              !state.isLoadingMore else {
          return .none // 더 이상 로드할 데이터 없거나 이미 로딩 중
        }

        state.isLoadingMore = true

        return .run { [currentPage = state.currentPage] send in
          try await Task.sleep(for: .milliseconds(500)) // 로딩 시뮬레이션
          await send(.inner(.loadMoreCompleted(currentPage + 1)))
        }

      case .favoriteTapped(let code):
        return .send(.async(.toggleFavorite(code)))
    }
  }

  private func updateDisplayedRates(state: inout State) {
    let sortedPairs = state.filteredRates.sorted { $0.key < $1.key }
    let allRates = sortedPairs.map { pair in
      CurrencyRateItem(
        code: pair.key,
        rate: pair.value,
        trend: state.rateTrends[pair.key] ?? .none
      )
    }
    let favorites = state.favoriteCodes
    let ordered = allRates.partitioned { favorites.contains($0.code) }
    let endIndex = min(state.currentPage * state.itemsPerPage, ordered.count)
    state.displayedRates = Array(ordered.prefix(endIndex))
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchExchangeRates:
        return .run { send in
          let exchangeRateResult = await Result {
            try await exchangeUseCase.getExchangeRates(currency: "USD")
          }

          switch exchangeRateResult {
            case .success(let exchangeRateData):
              if let exchangeRateData {
                await send(.inner(.onFetchExchangeRatesResponse(.success(exchangeRateData))))
              }
            case .failure(_):
              await send(.inner(.onFetchExchangeRatesResponse(.failure(.notFound))))
          }
        }

      case .searchCurrency(let currency):
        return .run { send in
          let exchangeRateResult = await Result {
            try await exchangeUseCase.getExchangeRates(currency: currency)
          }

          switch exchangeRateResult {
            case .success(let exchangeRateData):
              if let exchangeRateData {
                await send(.inner(.onFetchExchangeRatesResponse(.success(exchangeRateData))))
              }
            case .failure(_):
              await send(.inner(.onFetchExchangeRatesResponse(.failure(.notFound))))
          }
        }

      case .fetchFavorites:
        return .run { send in
          let favoriteResult = await Result {
            try await favoriteUseCase.fetchFavorites()
          }

          switch favoriteResult {
            case .success(let codes):
              await send(.inner(.onFavoritesUpdated(Set(codes))))
            case .failure(_):
              await send(.inner(.favoriteOperationFailed(.unknown)))
          }
        }

      case .toggleFavorite(let code):
        return .run { send in
          let favoriteResult = await Result {
            try await favoriteUseCase.toggleFavorite(currencyCode: code)
          }

          switch favoriteResult {
            case .success(let codes):
              await send(.inner(.onFavoritesUpdated(Set(codes))))
            case .failure(_):
              await send(.inner(.favoriteOperationFailed(.unknown)))
          }
        }

      case .loadCachedSnapshot:
        return .run { send in
          let cacheResult = await Result {
            try await cacheUseCase.loadSnapshot()
          }

          switch cacheResult {
            case .success(let snapshot):
              await send(.inner(.onCachedSnapshotLoaded(snapshot)))
            case .failure(_):
              await send(.inner(.cacheOperationFailed(.unknown)))
          }
        }

      case .saveSnapshot(let snapshot):
        return .run { send in
          let result = await Result {
            try await cacheUseCase.saveSnapshot(snapshot)
          }

          if case .failure(_) = result {
            await send(.inner(.cacheOperationFailed(.unknown)))
          }
        }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .onFetchExchangeRatesResponse(let result):
        switch result {
          case .success(let exchangeRateData):
            state.exchangeRateModel = exchangeRateData
            state.baseCurrencyCode = exchangeRateData.base.rawValue
            let newRates = exchangeRateData.rates.reduce(into: [String: Double]()) { dict, pair in
              dict[pair.key.rawValue] = pair.value
            }
            state.filteredRates = newRates
            state.rateTrends = computeTrends(newRates: newRates, previousRates: state.previousRates)
            state.previousRates = newRates
            state.lastCachedAt = exchangeRateData.lastUpdatedAt

            let snapshot = ExchangeRateSnapshot(
              base: exchangeRateData.base.rawValue,
              lastUpdatedAt: exchangeRateData.lastUpdatedAt,
              rates: newRates
            )

            return .merge(
              .send(.inner(.updateDisplayedRates)),
              .send(.async(.saveSnapshot(snapshot)))
            )

          case .failure(let error):
            state.exchangeRateModel = nil
            state.baseCurrencyCode = ""
            state.filteredRates = [:]
            state.displayedRates = []
            state.rateTrends = [:]
            state.previousRates = [:]
            state.lastCachedAt = nil
            state.alertMessage = "데이터를 불러올 수 없습니다 \(error.errorDescription ?? "Unknown Error")"
            return .send(.inner(.updateDisplayedRates))
        }

      case .loadMoreCompleted(let newPage):
        state.currentPage = newPage
        state.isLoadingMore = false
        return .send(.inner(.updateDisplayedRates))

      case .updateDisplayedRates:
        updateDisplayedRates(state: &state)
        return .none

      case .onFavoritesUpdated(let codes):
        state.favoriteCodes = codes
        return .send(.inner(.updateDisplayedRates))

      case .favoriteOperationFailed(let error):
        state.alertMessage = error.errorDescription
        return .none

      case .onCachedSnapshotLoaded(let snapshot):
        if let snapshot {
          state.previousRates = snapshot.rates
          state.lastCachedAt = snapshot.lastUpdatedAt
          if state.filteredRates.isEmpty {
            state.filteredRates = snapshot.rates
            if state.baseCurrencyCode.isEmpty {
              state.baseCurrencyCode = snapshot.base
            }
          }
          state.rateTrends = snapshot.rates.keys.reduce(into: [:]) { partialResult, code in
            partialResult[code] = RateTrend.none
          }
        } else {
          state.previousRates = [:]
          state.lastCachedAt = nil
          state.rateTrends = [:]
        }
        return .send(.inner(.updateDisplayedRates))

      case .cacheOperationFailed(let error):
        state.alertMessage = error.errorDescription
        return .none
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .navigateToCalculator:
      // RootReducer에서 처리
      return .none
    }
  }

  private func computeTrends(
    newRates: [String: Double],
    previousRates: [String: Double]
  ) -> [String: RateTrend] {
    newRates.reduce(into: [String: RateTrend]()) { result, entry in
      let previous = previousRates[entry.key] ?? entry.value
      let diff = entry.value - previous
      result[entry.key] = RateTrend(difference: diff)
    }
  }
}

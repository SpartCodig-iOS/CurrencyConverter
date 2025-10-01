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
    var filteredRates: [String: Double] = [:]
    var displayedRates: [String: Double] = [:]
    var alertMessage: String? = nil
    var searchText: String = ""
    var currentPage: Int = 1
    var itemsPerPage: Int = 20
    var isLoadingMore: Bool = false

    public init() {

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
    case clearAlert
    case searchTextChanged(String)
    case loadMoreData
  }


  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchExchangeRates
    case searchCurrency(String)

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case onFetchExchangeRatesResponse(Result<ExchangeRates, DomainError>)
    case loadMoreCompleted(Int)
    case updateDisplayedRates
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case navigateToCalculator(currencyCode: String)
  }

  @Injected(ExchangeUseCaseImpl.self) var exchangeUseCase
//  @Inject var exchangeUseCase : ExchangeRateInterface?

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
    }
  }

  private func updateDisplayedRates(state: inout State) {
    let sortedRates = state.filteredRates.sorted { $0.key < $1.key }
    let endIndex = min(state.currentPage * state.itemsPerPage, sortedRates.count)
    let pagedRates = Array(sortedRates[0..<endIndex])
    state.displayedRates = Dictionary(uniqueKeysWithValues: pagedRates)
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
            // 초기 로드 시 전체 리스트 표시
            state.filteredRates = Dictionary(uniqueKeysWithValues:
              exchangeRateData.rates.map { ($0.key.rawValue, $0.value) }
            )

          case .failure(let error):
            state.exchangeRateModel = nil
            state.filteredRates = [:]
            state.displayedRates = [:]
            state.alertMessage = "데이터를 불러올 수 없습니다 \(error.errorDescription ?? "Unknown Error")"
        }
        return .send(.inner(.updateDisplayedRates))

      case .loadMoreCompleted(let newPage):
        state.currentPage = newPage
        state.isLoadingMore = false
        return .send(.inner(.updateDisplayedRates))

      case .updateDisplayedRates:
        let sortedRates = state.filteredRates.sorted { $0.key < $1.key }
        let endIndex = min(state.currentPage * state.itemsPerPage, sortedRates.count)
        let pagedRates = Array(sortedRates[0..<endIndex])
        state.displayedRates = Dictionary(uniqueKeysWithValues: pagedRates)
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
}


//
//  CalculatorReducer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import Foundation
import ComposableArchitecture
import LogMacro
import WeaveDI

@Reducer
public struct CalculatorReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var currencyCode: String
    var currencyName: String = ""
    var amount: String = ""
    var convertedAmount: Double = 0.0
    var exchangeRate: Double = 0.0
    var exchangeRateModel: ExchangeRates? = nil
    var errorMessage: String? = nil



    public init(currencyCode: String) {
      self.currencyCode = currencyCode
    }
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
  }


  public enum View {
    case onAppear
    case calculateButtonTapped
  }

  public enum InnerAction: Equatable {
    case updateConvertedAmount
    case fetchFilterExchangeRateResponse(Result<ExchangeRates, DomainError>)
  }

  public enum AsyncAction: Equatable {
    case fetchFilterExchangeRate

  }


  @Injected(ExchangeUseCaseImpl.self) var exchangeUseCase
  @Dependency(\.mainQueue) var mainQueue

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .binding(_):
          return .none

        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .inner(let innerAction):
          return handleInnerAction(state: &state, action: innerAction)

        case .async(let asyncAction):
          return handleAsyncAction(state: &state, action: asyncAction)
      }
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        // 통화 이름 설정
        let locale = Locale(identifier: "ko_KR")
        state.currencyName = locale.currencyDisplayName(for: state.currencyCode)
        return .none

      case .calculateButtonTapped:
        return .send(.inner(.updateConvertedAmount))
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .updateConvertedAmount:
        if let amount = Double(state.amount) {
          state.convertedAmount = amount * state.exchangeRate
        }
        return .none

      case .fetchFilterExchangeRateResponse(let result):
        switch result {
          case .success(let filterExchangeModel):
            state.exchangeRateModel = filterExchangeModel
            #logDebug("filter data", filterExchangeModel)

          case .failure(let error):
            state.exchangeRateModel = nil
            state.errorMessage = error.errorDescription

            #logError("필터 실패", error)
        }
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchFilterExchangeRate:
        return .run {  [currencyCode = state.currencyCode] send in
          let filterExchangeResult = await Result {
            try await exchangeUseCase.filterExchangeRates(currency: currencyCode)
          }

          switch filterExchangeResult {
            case .success(let filterExchangeData):
              if let filterExchangeData = filterExchangeData {
                await send(.inner(.fetchFilterExchangeRateResponse(.success(filterExchangeData))))
              }

            case .failure( _):
              await send(.inner(.fetchFilterExchangeRateResponse(.failure(.notFound))))
          }
        }
        .debounce(id: "calculator/debounce", for: 0.3, scheduler: mainQueue)
    }
  }
}

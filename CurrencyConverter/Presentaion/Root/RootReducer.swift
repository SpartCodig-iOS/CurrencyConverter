//
//  RootReducer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import Foundation
import ComposableArchitecture

@MainActor
@Reducer
public struct RootReducer {
  public init() {}

  @Reducer(state: .equatable)
  public enum Path {
    case calculator(CalculatorReducer)
  }

  @ObservableState
  public struct State: Equatable {
    var currency = CurrencyReducer.State()
    var path = StackState<Path.State>()

    public init() {}
  }

  public enum Action {
    case currency(CurrencyReducer.Action)
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.currency, action: \.currency) {
      CurrencyReducer()
    }

    Reduce { state, action in
      switch action {
        case .currency(.navigation(.navigateToCalculator(let currencyCode, let currencyRate))):
          let base = state.currency.baseCurrencyCode.isEmpty
          ? (state.currency.exchangeRateModel?.base.rawValue ?? "USD")
          : state.currency.baseCurrencyCode
          state.path.append(
            .calculator(
              CalculatorReducer.State(
                currencyCode: currencyCode,
                exchangeRate: currencyRate,
                baseCurrencyCode: base
              )
            )
          )
          return .none

        case .currency:
          return .none

        case .path:
          return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}

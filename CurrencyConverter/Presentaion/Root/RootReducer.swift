//
//  RootReducer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import Foundation
import ComposableArchitecture
import WeaveDI

@MainActor
@Reducer
public struct RootReducer {
  private let currencyReducer: CurrencyReducer
  private let overrideLastViewedUseCase: LastViewedScreenInterface?

  @Injected(LastViewedScreenUseCaseImpl.self) private var injectedLastViewedUseCase

  private var lastViewedUseCase: LastViewedScreenInterface {
    overrideLastViewedUseCase ?? injectedLastViewedUseCase
  }

  public init(
    currencyReducer: CurrencyReducer? = nil,
    lastViewedUseCase: LastViewedScreenInterface? = nil
  ) {
    self.currencyReducer = currencyReducer ?? CurrencyReducer()
    self.overrideLastViewedUseCase = lastViewedUseCase
  }

  private func persistLastViewed(screen: LastViewedScreen) -> Effect<Action> {
    .run { [lastViewedUseCase] _ in
      do {
        try await lastViewedUseCase.updateLastViewedScreen(screen)
      } catch {
        print("[RootReducer] Failed to persist last viewed screen: \(error)")
      }
    }
  }

  @Reducer(state: .equatable)
  public enum Path {
    case calculator(CalculatorReducer)
  }

  @ObservableState
  public struct State: Equatable {
    var currency: CurrencyReducer.State
    var path: StackState<Path.State>

    public init(
      currency: CurrencyReducer.State,
      path: StackState<Path.State> = StackState<Path.State>()
    ) {
      self.currency = currency
      self.path = path
    }
  }

  public enum Action {
    case currency(CurrencyReducer.Action)
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.currency, action: \.currency) {
      currencyReducer
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

          return persistLastViewed(
            screen: LastViewedScreen(type: .calculator, currencyCode: currencyCode)
          )

        case .currency(.view(.onAppear)):
          return persistLastViewed(screen: LastViewedScreen(type: .list))

        case .currency:
          return .none

        case .path(.popFrom(id: _)):
          return persistLastViewed(screen: LastViewedScreen(type: .list))

        case .path:
          return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}

//
//  CalculatorReducer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CalculatorReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var currencyCode: String
    var baseCurrencyCode: String
    var currencyName: String = ""
    var amount: String = ""
    var convertedAmount: Double = 0.0
    var convertedAmountText: String = "0.00"
    var exchangeRate: Double
    var errorMessage: String? = nil
    var errorToken: Int = 0
    var conversionSummary: String = ""

    public init(
      currencyCode: String,
      exchangeRate: Double,
      baseCurrencyCode: String
    ) {
      self.currencyCode = currencyCode
      self.exchangeRate = exchangeRate
      self.baseCurrencyCode = baseCurrencyCode
    }
  }

  public enum Action: ViewAction {
    case view(View)
    case inner(InnerAction)
  }

  public enum View {
    case onAppear
    case calculateButtonTapped
    case amountChanged(String)
  }

  public enum InnerAction: Equatable {
    case updateConvertedAmount(Double)
    case setError(String?)
    case clearConversion
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .inner(let innerAction):
          return handleInnerAction(state: &state, action: innerAction)
      }
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        let locale = Locale(identifier: "ko_KR")
        state.currencyName = locale.currencyDisplayName(for: state.currencyCode)
        state.errorMessage = nil
        state.conversionSummary = makeSummary(
          baseAmount: amountValue(from: state.amount),
          convertedText: state.convertedAmountText,
          baseCode: state.baseCurrencyCode,
          targetCode: state.currencyCode
        )
        return .none

      case .calculateButtonTapped:
        switch AmountParser.parse(state.amount) {
          case .empty:
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.clearConversion)),
              .send(.inner(.setError("금액을 입력해주세요")))
            ])

          case .invalid:
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.clearConversion)),
              .send(.inner(.setError("올바른 숫자를 입력해주세요")))
            ])

          case .value(let parsed):
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.updateConvertedAmount(parsed)))
            ])
        }

      case .amountChanged(let amount):
        state.amount = amount

        switch AmountParser.parse(amount) {
          case .empty:
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.clearConversion))
            ])

          case .invalid:
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.clearConversion)),
              .send(.inner(.setError("올바른 숫자를 입력해주세요")))
            ])

          case .value(let parsed):
            return .concatenate([
              .send(.inner(.setError(nil))),
              .send(.inner(.updateConvertedAmount(parsed)))
            ])
        }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .updateConvertedAmount(let amount):
        state.errorMessage = nil
        let rawResult = amount * state.exchangeRate
        let rounded = (rawResult * 100).rounded() / 100
        state.convertedAmount = rounded
        let convertedText = rounded.formattedDecimal(fractionDigits: 2)
        state.convertedAmountText = convertedText
        state.conversionSummary = makeSummary(
          baseAmount: Optional(amount),
          convertedText: convertedText,
          baseCode: state.baseCurrencyCode,
          targetCode: state.currencyCode
        )
        return .none

      case .setError(let message):
        if let message {
          state.errorToken &+= 1
          state.errorMessage = message
        } else {
          state.errorMessage = nil
        }
        return .none

      case .clearConversion:
        state.convertedAmount = 0
        state.convertedAmountText = "0.00"
        state.conversionSummary = ""
        return .none
    }
  }

  private func amountValue(from raw: String) -> Double? {
    switch AmountParser.parse(raw) {
      case .value(let value):
        return value
      case .empty, .invalid:
        return nil
    }
  }

  private func makeSummary(
    baseAmount: Double?,
    convertedText: String,
    baseCode: String,
    targetCode: String
  ) -> String {
    guard let baseAmount else { return "" }
    let baseText = baseAmount.formattedDecimal(fractionDigits: 2)
    let sourceCode = baseCode.isEmpty ? "-" : baseCode
    let targetCodeText = targetCode.isEmpty ? "-" : targetCode
    return "\(baseText) \(sourceCode) → \(convertedText) \(targetCodeText)"
  }
}

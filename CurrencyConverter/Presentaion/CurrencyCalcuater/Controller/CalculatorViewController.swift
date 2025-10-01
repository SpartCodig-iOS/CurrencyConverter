//
//  CalculatorViewController.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import UIKit
import Combine
import ComposableArchitecture

@MainActor
final class CalculatorViewController: BaseViewController<CalculateView, CalculatorReducer> {

  init(store: StoreOf<CalculatorReducer>) {
    super.init(rootView: CalculateView(), store: store)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func configureUI() {
    super.configureUI()
    view.backgroundColor = .systemBackground
  }

  override func bindActions() {
    super.bindActions()

    // 화면 진입 시
    safeSend(.view(.onAppear))

    // TextField 입력 바인딩
    rootView.amountTextField
      .publisher(for: \.text)
      .compactMap { $0 }
      .sink { [weak self] text in
        self?.safeSend(.view(.amountChanged(text)))
      }
      .store(in: &cancellables)

    rootView.calculateButton
      .publisher(for: .touchUpInside)
      .sink { [weak self] in
        guard let self else { return }
        let currentText = self.rootView.amountTextField.text ?? ""
        self.safeSend(.view(.amountChanged(currentText)))
        self.safeSend(.view(.calculateButtonTapped))
      }
      .store(in: &cancellables)
  }

  override func bindState() {
    super.bindState()

    optimizedPublisher(\.currencyCode)
      .sink { [weak self] code in
        guard let self else { return }
        self.rootView.updateCurrencyCode(code)
        self.rootView.updateResultDescription(
          base: self.viewStore.baseCurrencyCode,
          target: code
        )
      }
      .store(in: &cancellables)

    optimizedPublisher(\.currencyName)
      .sink { [weak self] name in
        self?.rootView.updateCurrencyName(name)
      }
      .store(in: &cancellables)

    optimizedPublisher(\.baseCurrencyCode)
      .sink { [weak self] base in
        guard let self else { return }
        self.rootView.updateResultDescription(
          base: base,
          target: self.viewStore.currencyCode
        )
      }
      .store(in: &cancellables)

    optimizedPublisher(\.convertedAmountText)
      .sink { [weak self] amountText in
        guard let self else { return }
        self.rootView.updateConvertedAmount(amountText, currencyCode: self.viewStore.currencyCode)
      }
      .store(in: &cancellables)
  }

  override func extractError(from state: CalculatorReducer.State) -> String? {
    guard let message = state.errorMessage else { return nil }
    return "\(state.errorToken)|\(message)"
  }

  override func handleError(_ errorPayload: String) {
    let components = errorPayload.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
    let message = components.count == 2 ? String(components[1]) : errorPayload
    super.handleError(message)
  }
}

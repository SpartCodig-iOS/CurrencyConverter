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
    title = "환율 계산기"
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
        self?.store.send(.set(\.amount, text))
      }
      .store(in: &cancellables)

  }

  override func bindState() {
    super.bindState()

    optimizedPublisher(\.currencyCode)
      .sink { [weak self] code in
        self?.rootView.updateCurrencyCode(code)
      }
      .store(in: &cancellables)

    optimizedPublisher(\.currencyName)
      .sink { [weak self] name in
        self?.rootView.updateCurrencyName(name)
      }
      .store(in: &cancellables)

    optimizedPublisher(\.convertedAmount)
      .sink { [weak self] amount in
        self?.rootView.updateConvertedAmount(amount)
      }
      .store(in: &cancellables)

    if !store.amount.isEmpty {
      rootView.calculateButton
        .publisher(for: .touchUpInside)   // 버튼 탭 이벤트를 Publisher로 감지
        .sink { [weak self] in            // 구독해서 콜백 실행
          self?.store.send(.async(.fetchFilterExchangeRate)) // TCA Action 전송
        }
        .store(in: &cancellables)         // 메모리 해제 방지용 저장
    }
  }
}

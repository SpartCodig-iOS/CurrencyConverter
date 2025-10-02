//
//  RootViewController.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import UIKit
import Combine
import ComposableArchitecture

@MainActor
final class RootViewController: UINavigationController {

  private let store: StoreOf<RootReducer>
  private var cancellables = Set<AnyCancellable>()

  init(store: StoreOf<RootReducer>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupInitialViewController()
    observeNavigationStack()
  }

  private func setupInitialViewController() {
    let currencyStore = store.scope(state: \.currency, action: \.currency)
    let currencyVC = CurrencyViewController(store: currencyStore)
    setViewControllers([currencyVC], animated: false)
  }

  private func observeNavigationStack() {
    store.publisher.path
      .sink { [weak self] path in
        self?.handlePathChange(path)
      }
      .store(in: &cancellables)
  }

  private func handlePathChange(_ path: StackState<RootReducer.Path.State>) {
    // 현재 네비게이션 스택과 동기화
    let currentCount = viewControllers.count
    let expectedCount = path.count + 1 // +1 for root

    if expectedCount > currentCount {
      // Push new view controller
      guard let last = path.last else { return }

      switch last {
      case .calculator(let calculatorState):
        let calculatorStore = Store(initialState: calculatorState) {
          CalculatorReducer()
        }
        let calculatorVC = CalculatorViewController(store: calculatorStore)
        pushViewController(calculatorVC, animated: true)
      }
    } else if expectedCount < currentCount {
      // Pop view controller
      popViewController(animated: true)
    }
  }
}

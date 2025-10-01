//
//  CurrencyViewController.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit
import Combine
import ComposableArchitecture
import Reusable

@MainActor
final class CurrencyViewController: BaseViewController<CurrencyView, CurrencyReducer> {

  // MARK: - Init
  init(store: StoreOf<CurrencyReducer>) {
    super.init(rootView: CurrencyView(), store: store)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Lifecycle Hooks
  override func configureUI() {
    super.configureUI()
    self.view.backgroundColor = .systemBackground
    rootView.tableView.dataSource = self
    rootView.tableView.delegate = self
    rootView.searchBar.delegate = self
  }

  override func bindActions() {
    super.bindActions()

    // 화면 진입 시 환율 요청
    safeSend(.async(.fetchExchangeRates))

    rootView.refreshControl
      .publisher(for: .valueChanged)
      .sink { [weak self] in
        self?.safeSend(.async(.fetchExchangeRates))
      }
      .store(in: &cancellables)

    optimizedPublisher(\.alertMessage)
      .sink { [weak self] message in
        guard let self, let msg = message else { return }
        if (store.state.exchangeRateModel?.rates.isEmpty == nil) {
          let alertConteroller = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
          alertConteroller.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.safeSend(.view(.clearAlert))
          })
          self.present(alertConteroller, animated: true)

        }
      }
      .store(in: &cancellables)
  }

  override func bindState() {
    super.bindState()

    optimizedPublisher(\.exchangeRateModel)
      .sink { [weak self] _ in
        self?.rootView.reload()
        self?.rootView.endRefreshing()
      }
      .store(in: &cancellables)

    optimizedPublisher(\.filteredRates)
      .sink { [weak self] filteredRates in
        guard let self else { return }
        self.rootView.reload()
        self.rootView.updateEmptyState(isEmpty: filteredRates.isEmpty && !viewStore.searchText.isEmpty)
      }
      .store(in: &cancellables)

    optimizedPublisher(\.displayedRates)
      .sink { [weak self] _ in
        self?.rootView.reload()
      }
      .store(in: &cancellables)

    optimizedPublisher(\.isLoadingMore)
      .sink { [weak self] isLoading in
        if isLoading {
          self?.rootView.showLoadingIndicator()
        } else {
          self?.rootView.hideLoadingIndicator()
        }
      }
      .store(in: &cancellables)
  }

  // MARK: - View Models
  private var products: [Product] {
    let displayedRates = viewStore.displayedRates
    return Self.mapFilteredRatesToProducts(displayedRates)
  }

  private static func mapFilteredRatesToProducts(_ rates: [String: Double]) -> [Product] {
    let locale = Locale(identifier: "ko_KR")
    return rates
      .sorted { $0.key < $1.key }
      .map { (code, rate) in
        let name = locale.currencyDisplayName(for: code)
        return Product(
          title: "\(code)",
          subtitle: name,
          price: rate.decimalString(rate)
        )
      }
  }
}

// MARK: - UITableViewDataSource
extension CurrencyViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    products.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ProductCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(products[indexPath.row])
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CurrencyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selectedProduct = products[indexPath.row]
    safeSend(.navigation(.navigateToCalculator(currencyCode: selectedProduct.title)))
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let frameHeight = scrollView.frame.height

    // RefreshControl이 활성화된 상태가 아닐 때만 무한 스크롤 동작
    guard !rootView.refreshControl.isRefreshing else { return }

    // 하단 40pt 이내로 스크롤 시 더 로드
    if offsetY > contentHeight - frameHeight - 40 {
      safeSend(.view(.loadMoreData))
    }
  }
}

// MARK: - UISearchBarDelegate
extension CurrencyViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    safeSend(.view(.searchTextChanged(searchText)))
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    safeSend(.view(.searchTextChanged("")))
  }
}

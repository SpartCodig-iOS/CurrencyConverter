//
//  CurrencyView.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import UIKit
import PinLayout
import FlexLayout
import Reusable
import Then

final class CurrencyView: BaseView {

  // MARK: - UI (Then 초기화)
  let searchBar = UISearchBar().then {
    $0.placeholder = "통화 검색"
    $0.searchBarStyle = .minimal
    $0.backgroundColor = .systemBackground
    $0.searchTextField.textColor = .label
    $0.searchTextField.backgroundColor = .secondarySystemBackground
    $0.tintColor = .label                 // 커서/클리어 버튼
  }

  let tableView = UITableView(frame: .zero, style: .plain).then {
    $0.separatorStyle = .singleLine
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 80
    $0.backgroundColor = .systemBackground
    $0.showsVerticalScrollIndicator = false
  }

  let refreshControl = UIRefreshControl()

  let emptyLabel = UILabel().then {
    $0.text = "검색 결과 없음"
    $0.textAlignment = .center
    $0.textColor = .systemGray
    $0.font = .systemFont(ofSize: 16, weight: .medium)
    $0.isHidden = true
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
  }

  // MARK: - Layout Constants
  private enum Layout {
    static let hPadding: CGFloat = 20
    static let emptyHeight: CGFloat = 100
    static let emptyTopMargin: CGFloat = 8
  }

  // MARK: - View Lifecycle
  override func addView() {
    addSubview(searchBar)
    addSubview(tableView)
    addSubview(emptyLabel)
    tableView.addSubview(refreshControl)
  }

  override func setAttributes() {
    backgroundColor = .systemBackground

    // Reusable 등록
    tableView.register(cellType: ProductCell.self)

    // RefreshControl 연결
    tableView.refreshControl = refreshControl

    // 플레이스홀더 색상/아이콘 틴트
    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "통화 검색",
      attributes: [.foregroundColor: UIColor.secondaryLabel]
    )
    searchBar.searchTextField.leftView?.tintColor = .label
  }

  override func defineLayout() {
    // BaseView → configureUI() 시점에서 호출됨
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    searchBar.pin
      .top(pin.safeArea)
      .horizontally(Layout.hPadding)
      .sizeToFit(.width)

    tableView.pin
      .below(of: searchBar)
      .horizontally(Layout.hPadding)
      .bottom()

    // 빈 상태 라벨은 검색바 아래, 폭 맞추고 고정 높이
    emptyLabel.pin
      .below(of: searchBar)
      .marginTop(Layout.emptyTopMargin)
      .horizontally(Layout.hPadding)
      .height(Layout.emptyHeight)

    // 하단 세이프에어리어만큼 인셋
    tableView.contentInset.bottom = safeAreaInsets.bottom
  }

  // MARK: - Helpers
  func endRefreshing() {
    refreshControl.endRefreshing()
  }

  func reload() {
    tableView.reloadData()
  }

  func updateEmptyState(isEmpty: Bool) {
    emptyLabel.isHidden = !isEmpty
    tableView.isHidden = isEmpty
  }
}

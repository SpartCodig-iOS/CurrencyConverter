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
import SwiftUI

final class CurrencyView: BaseView {

  // MARK: - Subviews
  private let fixedHeaderContainer = UIView()
  private let emptyContainer = UIView()
  private let footerSpacerView = UIView()

  let titleLabel = UILabel.createLabel(
    text: "환율정보",
    family: .semiBold,
    size: 30,
    color: .appPrimaryText,
    alignment: .left
  )

  let searchBar = UISearchBar().then {
    $0.placeholder = "통화 검색"
    $0.searchBarStyle = .minimal
    $0.tintColor = .appButtonBackground
  }

  let tableView = UITableView(frame: .zero, style: .plain).then {
    $0.separatorStyle = .singleLine
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 72
    $0.backgroundColor = UIColor.appBackground
    $0.showsVerticalScrollIndicator = false
    $0.keyboardDismissMode = .onDrag
  }

  let refreshControl = UIRefreshControl()

  private let emptyLabel = UILabel.createLabel(
    text: "검색 결과 없음",
    family: .medium,
    size: 16,
    color: .appSecondaryText,
    alignment: .center,
    lines: 0,
    lineBreak: .byWordWrapping
  )

  let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
    $0.hidesWhenStopped = true
  }

  // MARK: - Layout constants
  private enum Layout {
    static let hPadding: CGFloat = 10
    static let vGapAfterTitle: CGFloat = 8
    static let headerBottomSpacing: CGFloat = 8
    static let emptyHeight: CGFloat = 100
    static let loadingBottomMargin: CGFloat = 20
    static let topMargin: CGFloat = 10
  }

  // MARK: - Lifecycle
  override func addView() {
    super.addView()
    addSubview(fixedHeaderContainer)
    addSubview(tableView)
    addSubview(loadingIndicator)
  }

  override func defineLayout() {
    fixedHeaderContainer.backgroundColor = .clear
    fixedHeaderContainer.flex.define { flex in
      flex.addItem(titleLabel)
        .marginTop(Layout.topMargin)
        .marginHorizontal(20)
        .marginBottom(Layout.vGapAfterTitle)
        .alignSelf(.start)

      flex.addItem(searchBar)
        .marginTop(15)
        .marginHorizontal(Layout.hPadding)
        .marginBottom(10)
        .height(44)

      flex.addItem()
        .height(Layout.headerBottomSpacing)
    }

    emptyContainer.backgroundColor = .clear
    emptyContainer.flex
      .alignItems(.center)
      .justifyContent(.center)
      .define { flex in
        flex.addItem(emptyLabel)
          .marginHorizontal(Layout.hPadding)
          .height(Layout.emptyHeight)
      }
    emptyContainer.backgroundColor = UIColor.appBackground
    tableView.backgroundView = emptyContainer
    footerSpacerView.backgroundColor = .clear
    tableView.tableFooterView = footerSpacerView
  }

  override func setAttributes() {
    backgroundColor = UIColor.appBackground

    tableView.register(cellType: ProductCell.self)
    tableView.refreshControl = refreshControl

    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "통화 검색",
      attributes: [.foregroundColor: UIColor.appSecondaryText]
    )

    searchBar.searchTextField.textColor = UIColor.appPrimaryText
    searchBar.searchTextField.backgroundColor = UIColor.appCellBackground
    searchBar.searchTextField.leftView?.tintColor = UIColor.appSecondaryText
    searchBar.searchTextField.layer.cornerRadius = 12
    searchBar.searchTextField.clipsToBounds = true
    searchBar.backgroundImage = UIImage()
    searchBar.searchTextField.borderStyle = .none

    tableView.separatorInset = UIEdgeInsets(
      top: 0, left: Layout.hPadding, bottom: 0, right: Layout.hPadding
    )
    tableView.layoutMargins = UIEdgeInsets(
      top: 0, left: Layout.hPadding, bottom: 0, right: Layout.hPadding
    )
    loadingIndicator.color = .appSecondaryText
    tableView.sectionHeaderTopPadding = 0
    tableView.automaticallyAdjustsScrollIndicatorInsets = false
    updateEmptyState(isEmpty: true)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let safeInsets = pin.safeArea
    fixedHeaderContainer.pin
      .top(pin.safeArea)
      .horizontally(safeInsets)
    fixedHeaderContainer.flex.layout(mode: .adjustHeight)

    tableView.pin
      .below(of: fixedHeaderContainer)
      .horizontally()
      .bottom(pin.safeArea)

    if let bg = tableView.backgroundView {
      bg.frame = tableView.bounds
      bg.flex.layout(mode: .fitContainer)
    }

    loadingIndicator.pin
      .bottom(pin.safeArea)
      .hCenter()
      .marginBottom(Layout.loadingBottomMargin)
      .sizeToFit()

    updateBottomInsets()
  }

  // MARK: - Insets helper
  private func updateBottomInsets() {
    let windowSafe = window?.safeAreaInsets.bottom ?? 0
    let safeBottom = max(safeAreaInsets.bottom, windowSafe)

    let indicatorExtra: CGFloat = loadingIndicator.isAnimating
      ? (Layout.loadingBottomMargin + loadingIndicator.bounds.height)
      : 0

    let bottom = safeBottom + indicatorExtra + 8
    tableView.contentInset.bottom = bottom

    if tableView.tableFooterView !== footerSpacerView {
      tableView.tableFooterView = footerSpacerView
    }
    if footerSpacerView.frame.height != bottom || footerSpacerView.frame.width != tableView.bounds.width {
      footerSpacerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: bottom)
      tableView.tableFooterView = footerSpacerView
    }
  }

  // MARK: - State Helpers
  func endRefreshing() {
    refreshControl.endRefreshing()
  }

  func reload() {
    tableView.reloadData()
  }

  func updateEmptyState(isEmpty: Bool) {
    tableView.backgroundView?.isHidden = !isEmpty
    tableView.separatorStyle = isEmpty ? .none : .singleLine
    tableView.reloadData()
    setNeedsLayout()
    layoutIfNeeded()
  }

  func showLoadingIndicator() {
    loadingIndicator.startAnimating()
    setNeedsLayout()
    layoutIfNeeded()
    updateBottomInsets()
  }

  func hideLoadingIndicator() {
    loadingIndicator.stopAnimating()
    updateBottomInsets()
  }
}


#Preview {
  CurrencyView()
}

//
//  ProductCell.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit
import FlexLayout
import PinLayout
import Reusable
import Then

final class ProductCell: UITableViewCell, Reusable {

  // MARK: UI
  private let root = UIView().then {
    $0.backgroundColor = .clear
  }

  private let leftCol = UIView()

  private let titleLabel = UILabel.createLabel(
    text: nil,
    family: .semiBold,
    size: 16,
    color: .label,
    alignment: .left,
    lines: 1,
    lineBreak: .byTruncatingTail
  ).then {
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }

  private let subtitleLabel = UILabel.createLabel(
    text: nil,
    family: .regular,
    size: 13,
    color: .secondaryLabel,
    alignment: .left,
    lines: 1,
    lineBreak: .byTruncatingTail
  ).then {
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }

  private let priceLabel = UILabel.createLabel(
    text: nil,
    family: .bold,
    size: 15,
    color: .secondaryLabel,
    alignment: .right,
    lines: 1,
    lineBreak: .byClipping
  ).then {
    $0.adjustsFontSizeToFitWidth = false
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  // MARK: Layout Const
  private enum Layout {
    static let paddingH: CGFloat = 12
    static let paddingV: CGFloat = 10
    static let priceWidthMin: CGFloat = 60
    static let priceWidthPad: CGFloat = 2
  }

  // MARK: Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    setupViews()
    buildFlexTree()
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: Setup
  private func setupViews() {
    contentView.backgroundColor = .systemBackground
    contentView.addSubview(root)
  }

  private func buildFlexTree() {
    root.flex
      .paddingHorizontal(Layout.paddingH)
      .paddingVertical(Layout.paddingV)
      .direction(.row)
      .alignItems(.center)
      .define { row in
        row.addItem(leftCol).grow(1).shrink(1).define { col in
          col.addItem(titleLabel)
          col.addItem(subtitleLabel).marginTop(4)
        }
        row.addItem(priceLabel).shrink(0).marginLeft(8)
      }
  }

  // MARK: Configure
  func configure(_ product: Product) {
    titleLabel.text = product.title
    subtitleLabel.text = product.subtitle
    priceLabel.text = product.price

    // 가격 고정폭 확보 (intrinsic 기준)
    let targetWidth = ceil(priceLabel.intrinsicContentSize.width)
    let minWidth = max(targetWidth, Layout.priceWidthMin) + Layout.priceWidthPad
    priceLabel.flex.minWidth(minWidth)

    contentView.flex.markDirty()
    setNeedsLayout()
  }

  // MARK: Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    root.pin.all()
    root.flex.layout(mode: .adjustHeight)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    root.pin.width(size.width)
    root.flex.layout(mode: .adjustHeight)
    return root.frame.size
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    subtitleLabel.text = nil
    priceLabel.text = nil
    priceLabel.flex.minWidth(0)
    contentView.flex.markDirty()
  }
}

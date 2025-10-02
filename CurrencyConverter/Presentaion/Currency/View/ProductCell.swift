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
    color: UIColor.appPrimaryText,
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
    color: UIColor.appSecondaryText,
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
    color: UIColor.appPrimaryText,
    alignment: .right,
    lines: 1,
    lineBreak: .byClipping
  ).then {
    $0.adjustsFontSizeToFitWidth = false
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let trendImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = UIColor.appPrimaryText
    $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let favoriteButton = UIButton(type: .system).then {
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    $0.accessibilityLabel = "즐겨찾기"

    if #available(iOS 15.0, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
      config.baseForegroundColor = UIColor.appFavoriteInactive
      $0.configuration = config
    } else {
      $0.tintColor = UIColor.appFavoriteInactive
      $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
  }

  var onFavoriteTapped: (() -> Void)?

  // MARK: Layout Const
  private enum Layout {
    static let paddingH: CGFloat = 12
    static let paddingV: CGFloat = 10
    static let priceWidthMin: CGFloat = 60
    static let priceWidthPad: CGFloat = 2
    static let trendWidth: CGFloat = 16
  }

  // MARK: Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear

    preservesSuperviewLayoutMargins = false
    contentView.preservesSuperviewLayoutMargins = false
     contentView.layoutMargins = .zero

    setupViews()
    buildFlexTree()

    favoriteButton.addAction(UIAction { [weak self] _ in
      self?.onFavoriteTapped?()
    }, for: .touchUpInside)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: Setup
  private func setupViews() {
    contentView.backgroundColor = .clear
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
        row.addItem(priceLabel).shrink(0).marginLeft(4)
        row.addItem(trendImageView)
          .width(Layout.trendWidth).height(Layout.trendWidth).marginLeft(4)
        row.addItem(favoriteButton).marginLeft(8)
      }
  }

  // MARK: Configure
  func configure(_ product: Product) {
    titleLabel.text = product.title
    subtitleLabel.text = product.subtitle
    priceLabel.text = product.price

    let symbolName = product.isFavorite ? "star.fill" : "star"
    let tint = product.isFavorite ? UIColor.appFavoriteActive : UIColor.appFavoriteInactive
    if #available(iOS 15.0, *) {
      var updatedConfig = favoriteButton.configuration ?? .plain()
      updatedConfig.image = UIImage(systemName: symbolName)
      updatedConfig.baseForegroundColor = tint
      favoriteButton.configuration = updatedConfig
    } else {
      favoriteButton.setImage(UIImage(systemName: symbolName), for: .normal)
      favoriteButton.tintColor = tint
    }

    switch product.trend {
      case .up:
        trendImageView.image = UIImage(systemName: "arrowtriangle.up.fill")?.withRenderingMode(.alwaysTemplate)
        trendImageView.tintColor = UIColor.appTrendUp
        trendImageView.alpha = 1
      case .down:
        trendImageView.image = UIImage(systemName: "arrowtriangle.down.fill")?.withRenderingMode(.alwaysTemplate)
        trendImageView.tintColor = UIColor.appTrendDown
        trendImageView.alpha = 1
      case .none:
        trendImageView.image = nil
        trendImageView.alpha = 0
    }

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
    root.flex.layout()
    root.pin.horizontally(20)
    root.flex.layout(mode: .adjustHeight)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    root.pin.width(size.width)
    return root.frame.size
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    subtitleLabel.text = nil
    priceLabel.text = nil
    priceLabel.flex.minWidth(0)
    favoriteButton.setImage(nil, for: .normal)
    trendImageView.image = nil
    trendImageView.alpha = 0
    if var config = favoriteButton.configuration {
      config.baseForegroundColor = UIColor.appFavoriteInactive
      favoriteButton.configuration = config
    }
    onFavoriteTapped = nil
    contentView.flex.markDirty()
  }
}

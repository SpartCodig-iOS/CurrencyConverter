//
//  CalculateView.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/1/25.
//

import FlexLayout
import PinLayout
import Then
import UIKit
import SwiftUI

final class CalculateView: BaseView {

  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = true
  }

  private let rootView = UIView()

  private let titleLabel = UILabel.createLabel(
    text: "환율 계산기",
    family: .semiBold,
    size: 40,
    color: .appPrimaryText,
    alignment: .left
  )

  private let currencyCodeLabel = UILabel.createLabel(
    text: "ALL",
    family: .extraBold,
    size: 25,
    color: .appPrimaryText,
    alignment: .center
  )

  private let currencyCountryName = UILabel.createLabel(
    text: "나라",
    family: .regular,
    size: 14,
    color: .appSecondaryText,
    alignment: .center
  )

   let amountTextField = UITextField().then {
    $0.borderStyle = .none
    $0.backgroundColor = .appCellBackground
    $0.layer.cornerRadius = 12
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.appBorder.cgColor
    $0.textColor = UIColor.appPrimaryText
    $0.font = .pretendardFont(family: .medium, size: 16)
    $0.tintColor = UIColor.appButtonBackground

    $0.attributedPlaceholder = NSAttributedString(
      string: "금액을 입력하세요",
      attributes: [
        .foregroundColor: UIColor.appSecondaryText,
        .font: UIFont.pretendardFont(family: .medium, size: 16)
      ]
    )

    let padding: CGFloat = 12
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
    $0.leftViewMode = .always
    $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
    $0.rightViewMode = .always

    $0.keyboardType = .decimalPad
    $0.returnKeyType = .done
    $0.clearButtonMode = .whileEditing
  }

  let calculateButton = UIButton(type: .system).then {
      $0.setTitle("환율 계산", for: .normal)
      $0.setTitleColor(UIColor.appButtonTitle, for: .normal)
      $0.titleLabel?.font = .pretendardFont(family: .semiBold, size: 17)
      $0.backgroundColor = .appButtonBackground
      $0.clipsToBounds = true
      $0.setTitleColor(UIColor.appButtonTitle.withAlphaComponent(0.6), for: .disabled)
    }


  private let calculateResultDescriptionLabel = UILabel.createLabel(
    text: "계산 결과가 여기에 표시됩니다",
    family: .semiBold,
    size: 20,
    color: .appSecondaryText,
    alignment: .center
  )

  override func addView() {
    super.addView()
    addSubview(scrollView)
    scrollView.addSubview(rootView)
  }

  override func defineLayout() {
     rootView.flex
       .paddingHorizontal(20)
       .define { flex in
         flex.addItem(titleLabel)
           .marginTop(0)
           .marginBottom(20)
           .alignSelf(.start)

         flex.addItem(currencyCodeLabel)
           .marginTop(40)
           .marginBottom(10)

         flex.addItem(currencyCountryName)
           .marginBottom(30)

         flex.addItem(amountTextField)
           .height(44)
           .marginBottom(20)
           .width(100%)

         flex.addItem(calculateButton)
           .height(48)
           .marginBottom(30)
           .width(100%)

         flex.addItem(calculateResultDescriptionLabel)
           .marginBottom(20)


         flex.addItem().height(12)
       }
   }

  override func setAttributes() {
     backgroundColor = .systemBackground
     rootView.backgroundColor = .clear
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
   }

  override func layoutSubviews() {
      super.layoutSubviews()

      let isLandscape = bounds.width > bounds.height

      scrollView.isScrollEnabled = isLandscape
      scrollView.pin.all(pin.safeArea)
      titleLabel.flex.marginTop(isLandscape ? 0 : 30)

      rootView.pin
        .top()
        .horizontally(20)

      rootView.flex.layout(mode: .adjustHeight)

      let safeBottom = max(safeAreaInsets.bottom, window?.safeAreaInsets.bottom ?? 0)
      let extraBottom: CGFloat = isLandscape ? 28 : 20

      scrollView.contentInset.bottom = safeBottom + extraBottom

      let contentH = rootView.frame.maxY + scrollView.contentInset.bottom
      scrollView.contentSize = CGSize(
        width: scrollView.bounds.width,
        height: max(contentH, scrollView.bounds.height + 1)
      )

      calculateButton.layer.cornerRadius = 12
      calculateButton.layer.masksToBounds = true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let t = textField.text, !t.isEmpty else { return }
    let normalized = t.replacingOccurrences(of: ",", with: "")
    if let number = Double(normalized) {
      let formate = NumberFormatter()
      formate.numberStyle = .decimal
      formate.maximumFractionDigits = 2
      formate.minimumFractionDigits = 0
      textField.text = formate.string(from: NSNumber(value: number))
    }
  }

  func configure(countryCode: String, countryName: String) {
    currencyCodeLabel.text = countryCode
    currencyCountryName.text = countryName
  }

  func updateCurrencyCode(_ code: String) {
    currencyCodeLabel.text = code
  }

  func updateCurrencyName(_ name: String) {
    currencyCountryName.text = name
  }

  func updateConversionSummary(_ summary: String) {
    if summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      calculateResultDescriptionLabel.text = "계산 결과가 여기에 표시됩니다"
    } else {
      calculateResultDescriptionLabel.text = summary
    }
  }
}


#Preview {
  CalculateView()
}

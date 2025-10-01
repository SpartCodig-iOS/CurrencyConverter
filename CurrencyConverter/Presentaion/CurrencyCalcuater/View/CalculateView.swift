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

  private let rootView = UIView()

  private let titleLabel = UILabel.createLabel(
    text: "환율 계산기",
    family: .semiBold,
    size: 40,
    color: .white,
    alignment: .left
  )

  private let currencyCodeLabel = UILabel.createLabel(
    text: "ALL",
    family: .extraBold,
    size: 25,
    color: .secondaryLabel,
    alignment: .center
  )

  private let currencyCountryName = UILabel.createLabel(
    text: "나라",
    family: .regular,
    size: 14,
    color: .gray60,
    alignment: .center
  )

   let amountTextField = UITextField().then {
    $0.borderStyle = .none
    $0.backgroundColor = .secondarySystemBackground
    $0.layer.cornerRadius = 12
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.systemGray4.cgColor
    $0.textColor = .label
    $0.font = .pretendardFont(family: .medium, size: 16)

    // placeholder 스타일
    $0.attributedPlaceholder = NSAttributedString(
      string: "금액을 입력하세요",
      attributes: [
        .foregroundColor: UIColor.systemGray2,
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
      $0.setTitleColor(.white, for: .normal)
      $0.titleLabel?.font = .pretendardFont(family: .semiBold, size: 17)
      $0.backgroundColor = .systemBlue
      $0.clipsToBounds = true
      $0.setTitleColor(.white, for: .disabled)
    }


  private let calculateResultLabel = UILabel.createLabel(

    text: "0.00",
    family: .bold,
    size: 16,
    color: .secondaryLabel,
    alignment: .center
  )

  private let calculateResultDescriptionLabel = UILabel.createLabel(
    text: "계산 결과가 여기에 표시됩니다",
    family: .semiBold,
    size: 20,
    color: .secondaryLabel,
    alignment: .center
  )

  override func addView() {
    super.addView()
    addSubview(rootView)
  }

  override func defineLayout() {
    rootView.flex.define { flex in
      flex.addItem(titleLabel)
        .marginTop(30)
        .marginBottom(20)
        .alignSelf(.start)

      flex.addItem(currencyCodeLabel)
        .marginTop(40)
        .marginBottom(10)

      flex.addItem(currencyCountryName)
        .marginBottom(30)

      flex.addItem(amountTextField)
        .height(40)
        .marginBottom(30)

      flex.addItem(calculateButton)
        .height(40)
        .marginBottom(30)

      flex.addItem(calculateResultLabel)
        .marginBottom(10)

      flex.addItem(calculateResultDescriptionLabel)


    }
  }

  override func setAttributes() {
     backgroundColor = .systemBackground
     rootView.backgroundColor = .clear
   }

  override func layoutSubviews() {
    super.layoutSubviews()
    rootView.pin.all(pin.safeArea)
    rootView.flex.marginHorizontal(20)
    rootView.flex.layout(mode: .adjustHeight)
    calculateButton.layer.cornerRadius = 10
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

  func configure(countryCode: String, countryName: String, resultCurrency: String ) {
    currencyCodeLabel.text = countryCode
    currencyCountryName.text = countryName
    calculateResultLabel.text = resultCurrency
  }

  func updateCurrencyCode(_ code: String) {
    currencyCodeLabel.text = code
  }

  func updateCurrencyName(_ name: String) {
    currencyCountryName.text = name
  }

  func updateConvertedAmount(_ displayAmount: String, currencyCode: String) {
    calculateResultLabel.text = "\(displayAmount) \(currencyCode)"
  }

  func updateResultDescription(base: String, target: String) {
    guard !base.isEmpty, !target.isEmpty else {
      calculateResultDescriptionLabel.text = "계산 결과가 여기에 표시됩니다"
      return
    }

    calculateResultDescriptionLabel.text = "\(base) 금액을 \(target)으로 변환"
  }
}


#Preview {
  CalculateView()
}

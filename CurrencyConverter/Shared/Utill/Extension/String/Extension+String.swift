//
//  Extension+String.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation

public extension Double {
    func decimalString(_ value: Double, fractionDigits: Int = 4) -> String {
    let format = NumberFormatter()
    format.numberStyle = .decimal
    format.maximumFractionDigits = fractionDigits
    format.minimumFractionDigits = fractionDigits
    format.roundingMode = .halfUp
    return format.string(from: NSNumber(value: value)) ?? "\(value)"
  }
}

public extension Locale {
  func currencyDisplayName(for code: String) -> String {
    localizedString(forCurrencyCode: code) ?? code
  }
}

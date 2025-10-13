//
//  Extension+String.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation

public extension Double {
  func formattedDecimal(fractionDigits: Int = 4, locale: Locale = .current) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = fractionDigits
    formatter.minimumFractionDigits = fractionDigits
    formatter.roundingMode = .halfUp
    return formatter.string(from: NSNumber(value: self))
    ?? String(format: "%0.*f", fractionDigits, self)
  }

  func decimalString(_ value: Double, fractionDigits: Int = 4) -> String {
    value.formattedDecimal(fractionDigits: fractionDigits)
  }
}

public extension Locale {
  func currencyDisplayName(for code: String) -> String {
    localizedString(forCurrencyCode: code) ?? code
  }
}

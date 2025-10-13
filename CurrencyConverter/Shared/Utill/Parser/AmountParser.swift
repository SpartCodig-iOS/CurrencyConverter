//
//  AmountParser.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 10/5/25.
//

import Foundation

public enum AmountParseResult {
  case empty
  case invalid
  case value(Double)
}

public enum AmountParser {
  public static func parse(_ raw: String, locale: Locale = .current) -> AmountParseResult {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmed.isEmpty else { return .empty }

    let groupingSeparator = locale.groupingSeparator ?? ","
    let decimalSeparator = locale.decimalSeparator ?? "."

    let whitespaceSet = CharacterSet.whitespacesAndNewlines
      .union(CharacterSet(charactersIn: "\u{00A0}\u{202F}"))

    var normalized = trimmed
      .replacingOccurrences(of: groupingSeparator, with: "")
      .components(separatedBy: whitespaceSet)
      .joined()

    if decimalSeparator != "." {
      normalized = normalized.replacingOccurrences(of: decimalSeparator, with: ".")
    }

    guard let value = Double(normalized) else {
      return .invalid
    }

    return .value(value)
  }
}

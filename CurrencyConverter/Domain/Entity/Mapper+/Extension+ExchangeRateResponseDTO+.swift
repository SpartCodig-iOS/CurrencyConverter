//
//  Extension+ExchangeRateResponseDTO+.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public extension ExchangeRateResponseDTO {
    func toDomain() -> ExchangeRates {
    let base = CurrencyCode(rawValue: baseCode)

    let last = Date(timeIntervalSince1970: TimeInterval(timeLastUpdateUnix))
    let next = Date(timeIntervalSince1970: TimeInterval(timeNextUpdateUnix))

    let providerURL = URL(string: provider)
    let docsURL = URL(string: documentation)
    let termsURL = URL(string: termsOfUse)

    let mappedRates: [CurrencyCode: Double] = rates.reduce(into: [:]) { acc, pair in
      acc[CurrencyCode(rawValue: pair.key)] = pair.value
    }

    return ExchangeRates(
      base: base,
      lastUpdatedAt: last,
      nextUpdateAt: next,
      provider: providerURL,
      documentation: docsURL,
      termsOfUse: termsURL,
      rates: mappedRates
    )
  }
}

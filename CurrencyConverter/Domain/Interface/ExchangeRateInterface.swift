//
//  ExchangeRateInterface.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public protocol  ExchangeRateInterface: Sendable {
  func getExchangeRates(currency: String) async throws -> ExchangeRates?
}

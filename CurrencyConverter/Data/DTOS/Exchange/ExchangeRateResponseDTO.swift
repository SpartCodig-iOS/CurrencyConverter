//
//  ExchangeRateResponseDTO.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation


nonisolated public struct ExchangeRateResponseDTO: Decodable, Sendable {
  public let result: String
  public let provider: String
  public let documentation: String
  public let termsOfUse: String
  public let timeLastUpdateUnix: Int
  public let timeLastUpdateUTC: String
  public let timeNextUpdateUnix: Int
  public let timeNextUpdateUTC: String
  public let timeEolUnix: Int
  public let baseCode: String
  public let rates: [String: Double]

  enum CodingKeys: String, CodingKey {
    case result
    case provider
    case documentation
    case termsOfUse = "terms_of_use"
    case timeLastUpdateUnix = "time_last_update_unix"
    case timeLastUpdateUTC  = "time_last_update_utc"
    case timeNextUpdateUnix = "time_next_update_unix"
    case timeNextUpdateUTC  = "time_next_update_utc"
    case timeEolUnix        = "time_eol_unix"
    case baseCode           = "base_code"
    case rates
  }
}

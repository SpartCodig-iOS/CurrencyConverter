//
//  ExchangeRateService.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Moya
import Alamofire
import Foundation



public enum ExchangeRateService: Sendable {
  case latest(base: String)
}

extension ExchangeRateService: @MainActor BaseTargetType {
  public typealias Domain = CurrencyDomain

  public var domain: CurrencyDomain { .exchangeRate }

  public var urlPath: String {
    switch self {
    case .latest(let base):
      return ExchangeRateAPI.latest(base: base).description
    }
  }

  public var error: [Int: NetworkError]? { nil }

  public var parameters: [String: Any]? {
    switch self {
    case .latest: return nil
    }
  }

  public var method: Moya.Method {
    switch self {
    case .latest: return .get
    }
  }
}

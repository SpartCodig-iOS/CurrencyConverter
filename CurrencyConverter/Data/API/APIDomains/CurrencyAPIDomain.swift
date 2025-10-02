//
//  CurrencyAPIDomain.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public enum CurrencyDomain {
  case exchangeRate
}

extension CurrencyDomain: DomainType {
  public var baseURLString: String {
    return BaseAPI.base.description
  }

  public var url: String {
    switch self {
      case .exchangeRate:
        return "/v6"
    }
  }
}

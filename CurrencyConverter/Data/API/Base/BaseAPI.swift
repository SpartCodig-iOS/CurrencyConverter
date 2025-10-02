//
//  BaseAPI.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public enum BaseAPI: String {
  case base

  var description: String {
    switch self {
      case .base:
        return "https://open.er-api.com"
    }
  }
}

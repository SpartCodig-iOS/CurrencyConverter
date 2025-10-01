//
//  APIHeader.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

public struct APIHeader {

  public static let contentType   = "Content-Type"
  public static let accessToken   = "Authorization"

  public init() {}
}



extension APIHeader {


  public static var baseHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.contentType
    ]
  }
}

//
//  BaseTargetType.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation
import Moya
import Alamofire

public protocol DomainType {
  var url: String { get }
  var baseURLString: String { get }
}

public protocol BaseTargetType: TargetType {
  associatedtype Domain: DomainType
  var domain: Domain { get }
   var urlPath: String { get }
  var error: [Int: NetworkError]? { get }
   var parameters: [String: Any]? { get }
}

public extension BaseTargetType {
   var baseURL: URL { URL(string: domain.baseURLString)! }
    var path: String { domain.url + urlPath }

  // ✅ 순수 캐시만 사용 (UI 접근 금지)
  var headers: [String: String]? { APIHeaders.cached }

  var task: Moya.Task {
    if let parameters {
      return method == .get
        ? .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        : .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    return .requestPlain
  }
}

// 순수 캐시
enum APIHeaders {
  static var cached: [String: String] = [
    "Content-Type": "application/json"
  ]
}

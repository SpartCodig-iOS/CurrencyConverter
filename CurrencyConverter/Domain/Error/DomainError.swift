//
//  DomainError.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation

public enum DomainError: Error, Equatable {
  case networkUnavailable
  case notFound
  case rateLimited(retryAfter: TimeInterval?)
  case validationFailed([String])       // 필드 키 등
  case dependencyUnavailable            // DI 실패 등
  case unknown                          // 마지막 방어선
}

/// 사용자에게 보여줄 메시지 (프레젠테이션에서 사용)
extension DomainError: LocalizedError {
  public var errorDescription: String? {
    switch self {
      case .networkUnavailable:
        return "네트워크 연결을 확인해주세요."
      case .notFound:
        return "요청한 데이터를 찾을 수 없습니다."
      case .rateLimited(let retryAfter):
        if let s = retryAfter { return "요청이 너무 많습니다. \(Int(s))초 후 다시 시도해주세요." }
        return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
      case .validationFailed(let fields):
        return fields.isEmpty
        ? "입력값이 올바르지 않습니다."
        : "\(fields.joined(separator: ", ")) 항목을 확인해주세요."
      case .dependencyUnavailable:
        return "서비스를 사용할 수 없습니다. 잠시 후 다시 시도해주세요."
      case .unknown:
        return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
    }
  }
}

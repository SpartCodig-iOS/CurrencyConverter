//
//  RateTrend.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

public enum RateTrend: Int, Equatable, Hashable, Sendable {
  case up
  case down
  case none

  public init(difference: Double, threshold: Double = 0.01) {
    if abs(difference) <= threshold {
      self = .none
    } else if difference > 0 {
      self = .up
    } else {
      self = .down
    }
  }
}

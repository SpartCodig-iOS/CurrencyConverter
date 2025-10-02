//
//  Collection+Partitioned.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

extension Array {
  func partitioned(_ isInFirstGroup: (Element) -> Bool) -> [Element] {
    var first: [Element] = []
    var second: [Element] = []
    first.reserveCapacity(count / 2)
    second.reserveCapacity(count / 2)

    for element in self {
      if isInFirstGroup(element) {
        first.append(element)
      } else {
        second.append(element)
      }
    }

    return first + second
  }
}

//
//  Extension+RepositoryModuleFactory.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import WeaveDI

extension RepositoryModuleFactory {
  public mutating func registerDefaultDefinitions() {
    let registerModuleCopy = registerModule  // self를 직접 캡처하지 않고 복사
    definitions = {
      return [
        registerModuleCopy.exchangeRepositoryModule
      ]
    }()
  }
}

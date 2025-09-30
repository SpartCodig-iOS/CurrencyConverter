//
//  Extension+ModuleFactoryManager.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import WeaveDI

extension UseCaseModuleFactory {
  public mutating func registerDefaultDefinitions() {
    let register = registerModule

    self.definitions = {
      return [
        register.exchangeUseCaseModule,
      ]
    }()
  }
}

//
//  Extension+UseCaseModuleFactory.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import WeaveDI

extension ModuleFactoryManager {
  mutating func registerDefaultDependencies() {
    // Repository
    repositoryFactory.registerDefaultDefinitions()

    useCaseFactory.registerDefaultDefinitions()
  }
}

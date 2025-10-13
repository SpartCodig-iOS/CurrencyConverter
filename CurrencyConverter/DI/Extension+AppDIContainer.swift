//
//  Extension+AppDIContainer.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import WeaveDI

extension AppWeaveDI.Container {
  func registerDefaultDependencies() async {
    await registerDependencies(logLevel: .all) { container in
      // Repository 먼저 등록
      let factory = ModuleFactoryManager()

      await factory.registerAll(to: container)
    }
  }
}

//
//  AutoDIRegistry.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025.
//

import WeaveDI

/// 모든 의존성을 자동으로 등록하는 레지스트리
extension WeaveDI.Container {
  private static let helper = RegisterModule()
  
  /// 📦 Repository 등록
  static func registerRepositories() async {
    let repositories = [
      helper.exchangeRepositoryModule(),
      // 추가 Repository들...
    ]
    
    await repositories.asyncForEach { module in
      await module.register()
    }
  }
  
  /// 🔧 UseCase 등록
  static func registerUseCases() async {
    
    let useCases = [
      helper.exchangeUseCaseModule(),
      // 추가 UseCase들...
    ]
    
    await useCases.asyncForEach { module in
      await module.register()
    }
  }
}

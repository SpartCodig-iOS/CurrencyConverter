//
//  LastViewedScreenUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation
import WeaveDI

public struct LastViewedScreenUseCaseImpl: LastViewedScreenInterface {
  private let repository: LastViewedScreenInterface

  nonisolated public init(repository: LastViewedScreenInterface) {
    self.repository = repository
  }

  public func loadLastViewedScreen() async throws -> LastViewedScreen? {
    try await repository.loadLastViewedScreen()
  }

  public func updateLastViewedScreen(_ screen: LastViewedScreen) async throws {
    try await repository.updateLastViewedScreen(screen)
  }

  public func clearLastViewedScreen() async throws {
    try await repository.clearLastViewedScreen()
  }
}

extension LastViewedScreenUseCaseImpl: InjectedKey {
  public static var liveValue: LastViewedScreenInterface {
    let repository: LastViewedScreenInterface = UnifiedDI.register(LastViewedScreenInterface.self) {
      LastViewedScreenRepositoryImpl()
    }
    return LastViewedScreenUseCaseImpl(repository: repository)
  }

  public static var testValue: LastViewedScreenInterface {
    let repository: LastViewedScreenInterface = UnifiedDI.register(LastViewedScreenInterface.self) {
      MockLastViewedScreenRepositoryImpl()
    }
    return LastViewedScreenUseCaseImpl(repository: repository)
  }
}



public extension InjectedValues {
  var lastViewedScreenUseCase: LastViewedScreenInterface {
    get { self[LastViewedScreenUseCaseImpl.self] }
    set { self[LastViewedScreenUseCaseImpl.self] = newValue }
  }
}

extension RegisterModule {
  var lastViewedScreenRepositoryModule: @Sendable () -> Module {
    makeDependency(LastViewedScreenInterface.self) {
      LastViewedScreenRepositoryImpl()
    }
  }

  var lastViewedScreenUseCaseModule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      LastViewedScreenInterface.self,
      repositoryProtocol: LastViewedScreenInterface.self,
      repositoryFallback: MockLastViewedScreenRepositoryImpl(),
      factory: { repository in
        LastViewedScreenUseCaseImpl(repository: repository)
      }
    )
  }
}

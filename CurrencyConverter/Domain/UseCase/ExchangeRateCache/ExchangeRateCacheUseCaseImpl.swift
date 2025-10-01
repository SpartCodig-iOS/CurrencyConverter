//
//  ExchangeRateCacheUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import WeaveDI

public struct ExchangeRateCacheUseCaseImpl: ExchangeRateCacheInterface {
  private let repository: ExchangeRateCacheInterface

  nonisolated public init(repository: ExchangeRateCacheInterface) {
    self.repository = repository
  }

  public func loadSnapshot() async throws -> ExchangeRateSnapshot? {
    try await repository.loadSnapshot()
  }

  public func saveSnapshot(_ snapshot: ExchangeRateSnapshot) async throws {
    try await repository.saveSnapshot(snapshot)
  }

  public func clearSnapshot() async throws {
    try await repository.clearSnapshot()
  }
}

extension ExchangeRateCacheUseCaseImpl: InjectedKey {
  public static var liveValue: ExchangeRateCacheInterface {
    let repository: ExchangeRateCacheInterface = UnifiedDI.register(ExchangeRateCacheInterface.self) {
      ExchangeRateCacheRepositoryImpl()
    }
    return ExchangeRateCacheUseCaseImpl(repository: repository)
  }
}

public extension InjectedValues {
  var exchangeRateCacheUseCase: ExchangeRateCacheInterface {
    get { self[ExchangeRateCacheUseCaseImpl.self] }
    set { self[ExchangeRateCacheUseCaseImpl.self] = newValue }
  }
}

extension RegisterModule {
  var exchangeRateCacheRepositoryModule: @Sendable () -> Module {
    makeDependency(ExchangeRateCacheInterface.self) {
      ExchangeRateCacheRepositoryImpl()
    }
  }

  var exchangeRateCacheUseCaseModule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      ExchangeRateCacheInterface.self,
      repositoryProtocol: ExchangeRateCacheInterface.self,
      repositoryFallback: MockExchangeRateCacheRepositoryImpl(),
      factory: { repository in
        ExchangeRateCacheUseCaseImpl(repository: repository)
      }
    )
  }
}

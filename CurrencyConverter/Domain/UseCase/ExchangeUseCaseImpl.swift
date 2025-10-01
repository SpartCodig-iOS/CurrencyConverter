//
//  ExchangeUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import ComposableArchitecture

import WeaveDI

public struct ExchangeUseCaseImpl: ExchangeRateInterface {
  private let repository: ExchangeRateInterface

  nonisolated public init(repository: ExchangeRateInterface) {
    self.repository = repository
  }

  public func getExchangeRates(currency: String) async throws -> ExchangeRates? {
    try await repository.getExchangeRates(currency: currency)
  }
}


extension ExchangeUseCaseImpl: InjectedKey {
  public static var liveValue: ExchangeRateInterface {
    let repository: ExchangeRateInterface = UnifiedDI.register(ExchangeRateInterface.self) {
      ExchangeRepositoryImpl()
    }
    return ExchangeUseCaseImpl(repository: repository)
  }
}

public extension InjectedValues {
  var exchangeUseCase: ExchangeRateInterface {
    get { self[ExchangeUseCaseImpl.self] }
    set { self[ExchangeUseCaseImpl.self] = newValue }
  }
}

extension RegisterModule {
  var exchangeUseCaseModule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      ExchangeRateInterface.self,
      repositoryProtocol: ExchangeRateInterface.self,
      repositoryFallback: MockExchangeRepositoryImpl(),
      factory: { repo in
        ExchangeUseCaseImpl(repository: repo)
      }
    )
  }

  var exchangeRepositoryModule: @Sendable () -> Module {
    makeDependency(ExchangeRateInterface.self) {
      ExchangeRepositoryImpl()
    }
  }
}


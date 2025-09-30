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


extension WeaveDI.Container {
  var exchangeUseCase: ExchangeRateInterface? {
    resolve(ExchangeRateInterface.self)
  }
}

extension ExchangeUseCaseImpl: DependencyKey {
   static public var liveValue: ExchangeRateInterface {
    let repository: ExchangeRateInterface = UnifiedDI.register(ExchangeRateInterface.self) {
      ExchangeRepositoryImpl()
    }
    return ExchangeUseCaseImpl(repository: repository)
  }
}

public extension DependencyValues {
  var exchangeUseCase: ExchangeRateInterface {
    get { self[ExchangeUseCaseImpl.self] }
    set { self[ExchangeUseCaseImpl.self] = newValue }
  }
}


extension RegisterModule {
    var exchangeUseCaseModule: @Sendable () -> Module {
      makeUseCaseWithRepository(
        ExchangeRateInterface.self,                    // UseCase 인터페이스
        repositoryProtocol: ExchangeRateInterface.self, // Repository 프로토콜
        repositoryFallback: MockExchangeRepositoryImpl(),    // Fallback 구현체
        factory: { repo in
          ExchangeUseCaseImpl(repository: repo)        // UseCase 생성
        }
      )
    }

    var exchangeRepositoryModule: @Sendable () -> Module {
      makeDependency(ExchangeRateInterface.self) { // Repository 프로토콜로 등록
        ExchangeRepositoryImpl()
      }
    }
  }

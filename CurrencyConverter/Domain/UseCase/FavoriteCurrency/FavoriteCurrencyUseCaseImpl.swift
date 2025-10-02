//
//  FavoriteCurrencyUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import WeaveDI

public struct FavoriteCurrencyUseCaseImpl: FavoriteCurrencyInterface {
  private let repository: FavoriteCurrencyInterface

  nonisolated public init(repository: FavoriteCurrencyInterface) {
    self.repository = repository
  }

  public func fetchFavorites() async throws -> [String] {
    try await repository.fetchFavorites()
  }

  public func toggleFavorite(currencyCode: String) async throws -> [String] {
    try await repository.toggleFavorite(currencyCode: currencyCode)
  }
}

extension FavoriteCurrencyUseCaseImpl: InjectedKey {
  public static var liveValue: FavoriteCurrencyInterface {
    let repository: FavoriteCurrencyInterface = UnifiedDI.register(FavoriteCurrencyInterface.self) {
      FavoriteCurrencyRepositoryImpl()
    }
    return FavoriteCurrencyUseCaseImpl(repository: repository)
  }

  public static var testValue: FavoriteCurrencyInterface {
    FavoriteCurrencyUseCaseImpl(repository: MockFavoriteCurrencyRepositoryImpl())
  }
}


public extension InjectedValues {
  var favoriteCurrencyUseCase: FavoriteCurrencyInterface {
    get { self[FavoriteCurrencyUseCaseImpl.self] }
    set { self[FavoriteCurrencyUseCaseImpl.self] = newValue }
  }
}

extension RegisterModule {
  var favoriteCurrencyRepositoryModule: @Sendable () -> Module {
    makeDependency(FavoriteCurrencyInterface.self) {
      FavoriteCurrencyRepositoryImpl()
    }
  }

  var favoriteCurrencyUseCaseModule: @Sendable () -> Module {
    makeUseCaseWithRepository(
      FavoriteCurrencyInterface.self,
      repositoryProtocol: FavoriteCurrencyInterface.self,
      repositoryFallback: MockFavoriteCurrencyRepositoryImpl(),
      factory: { repository in
        FavoriteCurrencyUseCaseImpl(repository: repository)
      }
    )
  }
}

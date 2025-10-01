//
//  FavoriteCurrencyRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import SwiftData
import WeaveDI

public final class FavoriteCurrencyRepositoryImpl: FavoriteCurrencyInterface {
   private let container: ModelContainer

  nonisolated public init(container: ModelContainer = SwiftDataStack.container()) {
    self.container = container
  }

  public func fetchFavorites() async throws -> [String] {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<FavoriteCurrencyEntity>(
        sortBy: [SortDescriptor(\.code, order: .forward)]
      )
      let entities = try context.fetch(descriptor)
      return entities.map { $0.code }
    }
  }

  public func toggleFavorite(currencyCode: String) async throws -> [String] {
    try await MainActor.run {
      let context = ModelContext(container)
      let predicate = #Predicate<FavoriteCurrencyEntity> { entity in
        entity.code == currencyCode
      }
      let descriptor = FetchDescriptor<FavoriteCurrencyEntity>(predicate: predicate)

      if let existing = try context.fetch(descriptor).first {
        context.delete(existing)
      } else {
        context.insert(FavoriteCurrencyEntity(code: currencyCode))
      }

      try context.save()

      let allDescriptor = FetchDescriptor<FavoriteCurrencyEntity>(
        sortBy: [SortDescriptor(\.code, order: .forward)]
      )
      return try context.fetch(allDescriptor).map { $0.code }
    }
  }
}

//
//  LastViewedScreenRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation
import SwiftData

public final class LastViewedScreenRepositoryImpl: LastViewedScreenInterface {
  private let container: ModelContainer

  nonisolated public init(container: ModelContainer = SwiftDataStack.container()) {
    self.container = container
  }

  public func loadLastViewedScreen() async throws -> LastViewedScreen? {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<LastViewedScreenEntity>(
        predicate: #Predicate { entity in
          entity.key == "last_viewed_screen"
        }
      )
      guard let entity = try context.fetch(descriptor).first else {
        return nil
      }

      let screenType = LastViewedScreenType(rawValue: entity.screenTypeRawValue) ?? .list
      return LastViewedScreen(type: screenType, currencyCode: entity.currencyCode)
    }
  }

  public func updateLastViewedScreen(_ screen: LastViewedScreen) async throws {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<LastViewedScreenEntity>(
        predicate: #Predicate { entity in
          entity.key == "last_viewed_screen"
        }
      )
      let entity = try context.fetch(descriptor).first ?? LastViewedScreenEntity(
        key: LastViewedScreenEntity.storageKey,
        screenTypeRawValue: screen.type.rawValue,
        currencyCode: screen.currencyCode
      )

      entity.screenTypeRawValue = screen.type.rawValue
      entity.currencyCode = screen.currencyCode
      entity.updatedAt = Date()

      if entity.modelContext == nil {
        context.insert(entity)
      }

      try context.save()
    }
  }

  public func clearLastViewedScreen() async throws {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<LastViewedScreenEntity>(
        predicate: #Predicate { entity in
          entity.key == "last_viewed_screen"
        }
      )
      try context.fetch(descriptor).forEach { context.delete($0) }
      if context.hasChanges {
        try context.save()
      }
    }
  }
}

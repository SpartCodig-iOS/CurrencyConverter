//
//  SwiftDataStack.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import SwiftData

public final class SwiftDataStack {
  @MainActor private static let shared = SwiftDataStack()

  private let container: ModelContainer

  @MainActor
  private init() {
    do {
      container = try ModelContainer(
        for: FavoriteCurrencyEntity.self,
        ExchangeRateCacheEntity.self,
        LastViewedScreenEntity.self
      )
    } catch {
      fatalError("Failed to initialize SwiftData container: \(error)")
    }
  }

  public nonisolated static func container() -> ModelContainer {
    MainActor.assumeIsolated { shared.container }
  }
}

//
//  ExchangeRateCacheRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation
import SwiftData

 public final class ExchangeRateCacheRepositoryImpl: ExchangeRateCacheInterface {
  private let container: ModelContainer
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  nonisolated init(container: ModelContainer = SwiftDataStack.container()) {
    self.container = container
  }

   public func loadSnapshot() async throws -> ExchangeRateSnapshot? {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<ExchangeRateCacheEntity>()
      guard let entity = try context.fetch(descriptor).first else { return nil }
      let payload = try decoder.decode(Payload.self, from: entity.snapshot)
      return ExchangeRateSnapshot(
        base: entity.base,
        lastUpdatedAt: entity.lastUpdatedAt,
        rates: payload.rates
      )
    }
  }

   public func saveSnapshot(_ snapshot: ExchangeRateSnapshot) async throws {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<ExchangeRateCacheEntity>()
      let payload = Payload(rates: snapshot.rates)
      let data = try encoder.encode(payload)

      if let existing = try context.fetch(descriptor).first {
        existing.base = snapshot.base
        existing.lastUpdatedAt = snapshot.lastUpdatedAt
        existing.snapshot = data
      } else {
        let entity = ExchangeRateCacheEntity(
          base: snapshot.base,
          lastUpdatedAt: snapshot.lastUpdatedAt,
          snapshot: data
        )
        context.insert(entity)
      }

      try context.save()
    }
  }

   public func clearSnapshot() async throws {
    try await MainActor.run {
      let context = ModelContext(container)
      let descriptor = FetchDescriptor<ExchangeRateCacheEntity>()
      try context.fetch(descriptor).forEach(context.delete)
      try context.save()
    }
  }
}

private struct Payload: Codable {
  let rates: [String: Double]
}

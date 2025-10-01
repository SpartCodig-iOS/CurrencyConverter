//
//  MockFavoriteCurrencyRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

@MainActor
final class MockFavoriteCurrencyRepositoryImpl: FavoriteCurrencyInterface {

  nonisolated public init() {}

  private var storage: Set<String> = []

  func fetchFavorites() async throws -> [String] {
    Array(storage).sorted()
  }

  func toggleFavorite(currencyCode: String) async throws -> [String] {
    if storage.contains(currencyCode) {
      storage.remove(currencyCode)
    } else {
      storage.insert(currencyCode)
    }
    return try await fetchFavorites()
  }
}

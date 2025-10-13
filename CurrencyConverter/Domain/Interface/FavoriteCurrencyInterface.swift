//
//  FavoriteCurrencyInterface.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 10/5/25.
//

import Foundation

public protocol FavoriteCurrencyInterface: Sendable {
  func fetchFavorites() async throws -> [String]
  func toggleFavorite(currencyCode: String) async throws -> [String]
}

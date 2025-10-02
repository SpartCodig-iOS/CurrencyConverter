//
//  Product.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation

// MARK: - Model
struct Product {
  let title: String
  let subtitle: String
  let price: String
  let rate: Double
  let isFavorite: Bool
  let trend: RateTrend
}


//
//  MockLastViewedScreenRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation

@MainActor
final class MockLastViewedScreenRepositoryImpl: LastViewedScreenInterface {
  var storage: LastViewedScreen?

  nonisolated public init(initial: LastViewedScreen? = nil) {
    self.storage = initial
  }

  func loadLastViewedScreen() async throws -> LastViewedScreen? {
    storage
  }

  func updateLastViewedScreen(_ screen: LastViewedScreen) async throws {
    storage = screen
  }

  func clearLastViewedScreen() async throws {
    storage = nil
  }
}

extension MockLastViewedScreenRepositoryImpl {
  static func sampleCalculator() -> MockLastViewedScreenRepositoryImpl {
    MockLastViewedScreenRepositoryImpl(
      initial: LastViewedScreen(type: .calculator, currencyCode: "USD")
    )
  }

  static func sampleList() -> MockLastViewedScreenRepositoryImpl {
    MockLastViewedScreenRepositoryImpl(
      initial: LastViewedScreen(type: .list)
    )
  }
}

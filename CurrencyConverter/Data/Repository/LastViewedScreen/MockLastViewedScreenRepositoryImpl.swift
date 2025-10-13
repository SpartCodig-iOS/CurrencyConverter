//
//  MockLastViewedScreenRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation

@MainActor
public final class MockLastViewedScreenRepositoryImpl: LastViewedScreenInterface {
  public var storage: LastViewedScreen?

  nonisolated public init(initial: LastViewedScreen? = nil) {
    self.storage = initial
  }

  public func loadLastViewedScreen() async throws -> LastViewedScreen? {
    storage
  }

  public func updateLastViewedScreen(_ screen: LastViewedScreen) async throws {
    storage = screen
  }

  public func clearLastViewedScreen() async throws {
    storage = nil
  }
}

extension MockLastViewedScreenRepositoryImpl {
  public static func sampleCalculator() -> MockLastViewedScreenRepositoryImpl {
    MockLastViewedScreenRepositoryImpl(
      initial: LastViewedScreen(type: .calculator, currencyCode: "USD")
    )
  }

  public static func sampleList() -> MockLastViewedScreenRepositoryImpl {
    MockLastViewedScreenRepositoryImpl(
      initial: LastViewedScreen(type: .list)
    )
  }
}

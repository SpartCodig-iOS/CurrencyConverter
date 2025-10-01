//
//  LastViewedScreenInterface.swift
//  CurrencyConverter
//
//  Created by Wonji Suh on 2025/10/10.
//

import Foundation

public protocol LastViewedScreenInterface: Sendable {
  func loadLastViewedScreen() async throws -> LastViewedScreen?
  func updateLastViewedScreen(_ screen: LastViewedScreen) async throws
  func clearLastViewedScreen() async throws
}

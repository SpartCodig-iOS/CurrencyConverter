//
//  ExchangeRepositoryImpl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//


import AsyncMoya
import Moya
import WeaveDI

public class ExchangeRepositoryImpl: ExchangeRateInterface {
   private let provider = MoyaProvider<ExchangeRateService>(plugins: [MoyaLoggingPlugin()])

  nonisolated public init() {

  }

  public func getExchangeRates(currency: String) async throws -> ExchangeRates? {
    let dtos = try await provider.requestAsync(.latest(base: currency), decodeTo: ExchangeRateResponseDTO.self)
    return dtos.toDomain()
  }
}

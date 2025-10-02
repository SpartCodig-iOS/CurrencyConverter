import Foundation
import Testing
import WeaveDI
@testable import CurrencyConverter

@MainActor
struct LastViewedScreenRepositoryMockTests {

  // MARK: - Basic Mock Repository Tests

  @Test(.tags(.mock, .repository))
  func loadReflectsUpdatedScreen_화면갱신_반영() async throws {
    let repository = MockLastViewedScreenRepositoryImpl()
    let initial = try await repository.loadLastViewedScreen()
    #expect(initial == nil)

    let screen = LastViewedScreen(type: .calculator, currencyCode: "JPY")
    try await repository.updateLastViewedScreen(screen)

    let loaded = try await repository.loadLastViewedScreen()
    #expect(loaded == screen)

    try await repository.clearLastViewedScreen()
    let cleared = try await repository.loadLastViewedScreen()
    #expect(cleared == nil)
  }

  @Test(.tags(.mock, .repository))
  func seededCalculatorScreenLoadsImmediately_시드_계산기_즉시로드() async throws {
    let repository = MockLastViewedScreenRepositoryImpl.sampleCalculator()
    let screen = try await repository.loadLastViewedScreen()
    #expect(screen == LastViewedScreen(type: .calculator, currencyCode: "USD"))
  }

  @Test(.tags(.mock, .repository))
  func mockLastViewedScreenRepositoryReturnsNilByDefault_기본값_nil_반환() async throws {
    let repository = MockLastViewedScreenRepositoryImpl()
    let result = try await repository.loadLastViewedScreen()
    #expect(result == nil)
  }

  @Test(.tags(.mock, .repository))
  func mockLastViewedScreenRepositoryUpdatesScreen_화면_업데이트() async throws {
    let repository = MockLastViewedScreenRepositoryImpl()

    let listScreen = LastViewedScreen(type: .list)
    try await repository.updateLastViewedScreen(listScreen)

    let loaded1 = try await repository.loadLastViewedScreen()
    #expect(loaded1 == listScreen)

    let calculatorScreen = LastViewedScreen(type: .calculator, currencyCode: "EUR")
    try await repository.updateLastViewedScreen(calculatorScreen)

    let loaded2 = try await repository.loadLastViewedScreen()
    #expect(loaded2 == calculatorScreen)
    #expect(loaded2 != listScreen)
  }

  @Test(.tags(.mock, .repository))
  func mockLastViewedScreenRepositorySampleList_샘플_리스트() async throws {
    let repository = MockLastViewedScreenRepositoryImpl.sampleList()
    let screen = try await repository.loadLastViewedScreen()
    #expect(screen == LastViewedScreen(type: .list))
  }

  @Test(.tags(.mock, .repository))
  func mockLastViewedScreenRepositoryHandlesDifferentScreenTypes_다양한_화면_처리() async throws {
    let repository = MockLastViewedScreenRepositoryImpl()

    // 리스트 화면 테스트
    let listScreen = LastViewedScreen(type: .list)
    try await repository.updateLastViewedScreen(listScreen)
    let loadedList = try await repository.loadLastViewedScreen()
    #expect(loadedList?.type == .list)
    #expect(loadedList?.currencyCode == nil)

    // 계산기 화면 테스트
    let calculatorScreen = LastViewedScreen(type: .calculator, currencyCode: "KRW")
    try await repository.updateLastViewedScreen(calculatorScreen)
    let loadedCalculator = try await repository.loadLastViewedScreen()
    #expect(loadedCalculator?.type == .calculator)
    #expect(loadedCalculator?.currencyCode == "KRW")
  }

  // MARK: - @Injected testValue Tests

  @Test(.tags(.useCase, .mock, .repository, .testValue))
  func testInjectedTestValueUsesDefaultMockRepository_testValue_기본_Mock() async throws {
    // testValue를 직접 사용하여 Mock이 제대로 작동하는지 확인
    let testUseCase = LastViewedScreenUseCaseImpl.testValue
    let result = try await testUseCase.loadLastViewedScreen()
    #expect(result == nil) // 기본값은 nil
  }

  @Test(.tags(.useCase, .mock, .repository))
  func testInjectedTestValueUpdateAndLoadScreen_화면_업데이트_로드() async throws {
    let customMock = MockLastViewedScreenRepositoryImpl()
    let customUseCase = LastViewedScreenUseCaseImpl(repository: customMock)

    let testScreen = LastViewedScreen(type: .calculator, currencyCode: "GBP")

    try await customUseCase.updateLastViewedScreen(testScreen)

    let loadedScreen = try await customUseCase.loadLastViewedScreen()
    #expect(loadedScreen == testScreen)
  }

  @Test(.tags(.useCase, .mock, .repository))
  func testInjectedTestValueClearScreen_화면_초기화() async throws {
    let customMock = MockLastViewedScreenRepositoryImpl()
    let customUseCase = LastViewedScreenUseCaseImpl(repository: customMock)

    let testScreen = LastViewedScreen(type: .list)

    try await customUseCase.updateLastViewedScreen(testScreen)

    let beforeClear = try await customUseCase.loadLastViewedScreen()
    #expect(beforeClear != nil)

    try await customUseCase.clearLastViewedScreen()

    let afterClear = try await customUseCase.loadLastViewedScreen()
    #expect(afterClear == nil)
  }

  @Test(.tags(.useCase, .mock, .repository))
  func testInjectedTestValueWithPreSeededData_시드데이터_확인() async throws {
    let preSeededScreen = LastViewedScreen(type: .calculator, currencyCode: "CAD")
    let customMock = MockLastViewedScreenRepositoryImpl(initial: preSeededScreen)
    let customUseCase = LastViewedScreenUseCaseImpl(repository: customMock)

    let loadedScreen = try await customUseCase.loadLastViewedScreen()
    #expect(loadedScreen == preSeededScreen)

    // 새로운 화면으로 업데이트
    let newScreen = LastViewedScreen(type: .list)
    try await customUseCase.updateLastViewedScreen(newScreen)

    let updatedScreen = try await customUseCase.loadLastViewedScreen()
    #expect(updatedScreen == newScreen)
    #expect(updatedScreen != preSeededScreen)
  }

  @Test(.tags(.useCase, .mock, .repository))
  func testInjectedTestValueSampleFactoryMethods_샘플팩토리_검증() async throws {
    // Sample Calculator
    let calculatorRepository = MockLastViewedScreenRepositoryImpl.sampleCalculator()
    let calculatorUseCase = LastViewedScreenUseCaseImpl(repository: calculatorRepository)

    let calculatorScreen = try await calculatorUseCase.loadLastViewedScreen()
    #expect(calculatorScreen?.type == .calculator)
    #expect(calculatorScreen?.currencyCode == "USD")

    // Sample List
    let listRepository = MockLastViewedScreenRepositoryImpl.sampleList()
    let listUseCase = LastViewedScreenUseCaseImpl(repository: listRepository)

    let listScreen = try await listUseCase.loadLastViewedScreen()
    #expect(listScreen?.type == .list)
    #expect(listScreen?.currencyCode == nil)
  }

  @Test(.tags(.useCase, .mock, .repository))
  func testInjectedTestValueMultipleOperations_연속_작업() async throws {
    let customMock = MockLastViewedScreenRepositoryImpl()
    let customUseCase = LastViewedScreenUseCaseImpl(repository: customMock)

    // 연속적인 화면 변경 시뮬레이션
    let screens = [
      LastViewedScreen(type: .list),
      LastViewedScreen(type: .calculator, currencyCode: "USD"),
      LastViewedScreen(type: .calculator, currencyCode: "EUR"),
      LastViewedScreen(type: .list)
    ]

    for screen in screens {
      try await customUseCase.updateLastViewedScreen(screen)
      let loaded = try await customUseCase.loadLastViewedScreen()
      #expect(loaded == screen)
    }

    // 마지막 화면이 올바르게 저장되었는지 확인
    let finalScreen = try await customUseCase.loadLastViewedScreen()
    #expect(finalScreen?.type == .list)
    #expect(finalScreen?.currencyCode == nil)
  }
}

import Foundation
import Testing
import ComposableArchitecture
@testable import CurrencyConverter

@MainActor
struct CalculatorReducerTests {

  @Test(.tags(.calculatorReducer))
  func onAppearPopulatesCurrencyNameAndSummary_온어피어_통화정보() async throws {
    var state = CalculatorReducer.State(
      currencyCode: "JPY",
      exchangeRate: 133.25,
      baseCurrencyCode: "USD"
    )
    state.amount = "100"

    let expectedCurrencyName = Locale(identifier: "ko_KR").currencyDisplayName(for: "JPY")

    let store = TestStore(initialState: state) {
      CalculatorReducer()
    }

    await store.send(.view(.onAppear)) {
      $0.currencyName = expectedCurrencyName
      $0.conversionSummary = "100.00 USD → 0.00 JPY"
      $0.errorMessage = nil
    }

    await store.finish()
  }

  @Test(.tags(.calculatorReducer))
  func amountChangedEmptyClearsConversion_금액비움_초기화() async throws {
    var state = CalculatorReducer.State(
      currencyCode: "JPY",
      exchangeRate: 133.25,
      baseCurrencyCode: "USD"
    )
    state.amount = "123"
    state.convertedAmount = 50
    state.convertedAmountText = "50.00"
    state.conversionSummary = "123.00 USD → 50.00 JPY"

    let store = TestStore(initialState: state) {
      CalculatorReducer()
    }

    await store.send(.view(.amountChanged(""))) {
      $0.amount = ""
    }

    await store.receive(.inner(.setError(nil)))

    await store.receive(.inner(.clearConversion)) {
      $0.convertedAmount = 0
      $0.convertedAmountText = "0.00"
      $0.conversionSummary = ""
    }

    await store.finish()
  }

  @Test(.tags(.calculatorReducer))
  func amountChangedInvalidShowsError_금액잘못됨_오류() async throws {
    let store = TestStore(
      initialState: CalculatorReducer.State(
        currencyCode: "JPY",
        exchangeRate: 133.25,
        baseCurrencyCode: "USD"
      )
    ) {
      CalculatorReducer()
    }

    await store.send(.view(.amountChanged("abc"))) {
      $0.amount = "abc"
    }

    await store.receive(.inner(.setError(nil)))

    await store.receive(.inner(.clearConversion))

    await store.receive(.inner(.setError("올바른 숫자를 입력해주세요"))) {
      $0.errorMessage = "올바른 숫자를 입력해주세요"
      $0.errorToken = 1
    }

    await store.finish()
  }

  @Test(.tags(.calculatorReducer))
  func calculateButtonTappedWithValidAmountUpdatesConversion_계산버튼_정상계산() async throws {
    var state = CalculatorReducer.State(
      currencyCode: "JPY",
      exchangeRate: 133.25,
      baseCurrencyCode: "USD"
    )
    state.amount = "2"

    let store = TestStore(initialState: state) {
      CalculatorReducer()
    }

    await store.send(.view(.calculateButtonTapped))

    await store.receive(.inner(.setError(nil)))

    await store.receive(.inner(.updateConvertedAmount(2))) {
      $0.convertedAmount = 266.5
      $0.convertedAmountText = "266.50"
      $0.conversionSummary = "2.00 USD → 266.50 JPY"
    }

    await store.finish()
  }

  @Test(.tags(.calculatorReducer))
  func calculateButtonTappedWithEmptyAmountShowsPrompt_계산버튼_입력요청() async throws {
    let store = TestStore(
      initialState: CalculatorReducer.State(
        currencyCode: "JPY",
        exchangeRate: 133.25,
        baseCurrencyCode: "USD"
      )
    ) {
      CalculatorReducer()
    }

    await store.send(.view(.calculateButtonTapped))

    await store.receive(.inner(.setError(nil)))

    await store.receive(.inner(.clearConversion))

    await store.receive(.inner(.setError("금액을 입력해주세요"))) {
      $0.errorMessage = "금액을 입력해주세요"
      $0.errorToken = 1
    }

    await store.finish()
  }
}

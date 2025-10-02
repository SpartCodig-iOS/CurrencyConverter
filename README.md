# CurrencyConverter
스파르타 캠프에서 진행한 환율 계산기 앱입니다. 숫자 데이터를 사람이 이해하기 쉬운 UI로 바꾸고, 사용자의 맥락을 잃지 않도록 상태를 저장·복원하는 데 초점을 맞췄습니다.

## 핵심 기능
- **환율 트렌드 아이콘 (Level 8)**: 이전 스냅샷과 최신 환율을 비교해 상승 🔼 / 하락 🔽 / 보합 여부를 표시합니다. 변동량이 `±0.01` 이하일 때는 아이콘 대신 정렬용 여백만 두어 UI가 흔들리지 않도록 했습니다.
- **앱 상태 저장 & 복원 (Level 10)**: 마지막으로 본 화면(리스트/계산기)과 통화 정보를 SwiftData에 저장해, 앱을 재시작해도 즉시 동일한 맥락으로 복귀합니다. 계산기의 입력 값과 결과는 일시적 상태로 간주해 저장하지 않습니다.
- **환율 캐시 스냅샷**: 최신 환율을 네트워크에서 가져오기 전까지 캐시된 데이터를 먼저 노출해 초기 표시 속도를 높였습니다.

## Level 11 – 메모리 이슈 디버깅 경험
Combine 바인딩 과정에서 `CurrencyViewController`가 메모리에서 해제되지 않는 누수를 발견했습니다. 문제 정의 → 분석 → 해결 → 검증까지 Xcode 툴을 활용해 정리했습니다.

### 1. 문제 정의
- **증상**: 환율 목록 → 계산기 화면 전환 후, 화면을 닫아도 `CurrencyViewController` 인스턴스가 메모리에 남아 있음.
- **기대 행동**: 네비게이션 스택에서 pop되면 ViewController가 즉시 해제되어야 함.

### 2. 분석 과정 (Xcode Memory Graph Debugger)
1. 시뮬레이터에서 목록 ↔ 계산기 화면을 반복 전환.
2. Memory Graph Debugger 실행 → pop 후에도 `CurrencyViewController` 인스턴스가 존재.
3. 그래프를 따라가 보니 `CurrencyViewController → BaseViewController.cancellables → AnyCancellable → Combine 클로저 → CurrencyViewController` 경로로 강한 참조 순환이 형성.

### 3. 추가 검증 (Instruments – Leaks)
- 동일 시나리오를 Instruments Leaks로 추적.
- `BaseViewController.bindErrorHandling()` 구독이 종료되지 않아 누수가 지속되는 것을 재확인.
- Leaks 타임라인에서 동일 주소의 `CurrencyViewController`가 반복적으로 살아 있는 것을 확인.

### 4. 근본 원인 & 코드 수정
- `bindErrorHandling()` 내부 `compactMap` 클로저가 `self`를 강하게 캡처.
- `cancellables`가 `AnyCancellable`을 강하게 보유하면서 View → Combine → View 구조가 순환 참조를 만듦.

```swift
private func bindErrorHandling() {
  viewStore.publisher
    .compactMap { $0.errorMessage }
    .sink { [weak self] message in
      guard let self else { return }
      self.presentError(message)
    }
    .store(in: &cancellables)
}
```
- `[weak self]`로 수정해 Combine 클로저가 ViewController를 약하게 캡처하도록 변경.

### 5. 해결 전/후 비교
| 단계 | 도구 | 결과 |
| --- | --- | --- |
| 수정 전 | Memory Graph Debugger | Pop 후에도 `CurrencyViewController`가 해제되지 않음 |
| 수정 전 | Instruments (Leaks) | 동일 인스턴스의 누수가 계속 보고됨 |
| 수정 후 | Memory Graph Debugger | 화면 전환 후 컨트롤러가 즉시 해제되는 것을 확인 |
| 수정 후 | Instruments (Leaks) | 누수 항목이 사라지고 메모리 사용량이 안정 유지 |

> 위 과정을 통해 View ↔ Combine 구독 간 강한 참조 순환을 해소했고, 화면 전환을 반복해도 컨트롤러가 즉시 해제되는 것을 확인했습니다.

## 아키텍처 & 기술 스택
| 계층 | 기술 |
| --- | --- |
| 상태 관리 | TCA (Composable Architecture) |
| 데이터 저장 | SwiftData (`@Model` + ModelContext) |
| 네트워크/도메인 | Repository + UseCase 계층 구조 |
| UI 레이아웃 | FlexLayout, PinLayout |
| 테스트 | Xcode `.xctestplan` (swift-testing) |

## 실행 방법
1. `CurrencyConverter.xcodeproj`를 Xcode에서 열기
2. Scheme `CurrencyConverter` 선택 후 실행 (`⌘ + R`)
3. 테스트는 `CurrencyConverter.xctestplan`을 이용해 전체 실행 (`⌘ + U`)

> ⚠️ 프로젝트는 Swift Package Manager 기반이 아니므로 `swift test`는 사용하지 않습니다.

## 환율 트렌드 계산 흐름
```swift
private func computeTrends(
  newRates: [String: Double],
  previousRates: [String: Double]
) -> [String: RateTrend] {
  newRates.reduce(into: [String: RateTrend]()) { result, entry in
    let previous = previousRates[entry.key] ?? entry.value
    let diff = entry.value - previous
    result[entry.key] = RateTrend(difference: diff)
  }
}
```

## SwiftData 저장 전략
```swift
@Model
final class LastViewedScreenEntity {
  @Attribute(.unique) var id: String = "singleton"
  var type: ScreenType
  var currencyCode: String?
  var exchangeRate: Double?

  init(type: ScreenType, currencyCode: String?, exchangeRate: Double?) {
    self.type = type
    self.currencyCode = currencyCode
    self.exchangeRate = exchangeRate
  }
}

func persistLastScreen(_ screen: LastViewedScreen, context: ModelContext) async {
  await context.perform {
    try? context.delete(model: LastViewedScreenEntity.self)
    let entity = LastViewedScreenEntity(
      type: screen.type,
      currencyCode: screen.currencyCode,
      exchangeRate: screen.exchangeRate
    )
    context.insert(entity)
    try? context.save()
  }
}
```

## ProductCell 레이아웃 조정
```swift
row.addItem(priceLabel).shrink(0).marginLeft(4)
row.addItem(trendImageView)
  .width(Layout.trendWidth)
  .height(Layout.trendWidth)
  .marginLeft(4)
```


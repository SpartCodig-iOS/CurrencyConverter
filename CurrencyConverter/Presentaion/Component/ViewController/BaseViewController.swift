//
//  BaseViewController.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit

@preconcurrency import Combine
import ComposableArchitecture

open class BaseViewController<
  RootView: UIView,
  Feature: Reducer
>: UIViewController where Feature.State: Equatable {

  // MARK: - Properties
  /// 루트 뷰 인스턴스
  public let rootView: RootView

  /// TCA Store
  public let store: StoreOf<Feature>

  /// ViewStore for observing state
  public let viewStore: ViewStoreOf<Feature>

  /// Combine cancellables - 메모리 관리 최적화
  public var cancellables: Set<AnyCancellable> = []

  // MARK: - Performance Monitoring

  #if DEBUG
  private var performanceTimer: CFAbsoluteTime = 0
  #endif

  // MARK: - Initialization

  public init(rootView: RootView, store: StoreOf<Feature>) {
    self.rootView = rootView
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  open override func loadView() {
    view = rootView
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    #if DEBUG
    performanceTimer = CFAbsoluteTimeGetCurrent()
    #endif

    setupView()
    configureUI()
    bindActions()
    bindState()

  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

  }

  // MARK: - Memory Management

  deinit {
    // Combine cancellables 정리
    cancellables.removeAll()
  }

  // MARK: - Setup Methods

  /// 뷰의 기본 설정 (배경색, 기본 속성 등)
  open func setupView() {
    view.backgroundColor = UIColor.appBackground
  }

  /// UI 구성 등 추가 설정
  /// 서브클래스에서 오버라이드하여 사용
  open func configureUI() {
    // Override in subclass
  }

  /// 액션 바인딩
  /// 서브클래스에서 오버라이드하여 UI 액션을 TCA 액션으로 연결
  open func bindActions() {
    // Override in subclass
  }

  /// 상태 바인딩
  /// 서브클래스에서 오버라이드하여 TCA 상태를 UI에 반영
  open func bindState() {
    // 기본 에러 처리 바인딩
    bindErrorHandling()
  }

  // MARK: - Error Handling

  /// 글로벌 에러 처리를 위한 기본 바인딩
  private func bindErrorHandling() {
    // TCA Store의 에러를 감지하고 처리
    viewStore.publisher
      .compactMap { state -> String? in
        // Feature.State에 error 프로퍼티가 있다면 추출
        // 서브클래스에서 오버라이드하여 구체적인 에러 추출 로직 구현
        return self.extractError(from: state)
      }
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] errorMessage in
        self?.handleError(errorMessage)
      }
      .store(in: &cancellables)
  }

  /// Feature State에서 에러 추출 (서브클래스에서 오버라이드)
  open func extractError(from state: Feature.State) -> String? {
    // 서브클래스에서 구체적인 에러 추출 로직 구현
    return nil
  }

  /// 에러 처리 (서브클래스에서 오버라이드 가능)
  open func handleError(_ errorMessage: String) {
    #if DEBUG
    print("🚨 [\(String(describing: type(of: self)))] Error: \(errorMessage)")
    #endif

    // 기본 에러 처리: 알림 표시
    showErrorAlert(message: errorMessage)
  }

  /// 에러 알림 표시
  private func showErrorAlert(message: String) {
    let alert = UIAlertController(
      title: "오류",
      message: message,
      preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "확인", style: .default))

    // 메인 스레드에서 실행 보장
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true)
    }
  }

  // MARK: - Performance Utilities

  /// ViewStore 구독 최적화 헬퍼
  public func optimizedPublisher<T: Equatable>(
    _ keyPath: KeyPath<Feature.State, T>
  ) -> AnyPublisher<T, Never> {
    return viewStore.publisher
      .map { $0[keyPath: keyPath] }
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  /// Optional 타입을 위한 ViewStore 구독 최적화 헬퍼
  public func optimizedPublisher<T: Equatable>(
    _ keyPath: KeyPath<Feature.State, T?>
  ) -> AnyPublisher<T?, Never> {
    return viewStore.publisher
      .map { $0[keyPath: keyPath] }
      .removeDuplicates { lhs, rhs in
        switch (lhs, rhs) {
        case let (l?, r?):
          return l == r
        case (nil, nil):
          return true
        default:
          return false
        }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  /// 안전한 액션 전송 (에러 처리 포함)
  /// 안전한 액션 전송 (로그 + 공통 후처리 훅)
  @MainActor
  public func safeSend(_ action: Feature.Action) {
    store.send(action)
    #if DEBUG
    print(" [\(String(describing: type(of: self)))] Action sent: \(action)")
    #endif
  }
}

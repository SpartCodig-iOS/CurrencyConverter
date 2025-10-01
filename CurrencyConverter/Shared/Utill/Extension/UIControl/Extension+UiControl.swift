//
//  Extension+UiControl.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/30/25.
//

import Foundation
import UIKit
import Combine

public extension UIControl {
  func publisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
    ControlEventPublisher(control: self, events: events).eraseToAnyPublisher()
  }
}

private final class ControlEventSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
  private var subscriber: S?
  weak var control: UIControl?
  let events: UIControl.Event

  init(subscriber: S, control: UIControl, events: UIControl.Event) {
    self.subscriber = subscriber
    self.control = control
    self.events = events
    control.addTarget(self, action: #selector(eventHandler), for: events)
  }

  func request(_ demand: Subscribers.Demand) { /* no-op */ }

  func cancel() {
    control?.removeTarget(self, action: #selector(eventHandler), for: events)
    subscriber = nil
  }

  @objc private func eventHandler() {
    _ = subscriber?.receive(())
  }
}

private struct ControlEventPublisher: Publisher {
  typealias Output = Void
  typealias Failure = Never

  let control: UIControl
  let events: UIControl.Event

  func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
    let subscription = ControlEventSubscription(subscriber: subscriber, control: control, events: events)
    subscriber.receive(subscription: subscription)
  }
}

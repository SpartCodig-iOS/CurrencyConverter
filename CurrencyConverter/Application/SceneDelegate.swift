//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit
import ComposableArchitecture
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  @MainActor
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)

    let lastViewed = fetchLastViewedScreen()

    let store = Store(initialState: RootReducer.State(currency: CurrencyReducer.State())) {
      RootReducer()
        ._printChanges()
    }

    let rootVC = RootViewController(store: store)
    rootVC.navigationBar.prefersLargeTitles = false

    window.rootViewController = rootVC
    window.makeKeyAndVisible()
    self.window = window

    if let lastViewed, lastViewed.type == .calculator {
      store.send(.currency(.inner(.setPendingRestoration(lastViewed))))
    }
  }



}

@MainActor
private extension SceneDelegate {
  func fetchLastViewedScreen() -> LastViewedScreen? {
    do {
      let context = ModelContext(SwiftDataStack.container())
      let descriptor = FetchDescriptor<LastViewedScreenEntity>(
        predicate: #Predicate { entity in
          entity.key == "last_viewed_screen"
        }
      )

      guard let entity = try context.fetch(descriptor).first,
            let type = LastViewedScreenType(rawValue: entity.screenTypeRawValue) else {
        return nil
      }

      return LastViewedScreen(type: type, currencyCode: entity.currencyCode)
    } catch {
      print("[SceneDelegate] Failed to fetch last viewed screen: \(error)")
      return nil
    }
  }
}

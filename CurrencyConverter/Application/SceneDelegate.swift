//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)

    let store = Store(initialState: CurrencyReducer.State()) {
      CurrencyReducer()
        ._printChanges()
    }

    window.rootViewController = CurrencyViewController(store: store)
    window.makeKeyAndVisible()
    self.window = window
  }



}


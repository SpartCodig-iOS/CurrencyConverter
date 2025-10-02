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

    let store = Store(initialState: RootReducer.State()) {
      RootReducer()
        ._printChanges()
    }

    let rootVC = RootViewController(store: store)
    rootVC.navigationBar.prefersLargeTitles = false

    window.rootViewController = rootVC
    window.makeKeyAndVisible()
    self.window = window
  }



}


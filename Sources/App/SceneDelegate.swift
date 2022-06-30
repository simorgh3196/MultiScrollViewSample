//
//  SceneDelegate.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/21.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      window = UIWindow(windowScene: windowScene)

//      window!.rootViewController = CollectionBaseViewController()
//      window!.rootViewController = StackBaseViewController()
      window!.rootViewController = MultiScrollViewController()

      window!.makeKeyAndVisible()
    }
  }
}

//
//  AppDelegate.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/21.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    true
  }

  // MARK: UISceneSession Lifecycle

  func application(_: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
}

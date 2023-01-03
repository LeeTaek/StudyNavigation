//
//  AppDelegate.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/01.
//

import UIKit
import NuguClientKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var appCoordinator: AppCoordinator?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    window = UIWindow.init(frame: UIScreen.main.bounds)
    let navController = UINavigationController()
    
    appCoordinator = AppCoordinator.init(navigationContorller: navController)
    appCoordinator?.start()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
    
    // NuguSDK ConfigurationStore init
    ConfigurationStore.shared.configure()
    
    return true
  }



}


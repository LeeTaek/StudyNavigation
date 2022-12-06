//
//  TabCoordinator.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/06.
//

import Foundation
import UIKit

enum TabBarPage {
  case counter
  case nfc
  
  init?(index: Int) {
    switch index {
    case 0:
      self = .counter
    case 1:
      self = .nfc
    default:
      return nil
    }
  }
  
  func pageTitleValue() -> String {
    switch self {
    case .counter:
      return "counter"
    case .nfc:
      return "nfc"
    }
    
  }
  
  func pageOrderNumber() -> Int {
    switch self {
    case .counter:
      return 0
    case .nfc:
      return 1
    }
  }
}


protocol TabCoordinatorProtocol: Coordinator {
  // tabBarController
  var tabBarController: UITabBarController { get set }
  
  func selectedPage(_ page: TabBarPage)
  
  func setSelectedIndex(_ index: Int)
  
  func currentPage() -> TabBarPage?
  
}


class TabCoordinator: NSObject, TabCoordinatorProtocol {
  var tabBarController: UITabBarController
  
  func selectedPage(_ page: TabBarPage) {
    tabBarController.selectedIndex = page.pageOrderNumber()
  }
  
  func setSelectedIndex(_ index: Int) {
    guard let page = TabBarPage.init(index: index) else { return }
    tabBarController.selectedIndex = page.pageOrderNumber()
  }
  
  func currentPage() -> TabBarPage? {
    TabBarPage.init(index: tabBarController.selectedIndex)
  }
  
  weak var finishDelegate: CoordinatorFinishDelegate?
  
  var childCoordinators: [Coordinator] = []
  
  var navigationContorller: UINavigationController
  
  var type: CoordinatorType { .main }
  
  required init(navigationController: UINavigationController) {
    self.navigationContorller = navigationController
    self.tabBarController = .init()
  }
  
  
  func start() {
    let pages: [TabBarPage] = [.counter, .nfc]
      .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
    let controllers: [UINavigationController] = pages.map({ getTabController($0)} )
        
    prepareTabBarController(withTabControllers: controllers)
    
    
    
  }
  
  
  // 해당 탭에 따른 ViewController 띄우기,
  private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
    tabBarController.delegate = self

    tabBarController.setViewControllers(tabControllers, animated: true)
    
    tabBarController.selectedIndex = TabBarPage.counter.pageOrderNumber()
    
    tabBarController.tabBar.isTranslucent = false
    
    navigationContorller.viewControllers = [tabBarController]
  }
  
  
  // Tabbar index에 따른 ViewController 리턴
  private func getTabController(_ page: TabBarPage) -> UINavigationController {
    let navController = UINavigationController()
    navController.setNavigationBarHidden(false, animated: false)
    
    navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue(), image: nil, tag: page.pageOrderNumber())
    
    switch page {
    case .counter:
      let counterVC = ViewController()
      let counterCoordinator = CounterCoordinator(navigationContorller: navigationContorller)
      counterCoordinator.finishDelegate = self
      childCoordinators.append(counterCoordinator)
      counterVC.coordinator = counterCoordinator
      navController.pushViewController(counterVC, animated: true)
            
    case .nfc:
      let nfcVC = NFCViewController()
      
      navController.pushViewController(nfcVC, animated: true)
    }
    
    return navController
  }
  
  
  
  
}

extension TabCoordinator: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    
  }
}

extension TabCoordinator: CoordinatorFinishDelegate {
  func coordinatorDidFinish(childCoordinator: Coordinator) {
    for (index, coordinator) in childCoordinators.enumerated() {
      if coordinator === childCoordinator {
        childCoordinators.remove(at: index)
        break
      }
    }
  }
}

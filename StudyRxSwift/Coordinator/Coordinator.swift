//
//  MainCoordinator.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/05.
//

import Foundation
import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
  // 자식이 finish 됐을 때에 알 수 있도록 돕는 delegate 프로토콜
  var finishDelegate: CoordinatorFinishDelegate? { get set }
  // 하위 코디네이터를 추적하는 배열
  var childCoordinators: [Coordinator] { get set }
  // ViewController
  var navigationContorller: UINavigationController { get set }
  // Coordinator 타입
  var type: CoordinatorType { get }
  
  func start()
  func finish()
}

// finish 메소드
extension Coordinator {
  func finish() {
    childCoordinators.removeAll()
    finishDelegate?.coordinatorDidFinish(childCoordinator: self)
  }
}

protocol CoordinatorFinishDelegate: AnyObject {
  func coordinatorDidFinish(childCoordinator: Coordinator)
}

enum CoordinatorType {
  case main
}





//
//// MARK: - mainCoordinator
//class TabCoordinator: NSObject, Coordinator {
//  var finishDelegate: CoordinatorFinishDelegate?
//
//  var type: CoordinatorType
//
//  var childCoordinators = [Coordinator]()
//
//  var navigationContorller: UINavigationController
//
//  init(navController: UINavigationController) {
//    self.navigationContorller = navController
//  }
//
//  func start() {
//    let vc = ViewController()
//    vc.coordinator = self
//    navigationContorller.delegate = self
//    navigationContorller.pushViewController(vc, animated: true)
//  }
//
//  func gotoSecondView() {
//    let child = SubCoordinator(navController: navigationContorller)
//    child.parentCoordinator = self
//    childCoordinators.append(child)
//    child.start()
//  }
//
//  func SecondViewDidFinish(_ child: Coordinator?) {
//    for (index, coordinator) in childCoordinators.enumerated() {
//      if coordinator === child {
//        childCoordinators.remove(at: index)
//        break
//      }
//    }
//
//  }
//}
//
//extension TabCoordinator: UINavigationControllerDelegate {
//
//  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//    guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
//      return
//    }
//
//    if navigationController.viewControllers.contains(fromViewController){
//      return
//    }
//
//    if let second = fromViewController as? SecondViewController {
//      SecondViewDidFinish(second.coordinator)
//    }
//  }
//}
//
//
//
//
//
//class SubCoordinator: Coordinator {
//  var finishDelegate: CoordinatorFinishDelegate?
//
//  var type: CoordinatorType
//
//  weak var parentCoordinator: TabCoordinator?
//  var childCoordinators = [Coordinator]()
//
//  var navigationContorller: UINavigationController
//
//  init(navController: UINavigationController) {
//    self.navigationContorller = navController
//  }
//
//  func start() {
//    let vc = SecondViewController()
//    vc.coordinator = self
//    navigationContorller.pushViewController(vc, animated: true)
//  }
//}

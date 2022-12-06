//
//  MainCoordinator.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/05.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
  var childCoordinators: [Coordinator] { get set }
  var navigationContorller: UINavigationController { get set }
  
  func start()
}

class MainCoordinator: NSObject, Coordinator {
  var childCoordinators = [Coordinator]()
  
  var navigationContorller: UINavigationController
  
  init(navController: UINavigationController) {
    self.navigationContorller = navController
  }
  
  func start() {
    let vc = ViewController()
    vc.coordinator = self
    navigationContorller.delegate = self
    navigationContorller.pushViewController(vc, animated: true)
  }
  
  func gotoSecondView() {
    let child = SubCoordinator(navController: navigationContorller)
    child.parentCoordinator = self
    childCoordinators.append(child)
    child.start()
  }
  
  func SecondViewDidFinish(_ child: Coordinator?) {
    for (index, coordinator) in childCoordinators.enumerated() {
      if coordinator === child {
        childCoordinators.remove(at: index)
        break
      }
    }
    
  }
}

extension MainCoordinator: UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
      return
    }
    
    if navigationController.viewControllers.contains(fromViewController){
      return
    }
    
    if let second = fromViewController as? SecondViewController {
      SecondViewDidFinish(second.coordinator)
    }
  }
}





class SubCoordinator: Coordinator {
  weak var parentCoordinator: MainCoordinator?
  var childCoordinators = [Coordinator]()
  
  var navigationContorller: UINavigationController
  
  init(navController: UINavigationController) {
    self.navigationContorller = navController
  }
  
  func start() {
    let vc = SecondViewController()
    vc.coordinator = self
    navigationContorller.pushViewController(vc, animated: true)
  }
}

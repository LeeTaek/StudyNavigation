//
//  CounterCoordinator.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/06.
//

import Foundation
import UIKit

protocol CounterCoordinatorProtocol: Coordinator {
  
  func pushMainVC()
  func pushSecondVC()
}


class CounterCoordinator: NSObject, CounterCoordinatorProtocol {
  
  weak var finishDelegate: CoordinatorFinishDelegate?
  
  var childCoordinators: [Coordinator] = []
  
  var navigationContorller: UINavigationController
  
  var type: CoordinatorType { .main }
  
  required init(navigationContorller: UINavigationController) {
    self.navigationContorller = navigationContorller
  }
  
  func start() {
    pushSecondVC()
  }
  
  func pushMainVC() {
    let counterVC = ViewController()
    counterVC.coordinator = self
    navigationContorller.delegate = self
    navigationContorller.pushViewController(counterVC, animated: true)
  }
  
  func pushSecondVC() {
    let secondVC = SecondViewController()
    secondVC.coordinator = self
    navigationContorller.delegate = self
    navigationContorller.pushViewController(secondVC, animated: true)
  }

  deinit {
    print("CounterCoordinator deinit")
  }
  
}

extension CounterCoordinator: UINavigationControllerDelegate {
  
}

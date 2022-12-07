//
//  AppCoordinator.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/06.
//

import Foundation
import UIKit

/*
  앱 시작 시 초기 컨트롤러를 연결하기 위한 코디네이터
  그 후 상태에 따른 코디네이터를 연결해 Flow를 진행한다.
  ex. 앱 처음 실행시 튜토리얼, 비로그인 시에 로그인 등
 
  AppDelegate에서 전달받은 window의 ViewContorller를 연결
 */

protocol AppCoordinatorProtocol: Coordinator {
  // mainFlow Coordinator 연결
  // 앱 실행 시 튜토리얼이나 로그인과 같은 화면 있다면 여기서 해당 flow 추가
  func showMainFlow()
}

class AppCoordinator: AppCoordinatorProtocol {
  weak var finishDelegate: CoordinatorFinishDelegate? = nil
  
  var childCoordinators = [Coordinator]()
  
  var navigationContorller: UINavigationController
  
  var type: CoordinatorType { .main }
  
  required init(navigationContorller: UINavigationController) {
    self.navigationContorller = navigationContorller
    navigationContorller.setNavigationBarHidden(true, animated: true)
  }
  
  func start() {
    showMainFlow()
  }
  
  // TabCoordinator 로 연결
  func showMainFlow() {
    let tabCoordinator = TabCoordinator.init(navigationController: navigationContorller)
    tabCoordinator.finishDelegate = self
    tabCoordinator.start()
    childCoordinators.append(tabCoordinator)
  }
  
}



extension AppCoordinator: CoordinatorFinishDelegate {
  func coordinatorDidFinish(childCoordinator: Coordinator) {
    childCoordinators = childCoordinators.filter({
      $0.type != childCoordinator.type
    })
    
    switch childCoordinator.type {
    case .main:
      navigationContorller.viewControllers.removeAll()
      
    }
  }
}

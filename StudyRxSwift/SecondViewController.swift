//
//  SecondViewController.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/05.
//

import UIKit

class SecondViewController: UIViewController {
  weak var coordinator: SubCoordinator?
  
  var text: UILabel = {
    var text = UILabel()
    text.text = "SecondViewController!"
    return text
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupLayout()
  }
    
  func setupView() {
    view.addSubview(text)
  }
  
  func setupLayout() {
    text.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.center.equalToSuperview()
      
    }
  }
  
  
}

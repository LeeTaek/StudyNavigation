//
//  ViewController.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/01.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {
  var testLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    return label
  }()
  
  var testButton: UIButton = {
    let button = UIButton()
    button.setTitle("버튼", for: .normal)
    return button
  }()

  weak var coordinator: CounterCoordinator?
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupLayout()
    timer()
    
    testButton.rx.tap
      .bind{
        self.coordinator?.start()
        print("터치")
      }
      .disposed(by: disposeBag)
    
    // Do any additional setup after loading the view.
  }
  
  func setupView() {
    view.addSubview(testLabel)
    view.addSubview(testButton)
  }
  
  func setupLayout() {
    testLabel.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.center.equalToSuperview()
      
    }
    
    testButton.snp.makeConstraints { make in
      make.width.height.equalTo(50)
      make.centerX.centerX.equalToSuperview()
      make.centerY.equalTo(testLabel).offset(70)
    }
  }

  
  func timer() {
    // 현재 날짜
    let year = Calendar.current.component(.year, from: .now)
    let month = Calendar.current.component(.month, from: .now)
    let day = Calendar.current.component(.day, from: .now)
    
    // 퇴근 시간
    let leaveWorkTimeStr = "\(year)-\(month)-\(day) 18:30:00"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let leaveTime = dateFormatter.date(from: leaveWorkTimeStr)!
    
    // 남은 시간
    let intervalTime = leaveTime.timeIntervalSince(.now)
    let intervalFormatter = DateComponentsFormatter()
    intervalFormatter.allowedUnits = [.hour, .minute, .second]
    
    
    Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
      .subscribe{ elem in
        let interval = intervalTime - Double(elem.element!)
        
        self.testLabel.text = "남은 시간 \(intervalFormatter.string(from: interval)!)"
      }
      .disposed(by: disposeBag)
  }
}


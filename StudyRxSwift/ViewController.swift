//
//  ViewController.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/01.
//

import AVFAudio
import UIKit
import ActivityKit

import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {
  // MARK: - Properties
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
    
  // MARK: - Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupLayout()
    timer()
    
    testButton.rx.tap
      .bind{
//        self.coordinator?.start()
        print("터치")
        if self.isStart() {
          self.stop()
        } else {
          self.start()
        }
        
      }
      .disposed(by: disposeBag)
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
  
  
  @objc private func start() {
    print("start")
    return LiveActivityManager.shared.start()
  }
  
  @objc private func update() {
    print("update")
    return LiveActivityManager.shared.update(state: .init(value: (0...100).randomElement()!))
  }
  
  @objc private func stop() {
    print("stop")
    return LiveActivityManager.shared.stop()
  }
  
  @objc private func isStart() -> Bool {
    print(LiveActivityManager.shared.isStart())
    return LiveActivityManager.shared.isStart()
  }
  
}


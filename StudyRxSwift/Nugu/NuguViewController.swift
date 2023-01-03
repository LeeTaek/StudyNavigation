//
//  NuguViewController.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/20.
//

import UIKit
import AVFAudio

import NuguAgents
import NuguClientKit
import NuguUIKit
import NuguLoginKit
import SnapKit


class NuguViewController: UIViewController {
  // MARK: - Properties
  private var nuguButton = NuguButton()
  
  private lazy var voiceChromePresenter = VoiceChromePresenter(
    viewController: self,
    nuguClient: NuguCentralManager.shared.client,
    themeController: NuguCentralManager.shared.themeController
  )
  
  private lazy var displayWebViewPresenter = DisplayWebViewPresenter(
    viewController: self,
    nuguClient: NuguCentralManager.shared.client,
    clientInfo: ["buttonColor": "white"],
    themeController: NuguCentralManager.shared.themeController
  )
  
  private lazy var audioDisplayViewPresenter = AudioDisplayViewPresenter(
    viewController: self,
    nuguClient: NuguCentralManager.shared.client,
    themeController: NuguCentralManager.shared.themeController,
    options: .all
  )
  
  private let notificationCenter = NotificationCenter.default
  private var becomeActiveObserver: Any?
  private var nuguServiceStateObserver: Any?
  private var speechStateObserver: Any?
  private var dialogStateObserver: Any?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    setupLayout()
    anonymousLogin()
    
    initializeNugu()
    registerObservers()
  }
  
  
  
  func setupView() {
    nuguButton.addTarget(self, action: #selector(startRecognizeButtonDidClick), for: .touchUpInside)
    nuguButton.nuguButtonType = .button(color: .white)
    view.addSubview(nuguButton)
  }
  
  func setupLayout() {
    nuguButton.snp.makeConstraints { make in
      make.height.width.equalTo(72)
      make.center.equalToSuperview()
    }
  }
  
  
  func requestAudioPermission() {
    AVAudioSession.sharedInstance().requestRecordPermission { (accepted) in
      if accepted {
        print("permission granted")
      }
    }
  }
  
  func anonymousLogin() {
    //    UserDefaults.Standard.loginMethod = SampleApp.LoginMethod.anonymous.rawValue
    //
    //    NuguCentralManager.shared.login(from: self) { [weak self] result in
    //      DispatchQueue.main.async { [weak self] in
    //        switch result {
    //        case .success:
    //          print("로그인 성공")
    //        case .failure(let error):
    //          log.debug(error.errorDescription)
    //
    //          NuguToast.shared.showToast(message: error.errorDescription)
    //          UserDefaults.Standard.clear()
    //          UserDefaults.Nugu.clear()
    //        }
    //      }
    //    }
    NuguCentralManager.shared.oauthClient.loginAnonymously {(result) in
      switch result {
      case .success(let authInfo):
        UserDefaults.Standard.accessToken = authInfo.accessToken
        UserDefaults.Standard.refreshToken = authInfo.refreshToken
        print("로그인 성공")
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  
  
  
  func presentVoiceChrome(initiator: ASRInitiator? = nil) {
    guard AVAudioSession.sharedInstance().recordPermission == .granted else {
      requestAudioPermission()
      NuguToast.shared.showToast(message: "마이크 권한 설정해줭")
      return
    }
    do {
      try voiceChromePresenter.presentVoiceChrome(chipsData: [
        NuguChipsButton.NuguChipsButtonType.normal(text: "오늘 며칠이야", token: nil),
        NuguChipsButton.NuguChipsButtonType.normal(text: "오늘 날씨 어때?", token: nil)
      ])
      
      if let initiator = initiator {
        NuguCentralManager.shared.startListening(initiator: initiator)
      }
    } catch {
      switch error {
      case VoiceChromePresenterError.networkUnreachable:
        NuguCentralManager.shared.localTTSAgent.playLocalTTS(type: .deviceGatewayNetworkError)
      default :
        log.error(error)
      }
    }
  }
}

// MARK: - extension
private extension NuguViewController {
  func initializeNugu() {
    voiceChromePresenter.delegate = self
    displayWebViewPresenter.delegate = self
    audioDisplayViewPresenter.delegate = self
  }
  
  func registerObservers() {
    removeObservers()
    
    // Nugu가 활성화 되기 전에 mic와 백그라운드 상태를 초기화
    becomeActiveObserver = notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main, using: { [weak self] (_) in
      guard let self = self else { return }
      guard self.navigationController?.visibleViewController == self else { return }
      
      NuguCentralManager.shared.refreshNugu()
    })
    
    // Nugu 버튼 상태에 따라 숨기고 띄우는 옵저버
    nuguServiceStateObserver = notificationCenter.addObserver(forName: .nuguServiceStateDidChangeNotification, object: nil, queue: .main, using: { [weak self] (notification) in
      guard let self = self,
            let isEnabled = notification.userInfo?["isEnabled"] as? Bool else { return }
      if isEnabled == true {
        self.nuguButton.isEnabled = true
        self.nuguButton.isHidden = false
      } else  {
        self.nuguButton.isEnabled = false
        self.nuguButton.isHidden = true
      }
    })
    
    // 음성에 따른 그래프 애니메이션을 위한 옵저버
    speechStateObserver = notificationCenter.addObserver(forName: .speechStateDidChangeNotification, object: nil, queue: .main, using: { [weak self] (notification) in
      guard let self = self,
            let state = notification.userInfo?["state"] as? SpeechRecognizerAggregatorState else { return }
      switch state {
      case .wakeupTriggering:
        self.nuguButton.startFlipAnimation()
      case .cancelled:
        self.nuguButton.stopFlipAnimation()
      case .wakeup(let initiator):
        self.presentVoiceChrome(initiator: initiator)
      case .error(let error):
        log.error("speechState error: \(error)")
        if case SpeechRecognizerAggregatorError.cannotOpenMicInputForWakeup = error {
          self.nuguButton.stopFlipAnimation()
        } else if case SpeechRecognizerAggregatorError.cannotOpenMicInputForWakeup = error {
          NuguToast.shared.showToast(message: "음성 인식을 위한 마이크를 사용할 수 없다.")
        }
      default:
        break
      }
    })
    
    dialogStateObserver = notificationCenter.addObserver(forName: .dialogStateDidChangeNotification, object: nil, queue: .main, using: { [weak self] (notification) in
      guard let self = self,
            let state = notification.userInfo?["state"] as? DialogState else { return }
      switch state {
      case .thinking:
        self.nuguButton.pauseDeactivateAnimation()
      default:
        break
      }
    })
  }
  
  
  func removeObservers() {
    if let becomeActiveObserver = becomeActiveObserver {
      NotificationCenter.default.removeObserver(becomeActiveObserver)
      self.becomeActiveObserver = nil
    }
    
    if let nuguServiceStateObserver = nuguServiceStateObserver {
      NotificationCenter.default.removeObserver(nuguServiceStateObserver)
      self.nuguServiceStateObserver = nil
    }
    
    if let speechStateObserver = speechStateObserver {
      NotificationCenter.default.removeObserver(speechStateObserver)
      self.speechStateObserver = nil
    }
    
    if let dialogStateObserver = dialogStateObserver {
      NotificationCenter.default.removeObserver(dialogStateObserver)
      self.dialogStateObserver = nil
    }
  }
  
  
  // 버튼 액션
  @objc func startRecognizeButtonDidClick() {
    presentVoiceChrome(initiator: .tap)
  }
}


// MARK: - Delegate extension
extension NuguViewController: VoiceChromePresenterDelegate {
  func voiceChromeWillShow() {
    nuguButton.isActivated = false
  }
  
  func voiceChromeWillHide() {
    nuguButton.isActivated = true
  }
  
  func voiceChromeChipsDidClick(chips: NuguUIKit.NuguChipsButton.NuguChipsButtonType) {
    NuguCentralManager.shared.chipsDidSelect(selectedChips: chips)
  }
  
  func voiceChromeDidReceiveRecognizeError() {
    NuguCentralManager.shared.localTTSAgent.playLocalTTS(type: .deviceGatewayRequestUnacceptable)
  }
}

extension NuguViewController: DisplayWebViewPresenterDelegate {
  func onDisplayWebViewNuguButtonClick() {
    presentVoiceChrome(initiator: .tap)
  }
}

extension NuguViewController: AudioDisplayViewPresenterDelegate {
  func onAudioDisplayViewNuguButtonClick() {
    presentVoiceChrome(initiator: .tap)
  }
  
  func onAudioDisplayViewChipsSelect(selectedChips: NuguUIKit.NuguChipsButton.NuguChipsButtonType?) {
    NuguCentralManager.shared.chipsDidSelect(selectedChips: selectedChips)
  }
}

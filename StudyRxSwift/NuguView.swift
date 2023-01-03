//
//  NuguButton.swift
//  StudyRxSwift
//
//  Created by openobject on 2023/01/03.
//

import UIKit
import AVFAudio
import SwiftUI

import NuguUIKit
import NuguClientKit
import NuguAgents
import SnapKit

class NuguUIView: UIView {
  var nuguButton = NuguButton()

  lazy var voiceChromePresenter = VoiceChromePresenter(
    superView: self,
    nuguClient: NuguCentralManager.shared.client
  )
  
  lazy var displayWebViewPresenter = DisplayWebViewPresenter(
    superView: self,
    nuguClient: NuguCentralManager.shared.client
  )
  
  lazy var audioDisplayViewPresenter = AudioDisplayViewPresenter(
    superView: self,
    nuguClient: NuguCentralManager.shared.client,
    themeController: NuguCentralManager.shared.themeController,
    options: .all
  )
  
  private let notificationCenter = NotificationCenter.default
  private var becomeActiveObserver: Any?
  private var nuguServiceStateObserver: Any?
  private var speechStateObserver: Any?
  private var dialogStateObserver: Any?
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    nuguButton.addTarget(self, action: #selector(startRecognizeButtonDidClick), for: .touchUpInside)
    addSubview(nuguButton)
    
  }
  
  func setupLayout() {
    nuguButton.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }
  
  // 버튼 액션
  @objc func startRecognizeButtonDidClick() {
    presentVoiceChrome(initiator: .tap)
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
  
  
  func requestAudioPermission() {
    AVAudioSession.sharedInstance().requestRecordPermission { (accepted) in
      if accepted {
        print("permission granted")
      }
    }
  }
}



struct NuguView: UIViewRepresentable {
  typealias UIViewType = NuguUIView
  let nuguView = NuguUIView()

  func makeUIView(context: Context) -> NuguUIView {
    return nuguView
  }
  
  func updateUIView(_ uiView: NuguUIView, context: Context) {
    nuguView.voiceChromePresenter.delegate = context.coordinator
    nuguView.displayWebViewPresenter.delegate = context.coordinator
    nuguView.audioDisplayViewPresenter.delegate = context.coordinator
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(nuguView: nuguView)
  }
  
  
  class Coordinator: NSObject, VoiceChromePresenterDelegate, DisplayWebViewPresenterDelegate, AudioDisplayViewPresenterDelegate {
    func onAudioDisplayViewNuguButtonClick() {
      nuguView.presentVoiceChrome(initiator: .tap)
    }
    
    func onAudioDisplayViewChipsSelect(selectedChips: NuguUIKit.NuguChipsButton.NuguChipsButtonType?) {
      NuguCentralManager.shared.chipsDidSelect(selectedChips: selectedChips)
    }
    
    // DisplayWebViewPresenterDelegate
    func onDisplayWebViewNuguButtonClick() {
      nuguView.presentVoiceChrome(initiator: .tap)
    }
    
    var nuguView: NuguUIView
    
    init(nuguView: NuguUIView) {
      self.nuguView = nuguView
    }
    
    // VoiceChromePresenterDelegate
    func voiceChromeWillShow() {
      nuguView.nuguButton.isActivated = false
    }
    
    func voiceChromeWillHide() {
      nuguView.nuguButton.isActivated = true
      
    }
    
    func voiceChromeChipsDidClick(chips: NuguUIKit.NuguChipsButton.NuguChipsButtonType) {
      nuguView.nuguButton.isActivated = true
    }
  }
}



// Code Previews
struct NuguVuew_PreviewProvider: PreviewProvider {
    static var previews: some View {
      NuguView()
    }
}

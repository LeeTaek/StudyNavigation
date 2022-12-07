//
//  NFCViewController.swift
//  StudyRxSwift
//
//  Created by openobject on 2022/12/06.
//

import UIKit
import CoreNFC

import RxSwift

class NFCViewController: UIViewController {
  weak var coordinator: CounterCoordinator?
  
  var readNFCButton: UIButton = {
    var btn = UIButton()
    btn.setTitle("open Reading NFC", for: .normal)
    return btn
  }()
  
  var writeNFCButton: UIButton = {
    var btn = UIButton()
    btn.setTitle("open Write NFC", for: .normal)
    return btn
  }()
  
  var disposeBag = DisposeBag()
  var message = NFCNDEFMessage.init(records: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupLayout()
    
    readNFCButton.rx.tap
      .bind{
        self.runReadingNFC()
        print("터치")
      }
      .disposed(by: disposeBag)
    
    writeNFCButton.rx.tap
      .bind{
        self.runWritingNFC()
        print("터치")
      }
      .disposed(by: disposeBag)
    
  }
  
  func setupView() {
    view.addSubview(readNFCButton)
    view.addSubview(writeNFCButton)
  }
  
  func setupLayout() {
    readNFCButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.center.equalToSuperview()
    }
    
    writeNFCButton.snp.makeConstraints{ make in
      make.height.equalTo(50)
      make.centerX.equalToSuperview()
      make.centerY.equalTo(readNFCButton).offset(50)
    }
  }
  
  
  func runReadingNFC() {
    guard NFCReaderSession.readingAvailable else {
      return
    }
    
    let session = NFCNDEFReaderSession(
      delegate: self,
      queue: nil,
      invalidateAfterFirstRead: true
    )
    
    session.alertMessage = "NFC에 터치 해줘"
    session.begin()
  }
  
  func runWritingNFC()  {
    let naver = NFCNDEFPayload.wellKnownTypeURIPayload(url: URL(string: "www.naver.com")!)!
    let customTextPayload = NFCNDEFPayload.init(
      format: .nfcWellKnown,
      type: "T".data(using: .utf8)!,
      identifier: Data(),
      payload: "커스텀 데이터!".data(using: .utf8)!
    )
    
    self.message =  NFCNDEFMessage.init(
      records: [
        naver,
        customTextPayload
      ]
    )
    
    runReadingNFC()
    initWritingMessage()
  }
  
  
  func initWritingMessage() {
    self.message = NFCNDEFMessage.init(records: [])
  }
  
}



extension NFCViewController: NFCNDEFReaderSessionDelegate {
  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    print("NFC 세션 에러: \(error)")
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    print("Detected tags with \(messages.count) messages")
    
    for messageIndex in 0 ..< messages.count {
      
      let message = messages[messageIndex]
      print("\tMessage \(messageIndex) with length \(message.length)")
      
      for recordIndex in 0 ..< message.records.count {
        
        let record = message.records[recordIndex]
        print("\t\tRecord \(recordIndex)")
        print("\t\t\tidentifier: \(String(data: record.identifier, encoding: .utf8)!)")
        print("\t\t\ttype: \(String(data: record.type, encoding: .utf8)!)")
        print("\t\t\tpayload: \(String(data: record.payload, encoding: .utf8)!)")
      }
    }
  }
  
  // NDEF 태그 감지하면 호출
  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    guard tags.count == 1 else {
      session.invalidate(errorMessage: "하나 이상의 태그를 쓸 수 없음")
      return
    }
    let currentTag = tags.first!
    
    session.connect(to: currentTag) { error in
      guard error == nil else {
        session.invalidate(errorMessage: "태그 연결 안됨")
        return
      }
        
      currentTag.queryNDEFStatus { status, capacity, error in
        guard error == nil else {
          session.invalidate(errorMessage: "태그의 쿼리가 이상해")
          return
        }
        
        switch status {
        case .notSupported:
          session.invalidate(errorMessage: "태그 지원 안돼")
        case .readOnly:
          session.invalidate(errorMessage: "읽기 전용 태그야")
        case .readWrite:
          currentTag.writeNDEF(self.message) { error in
            if error != nil {
              session.invalidate(errorMessage: "메세지 쓰는데 실패했어")
            } else {
              session.alertMessage = "데이터 전송 성공"
              session.invalidate()
            }
          }
        @unknown default:
          session.invalidate(errorMessage: "알수없는 오류")
        }
      }
    }
  }
  
}

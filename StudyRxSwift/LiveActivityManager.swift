//
//  LiveActivityManager.swift
//  StudyRxSwift
//
//  Created by openobject on 2023/01/02.
//

import SwiftUI
import ActivityKit

final class LiveActivityManager: ObservableObject {
  static let shared = LiveActivityManager()
  @Published var activity: Activity<StudyWidgetAttributes>?
  private init() {}
  
  func start() {
    guard activity == nil else { return }
    let attributes = StudyWidgetAttributes(name: "taek")
    let contentState = StudyWidgetAttributes.ContentState(value: 5)
    
    do {
      let activity = try Activity<StudyWidgetAttributes>.request(
        attributes: attributes,
        contentState: contentState
      )
      print(activity)
    } catch {
      print(error)
    }
  }
  
  func update(state: StudyWidgetAttributes.ContentState) {
    Task {
      let updateContentState = StudyWidgetAttributes.ContentState(value: state.value)
      for activity in Activity<StudyWidgetAttributes>.activities {
        await activity.update(using: updateContentState)
      }
    }
  }
  
  func stop() {
    Task {
      for activity in Activity<StudyWidgetAttributes>.activities {
        await activity.end(dismissalPolicy: .immediate)
      }
    }
  }
}

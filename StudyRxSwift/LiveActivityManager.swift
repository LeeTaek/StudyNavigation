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
  private var isActive: Bool = false
  private init() {}
  
  func start() {
    guard activity == nil else { return }
    let attributes = StudyWidgetAttributes(name: "taek")
    let initialContentState = StudyWidgetAttributes.ContentState(value: 5)
    let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)

    do {
      let activity = try Activity<StudyWidgetAttributes>.request(
        attributes: attributes,
        content: activityContent,
        pushType: nil
      )
      isActive = true
      print(activity)
    } catch (let error) {
      print(error)
    }
  }
  
  func update(state: StudyWidgetAttributes.ContentState) {
    Task {
//      let updateContentState = StudyWidgetAttributes.ContentState(value: state.value)
      for activity in Activity<StudyWidgetAttributes>.activities {
        await activity.update(activity.content)
      }
    }
  }
  
  func stop() {
    let finalState = StudyWidgetAttributes.ContentState(value: 0)
    let finalContent = ActivityContent(state: finalState, staleDate: nil)
    Task {
      for activity in Activity<StudyWidgetAttributes>.activities {
        await activity.end(finalContent, dismissalPolicy: .default)
      }
    }
    isActive = false
  }
  
  
  func isStart() -> Bool {
    return isActive
  }
  
}

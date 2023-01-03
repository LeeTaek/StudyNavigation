//
//  StudyWidget.swift
//  StudyWidget
//
//  Created by openobject on 2022/12/29.
//

import WidgetKit
import SwiftUI
import Intents
import Combine

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent(), leaveTime:" 남은시간")
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration, leaveTime: "")
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []
    
    
    
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for term in 0 ..< 100 {
      // 1초마다 refresh
      let entryDate = Calendar.current.date(byAdding: .second, value: term, to: currentDate)!
      
      // 현재 날짜
      let year = Calendar.current.component(.year, from: .now)
      let month = Calendar.current.component(.month, from: .now)
      let day = Calendar.current.component(.day, from: .now)
      
      // 좋은 시간
      let leaveWorkTimeStr = "\(year)-\(month)-\(day) 18:30:00"
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let leaveTime = dateFormatter.date(from: leaveWorkTimeStr)!
      
      // 남은 시간
      let intervalTime = leaveTime.timeIntervalSince(.now)
      let intervalFormatter = DateComponentsFormatter()
      intervalFormatter.allowedUnits = [.hour, .minute, .second]
      
      let interval = intervalTime - Double(term)
      let entry = SimpleEntry(date: entryDate, configuration: configuration, leaveTime: "남은시간\n\(intervalFormatter.string(from: interval)!)")
      entries.append(entry)

    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let leaveTime: String
}

struct StudyWidgetEntryView : View {
  var entry: Provider.Entry
  @State var leaveTime: String = ""
  
  
  var body: some View {
    Text(entry.leaveTime)
  }
}

//  func timer() {
//    var bag = Set<AnyCancellable>()
//
//    // 현재 날짜
//    let year = Calendar.current.component(.year, from: .now)
//    let month = Calendar.current.component(.month, from: .now)
//    let day = Calendar.current.component(.day, from: .now)
//
//    // 퇴근 시간
//    let leaveWorkTimeStr = "\(year)-\(month)-\(day) 18:30:00"
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    let leaveTime = dateFormatter.date(from: leaveWorkTimeStr)!
//
//    // 남은 시간
//    let intervalTime = leaveTime.timeIntervalSince(.now)
//    let intervalFormatter = DateComponentsFormatter()
//    intervalFormatter.allowedUnits = [.hour, .minute, .second]
//
//    self.leaveTime =  "남은시간\n\(intervalFormatter.string(from: intervalTime)!)"
//
//    Timer
//      .publish(every: 1.0, on: .main, in: .common)
//      .autoconnect()
//      .scan(0) { counter, _ in counter + 1 }
//      .sink { counter in
//          let interval = intervalTime - Double(counter)
//
//        self.leaveTime = "남은시간\n\(intervalFormatter.string(from: interval)!)"
//        print(leaveTime)
//      }
//      .store(in: &bag)
//  }
//
//}

struct StudyWidget: Widget {
  let kind: String = "StudyWidget"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      StudyWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Leave worktime")
    .description("샘플 위젯.")
    .supportedFamilies([.systemSmall, .systemLarge, .systemMedium, .systemExtraLarge])
  }
  
  
  
}

struct StudyWidget_Previews: PreviewProvider {
  static var previews: some View {
    StudyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), leaveTime: ""))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}

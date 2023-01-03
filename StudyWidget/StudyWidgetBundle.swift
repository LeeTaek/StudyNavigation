//
//  StudyWidgetBundle.swift
//  StudyWidget
//
//  Created by openobject on 2022/12/29.
//

import WidgetKit
import SwiftUI

@main
struct StudyWidgetBundle: WidgetBundle {
    var body: some Widget {
        StudyWidget()
        StudyWidgetLiveActivity()
    }
}

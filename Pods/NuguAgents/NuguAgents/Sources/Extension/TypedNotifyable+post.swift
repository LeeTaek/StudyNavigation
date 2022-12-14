//
//  TypedNotifyable+post.swift
//  NuguAgents
//
//  Created by childc on 2021/01/20.
//  Copyright © 2021 SK Telecom Co., Ltd. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

import NuguUtils

extension TypedNotifyable {
    func post<Notification: TypedNotification>(_ notification: Notification) {
        NotificationCenter.default.post(name: Notification.name, object: self, userInfo: notification.dictionary)
    }
    
    /**
     Observe specific type
     */
    func observe<Notification: TypedNotification>(
        _ forType: Notification.Type,
        queue: DispatchQueue,
        using block: @escaping (Notification) -> Void
    ) -> Any {
        return NotificationCenter.default.addObserver(forName: Notification.name, object: self, queue: nil) { (notification) in
            guard let userInfo = notification.userInfo as? [String: Any],
                  let typedNotification = Notification.make(from: userInfo) else { return }

            queue.async {
                block(typedNotification)
            }
        }
    }
}

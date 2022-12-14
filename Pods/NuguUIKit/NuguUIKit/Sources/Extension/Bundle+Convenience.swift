//
//  Bundle+Convenience.swift
//  NuguUIKit
//
//  Created by 이민철님/AI Assistant개발Cell on 2020/10/23.
//  Copyright © 2020 SK Telecom Co., Ltd. All rights reserved.
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

extension Bundle {
    /// Creates an image object using the named image asset from the current library bundle.
    ///
    /// https://github.com/CocoaPods/CocoaPods/issues/8122#issuecomment-674844941
    static var imageBundle: Bundle? {
        #if DEPLOY_OTHER_PACKAGE_MANAGER
        guard let bundlePath = Bundle(for: NuguButton.self).path(forResource: "NuguUIKit-Images", ofType: "bundle") else {
            return Bundle(for: NuguButton.self)
        }
        
        return Bundle(path: bundlePath)
        #else
        return Bundle.module
        #endif
    }
}

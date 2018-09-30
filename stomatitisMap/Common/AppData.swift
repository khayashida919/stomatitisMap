//
//  AppData.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/07/22.
//  Copyright © 2018 khayashida. All rights reserved.
//

import Foundation

final class AppData {
    static let shared = AppData()
    private init() { }
    
    var isFirstTime = true
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    var dateFormater: DateFormatter {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormater
    }
    
    var blocks: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "blocks") ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "blocks")
        }
    }
}

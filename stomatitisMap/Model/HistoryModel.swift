//
//  HistoryModel.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/06/23.
//  Copyright © 2018 khayashida. All rights reserved.
//

import Foundation

enum History: Int {
    case today
    case oneDayAgo
    case twoDayAgo
    case threeDayAgo
    case fourDayAgo
    
    static var todayCount = 0
    static var oneDayAgoCount = 0
    static var twoDayAgoCount = 0
    static var threeDayAgoCount = 0
    static var fourDayAgoCount = 0
    
    static var sum = 0
    
    var aDayCount: Int {
        switch self {
        case .today:
            return History.todayCount
        case .oneDayAgo:
            return History.oneDayAgoCount
        case .twoDayAgo:
            return History.twoDayAgoCount
        case .threeDayAgo:
            return History.threeDayAgoCount
        case .fourDayAgo:
            return History.fourDayAgoCount
        }
    }
    
    static func add(day: Int) {
        switch day {
        case 0:
            History.todayCount += 1
        case 1:
            History.oneDayAgoCount += 1
        case 2:
            History.twoDayAgoCount += 1
        case 3:
            History.threeDayAgoCount += 1
        case 4:
            History.fourDayAgoCount += 1
        default:
            break
        }
    }
    
    static func reset() {
        todayCount = 0
        oneDayAgoCount = 0
        twoDayAgoCount = 0
        threeDayAgoCount = 0
        fourDayAgoCount = 0
    }
}


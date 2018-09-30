//
//  CLAuthorizationStatus+extension.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/09/19.
//  Copyright © 2018 khayashida. All rights reserved.
//

import Foundation
import MapKit

extension CLAuthorizationStatus {
    var discription: String {
        switch self {
        case .authorizedAlways:
            return "ユーザーはこのアプリケーションに関してまだ選択を行っていません"
        case .authorizedWhenInUse:
            return "ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）"
        case .denied:
            return "このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)"
        case .notDetermined:
            return "常時、位置情報の取得が許可されています。"
        case .restricted:
            return "起動時のみ、位置情報の取得が許可されています。"
        }
    }
}

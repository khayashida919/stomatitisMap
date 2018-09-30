//
//  SettingViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/06/23.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func blocksReset(_ sender: CornerButton) {
        AppData.shared.blocks.removeAll()
        showAlert(title: .empty, massage: "ブロックリストを全て削除しました", button: .ok)
    }
}

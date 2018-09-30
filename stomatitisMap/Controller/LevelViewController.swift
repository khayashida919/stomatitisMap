//
//  LevelViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/09/18.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit

class LevelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view === view {
            dismiss(animated: true, completion: nil)
        }
    }
}

//
//  ViewController+extension.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/05/20.
//  Copyright © 2018年 khayashida. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func startIndicator(completion: (() -> Void)? = nil) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let indicatorViewController = mainStoryboard.instantiateViewController(withIdentifier: "indicatorViewController") as? IndicatorViewController else { return }
        DispatchQueue.main.async {
            self.present(indicatorViewController, animated: true, completion: {
                guard let completion = completion else { return }
                completion()
            })
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showMenu(completion: (() -> Void)? = nil) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let menuViewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        present(menuViewController, animated: false, completion: {
            guard let completion = completion else { return }
            completion()
        })
    }
    
    enum Alert: String {
        case empty = ""
        case error = "エラー"
        case warning = "警告"
        case ok = "OK"
        case cancel = "キャンセル"
        case report = "通報"
        case block = "ブロック"
    }
    
    func showAlert(title: Alert, massage: String, button: Alert, isCancel: Bool = false, handler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title.rawValue, message: massage, preferredStyle:.alert)
        let okAction = UIAlertAction(title: button.rawValue, style: .default) { _ in
            if let handler = handler {
                handler()
            }
        }
        alert.addAction(okAction)
        if isCancel {
            let cancelAction = UIAlertAction(title: Alert.cancel.rawValue, style: .cancel)
            alert.addAction(cancelAction)
        }
        present(alert, animated: true)
    }
    
    func showReport(title: Alert, massage: String,
                    reportHandler: @escaping () -> Void,
                    blockHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle:.actionSheet)
        let reportAction = UIAlertAction(title: Alert.report.rawValue, style: .destructive) { _ in
            reportHandler()
        }
        let blockAction = UIAlertAction(title: Alert.block.rawValue, style: .destructive) { _ in
            blockHandler()
        }
        let cancelAction = UIAlertAction(title: Alert.cancel.rawValue, style: .cancel)
        alert.addAction(blockAction)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

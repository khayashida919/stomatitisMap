//
//  HistoryViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/06/23.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        guard let history = History(rawValue: indexPath.row) else { return UITableViewCell() }
        
        if history.aDayCount < 0 {
            cell.arrowImageView.image = UIImage(named: "blueArrow")
            cell.difLabel.text = "(" + String(history.aDayCount) + ")"
        } else if history.aDayCount == 0 {
            cell.arrowImageView.image = UIImage(named: "yellowArrow")
            cell.difLabel.text = "(+" + String(history.aDayCount) + ")"
        } else if 0 < history.aDayCount {
            cell.arrowImageView.image = UIImage(named: "redArrow")
            cell.difLabel.text = "(+" + String(history.aDayCount) + ")"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 (E)"
        let date = Date(timeInterval: TimeInterval(-indexPath.row*60*60*24), since: Date())
        cell.dateLabel.text = formatter.string(from: date)
        return cell
    }
}

final class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var difLabel: UILabel!
}

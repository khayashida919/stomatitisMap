//
//  MenuViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/06/19.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController, UIGestureRecognizerDelegate {

    //MARK: Properties
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var gestureView: UIView!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        versionLabel.text = AppData.shared.version
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(MenuViewController.dismissGesture))
        gestureView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        sideMenuView.center.x += menuTableView.bounds.width
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
            self.sideMenuView.center.x -= self.menuTableView.bounds.width
        }, completion: nil)
    }
    
    //MARK: Method
    @objc func dismissGesture() { dismissAction() }
    
    private func dismissAction(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
            self.sideMenuView.center.x += self.menuTableView.bounds.width
        }, completion: { result in
            self.dismiss(animated: false, completion: { () in
                completion?()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = Menu(rawValue: indexPath.row) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = menu.info.title
        cell.metaImage.image = menu.info.image
        cell.contentView.backgroundColor = menu.info.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = Menu(rawValue: indexPath.row) else { return }
        guard let navigationController = presentingViewController as? UINavigationController else { return }
        guard let mapViewController = navigationController.topViewController as? MapViewController else { return }
        dismissAction(completion: { () in
            mapViewController.menu(menu)
        })
    }
}

final class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var metaImage: UIImageView!
}

enum Menu: Int {
    case history
    case chat
    case setting
    
    struct MenuData {
        var title: String
        var image: UIImage?
        var color: UIColor
        var segue: String
    }
    
    var info: MenuData {
        switch self {
        case .history:
            let menuData = MenuData(title: "History",
                     image: UIImage(named: "History"),
                     color: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1),
                     segue: "toHistoryViewController")
            return menuData
        case .chat:
            let menuData = MenuData(title: "Chat",
                                    image: UIImage(named: "Chat"),
                                    color: UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1),
                                    segue: "toChatViewController")
            return menuData
        case .setting:
            let menuData = MenuData(title: "Setting",
                                    image: UIImage(named: "Setting"),
                                    color: UIColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 1),
                                    segue: "toSettingViewController")
            return menuData
        }
    }
}

//
//  TabBarViewController.swift
//  OhnawaLog
//
//  Created by 田岸将勝 on 2021/10/05.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,animated:true)
    }

}

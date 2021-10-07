//
//  ViewController.swift
//  OhnawaLog
//
//  Created by 田岸将勝 on 2021/10/05.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let keyChain = Keychain()
    
    @IBOutlet weak private var logoImage: UIImageView!
    @IBOutlet weak private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationBarを非表示にする
        navigationController?.setNavigationBarHidden(true,animated:true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        loginButton.isEnabled = false
        registerId()
    }
    
    func registerId() {
        //ログインidを保存
        Auth.auth().signInAnonymously { [self] authResult, error in
            guard let user = authResult?.user
            else {
                loginButton.isEnabled = true
                return
            }
            let uid = user.uid
            try? keyChain.set(uid, key: "uid")
            //ホーム画面へ遷移
            let tabVC = self.storyboard?.instantiateViewController(identifier: "tabVC") as! TabBarViewController
            self.navigationController?.pushViewController(tabVC, animated: true)
        }
    }
    
}


//
//  CountRegisterViewController.swift
//  OhnawaLog
//
//  Created by 田岸将勝 on 2021/10/05.
//

import UIKit
import Firebase
import FirebaseFirestore

class CountRegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    
    let db = Firestore.firestore()
    let keyChain = Keychain()
    var slectDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = slectDate
        countTextField.delegate = self
        countTextField.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBAction func registerButton(_ sender: Any) {
        sendData()
        countTextField.resignFirstResponder()
    }
    
    func sendData() {
        
        if countTextField.text == "" || countTextField.text?.prefix(1) == "0" {
            //アラート（数字を入力してください）
            let alert = UIAlertController(title: "エラー", message: "回数を入力してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            countTextField.text = ""
            return
        } else if Int(countTextField.text!.count) > 4 {
            let alert = UIAlertController(title: "エラー", message: "4桁以下の数値を入力してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            countTextField.text = ""
            return
        } else {
            let date:String = slectDate
            let count:Int = Int(countTextField.text!)!
            let userId:String = try! keyChain.get("uid")!
            //Firestoreへscoreを送信
            db.collection(userId).document(date).setData(["date" : date,
                                                          "count" : count,
                                                          "userId" : userId])
        }
        //１つ前の画面（score画面）へ遷移
        self.navigationController?.popViewController(animated: true)
    }
}

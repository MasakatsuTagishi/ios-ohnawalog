//
//  RankingViewController.swift
//  OhnawaLog
//
//  Created by 田岸将勝 on 2021/10/05.
//

import UIKit
import Firebase
import FirebaseFirestore
import KeychainAccess

class RankingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let keyChain = Keychain()
    var ranking = [Ranking]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getScore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let numberLabel = cell.contentView.viewWithTag(1) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(2) as! UILabel
        let countLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        numberLabel.text = String(indexPath.row + 1) + "位"
        dateLabel.text = ranking[indexPath.row].date
        countLabel.text = String(ranking[indexPath.row].count) + "回"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //セルの削除許可を設定
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    //セルの削除ボタンが押された時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let userId = try! keyChain.get("uid")
            let date = ranking[indexPath.row].date
            let alert = UIAlertController(title: "確認", message: "データを削除しますか？", preferredStyle: UIAlertController.Style.alert)
            let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
                //FireStore内のデータを削除
                self.db.collection(userId!).document(date).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                        self.tableView.reloadData()
//                        self.ranking.remove(at: indexPath.row)
//                        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
                    }
                }
                //１つ前の画面（score画面）へ遷移
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(alertAction)
            alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    
    func getScore() {
        let userId = try! keyChain.get("uid")
        db.collection(userId!).order(by: "count", descending: true).addSnapshotListener { snapshot, error in
            if error != nil {return}
            self.ranking = []
            if let snapshotDoc = snapshot?.documents {
                for document in snapshotDoc {
                    let data = document.data()
                    if let count = data["count"] as? Int,
                       let date = data["date"] as? String{
                        let newDataSet = Ranking(count: Int(exactly: count)!, date: date)
                        self.ranking.append(newDataSet)
                        print("hoge")
                        print(self.ranking)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

}

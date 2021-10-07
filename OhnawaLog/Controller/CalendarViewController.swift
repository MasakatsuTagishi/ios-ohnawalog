//
//  CalendarViewController.swift
//  OhnawaLog
//
//  Created by 田岸将勝 on 2021/10/05.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import KeychainAccess
import Firebase
import FirebaseFirestore

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak private var maxLabel: UILabel!
    @IBOutlet weak private var scoreLabel: UILabel!
    
    let db = Firestore.firestore()
    let keyChain = Keychain()
    var tapDate:String = ""
    var counts = [Count]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate = self
        calendarView.dataSource = self
        scoreLabel.text = "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreLabel.text = "0"
        getScore()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let weekDay = self.getWeekIndex(date: date)
        
        if self.getHoliday(date: date) {
            return UIColor.red
        }
        
        if weekDay == 1 {
            return UIColor.red
        } else if weekDay == 7 {
            return UIColor.blue
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        tapDate = "\(year)年\(month)月\(day)日"
        let selectDate:String = tapDate
        let vc = storyboard?.instantiateViewController(withIdentifier: "countRegisterVC") as! CountRegisterViewController
        vc.slectDate = selectDate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getScore() {
        let userId = try! keyChain.get("uid")
        db.collection(userId!).order(by: "count", descending: true).limit(to: 1).addSnapshotListener { snapshot, error in
            if error != nil {return}
            self.counts = []
            if let snapshotDoc = snapshot?.documents {
                for document in snapshotDoc {
                    let data = document.data()
                    if let count = data["count"] as? Int {
                        let newDataSet = Count(count: Int(exactly: count)!)
                        self.counts.append(newDataSet)
                        print("hoge")
                        print(self.counts)
                        self.scoreLabel.text = String(self.counts[0].count) + "回"
                    }
                }
            }
        }
    }
    
    func getHoliday(date: Date) -> Bool {
        
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        
    }
    
    func getDay(date: Date) -> (String, String, String) {
        var year = String()
        var month = String()
        var day = String()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyymmdd", options: 0, locale: Locale(identifier: "ja_JP"))
        var selectedDate = dateFormatter.string(from: date)
        for i in 0...1 {
            if let slash = selectedDate.range(of: "/") {
                selectedDate.replaceSubrange(slash, with: "")
                year = String(selectedDate.prefix(4))
                let startIndex = selectedDate.index(selectedDate.startIndex, offsetBy: 4)
                let endIndex = selectedDate.index(startIndex, offsetBy: 1)
                month = String(selectedDate[startIndex...endIndex])
                day = String(selectedDate.suffix(2))
            }
        }
        return (year, month, day)
    }
    
    func getWeekIndex(date: Date) -> Int {
        let tmpCalender = Calendar(identifier: .gregorian)
        return tmpCalender.component(.weekday, from: date)
    }
    
}



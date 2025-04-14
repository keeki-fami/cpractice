//
//  CalendarTestView.swift
//  cpractice
//
//  Created by 桜田聖和 on 2024/12/08.
//

import Foundation
import SwiftUI
import FSCalendar
import UIKit

struct CalendarTestView: UIViewRepresentable{
    @Binding var selectedDate: IdentifiableDate? //モーダルで表示する日付
    @Binding var goal_num:String//目標金額
    @Binding var notificationname:Notification.Name
    @State var subtractions:Int = 0//引き算の結果（その日の超過分）
    @Binding var fsCalendar:FSCalendar
    @Binding var TotalSum:Int
    @Binding var row : [[String:String]] //お金と目的のデータ一個分
    @State private var totalAmount: Int = 0
    @Binding var CntForSum:Int//その月の日数
    @Binding var Month:Int
    @AppStorage("data_by_date") private var dataByDate: String = "{}"

    
    //2025-12-24みたいな形式にする
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            fsCalendar.reloadData()
            print("@renual: 非同期でリロード完了")
        }
    }
    
    
    func updateList(newData: [[String: String]]) {
        // データの更新処理
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(newData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            UserDefaults.standard.set(jsonString, forKey: "data_by_date")
        }
        
        NotificationCenter.default.post(name:notificationname,object:nil)
    }
    
    
    
    class Coordinator: NSObject,FSCalendarDelegate,FSCalendarDataSource{
        var parent:CalendarTestView
        init(_ parent: CalendarTestView) {
            print("初期設定")
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self,selector : #selector(renual),name:parent.notificationname,object:nil)
        }
        deinit{
            NotificationCenter.default.removeObserver(self, name: parent.notificationname, object: nil)
        }
        @objc func renual(){
            parent.fsCalendar.reloadData()
            print("@renual : カレンダーをリロードしました。")
        }
        
        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition){
            
            
            
            print("calendar : calendarメソッドが呼び出されました。(1/2)")
          
        
            //再利用されるセル内のサブビューをクリア
            //（でたらめなUIButtonの割り当てを防いだ。）
            cell.subviews.forEach{subview in
                if subview is UIButton || subview is UILabel{
                    subview.removeFromSuperview()
                }
            }
            //現在の月以外の日付はスキップ
            //今月ではない数日にUIButtonなどが割り当てられない。
            guard monthPosition == .current else{
                return
            }
            
            
            
            let nowday = Date()
            let otherday = Calendar.current
            let selectedDate = otherday.startOfDay(for:date)
            let todayDate = otherday.startOfDay(for: nowday)
            
            let currentPageDate = calendar.currentPage
            let cale = Calendar.current
            parent.Month = cale.component(.month,from:currentPageDate)//nowday
            
            

            
            //合計金額を計算
            if cell.subviews.first(where: {$0 is UILabel})==nil{
                parent.totalAmount = calculateTotalAmount(for: date)
                print(parent.totalAmount)
                
                
                
                guard cell.bounds.width > 0, cell.bounds.height > 0 else {
                    print("無効なセルのサイズ: \(cell.bounds)")
                    return
                }
                
                //その日の合計使用金額を表示するラベル
                let totalLabel = UILabel(frame: CGRect(x:0, y: cell.bounds.height - 20, width: cell.bounds.width, height: 20))
                
                //表示するデータ
                if selectedDate > todayDate{
                    if parent.totalAmount <= 0{
                        totalLabel.text = ""
                    }
                    else{
                        totalLabel.text = "¥\(parent.totalAmount)"
                    }
                }
                else{
                    totalLabel.text = parent.totalAmount > 0 ? "¥\(parent.totalAmount)" : "¥0"
                }
                
                totalLabel.font = UIFont.systemFont(ofSize: 12)
                totalLabel.textColor = .gray
                totalLabel.textAlignment = .center
                totalLabel.backgroundColor = UIColor.white
                
                //目標金額
                let advantage = parent.goal_num
                
                let advantageLabel = UILabel(frame: CGRect(x:0,y:cell.bounds.height-35,width:cell.bounds.width,height:20))
                if let number2 = Int(parent.goal_num){
                    parent.subtractions = number2-parent.totalAmount
                }
                advantageLabel.text = parent.totalAmount > 0 ? (parent.subtractions > 0 ? "(-\(parent.subtractions))" : "(+\(parent.subtractions * (-1)))") : ""
                
                
                //前の日で一度も入力を行わなかった日は０円にする。
                
                if selectedDate < todayDate{
                    if advantageLabel.text==""{
                        advantageLabel.text = "(-\(parent.goal_num))"
                        totalLabel.text = "¥0"
                    }
                }
                
                advantageLabel.backgroundColor = UIColor.white
                advantageLabel.font = UIFont.systemFont(ofSize:12)
                advantageLabel.textColor = parent.subtractions >= 0 ? .blue : .red
                advantageLabel.textAlignment = .center
                cell.addSubview(advantageLabel)
                cell.addSubview(totalLabel)
                
                
                print("計算した日付：\(date)")
                print("計算した合計金額: \(parent.totalAmount) for アドバンテージ: \(advantage)")
                print("")
                
            }
            
            
            if cell.subviews.first(where: {$0 is UIButton})==nil{
                
                let button = UIButton()
                //cell.bounds全体をボタンが覆う
                button.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                button.backgroundColor = UIColor.clear
                button.clipsToBounds = true
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.layer.borderWidth = 1
                if todayDate == selectedDate{
                    //button.layer.borderColor = UIColor.systemCyan.cgColor
                    button.layer.backgroundColor = UIColor(red: 0, green: 1.0, blue: 1.0, alpha: 0.3).cgColor
                    //button.layer.borderWidth = 2
                    
                }
                
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                let timestamp = Int(date.timeIntervalSince1970)
                button.tag = timestamp
                cell.addSubview(button)
            }
            
            if(parent.CntForSum == 0){
                totalsumcalculator(date, calendar: calendar)
            }
            
        }//calendarメソッド
        
        
        //日付を押した時に実行
        @objc func buttonTapped(_ sender:UIButton){
            let timestamp = TimeInterval(sender.tag)
            let date = Date(timeIntervalSince1970: timestamp)
            
            guard parent.selectedDate == nil || Calendar.current.isDate(date, equalTo:parent.selectedDate?.date ?? Date(), toGranularity: .month) else {
                print("現在の月以外の日付が選択されました。")
                return
            }
            print("選択された日付：\(date)")
            parent.selectedDate = IdentifiableDate(date: date)
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            let currentPageDate = calendar.currentPage
            let calendar = Calendar.current
            print("月が変更されました")
            
            // 現在の月の開始日と終了日を計算
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentPageDate)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return }
            
            print("表示中の月: \(startOfMonth) ~ \(endOfMonth)")
            
            // 使用金額を計算
            let today = Date()
            var temp = startOfMonth
            parent.CntForSum = 0
            while(temp<=endOfMonth){
                parent.CntForSum += 1
                temp = calendar.date(byAdding: .day, value: 1, to: temp)!//次の日に進む
            }
            print("合計日：\(parent.CntForSum)")
            if(startOfMonth <= today && today <= endOfMonth){
                calculateTotalForMonth(startDate: startOfMonth, endDate: today)
            }
            else{
                calculateTotalForMonth(startDate: startOfMonth, endDate: endOfMonth)
            }
            
        }
        
        func calculateTotalForMonth(startDate: Date, endDate: Date) {
            let calendar = Calendar.current
            var totalAmount = 0
            var currentDate = startDate
            
            while currentDate <= endDate {
                // 1日ごとにデータを取得して合計
                //parent.CntForSum += 1
                totalAmount += calculateTotalAmount(for: currentDate)//リストの値の合計を計算
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!//次の日に進む
            }
            
            print("現在の月の合計使用金額: ¥\(totalAmount)")
            // 必要に応じてStateプロパティやUIを更新
            //非同期処理？？
            DispatchQueue.main.async {
                self.parent.TotalSum = totalAmount
            }
        }
        
        func totalsumcalculator(_ date:Date, calendar: FSCalendar){
            
            let currentPageDate = calendar.currentPage
            
            //更新前に二つのStateプロパティを初期化
            if (parent.TotalSum > 0){
                parent.TotalSum = 0
            }
            if (parent.CntForSum != 0){
                parent.CntForSum = 0
            }
            
            
            let cale = Calendar.current
            
            let year = cale.component(.year,from:currentPageDate)
            let month = cale.component(.month,from:currentPageDate)//nowday
            print("月の更新")
            
            //月の最初の日を求める
            let start = cale.date(from: DateComponents(year: year, month: month, day: 1))!
            let finish = cale.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
            let range = cale.range(of: .day, in: .month, for: start)!

            parent.CntForSum = range.count
            //let otherday = calendar.startOfDay(for:Date())
            
            var current = start
            
            while(current <= finish){
                //print(nowday)
                print(current)
                parent.TotalSum += calculateTotalAmount(for: current)
                current = cale.date(byAdding: .day, value: 1, to: current)!
            }
            
        }
        
        private func calculateTotalAmount(for date: Date) -> Int{
            //↓更新処理（使用するJSONファイルを最新のものにする）
            let currentDataByDate = UserDefaults.standard.string(forKey: "data_by_date") ?? "{}"
            let allData: [String: [[String: String]]] = (try? JSONDecoder().decode([String: [[String: String]]].self, from: Data(currentDataByDate.utf8))) ?? [:]
            let currentDateString = parent.dateFormatter.string(from: date)
            

            
            guard let dailyData = allData[currentDateString] else{
                print("データが見つかりません")
                return 0
            }
            
            return dailyData.reduce(0) { result, entry in
                    if let valueString = entry["value"], let value = Int(valueString) {
                        print("\(currentDateString) = valueString型変更成功 : \(result+value)")
                        return result + value
                    }
                    return result
                }
        }
        
    }
    
    //UIViewRepresentableに準拠しているため必ず実装
    //カレンダーの表示↓
    func makeUIView(context: Context)->UIView{
        typealias UIViewType = FSCalendar
        //let fsCalendar = FSCalendar()
        
        //swiftuiのプロジェクト内でFSCalendarを使用するため、対応するためにCoordinateクラスの作成、利用をするための実装を行う（delegate,dataSourceの定義）
        fsCalendar.delegate = context.coordinator
        fsCalendar.dataSource = context.coordinator
        fsCalendar.appearance.titleOffset = CGPoint(x: 0, y: -10)
        fsCalendar.appearance.titleWeekendColor = .red//週末（土、日曜の日付表示カラー）
        fsCalendar.appearance.borderRadius = 0 //本日・選択日の塗りつぶし角丸量
        fsCalendar.appearance.todaySelectionColor = UIColor.black
        fsCalendar.appearance.selectionColor = .clear //選択した日付のカラー
        fsCalendar.appearance.todayColor = .clear
        fsCalendar.appearance.titleTodayColor = .black
        fsCalendar.appearance.borderSelectionColor = UIColor.clear//選択した日付のボーダーカラー
        fsCalendar.appearance.titleSelectionColor = UIColor.black//選択した日付のテキストカラー
        
        return fsCalendar
    }
    
    //UIViewRepresentableに準拠している構造体は必ず実装
    //変更を確実に反映するようにしている。
    
    //UIViewRepresentableに準拠しているため必ず実装
    //swiftuiのプロジェクト内でFSCalendarを使用するため、対応するためにCoordinateクラスの作成、利用をするための実装を行う（makeCoordinatorメソッド、Coordinatorクラス）
    func makeCoordinator() -> Coordinator{
        return Coordinator(self)
    }
    
}


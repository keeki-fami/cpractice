//
//  Helper.swift
//  cpractice
//
//  Created by 桜田聖和 on 2025/04/14.
//
import SwiftUI
import UIKit

//目標金額の保存
func saveGoal(goal_num:String) {
    let data = MyData(goal_num: goal_num)
    
    if let jsondata = try? JSONEncoder().encode(data) {
        
        let jsonstring = String(data: jsondata, encoding: .utf8)
        UserDefaults.standard.set(jsonstring, forKey: "goalkey")
        //print("保存しました。")
        
    } else {
        
        //print("保存失敗")
        
    }
}

//Stringー＞０以上の整数に変換する
func formatInput(_ input: String) -> String {
    let filtered = input.filter { $0.isNumber }
    if let intValue = Int(filtered) {
        return "\(intValue)"
    }
    return "0"
}

struct MyData: Codable {
    let goal_num: String
}

//(主に起動時に)保存しておいた目標金額をgoal_numに格納する
func decodeGoal() -> String? {
    if let jsongoal = UserDefaults.standard.string(forKey: "goalkey") {
        if let jsondata = jsongoal.data(using: .utf8),
           let decodedData = try? JSONDecoder().decode(MyData.self, from: jsondata) {
            return decodedData.goal_num
        } else {
            //print("デコード失敗")
        }
    } else {
        //print("保存されたデータがありません。")
    }
    return nil
}

func getWeekDay()->Int{
    return Calendar.current.component(.weekday,from:Date())-1 //0:日曜日 0-indexedに合わせる
}

func getWeekAnyDay(date:Date)->Int{
    return Calendar.current.component(.weekday,from:date)-1//0-indexed
}

func TodayGoalNum()->Int{
    let idx:Int = getWeekDay()
    guard 0<=idx && idx<7 else{
        return 0 //えらーが生じた場合、とりあえず０（日曜日）を返す
    }
    
    return idx
}


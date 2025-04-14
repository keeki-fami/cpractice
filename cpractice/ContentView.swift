//
//  ContentView.swift
//  cpractice
//
//  Created by 桜田聖和 on 2024/12/08.
//

import SwiftUI
import FSCalendar
import AudioToolbox
import AppVersionMonitorSwiftUI
import StoreKit

struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct ContentView: View {
    @State private var selectedDate: IdentifiableDate? = nil
    @State private var goal_num: String = "0"
    //@State private var isGoalActive: Bool = false
    @State var notificationname = Notification.Name("notify")
    @State private var fsCalendar = FSCalendar()
    @State private var totalnum:Int = 0
    @State private var totaladvantage:Int = 0
    @State private var TotalSum:Int = 0
    @State private var row: [[String: String]] = []
    @State private var TotalAmountSpentThisMonth:Int = 0
    @State private var Month:Int = 0
    @State private var GoalNumForMonth:Int = 0
    @State var WeekData:[String] = ["0","0","0","0","0","0","0"]
    @AppStorage("week_goalnum") var weekGoalnum:String = "{}"
    @State var isAlert:Bool = false
    @State var updateCount:Int = 0
 
    
    var body: some View {
        
        NavigationView {
            VStack{
                
                
                GeometryReader{geometry in
                    //let widthRatio: CGFloat = 1.0
                    let underheightRatio:CGFloat = 0.20
                    let titleheightRatio:CGFloat = 0.05
                    let calendarheightRatio:CGFloat = 0.7
                    
                    let componentWidth = geometry.size.width * 0.995
                    //let titleHeight = geometry.size.height * titleheightRatio
                    let calendarHeight = geometry.size.height * calendarheightRatio
                    let componentHeight = geometry.size.height * underheightRatio
                    
                    VStack{
                        VStack{
                            //ロゴ：Coilin
                            ZStack{
                                Rectangle()
                                    .fill(Color.cyan)
                                    .edgesIgnoringSafeArea(.top)
                                    .position(x:geometry.size.width*0.5,y:15)
                                    .frame(height:titleheightRatio*geometry.size.height)
                                Text("Coilin")
                                    .font(.custom("bold",size:24))
                                    .foregroundStyle(.white)

                                
                                //ボタン
                            }
                            
                            ScrollView{
                                ZStack{
                                    Color.white
                                        .ignoresSafeArea()
                                    CalendarTestView(selectedDate: $selectedDate, goal_num: $goal_num, notificationname: $notificationname,fsCalendar:$fsCalendar,TotalSum:$TotalSum,row:$row
                                        ,TotalAmountSpentThisMonth:$TotalAmountSpentThisMonth
                                        ,Month:$Month
                                        ,WeekData: $WeekData
                                        ,updateCount: $updateCount)
                                        .sheet(item: $selectedDate) { identifiableDate in
                                            ModalView(
                                                date: identifiableDate.date,
                                                fsCalendar: $fsCalendar,
                                                row: $row,
                                                TotalSum: $TotalSum,
                                                TotalAmountSpentThisMonth: $TotalAmountSpentThisMonth,
                                                updateCount: $updateCount)


                                        }
                                        .frame(width:componentWidth,height:calendarHeight)
                                        .onAppear(){
                                            updateCount = 2
                                        }
                                    
                                }
                                
                                //}//VStack（カレンダー部分まで）
                                
                                
                                
                                
                                
                                Spacer()
                                //undercalendarview
                                UnderCalendarView(
                                    goal_num: $goal_num,
                                    TotalAmountSpentThisMonth: $TotalAmountSpentThisMonth,
                                    Month: $Month,
                                    TotalSum: $TotalSum,
                                    fsCalendar: $fsCalendar,
                                    WeekData : $WeekData,
                                    componentHeight: componentHeight
                                )
                            }
                        }//VStack（カレンダー部分まで）
                    }
                    
                }
                
                
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cyan)
            .onAppear(){
                WeekData = decodeWeekGoalnum()
                print("WeekData\(WeekData)")
                goal_num = WeekData[TodayGoalNum()]
                
                
            }
            
        }
        .alert(isPresented: $isAlert) {
            Alert(title: Text("お知らせ"), message: Text("最新のバージョンをインストールしてください。"), dismissButton: .default(Text("OK")) {
                if let url = URL(string: "https://apps.apple.com/jp/app/coilin-%E5%90%91%E4%B8%8A%E5%BF%83%E3%82%92%E5%88%BA%E6%BF%80%E3%81%99%E3%82%8B%E3%81%8A%E5%B0%8F%E9%81%A3%E3%81%84%E5%B8%B3/id6743780127"){
                    UIApplication.shared.open(url)
                }
        })
        }
        .appVersionMonitor(id: 6743780127) { status in
                    switch status {
                    case .updateAvailable:
                        isAlert = true
                        print("アップデートがあります")
                    case .updateUnavailable:
                        print("アップデートがありません")
                    case .failure(let error):
                        print("エラーが発生しました: \(error)")
                    }
                }
        
        
        
    }
    
    //decodeGoal
    
    private func totalsum(){
        TotalSum = row.reduce(0){value,arr in
            if let valueStr = arr["value"],let valueint = Int(valueStr){
                return value + valueint
            }
            return value
        }
    }
    
    func decodeWeekGoalnum()->[String]{
        //print("decodeWeekGoalnumのデコード開始")
        var weekData:[String] = (try? JSONDecoder().decode([String].self,from:Data(weekGoalnum.utf8))) ?? []
        //print("decodeWeekGoalnumのデコード終了")
        while weekData.count<7{
            weekData.append("0")
        }
        
        //print(weekData)
        return weekData
    }
    

    

}
#Preview{
    ContentView()
}

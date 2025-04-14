//
//  ContentView.swift
//  cpractice
//
//  Created by 桜田聖和 on 2024/12/08.
//

import SwiftUI
import FSCalendar
import AudioToolbox

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
    @State private var CntForSum:Int = 0
    @State private var Month:Int = 0
    
    
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
                            }
                            
                            ScrollView{
                                ZStack{
                                    Color.white
                                        .ignoresSafeArea()
                                    CalendarTestView(selectedDate: $selectedDate, goal_num: $goal_num, notificationname: $notificationname,fsCalendar:$fsCalendar,TotalSum:$TotalSum,row:$row, CntForSum: $CntForSum,Month:$Month)
                                        .sheet(item: $selectedDate) { identifiableDate in
                                            ModalView(
                                                date: identifiableDate.date,
                                                fsCalendar: $fsCalendar,
                                                row: $row,
                                                TotalSum: $TotalSum,
                                                CntForSum: $CntForSum)
                                        }
                                    
                                        .frame(width:componentWidth,height:calendarHeight)
                                    
                                }
                                
                                //}//VStack（カレンダー部分まで）
                                
                                
                                
                                
                                
                                Spacer()
                                //undercalendarview
                                UnderCalendarView(
                                    goal_num: $goal_num,
                                    CntForSum: $CntForSum,
                                    Month: $Month,
                                    TotalSum: $TotalSum,
                                    fsCalendar: $fsCalendar,
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
    

}
#Preview{
    ContentView()
}

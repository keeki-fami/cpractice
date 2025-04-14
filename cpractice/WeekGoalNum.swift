//
//  WeekGoalNum.swift
//  cpractice
//
//  Created by 桜田聖和 on 2025/04/11.
//

//TODO:曜日単位で目標金額の設定を行う。
//全ての曜日に対するTextFieldを用意する。タイトルはNavigationViewを使用。
import SwiftUI
import FSCalendar


struct WeekGoalNum:View{
    @Binding var Month:Int
    @State var WeekData:[String] = ["0","0","0","0","0","0","0"]
    @Environment(\.dismiss) var dismiss
    @AppStorage("week_goalnum") var weekGoalnum:String = "{}"
    
    var body:some View{
            NavigationView{
                VStack{
                    ScrollView{
                        Text("目標金額の設定")
                        // WeekData = decodeWeekGoalnum()
 
                        TextField("月曜日",text: $WeekData[0])
                            .onChange(of: WeekData[0]){ newValue in
                                WeekData[0] = formatInput(newValue)
                            }
                        TextField("火曜日",text: $WeekData[1])
                            .onChange(of: WeekData[1]){ newValue in
                                WeekData[1] = formatInput(newValue)
                            }
                        TextField("水曜日",text: $WeekData[2])
                            .onChange(of: WeekData[2]){ newValue in
                                WeekData[2] = formatInput(newValue)
                            }
                        TextField("木曜日",text: $WeekData[3])
                            .onChange(of: WeekData[3]){ newValue in
                                WeekData[3] = formatInput(newValue)
                            }
                        TextField("金曜日",text: $WeekData[4])
                            .onChange(of: WeekData[4]){ newValue in
                                WeekData[4] = formatInput(newValue)
                            }
                        TextField("土曜日",text: $WeekData[5])
                            .onChange(of: WeekData[5]){ newValue in
                                WeekData[5] = formatInput(newValue)
                            }
                        TextField("日曜日",text: $WeekData[6])
                            .onChange(of: WeekData[6]){ newValue in
                                WeekData[6] = formatInput(newValue)
                            }
                        
                        Button(action:{
                            encodeWeekGoalnum()
                            dismiss()
                        },label:{
                            Text("決定")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width:300,height:50)
                                .background(Color.cyan)
                                .cornerRadius(30)
                        })
                        
                        
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                    .onAppear {
                        //ビュー出現時に各配列に値を格納
                        WeekData = decodeWeekGoalnum()
                    }
                }
                .navigationBarTitle("\(Month)月",displayMode: .inline)
                .toolbarBackground(Color.cyan, for: .navigationBar) // 背景色を青に設定
                .toolbarBackground(.visible, for: .navigationBar) // 背景を表示
                            
            }
        
        

        
    }
    func decodeWeekGoalnum()->[String]{
        print("decodeWeekGoalnumのデコード開始")
        var weekData:[String] = (try? JSONDecoder().decode([String].self,from:Data(weekGoalnum.utf8))) ?? []
        print("decodeWeekGoalnumのデコード終了")
        while weekData.count<7{
            weekData.append("0")
        }
        
        print(weekData)
        return weekData
    }
    
    func encodeWeekGoalnum(){
        
        print("encodeWeekGoalnumのエンコード開始")
        if let encodedata = try? JSONEncoder().encode(WeekData){
            weekGoalnum = String(data:encodedata,encoding:.utf8) ?? "{}"
        }
        print("encodeWeekGoalnumのエンコード終了")
    }
    
    func formatInput(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        if let intValue = Int(filtered) {
            return "\(intValue)"
        }
        return "0"
    }
}

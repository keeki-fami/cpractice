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
    //@State var WeekData:[String] = ["0","0","0","0","0","0","0"]
    @Binding var WeekData:[String]
    @Environment(\.dismiss) var dismiss
    @AppStorage("week_goalnum") var weekGoalnum:String = "{}"
    @Binding var goal_num:String
    @Binding var fsCalendar:FSCalendar
    @State var settingData:[String] = ["0","0","0","0","0","0","0"]
    @FocusState var isActive: Bool // focusのon/off切り替え
    
    var body:some View{
            NavigationView{
                VStack{
                    ScrollView{

                        Rectangle()
                            .fill(Color(.white))
                            .frame(height:20)
                        HStack{
                            Text(" 目標金額の設定")
                                .padding()
                                .font(.title)
                                .frame(height:30)// 中見出しに適したフォントスタイル
                            Spacer()
                        }
                        // WeekData = decodeWeekGoalnum()
                        
 
                        ZStack{
                            Rectangle()
                                .fill(Color(red: 0.949, green: 0.949, blue: 0.969))
                                .frame(height:350)
                            
                                
                            VStack{
                                HStack{
                                    Text("月")
                                    TextField("月曜日",text: $settingData[1])
                                        .onChange(of: settingData[1]){ newValue in
                                            settingData[1] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                }
                                HStack{
                                    Text("火")
                                    TextField("火曜日",text: $settingData[2])
                                        .onChange(of: settingData[2]){ newValue in
                                            settingData[2] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                }
                                HStack{
                                    Text("水")
                                    TextField("水曜日",text: $settingData[3])
                                        .onChange(of: settingData[3]){ newValue in
                                            settingData[3] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                }
                                HStack{
                                    Text("木")
                                    TextField("木曜日",text: $settingData[4])
                                        .onChange(of: settingData[4]){ newValue in
                                            settingData[4] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                    
                                }
                                HStack{
                                    Text("金")
                                    TextField("金曜日",text: $settingData[5])
                                        .onChange(of: settingData[5]){ newValue in
                                            settingData[5] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                }
                                
                                HStack{
                                    Text("土")
                                    TextField("土曜日",text: $settingData[6])
                                        .onChange(of: settingData[6]){ newValue in
                                            settingData[6] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                    
                                }
                                HStack{
                                    Text("日")
                                    TextField("日曜日",text: $settingData[0])
                                        .onChange(of: settingData[0]){ newValue in
                                            settingData[0] = formatInput(newValue)
                                        }
                                        .frame(width: 330)
                                }
                                
                                
                                
                            }
                            .focused($isActive)
                            .toolbar { ToolbarItemGroup(placement: .keyboard)
                                {
                                    Spacer()
                                    Button("閉じる") {
                                        isActive = false
                                    }
                                }
                            }//toolbar
                        }

                        
                        
                        
                        Button(action:{
                            settingdataToweekdata()
                            encodeWeekGoalnum()
                            fsCalendar.reloadData()

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
                        settingData = decodeWeekGoalnum()

                    }
                }
                .navigationBarTitle("\(Month)月",displayMode: .inline)
                .toolbarBackground(Color.cyan, for: .navigationBar) // 背景色を青に設定
                .toolbarBackground(.visible, for: .navigationBar) // 背景を表示
                            
            }
        
        

        
    }

    func settingdataToweekdata(){
        for i in 0..<7{
            WeekData[i] = settingData[i]
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
    
    func encodeWeekGoalnum(){
        

        //print("encodeWeekGoalnumのエンコード開始")
        if let encodedata = try? JSONEncoder().encode(WeekData){
            weekGoalnum = String(data:encodedata,encoding:.utf8) ?? "{}"
        }
        //print("encodeWeekGoalnumのエンコード終了")
        goal_num = WeekData[TodayGoalNum()]
        //fsCalendar.reloadData()
        

    }
    
    func formatInput(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        if let intValue = Int(filtered) {
            return "\(intValue)"
        }
        return "0"
    }

    
    
}

#Preview{
    ContentView()
}

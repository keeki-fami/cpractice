//
//  UnderCalendarView.swift
//  cpractice
//
//  Created by 桜田聖和 on 2025/04/14.
//

import SwiftUI
import FSCalendar
import AudioToolbox

struct UnderCalendarView:View{
    @State private var isGoalActive: Bool = false
    @Binding var goal_num:String
    @Binding var TotalAmountSpentThisMonth:Int
    @Binding var Month:Int
    @Binding var TotalSum:Int
    @Binding var fsCalendar:FSCalendar
    @Binding var WeekData:[String]
    let componentHeight:CGFloat
    var body:some View{
        HStack{
            ZStack{
                Rectangle()
                    .fill(Color.cyan)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height:componentHeight)
                
                
                HStack{
                    VStack {
                        ZStack{
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth:150,maxHeight:componentHeight*0.9+10)
                                //.ignoresSafeArea(.keyboard, edges: .all)
                            
                                VStack{
                                    Text("今日の目標の金額")

                                        .position(x:75,y:25)
                                    
                                    Text("\(goal_num)")
                                        .position(x:75,y:15)
                                        .font(.custom("bold",size:25))
                                    
                                
                                    
                                    Button(action:{
                                        isGoalActive.toggle()
                                    }){
                                        Text("変更する")
                                            .font(.custom("Regular", size: 15))
                                            .foregroundColor(.white)
                                            .frame(width:100,height:componentHeight*0.25)
                                            .background(Color.cyan)
                                            .cornerRadius(30)
                                            .position(x:75,y:20)
                                    }.sheet(isPresented: $isGoalActive,onDismiss: {
                                        fsCalendar.reloadData()
                                    }){
                                        WeekGoalNum(
                                            Month: $Month,
                                            WeekData: $WeekData,
                                            goal_num: $goal_num,
                                            fsCalendar: $fsCalendar,
                                        )
                                        .onAppear(){
                                            TotalAmountSpentThisMonth = 0
                                        }
                                    }

                                    //
                                    //
                                    //この部分を変更
                                    //↓トレイリングクロージャ
                                    

                                    Button(action:{
                                        isGoalActive.toggle()
                                    }){
                                        Text("変更する")
                                            .font(.custom("Regular", size: 15))
                                            .foregroundColor(.white)
                                            .frame(width:100,height:componentHeight*0.25)
                                            .background(Color.cyan)
                                            .cornerRadius(30)
                                            .position(x:75,y:20)
                                        //.ignoresSafeArea(.keyboard, edges: .all)
                                    }
                                    .alert("目標金額を設定してください。", isPresented: $isGoalActive) {
                                        TextField("数字", text: $goal_num)
                                        
                                            .keyboardType(.decimalPad)
                                            .onChange(of: goal_num){ newValue in
                                                goal_num = formatInput(newValue)
                                                DispatchQueue.main.async {
                                                    fsCalendar.reloadData()
                                                }
                                            }//クロージャ（省略型）
                                        Button("OK"){
                                            saveGoal(goal_num:goal_num)
                                        }
                                    }

                                    
                                    
                                }
                                .frame(maxWidth:150,maxHeight:componentHeight*0.9)
                           
                        }
                        
                        
                    }
                    //.ignoresSafeArea(.keyboard, edges: .all)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                        // ぼかし効果
                        
                            .foregroundStyle(.ultraThinMaterial)
                        // ドロップシャドウで立体感を表現
                            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                    )
                    .overlay(
                        // strokeでガラスの縁を表現
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.init(white: 1, opacity:0.5), lineWidth: 1)
                    )
                    
                    //カレンダー下のVStack
                    
                    //ここまで読んだ
                    
                    VStack{
                        ZStack{
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth:150,maxHeight:componentHeight*0.9+10)
                                //.ignoresSafeArea(.keyboard, edges: .all)
                            VStack{
                                
                                Text("\(Month)月の使用金額")
                                    .position(x:75,y:25)
                                    //.ignoresSafeArea(.keyboard, edges: .all)
                                

                                //CntForSum:月ごとの目標金額
                                //TotalSum:月毎の使用金額
                                    let temp = TotalAmountSpentThisMonth - TotalSum

                                    if temp > 0{
                                        Text("(-\(temp))")
                                            .foregroundColor(.blue)
                                            .font(.custom("bold",size:18))
                                    }
                                    else if temp == 0{
                                        Text("(0)")
                                            .foregroundColor(.blue)
                                            .font(.custom("bold",size:18))
                                        
                                    }
                                    else{
                                        Text("(+\(temp * (-1)))")
                                            .foregroundColor(.red)
                                            .font(.custom("bold",size:18))
                                    }
                                    
                                    HStack(alignment:.bottom){
                                        
                                        Text("¥\(TotalSum)")
                                            .font(.custom("bold",size:18))
                                        
                                        
                                        
                                        

                                        Text("/ ¥\(TotalAmountSpentThisMonth)")
                                            .font(.custom("bold",size:13))
                                            
                                        
                                        
                                    }
                                    .position(x:75,y:20)
                                    

                                
                                
                            }
                            .frame(maxWidth:150,maxHeight:componentHeight*0.9)
                            //.ignoresSafeArea(.keyboard, edges: .all)
                            
                        }
                        
                        
                        
                    }//VStack(今月の目標金額)
                    //.offset(x:0,y:0)
                    //.ignoresSafeArea(.keyboard, edges: .all)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                        // ぼかし効果
                        // .ultraThinMaterialはiOS15から対応
                            .foregroundStyle(.ultraThinMaterial)
                        // ドロップシャドウで立体感を表現
                            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                    )
                    .overlay(
                        // strokeでガラスの縁を表現
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.init(white: 1, opacity:0.5), lineWidth: 1)
                    )
                    
                }
                //.ignoresSafeArea(.keyboard, edges: .all)
                
                
            }
            //.offset(x:0,y:0)
            
            
        }
        .ignoresSafeArea()
        .onAppear {

            //goal_num = decodeGoal() ?? "0"
            goal_num = WeekData[TodayGoalNum()]
        }
    }
    

    
}
#Preview{
    ContentView()

}

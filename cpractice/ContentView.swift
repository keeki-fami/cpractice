//
//  ContentView.swift
//  cpractice
//
//  Created by 桜田聖和 on 2024/12/08.
//

import SwiftUI
import FSCalendar
import AudioToolbox
import StoreKit
import AppVersionMonitorSwiftUI

struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct ContentView: View {
    @State private var selectedDate: IdentifiableDate? = nil
    @State private var goal_num: String = "0"
    @State private var isGoalActive: Bool = false
    @State var notificationname = Notification.Name("notify")
    @State private var fsCalendar = FSCalendar()
    @State private var totalnum:Int = 0
    @State private var totaladvantage:Int = 0
    @State private var TotalSum:Int = 0
    @State private var row: [[String: String]] = []
    @State private var CntForSum:Int = 0
    @State private var Month:Int = 0
    @State private var showUpdateAlert:Bool = false
    
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
                                            ModalView(date: identifiableDate.date, fsCalendar: $fsCalendar, row: $row, TotalSum: $TotalSum, CntForSum: $CntForSum)
                                            
                                            
                                        }
                                    
                                        .frame(width:componentWidth,height:calendarHeight)
                                    
                                }
                                
                                //}//VStack（カレンダー部分まで）
                                
                                
                                
                                
                                
                                Spacer()
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
                                                        
                                                        Text("1日の目標の金額")
                                                            .position(x:75,y:25)
                                                        
                                                        Text("\(goal_num)")
                                                            .position(x:75,y:15)
                                                            .font(.custom("bold",size:25))
                                                        
                                                        
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
                                                                }//クロージャ（省略型）
                                                            Button("OK"){
                                                                saveGoal()
                                                            }
                                                            Button("キャンセル", role: .cancel) {}
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
                                                        
                                                        
                                                        if let num = Int(goal_num){
                                                            let temp = CntForSum*num - TotalSum
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
                                                                
                                                                
                                                                
                                                                
                                                                if let num = Int(goal_num){
                                                                    Text("/ ¥\(num * CntForSum)")
                                                                        .font(.custom("bold",size:13))
                                                                    
                                                                }
                                                                
                                                                
                                                            }
                                                            .position(x:75,y:20)
                                                            
                                                        }
                                                        
                                                        
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
                                    goal_num = decodeGoal() ?? "0"
                                }
                            }
                        }//VStack（カレンダー部分まで）
                    }
                    
                }
                //if let url = URL(string:"https://apps.apple.com/jp/app/coilin-%E5%90%91%E4%B8%8A%E5%BF%83%E3%82%92%E5%88%BA%E6%BF%80%E3%81%99%E3%82%8B%E3%81%8A%E5%B0%8F%E9%81%A3%E3%81%84%E5%B8%B3/id6743780127")
                
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cyan)
        }
        .alert(isPresented: $showUpdateAlert){
            Alert(title: Text("更新"),message:Text("新しいバージョンが公開されています。最新版にアップデートしてください。"),dismissButton:.default(Text("OK")){
                print("最新版を発見しました。")
                openURL()
            })
        }
        .appVersionMonitor(id:6743780127){status in
            switch status{
            case .updateAvailable:
                showUpdateAlert = true
                print("アップデートがあります。")
            case .updateUnavailable:
                print("アップデートがありません")
            case .failure(let error):
                print("エラーが発生しました：\(error)")
            }
        }
        
    }
    
    
    func openURL(){
        if let url = URL(string:"https://apps.apple.com/jp/app/coilin-%E5%90%91%E4%B8%8A%E5%BF%83%E3%82%92%E5%88%BA%E6%BF%80%E3%81%99%E3%82%8B%E3%81%8A%E5%B0%8F%E9%81%A3%E3%81%84%E5%B8%B3/id6743780127"){
            UIApplication.shared.open(url,options:[:],completionHandler:nil)
        }
    }
    
    
    func formatInput(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        if let intValue = Int(filtered) {
            return "\(intValue)"
        }
        return "0"
    }
    
    func saveGoal() {
        let data = MyData(goal_num: goal_num)
        if let jsondata = try? JSONEncoder().encode(data) {
            let jsonstring = String(data: jsondata, encoding: .utf8)
            UserDefaults.standard.set(jsonstring, forKey: "goalkey")
            print("保存しました。")
        } else {
            print("保存失敗")
        }
    }
    
    func decodeGoal() -> String? {
        if let jsongoal = UserDefaults.standard.string(forKey: "goalkey") {
            if let jsondata = jsongoal.data(using: .utf8),
               let decodedData = try? JSONDecoder().decode(MyData.self, from: jsondata) {
                return decodedData.goal_num
            } else {
                print("デコード失敗")
            }
        } else {
            print("保存されたデータがありません。")
        }
        return nil
    }
    
    private func totalsum(){
        TotalSum = row.reduce(0){value,arr in
            if let valueStr = arr["value"],let valueint = Int(valueStr){
                return value + valueint
            }
            return value
        }
    }
    
    struct MyData: Codable {
        let goal_num: String
    }
}

struct ModalView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Binding var fsCalendar:FSCalendar
    @State private var value: String = ""
    @State private var purpose: String = ""
    @Binding var row: [[String: String]]
    @State private var ShowAlert: Bool =  false
    @AppStorage("data_by_date") private var dataByDate: String = "{}"
    @Binding var TotalSum: Int
    @Binding var CntForSum:Int
    @FocusState var isActive: Bool // focusのon/off切り替え
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        NavigationView{
            
            VStack {
                Rectangle()
                    .fill(Color.cyan)
                    .edgesIgnoringSafeArea(.all)
                    .frame(height:8)
                ScrollView{
                    
                    VStack{
                        HStack{
                            Text("  入力")
                                .font(.title)
                                .frame(height:30)// 中見出しに適したフォントスタイル
                            Spacer()
                        }
                        
                        ZStack{
                            Rectangle()
                                .fill(Color(red: 0.949, green: 0.949, blue: 0.969))
                                .frame(height:300)
                            
                            //4216bb9cbc6c5
                            VStack{
                                TextField("金額を入力してください", text: $value)
                                
                                    .frame(width: 330)
                                
                                
                                
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($isActive)
                                    .toolbar { ToolbarItemGroup(placement: .keyboard)
                                        {
                                            Spacer()
                                            Button("閉じる") {
                                                isActive = false
                                            }
                                        }
                                    }//toolbar
                                
                                TextField("内容", text: $purpose)
                                    .frame(width:330)
                                
                                
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($isActive)
                                    .padding(.bottom)
                                
                                if value.count > 0 && purpose.count > 0 {
                                    Button(action:{
                                        
                                        saveData()
                                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(1521)) {}
                                        dismiss()
                                        requestReview()
                                        
                                    },label:{
                                        Text("記録")
                                        
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(width:300,height:50)
                                            .background(Color.cyan)
                                            .cornerRadius(30)
                                    })
                                    
                                } else {
                                    Button(action: {
                                        
                                        
                                        ShowAlert.toggle()
                                        
                                    },label:{
                                        Text("記録")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(width:300,height:50)
                                            .background(Color.cyan)
                                            .cornerRadius(30)
                                    })
                                    .padding()
                                }
                            }
                            .ignoresSafeArea(.keyboard)
                            
                            
                            //入力欄VStack
                        }
                        
                        
                        
                        
                        HStack{
                            Text("  履歴")
                                .font(.title)
                                .frame(height:30)//キーボードで動く対策
                            Spacer()
                        }
                        
                        
                        
                        ZStack{
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height:300)
                            Text("現在登録しているデータはありません")
                            ZStack {
                                // 背景色
                                Color(red: 0.949, green: 0.949, blue: 0.969)
                                
                                    .ignoresSafeArea() // 画面全体に適用
                                if row.isEmpty {
                                    Text("リストがありません").ignoresSafeArea()
                                        .foregroundColor(.black)
                                } else {
                                    List {
                                        ForEach(row, id: \.self) { valuenum in
                                            if let value = valuenum["value"], let purpose = valuenum["purpose"] {
                                                Text("¥\(value) - \(purpose)")
                                            }
                                        }
                                        .onDelete(perform: deleteRow)
                                    }//List
                                }
                            }
                            
                        }
                    }//全体のVStack
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onAppear {
                        //ここを消すと、リストが描画されなかった
                        
                        loadDailyData()
                    }
                    .alert("Error", isPresented: $ShowAlert) {
                    } message: {
                        Text("全ての項目を入力してください。")
                    }
                }
            }//全体VStack
            .navigationTitle("\(dateFormatter.string(from: date))")
            .navigationBarTitleDisplayMode(.inline)
        }//NavigationView
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func saveData() {
        let currentDate = dateFormatter.string(from: date)
        var allData: [String: [[String: String]]] = (try? JSONDecoder().decode([String: [[String: String]]].self, from: Data(dataByDate.utf8))) ?? [:]
        
        var currentDateData = allData[currentDate] ?? []
        currentDateData.append(["value": value, "purpose": purpose])
        allData[currentDate] = currentDateData
        
        
        if let encodedData = try? JSONEncoder().encode(allData) {
            dataByDate = String(data: encodedData, encoding: .utf8) ?? "{}"
        }
        
        // カレンダー更新の通知を送信
        CntForSum = 0
        fsCalendar.reloadData()
        
    }
    
    //指定した日から
    private func loadDailyData() {
        let currentDate = dateFormatter.string(from: date)
        
        if let allData = try? JSONDecoder().decode([String: [[String: String]]].self, from: Data(dataByDate.utf8)){
            row = allData[currentDate] ?? []
        }
        
    }
    
    private func deleteRow(at offsets: IndexSet) {
        offsets.forEach { index in
            row.remove(at: index)
        }
        
        let currentDate = dateFormatter.string(from: date)
        var allData: [String: [[String: String]]] = (try? JSONDecoder().decode([String: [[String: String]]].self, from: Data(dataByDate.utf8))) ?? [:]
        allData[currentDate] = row
        
        if let encodedData = try? JSONEncoder().encode(allData) {
            dataByDate = String(data: encodedData, encoding: .utf8) ?? "{}"
        }
        
        // カレンダー更新の通知を送信
        CntForSum = 0
        fsCalendar.reloadData()
    }
    
    
}

#Preview{
    ContentView()
}

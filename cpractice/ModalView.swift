
import SwiftUI
import FSCalendar
import AudioToolbox

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
    //dateformatter
    
    //savedata
    
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
    
    func saveData() {
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    
}





#Preview{
    ContentView()
}



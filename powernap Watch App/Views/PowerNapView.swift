import SwiftUI
import WatchKit

struct PowerNapView: View {
    @ObservedObject var viewModel: PowerNapViewModel
    @State private var selectedTimeDouble: Double = 5.0
    
    // 計算屬性轉換為Int
    private var selectedTime: Int {
        return Int(selectedTimeDouble)
    }
    
    var body: some View {
        ZStack {
            // 背景改為純黑色
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // 主要內容
            VStack(spacing: 0) {
                // 顯示當前時間
                if viewModel.isSessionActive || viewModel.sleepDetected {
                    // 監測或睡眠狀態下顯示倒計時
                    countdownView
                } else {
                    // 時間選擇器
                    timePickerView
                }
                
                Spacer(minLength: 0) // 確保按鈕位置穩定
                
                // 開始按鈕或控制按鈕
                if viewModel.isSessionActive || viewModel.sleepDetected {
                    Button(action: viewModel.stopNap) {
                        Text("取消")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity) // 確保按鈕佔據可用寬度
                    }
                    .buttonStyle(BorderlessButtonStyle()) // 使用無邊框按鈕樣式
                } else {
                    Button(action: {
                        viewModel.setDuration(selectedTime)
                        viewModel.startNap()
                    }) {
                        Text("開始休息")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity) // 確保按鈕佔據可用寬度
                    }
                    .buttonStyle(BorderlessButtonStyle()) // 使用無邊框按鈕樣式
                    
                    // 快速時間選擇按鈕
                    HStack(spacing: 10) {
                        Button(action: { selectedTimeDouble = 5.0 }) {
                            Text("5分鐘")
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedTime == 5 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button(action: { selectedTimeDouble = 10.0 }) {
                            Text("10分鐘")
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedTime == 10 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer(minLength: 20) // 底部留一點空間
            }
            .padding()
        }
        .onAppear {
            selectedTimeDouble = Double(viewModel.selectedDuration)
            // 添加數字錶冠控制
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    // 倒計時視圖
    private var countdownView: some View {
        VStack(spacing: 10) {
            if viewModel.sleepDetected {
                Text("小睡中")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Text("監測中")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if viewModel.sleepDetected {
                // 倒計時顯示
                Text(viewModel.formattedTimeRemaining())
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                // 進度環
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.progress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.progress)
                }
                .padding(.top, 5)
            } else {
                // 監測等待動畫
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("等待入睡...")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // 時間選擇器視圖
    private var timePickerView: some View {
        VStack(spacing: 0) {
            // 增加頂部空間，讓內容顯著往下移
            Spacer(minLength: 110)
            
            // 自定義時間選擇器
            ZStack {
                // 灰色背景框
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 2)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                
                // 時間選擇器內容
                Picker("選擇時間", selection: $selectedTimeDouble) {
                    ForEach(1...30, id: \.self) { minute in
                        Text("\(minute):00")
                            .foregroundColor(.white)
                            .tag(Double(minute))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .accentColor(.gray) // 嘗試設置選擇指示器顏色
                .onChange(of: selectedTimeDouble) { _ in
                    WKInterfaceDevice.current().play(.click)
                }
            }
            .frame(height: 110)
            .padding(.bottom, 5)
            
            // 分鐘文字放在選擇器下方
            Text("分鐘")
                .font(.system(size: 18)) // 稍微縮小字體
                .fontWeight(.regular)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 20) // 調整底部間距
             
            // 移除底部Spacer，讓按鈕位置更穩定
        }
    }
} 
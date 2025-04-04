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
        GeometryReader { geometry in
            ZStack {
                // 背景改為純黑色
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                // 主要內容 - 使用VStack並基於屏幕比例設置間距
                VStack(spacing: 0) {
                    // 顯示當前時間
                    if viewModel.isSessionActive || viewModel.sleepDetected {
                        // 監測或睡眠狀態下顯示倒計時
                        countdownView(geometry: geometry)
                    } else {
                        // 時間選擇器
                        timePickerView(geometry: geometry)
                    }
                    
                    // 按鈕區域 - 使用比例佈局讓它在所有設備上都有適當位置
                    buttonArea(geometry: geometry)
                }
                .padding(.horizontal, geometry.size.width * 0.05) // 水平間距使用屏幕寬度的5%
                .padding(.vertical, geometry.size.height * 0.03) // 垂直間距使用屏幕高度的3%
            }
        }
        .onAppear {
            selectedTimeDouble = Double(viewModel.selectedDuration)
            // 添加數字錶冠控制
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    // 按鈕區域 - 提取為函數以接收geometry參數
    private func buttonArea(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // 根據屏幕高度調整按鈕與選擇器之間的距離
            Spacer()
                .frame(height: geometry.size.height * 0.2) // 增加間距讓按鈕往下移
            
            // 開始按鈕或控制按鈕
            if viewModel.isSessionActive || viewModel.sleepDetected {
                Button(action: viewModel.stopNap) {
                    Text("取消")
                        .font(.system(size: geometry.size.width * 0.1, weight: .bold))
                        .foregroundColor(.white)
                        // 先設置固定高度，再應用背景色 - 寬度縮小到60%
                        .frame(width: geometry.size.width * 0.60, height: geometry.size.height * 0.25)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(30)
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Button(action: {
                    viewModel.setDuration(selectedTime)
                    viewModel.startNap()
                }) {
                    Text("開始休息")
                        .font(.system(size: geometry.size.width * 0.1, weight: .bold))
                        .foregroundColor(.white)
                        // 先設置固定高度，再應用背景色
                        .frame(width: geometry.size.width * 0.80, height: geometry.size.height * 0.25)
                        .background(Color.blue)
                        .cornerRadius(30) // 增加圓角以匹配更圓潤的外觀
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            // 底部空間
            Spacer(minLength: geometry.size.height * 0.05)
        }
    }
    
    // 倒計時視圖 - 使用比例佈局
    private func countdownView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.01) {
            if viewModel.sleepDetected {
                Text("小睡中")
                    .font(.system(size: min(18, geometry.size.width * 0.05)))
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Text("監測中")
                    .font(.system(size: min(18, geometry.size.width * 0.05)))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if viewModel.sleepDetected {
                // 倒計時顯示
                Text(viewModel.formattedTimeRemaining())
                    .font(.system(size: min(48, geometry.size.width * 0.15), weight: .bold))
                    .foregroundColor(.white)
                
                // 進度環 - 使用比例尺寸
                let circleSize = min(geometry.size.width * 0.7, geometry.size.height * 0.4)
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: circleSize * 0.06))
                        .frame(width: circleSize, height: circleSize)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.progress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: circleSize * 0.06, lineCap: .round))
                        .frame(width: circleSize, height: circleSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.progress)
                }
                .padding(.top, geometry.size.height * 0.01)
            } else {
                // 監測等待動畫
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: min(40, geometry.size.width * 0.12)))
                    .foregroundColor(.white)
                
                Text("等待入睡...")
                    .font(.system(size: min(16, geometry.size.width * 0.045)))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        // 垂直居中但稍微往上偏移
        .padding(.top, geometry.size.height * 0.1)
    }
    
    // 時間選擇器視圖 - 使用比例佈局
    private func timePickerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // 根據屏幕比例計算頂部空間
            Spacer().frame(height: geometry.size.height * 0.18)
            
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
                            .font(.system(size: geometry.size.width * 0.12)) // 為選擇器文字設置明確的字體大小
                            .tag(Double(minute))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .accentColor(.gray)
                .onChange(of: selectedTimeDouble) { _ in
                    WKInterfaceDevice.current().play(.click)
                }
            }
            .frame(height: geometry.size.height * 0.25) // 選擇器高度為屏幕高度的25%
            .padding(.bottom, geometry.size.height * 0.01)
            
            // 分鐘文字 - 設置與時間選擇器相同大小
            Text("分鐘")
                .font(.system(size: geometry.size.width * 0.12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, geometry.size.height * 0.03)
        }
    }
} 
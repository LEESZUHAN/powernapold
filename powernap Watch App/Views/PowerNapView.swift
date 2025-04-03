import SwiftUI
import WatchKit

struct PowerNapView: View {
    @ObservedObject var viewModel: PowerNapViewModel
    @State private var selectedTime = 5
    
    var body: some View {
        ZStack {
            // 背景漸變
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // 主要內容
            VStack(spacing: 20) {
                // 顯示當前時間
                if viewModel.isSessionActive || viewModel.sleepDetected {
                    // 監測或睡眠狀態下顯示倒計時
                    countdownView
                } else {
                    // 時間選擇器
                    timePickerView
                }
                
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
                    }
                    .padding(.top, 20)
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
                    }
                    .padding(.top, 20)
                    
                    // 快速時間選擇按鈕
                    HStack(spacing: 10) {
                        Button(action: { selectedTime = 5 }) {
                            Text("5分鐘")
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedTime == 5 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button(action: { selectedTime = 10 }) {
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
            }
            .padding()
        }
        .onAppear {
            selectedTime = viewModel.selectedDuration
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
        VStack(spacing: 15) {
            Text("等待開始")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
            
            // 時間選擇器，支持手指滑動和錶冠
            Picker("選擇時間", selection: $selectedTime) {
                ForEach(1...30, id: \.self) { minute in
                    Text("\(minute):00")
                        .foregroundColor(.white)
                        .tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .labelsHidden()
            .onChange(of: selectedTime) { newValue in
                WKInterfaceDevice.current().play(.click)
            }
            
            Text("分鐘")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
    }
} 
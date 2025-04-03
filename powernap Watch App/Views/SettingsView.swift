import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("playAudio") private var playAudio = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @ObservedObject var viewModel: PowerNapViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Group {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                        Text("音效")
                        Spacer()
                        Toggle("", isOn: $playAudio)
                            .labelsHidden()
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                        Text("震動")
                        Spacer()
                        Toggle("", isOn: $vibrationEnabled)
                            .labelsHidden()
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "bed.double")
                        Text("自動檢測睡眠")
                        Spacer()
                        Toggle("", isOn: $viewModel.isSleepDetectionEnabled)
                            .labelsHidden()
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "bell")
                        Text("通知")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                
                VStack(spacing: 2) {
                    Text("PowerNap")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Text("版本 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("設置")
    }
} 
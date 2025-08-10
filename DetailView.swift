import SwiftUI

struct DetailView: View {
    let bpm: Int
    let hrv: Float
    let spo2: Int
    @Binding var backToHome: Bool
    @State private var shouldPlayLottie = true
    @EnvironmentObject var historyModel: HistoryModel

    var moodLevel: Int {
        if bpm > 95 || hrv < 25 {
            return 1 // stressed
        } else if bpm < 75 && hrv > 40 {
            return 3 // relaxed
        } else {
            return 2 // neutral
        }
    }

    var cocoTip: String {
        switch moodLevel {
        case 1:
            return "ゆっくり深呼吸してね。大丈夫、がんばりすぎなくていいんだよ🍃"
        case 2:
            return "その調子で自分のペースを大切にね☕️ たまにはひと息ついてみて。"
        case 3:
            return "とってもいい状態だね🌸 今日のこの気持ち、覚えておこう✨"
        default:
            return ""
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {

                    // 📊 HRV Graph
                    HRVGraphView()
                        .frame(height: 280)

                    // 🦒 Lottie + Mood
                    HStack {
                        LottieView(filename: "Meditating Giraffe", isPlaying: shouldPlayLottie)
                            .frame(height: 200)

                        VStack(alignment: .leading, spacing: 12) {
                            Group {
                                if moodLevel == 1 {
                                    Text("  心拍数 : \(bpm) BPM\n心拍変動: \(String(format: "%.1f", hrv)) ms\n酸素濃度: \(spo2)%")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("少しストレス反応が見られるよ。落ち着く呼吸をして、心を整えよう🍃")
                                } else if moodLevel == 2 {
                                    
                                    Text("  心拍数 : \(bpm) BPM\n心拍変動: \(String(format: "%.1f", hrv)) ms\n酸素濃度: \(spo2)%")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("穏やかな状態だよ。リズムを崩さず過ごしてね✨")
                                } else if moodLevel == 3 {
                                    
                                    Text("  心拍数 : \(bpm) BPM\n心拍変動: \(String(format: "%.1f", hrv)) ms\n酸素濃度: \(spo2)%")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("とってもリラックスできてるみたい🌸\n心と体が整っていて理想的な状態だよ")
                                }
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .foregroundColor(.black)
                        }
                        .offset(x: -20)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("🦒 Coco’s Tip")
                            .font(.headline)
                            .foregroundColor(.brown)

                        Text(cocoTip)
                            .font(.body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("詳細データ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        backToHome = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る").bold()
                        }
                    }
                }
            }
            .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(red: 250/255, green: 246/255, blue: 235/255))
        }
    }
}

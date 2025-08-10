import SwiftUI

struct Measuring_View: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var historyModel: HistoryModel // 💖 Add this
    
    @Binding var backToHome: Bool
    @State private var shouldPlayLottie = true
    @State private var navigateToDetail = false
    @State private var isNewDataAvailable = false

    var body: some View {
        GeometryReader { geometry in
            VStack {

                LottieView(filename: "Heart", delay: 2.0, isPlaying: shouldPlayLottie)
                    .frame(height: 250)

                LottieView(filename: "ECG", delay: 2.0, isPlaying: shouldPlayLottie)
                    .frame(height: 100)

                VStack(spacing: 20) {
                    HStack {
                        Text("   BPM（心拍数） :")
                            .font(.headline)
                            .foregroundStyle(Color(red: 84/255, green: 54/255, blue: 47/255))
                        Spacer()
                        Text("\(bleManager.bpm) bpm")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }

                    HStack {
                        Text(" HRV（心拍変動）:")
                            .font(.headline)
                            .foregroundStyle(Color(red: 84/255, green: 54/255, blue: 47/255))
                        Spacer()
                        Text(String(format: "%.2f", bleManager.hrv))
                            .font(.title3)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("SpO₂（酸素濃度）:")
                            .font(.headline)
                            .foregroundStyle(Color(red: 84/255, green: 54/255, blue: 47/255))
                        Spacer()
                        Text("\(bleManager.spo2)%")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                .padding(20)
                .padding(.horizontal, 50)

                Spacer()

                if isNewDataAvailable {
                    Button("View Detail") {
                        navigateToDetail = true
                    }
                    .font(.body)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color(red: 84/255, green: 54/255, blue: 47/255))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }else {
                    Text("データを取得中です…") //  “Still processing…”
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(red: 250/255, green: 246/255, blue: 235/255))
            .navigationTitle("測定結果")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToDetail) {
                DetailView(
                    bpm: bleManager.bpm,
                    hrv: bleManager.hrv,
                    spo2: bleManager.spo2,
                    backToHome: $backToHome
                )
            }
            .onChange(of: bleManager.bpm) {
                checkIfDataIsReady()
            }
            .onChange(of: bleManager.hrv) {
                checkIfDataIsReady()
            }
            .onChange(of: bleManager.spo2) {
                checkIfDataIsReady()
            }
        }
    }

    func checkIfDataIsReady() {
        if bleManager.bpm > 0 && bleManager.hrv > 0 && bleManager.spo2 > 0 {
            if !isNewDataAvailable {
                // 💾 Save only once!
                historyModel.addEntry(bpm: bleManager.bpm, hrv: bleManager.hrv, spo2: bleManager.spo2)
                isNewDataAvailable = true
            }
        }
    }

}

#Preview {
    Measuring_View(backToHome: .constant(false))
        .environmentObject(BLEManager())
}

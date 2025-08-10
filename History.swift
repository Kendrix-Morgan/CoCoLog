//  HistoryView.swift
//  HeartEase / CocoLog

import SwiftUI

struct MeasurementEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let bpm: Int
    let hrv: Float
    let spo2: Int
}

class HistoryModel: ObservableObject {
    @Published var entries: [MeasurementEntry] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    func addEntry(bpm: Int, hrv: Float, spo2: Int) {
        let newEntry = MeasurementEntry(date: Date(), bpm: bpm, hrv: hrv, spo2: spo2)
        entries.insert(newEntry, at: 0) // Newest on top
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "measurementHistory")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "measurementHistory"),
           let decoded = try? JSONDecoder().decode([MeasurementEntry].self, from: data) {
            entries = decoded
        }
    }
}
import SwiftUI

struct History: View {
    @EnvironmentObject var historyModel: HistoryModel

    // 🔁 MeasurementEntry を日付でグループ化
    var groupedEntries: [String: [MeasurementEntry]] {
        Dictionary(grouping: historyModel.entries) { entry in
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.locale = Locale(identifier: "ja_JP")
            if Calendar.current.isDateInToday(entry.date) {
                return "今日"
            }
            return formatter.string(from: entry.date)
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "FAF6EB").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    (
                        Text("すべての") +
                        Text("心拍数").foregroundColor(.pink) +
                        Text("データ")
                    )
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 4)

                    // 🔁 日付ごとの表示
                    ForEach(groupedEntries.keys.sorted(by: sortDateString), id: \.self) { dateKey in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(dateKey)
                                .font(.headline)
                                .padding(.top, 8)

                            ForEach(groupedEntries[dateKey] ?? []) { entry in
                                HStack {
                                    Text("\(entry.bpm) 拍/分")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)

                                    Spacer()

                                    Text("HRV \(String(format: "%.1f", entry.hrv))")
                                        .font(.subheadline)
                                        .foregroundColor(.white)

                                    AnimatedHeart()
                                }
                                .padding()
                                .background(Color(hex: "914D26"))
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    // 📅 並び順のための日付比較
    func sortDateString(_ lhs: String, _ rhs: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")

        if lhs == "今日" { return true }
        if rhs == "今日" { return false }

        if let lhsDate = formatter.date(from: lhs),
           let rhsDate = formatter.date(from: rhs) {
            return lhsDate > rhsDate
        }
        return false
    }
}

// ❤️ アニメーションするハート
struct AnimatedHeart: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.pink)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.3
                }
            }
    }
}

#Preview {
    History()
        .environmentObject(HistoryModel())
}

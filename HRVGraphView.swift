import SwiftUI
import Charts

struct HRVGraphView: View {
    @EnvironmentObject var historyModel: HistoryModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if historyModel.entries.isEmpty {
                Text("まだデータがありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(alignment: .leading) {
                    Text("HRV レベル")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
                        .padding(.leading)

                    ZStack {
                        Chart {
                            let recentEntries = Array(historyModel.entries.sorted(by: { $0.date < $1.date }).suffix(4))
                            ForEach(recentEntries) { entry in
                                LineMark(
                                    x: .value("時間", entry.date),
                                    y: .value("HRV", entry.hrv)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color(red: 180/255, green: 102/255, blue: 90/255))
                                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                                .symbol(Circle())
                                .foregroundStyle(Color(red: 180/255, green: 102/255, blue: 90/255))

                                AreaMark(
                                    x: .value("時間", entry.date),
                                    y: .value("HRV", entry.hrv)
                                )
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [
                                            Color(red: 180/255, green: 102/255, blue: 90/255).opacity(0.3),
                                            .clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(), centered: true)
                                    .foregroundStyle(Color(red: 84/255, green: 54/255, blue: 47/255))
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                                    .foregroundStyle(Color(red: 84/255, green: 54/255, blue: 47/255))
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }

                        // ⬅️ Y-axis title
                        VStack {
                            Text("HRV")
                                .rotationEffect(.degrees(-90))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
                           
                            Spacer()
                        }
                        .offset(x:-180,y: 80)

                        // ⬇️ X-axis title
                        VStack(spacing: 4) {
                            Spacer()
                            Text("時間")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
                                .offset(y:25)
                        }
                        .padding(.bottom, 4)
                    }
                    .frame(height: 200)
                    .padding(20)
                }
            }
        }
    }
}

#Preview {
    HRVGraphView()
        .environmentObject(HistoryModel())
}

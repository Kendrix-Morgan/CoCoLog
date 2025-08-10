//
//  RecommendationView.swift
//  COCOLOG_Sample
//
//  Created by cmStudent on 2025/07/22.
//
import SwiftUI

enum StressLevel {
    case low
    case moderate
    case high
}

struct RecommendationView: View {
    @ObservedObject var bleManager: BLEManager

    var stressLevel: StressLevel {
        if bleManager.bpm > 95 || bleManager.hrv < 25 {
            return .high
        } else if bleManager.bpm < 75 && bleManager.hrv > 40 {
            return .moderate
        } else {
            return .low
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "FAF6EB").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    
                    // 音楽セクション
                    Section(header: Text("音楽")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color(hex: "914D26")))  {
                            ForEach(getMusicList(), id: \.title) { song in
                                MusicItem(title: song.title, artist: song.artist, url: song.url)
                            }
                    }
                    
                    // 食べ物セクション
                    Section(header: Text("食べ物")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color(hex: "914D26"))) {
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                            ForEach(getFoodList(), id: \.name) { food in
                                FoodItem(imageName: food.image, label: food.name)
                            }
                        }
                    }
                    
                    // アクティビティセクション
                    Section(header: Text("アクティビティ")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color(hex: "914D26")))  {
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: getActivity().icon)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.top, 4)
                                .padding(.leading, -35)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(getActivity().title)
                                    .font(.title2)
                                Text(getActivity().description)
                                    .font(.subheadline)
                            }
                            .foregroundColor(Color(hex: "FAF6EB"))

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "914D26"))
                        .cornerRadius(20)
                    }

                }
                .padding()
            }
            .navigationTitle("Recommendations")
        }
    }
    
    // 音楽データ
    func getMusicList() -> [(title: String, artist: String, url: String)] {
        switch stressLevel {
        case .low:
            return [
                ("Sunday Best", "Surfaces", "https://youtu.be/_83KqwEEGw4?si=d9j3VoHBMOYZb8IU"),
                ("Pretender", "Official髭男dism", "https://youtu.be/TQ8WlA2GXbk?si=0oPIv5Qr1bp_wZVF"),
                ("Good Day", "IU", "https://youtu.be/jeqdYqsrsA0?si=5cn89POdvrh6_JC1")
            ]
        case .moderate:
            return [
                ("Golden Hour", "JVKE", "https://youtu.be/PEM0Vs8jf1w?si=EwbvnUtOvJZ_q_0E"),
                ("虹", "菅田将暉", "https://youtu.be/hkBbUf4oGfA?si=zl_KS386ceTRPqev"),
                ("Lemon", "米津玄師", "https://youtu.be/SX_ViT4Ra7k?si=6jv0TkxnlRJu4MUL")
            ]
        case .high:
            return [
                ("Weightless", "Marconi Union", "https://www.youtube.com/watch?v=UfcAVejslrU"),
                ("River Flows in You", "Yiruma", "https://www.youtube.com/watch?v=7maJOI3QMu0"),
                ("やさしさで溢れるように", "JUJU", "https://youtu.be/jIl8_jMMULs?si=D29uS53_fr3br-EQ")
            ]
        }
    }



    // 食べ物データ
    func getFoodList() -> [(name: String, image: String)] {
        switch stressLevel {
        case .low:
            return [
                ("フルーツヨーグルト", "fruit_yogurt"),
                    ("グリーンスムージー", "green_smoothie"),
                    ("全粒粉トースト", "whole_grain_toast"),
                    ("ドライフルーツ", "nuts_dried_fruits")
            ]
        case .moderate:
            return [
                ("アボカドトースト", "avocado"),
                ("サツマイモ", "sweetpotato"),
                ("味噌汁", "misosoup"),
                ("バナナスムージー", "bananasmoothie")
            ]
        case .high:
            return [
                ("焼き鮭と玄米ごはん", "grilled_salmon_rice"),
                 ("かぼちゃポタージュ", "pumpkin_potage"),
                 ("ベリースムージー", "blueberry_almond_smoothie"),
                 ("ハーブティー", "herbal_tea_crackers")
            ]
        }
    }

    // アクティビティデータ
    func getActivity() -> (icon: String, title: String, description: String) {
        switch stressLevel {
        case .low:
            return ("figure.walk", "散歩", "自然の中を歩いて心をリフレッシュ")
        case .moderate:
            return ("books.vertical", "読書", "静かに集中することで心が落ち着く")
        case .high:
            return ("lungs.fill", "呼吸法", "深呼吸で自律神経を整える")
        }
    }
}

// カスタムビュー
struct MusicItem: View {
    var title: String
    var artist: String
    var url: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(artist).font(.subheadline)
            }
            .foregroundColor(Color(hex: "FAF6EB"))

            Spacer()

            Button {
                if let link = URL(string: url) {
                    UIApplication.shared.open(link)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.brown)
            }
        }
        .padding()
        .background(Color(hex: "914D26"))
        .cornerRadius(12)
    }
}


struct FoodItem: View {
    var imageName: String
    var label: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            Text(label)
                .font(.headline)
                .foregroundColor(Color(hex: "FAF6EB"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "914D26"))
        .cornerRadius(12)
    }
}


// プレビュー
#Preview {
    RecommendationView(bleManager: BLEManager())
}


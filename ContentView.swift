//
//  ContentView.swift
//  HeartEase
//
//  Created by YUN NADI OO   on 2025/07/18.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var historyModel: HistoryModel
    @EnvironmentObject var bleManager: BLEManager
 
    
    var body: some View {
        GeometryReader { geometry in
            TabView {
                //  Home tab
                Home()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("ホーム")
                    }
                
                // Create MoodShake tab
              
                RecommendationView(bleManager: bleManager)
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("オススメ")
                    }
                
                //  History tab
                History()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("履歴")
                    }
                //  Account tab
                AccountView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("アカウント")
                    }
                
            }
             
            .frame(width: geometry.size.width, height: geometry.size.height)
            
                .background(Color(red: 250/255, green: 246/255, blue: 235/255))
        }
        .environmentObject(historyModel)
              .environmentObject(bleManager)
    }
}


#Preview {
    ContentView()
        .environmentObject(HistoryModel())
        .environmentObject(BLEManager()) 
}

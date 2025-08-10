//
//  Home.swift
//  CocoLog
//
//  Created by YUN NADI OO on 2025/07/22.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var historyModel: HistoryModel
    @EnvironmentObject var bleManager: BLEManager
    
    @State private var started = false
    @State private var navigateToDetail = false
   
    @State private var showCalendar = false
    @State private var shouldPlayLottie = true
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image("brown")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .offset(y: -40)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("ココログへようこそ🍀")
                                .font(.title2).bold()
                                .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
                                .padding(.top, 24)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { bleManager.isScanning },
                                set: { newValue in
                                    if newValue {
                                        bleManager.startScan()
                                    } else {
                                        bleManager.stopScan()
                                    }
                                }))
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 106/255, green: 49/255, blue: 24/255)))
                            .padding(.top, 20)
                        }
                        
                        LottieView(filename: "Meditating Giraffe", isPlaying: shouldPlayLottie)
                            .frame(height: 200)
                            .offset(y: -10)
                        
                        Text(bleManager.isConnected ? "💖 M5StickCPlus connected" : "🌿 Searching for device…")
                            .font(.headline)
                            .foregroundColor(Color(red: 84/255, green: 54/255, blue: 47/255))
                        
                        Button(action: {
                            bleManager.resetValues()
                            bleManager.sendStartSignal()
                            withAnimation { started = true }
                        }) {
                            Text("Start")
                                .font(.title3)
                                .bold()
                                .padding()
                                .frame(width: 120, height: 40)
                                .background(Color(red: 106/255, green: 49/255, blue: 24/255))
                                .foregroundColor(.white)
                                .cornerRadius(29)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
                    .padding(.all, 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(red: 250/255, green: 246/255, blue: 235/255))
            }
            
            .navigationDestination(isPresented: $started) {
                Measuring_View(backToHome: $started)
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(HistoryModel())
        .environmentObject(BLEManager())
}

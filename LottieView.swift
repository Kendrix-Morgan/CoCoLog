//
//  LottieView.swift
//  HeartEase
//
//  Created by YUN NADI OO   on 2025/07/18.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .loop
    var delay: Double = 0.0
    var isPlaying: Bool

    class Coordinator {
        var animationView: LottieAnimationView?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        context.coordinator.animationView = animationView

        if isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animationView.play()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }
        if isPlaying {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
}

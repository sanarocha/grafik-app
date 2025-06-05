//
//  SplashLoadingView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 25/05/25.
//

import SwiftUI

struct SplashLoadingView: View {
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            Color.grafikBackground
                .ignoresSafeArea()
            VStack(spacing: 40) {
                Image("LogoGrafikSimple")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                HStack(spacing: 20) {
                    Circle().fill(.red).frame(width: 40, height: 40).opacity(currentIndex >= 1 ? 1 : 0)
                    Circle().fill(.green).frame(width: 40, height: 40).opacity(currentIndex >= 2 ? 1 : 0)
                    Circle().fill(.blue).frame(width: 40, height: 40).opacity(currentIndex >= 3 ? 1 : 0)
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                currentIndex = (currentIndex + 1) % 4
            }
        }
    }
}


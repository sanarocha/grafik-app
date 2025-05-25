//
//  RootView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 25/05/25.
//


import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            HomeView()
                .opacity(showSplash ? 0 : 1)

            SplashLoadingView()
                .opacity(showSplash ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showSplash = false
            }
        }
    }
}


//
//  HomeView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 17/03/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isARViewPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Grafik")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Button(action: {
                isARViewPresented = true
            }) {
                Text("Câmera Virtual")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            .fullScreenCover(isPresented: $isARViewPresented) {
                ARViewScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

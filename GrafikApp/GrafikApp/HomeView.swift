//
//  HomeView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 17/03/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isCameraARViewPresented = false
    @State private var isIlluminationARViewPresented = false
    @State private var isTransformationsARViewPresented = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Image("Logo Grafik")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 200)

                    Button(action: {
                        isCameraARViewPresented = true
                    }) {
                        Text("CÂMERA VIRTUAL")
                            .font(.balooBold(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.grafikBlue)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.grafikOutline, lineWidth: 3)
                            )
                            .padding(.horizontal, 40)
                    }
                    .fullScreenCover(isPresented: $isCameraARViewPresented) {
                        CameraTheoryView()
                    }

                    Button(action: {
                        isIlluminationARViewPresented = true
                    }) {
                        Text("ILUMINAÇÃO")
                            .font(.balooBold(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.grafikRed)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.grafikOutline, lineWidth: 3)
                            )
                            .padding(.horizontal, 40)
                    }
                    .fullScreenCover(isPresented: $isIlluminationARViewPresented) {
                        IlluminationARViewScreen()
                    }

                    Button(action: {
                        isTransformationsARViewPresented = true
                    }) {
                        Text("TRANSFORMAÇÕES GEOMÉTRICAS")
                            .font(.balooBold(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.grafikGreen)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.grafikOutline, lineWidth: 3)
                            )
                            .padding(.horizontal, 40)
                    }
                    .fullScreenCover(isPresented: $isTransformationsARViewPresented) {
                        TransformationTheoryView()
                    }
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.grafikBackground)
                .edgesIgnoringSafeArea(.all)
            }
            .overlay(
                NavigationLink(destination: TutorialView()) {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.grafikOutline)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                },
                alignment: .topTrailing
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

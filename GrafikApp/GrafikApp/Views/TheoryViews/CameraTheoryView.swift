//
//  CameraTheoryView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 21/04/25.
//

import SwiftUI

struct CameraTheoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    @State private var navigateToAR = false

    let pages: [CameraPage] = [
        CameraPage(
            title: "Conceito",
            imageName: "Camera1Image",
            description: "A câmera define o que é visto na cena. Sua posição, rotação e campo de visão (FOV) influenciam como os objetos aparecem."
        ),
        CameraPage(
            title: "Perspectiva",
            imageName: "Camera2Image",
            description: "A perspectiva muda conforme o ângulo da câmera. Isso afeta tamanho, profundidade e alinhamento dos objetos."
        ),
        CameraPage(
            title: "Exercício em RA",
            imageName: "Camera3Image",
            description: "Mova-se até encontrar o ângulo que revela duas palavras escondidas. Digite-as para concluir o exercício!"
        )
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.grafikBackground
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("CÂMERA\nSINTÉTICA")
                        .font(.balooBold(size: 24))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 24)

                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            VStack(spacing: 20) {
                                Text(pages[index].title)
                                    .font(.balooBold(size: 20))
                                    .foregroundColor(.black)

                                Image(pages[index].imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 220)

                                Text(pages[index].description)
                                    .font(.balooRegular(size: 16))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 24)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 460)

                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.grafikRed : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }

                    NavigationLink(
                        destination: CameraARViewScreen().navigationBarBackButtonHidden(true),
                        isActive: $navigateToAR
                    ) {
                        EmptyView()
                    }

                    Button(action: {
                        navigateToAR = true
                    }) {
                        Text("COMEÇAR EXERCÍCIO")
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
                            .padding(.bottom, 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.grafikBlue)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

struct CameraPage {
    let title: String
    let imageName: String
    let description: String
}

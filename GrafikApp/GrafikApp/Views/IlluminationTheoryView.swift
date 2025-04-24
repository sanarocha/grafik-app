//
//  IlluminationTheoryView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 23/04/25.
//

import SwiftUI

struct IlluminationTheoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    @State private var navigateToAR = false

    let pages: [IlluminationPage] = [
        IlluminationPage(
            title: "Conceito",
            imageName: "Light1Image",
            description: "A iluminação define como os objetos aparecem em uma cena 3D. Ela simula a luz do mundo real, revelando formas, profundidade e sombras."
        ),
        IlluminationPage(
            title: "Tipos de Luz",
            imageName: "Light2Image",
            description: "Existem diferentes tipos, como luz direcional (sol), pontual (lâmpada) e spot (lanterna). Cada uma cria efeitos distintos na cena."
        ),
        IlluminationPage(
            title: "Exercício em AR",
            imageName: "Light3Image",
            description: "Aponte a luminária real para iluminar o cubo em AR. Você pode mover a luz, mudar seu tipo e até controlar a cor conforme o ângulo da lanterna!"
        )
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.grafikBackground
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("ILUMINAÇÃO")
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
                        destination: IlluminationARViewScreen().navigationBarBackButtonHidden(true),
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

struct IlluminationPage {
    let title: String
    let imageName: String
    let description: String
}

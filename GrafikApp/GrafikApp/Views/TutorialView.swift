//
//  TutorialView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 18/04/25.
//
import SwiftUI

struct TutorialView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0

    let pages: [TutorialPage] = [
        TutorialPage(
            title: "Escolha um tema",
            imageName: "Tutorial1Image",
            description: "Na home do app, você pode escolher entre 3 assuntos para aprender. Cada tema representa um conceito da computação gráfica."
        ),
        TutorialPage(
            title: "Leia a explicação",
            imageName: "Tutorial2Image",
            description: "Antes de iniciar cada exercício, mostramos uma explicação simples do conceito a ser praticado."
        ),
        TutorialPage(
            title: "Inicie o exercício em AR",
            imageName: "Tutorial3Image",
            description: "Ao começar, a câmera será ativada. Mire para uma superfície plana e escaneie o ambiente para o app detectar os planos. Pressione a tela para adicionar os eixos e objetos no ambiente em realidade aumentada."
        ),
        TutorialPage(
            title: "Interaja com os controles",
            imageName: "Tutorial4Image",
            description: "Use os botões na parte superior direita para interagir com o ambiente em realidade aumentada."
        )
    ]

    var body: some View {
        ZStack {
            Color.grafikBackground
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("COMO USAR\nO APLICATIVO")
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
                .frame(height: 480)

                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.grafikRed : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("COMEÇAR")
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
        .navigationBarBackButtonHidden(true)
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

struct TutorialPage {
    let title: String
    let imageName: String
    let description: String
}

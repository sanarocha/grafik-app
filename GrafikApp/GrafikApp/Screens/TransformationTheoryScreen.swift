//
//  TransformationTheoryScreen.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

import SwiftUI

struct TransformationTheoryScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToAR = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Transformações Geométricas")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Group {
                            Text("📍 Translação")
                                .font(.headline)
                            Text("Translação move o objeto de um ponto a outro no espaço 3D, modificando sua posição nos eixos X, Y e Z.")

                            Text("🔁 Rotação")
                                .font(.headline)
                            Text("Rotação gira o objeto em torno de seus eixos.\n\n- **Pitch**: rotação no eixo X (para cima/baixo)\n- **Yaw**: rotação no eixo Y (esquerda/direita)\n- **Roll**: rotação no eixo Z (giro no próprio eixo frontal)")

                            Text("📏 Escala")
                                .font(.headline)
                            Text("Escala altera o tamanho do objeto. A escala uniforme mantém as proporções em todos os eixos.")
                        }

                        Group {
                            Text("🎯 Como funcionam os exercícios?")
                                .font(.headline)
                            Text("""
                            Ao iniciar os exercícios, você verá um cubo e controles deslizantes.
                            
                            Cada exercício pedirá que você aplique uma transformação específica. Você pode verificar sua resposta clicando em “Verificar”. Quando estiver correto, o cubo confirmará em realidade aumentada!

                            Complete todos os exercícios para finalizar a atividade.
                            """)
                        }
                    }
                    .padding()
                }

                NavigationLink(destination: TransformationsARViewScreen().navigationBarBackButtonHidden(true), isActive: $navigateToAR) {
                    EmptyView()
                }

                Button(action: {
                    navigateToAR = true
                }) {
                    Text("🚀 Começar Exercício")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}


//
//  ExercisePanelWords.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 21/04/25.
//

import SwiftUI

struct ExercisePanelWords: View {
    var onComplete: () -> Void

    @State private var userInput = ""
    @State private var showError = false
    @State private var isCompleted = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }

                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercício")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Escreva as duas palavras escondidas.")
                            .foregroundColor(.white)

                        TextField("Digite aqui sua resposta...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top, 4)

                        if isCompleted {
                            Text("✅ Concluído!")
                                .foregroundColor(.green)
                                .bold()
                        } else {
                            Button(action: checkAnswer) {
                                Text("Verificar")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }

                            if showError {
                                Text("❌ Resposta incorreta. Tente novamente.")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                    .padding()
                    .frame(maxHeight: geometry.size.height * 0.4)
                }
            }
        }
    }

    func checkAnswer() {
        let respostaCorreta = userInput.lowercased().contains("catman") &&
                              userInput.lowercased().contains("rabbit")

        if respostaCorreta {
            isCompleted = true
            showError = false
            UIApplication.shared.endEditing() // encerra edição ao completar
            onComplete()
        } else {
            showError = true
        }
    }
}

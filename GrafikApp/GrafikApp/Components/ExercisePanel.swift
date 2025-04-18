//
//  ExercisePanel.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

import SwiftUI

struct ExerciseData: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    var isCompleted: Bool
    let onCheck: () -> Void
}

struct ExercisePanel: View {
    @Binding var exercises: [ExerciseData]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(exercises.indices, id: \.self) { index in
                            let exercise = exercises[index]

                            VStack(alignment: .leading, spacing: 8) {
                                Text(exercise.title)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(exercise.instruction)
                                    .foregroundColor(.white)
                                    .font(.body)

                                if exercise.isCompleted {
                                    Text("✅ Concluído!")
                                        .foregroundColor(.green)
                                        .bold()
                                } else {
                                    Button(action: {
                                        exercises[index].onCheck()
                                    }) {
                                        Text("Verificar")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: geometry.size.height * 0.5)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
        }
    }
}

//
//  TransformationControlsPanel.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

import Foundation
import Combine
import SwiftUI
import RealityKit
import ARKit

struct TransformationControlsPanel: View {
    @ObservedObject var model: TransformationModel
    var onReset: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // empurra o painel para baixo

                ScrollView {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Transformações do Cubo")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                model.posX = 0
                                model.posY = 0
                                model.posZ = 0
                                model.rotX = 0
                                model.rotY = 0
                                model.rotZ = 0
                                model.scale = 1.0
                                onReset()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.white)
                            }
                        }

                        Group {
                            Text("Posição").foregroundColor(.white).bold()
                            TransformationSliderRow(label: "X", value: $model.posX, range: -1...1)
                            TransformationSliderRow(label: "Y", value: $model.posY, range: -1...1)
                            TransformationSliderRow(label: "Z", value: $model.posZ, range: -1...1)
                        }

                        Group {
                            Text("Rotação (°)").foregroundColor(.white).bold()
                            TransformationSliderRow(label: "Pitch", value: $model.rotX, range: -180...180)
                            TransformationSliderRow(label: "Yaw", value: $model.rotY, range: -180...180)
                            TransformationSliderRow(label: "Roll", value: $model.rotZ, range: -180...180)
                        }

                        Group {
                            Text("Escala").foregroundColor(.white).bold()
                            TransformationSliderRow(label: "Tamanho", value: $model.scale, range: 0.1...2.0)
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

struct TransformationSliderRow: View {
    var label: String
    @Binding var value: Float
    var range: ClosedRange<Float>

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(String(format: "%.2f", value))")
                .foregroundColor(.white)
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Float($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
        }
    }
}

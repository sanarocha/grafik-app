//
//  CameraControlsPanel.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 28/03/25.
//

import UIKit
import SwiftUI

struct CameraControlsPanel: View {
    @ObservedObject var cameraModel: CameraPositionModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Mover Câmera Virtual")
                .font(.headline)
                .foregroundColor(.white)

            SliderRow(label: "X", value: $cameraModel.posX)
            SliderRow(label: "Y", value: $cameraModel.posY)
            SliderRow(label: "Z", value: $cameraModel.posZ)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct SliderRow: View {
    var label: String
    @Binding var value: Float

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(String(format: "%.2f", value))")
                .foregroundColor(.white)
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Float($0) }
            ), in: -1.0...1.0)
        }
    }
}

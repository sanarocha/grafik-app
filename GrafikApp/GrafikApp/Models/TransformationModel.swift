//
//  TransformationModel.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

import Foundation
import Combine

class TransformationModel: ObservableObject {
    // posição/translação
    @Published var posX: Float = 0
    @Published var posY: Float = 0
    @Published var posZ: Float = 0

    // rotação
    @Published var rotX: Float = 0
    @Published var rotY: Float = 0
    @Published var rotZ: Float = 0

    // escala
    @Published var scale: Float = 1.0
}

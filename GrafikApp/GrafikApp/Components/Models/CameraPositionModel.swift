//
//  CameraPositionModel.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 28/03/25.
//

import Foundation
import Combine

class CameraPositionModel: ObservableObject {
    @Published var posX: Float = 0.0
    @Published var posY: Float = 0.0
    @Published var posZ: Float = 0.0
}

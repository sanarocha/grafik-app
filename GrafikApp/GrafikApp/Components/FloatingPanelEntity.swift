//
//  FloatingPanelEntity.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 24/03/25.
//

import RealityKit
import UIKit

class FloatingPanelEntity: Entity, HasModel {
    private var textEntity: ModelEntity!
    
    required init() {
        super.init()
        
        let backgroundMesh = MeshResource.generatePlane(width: 0.25, height: 0.20, cornerRadius: 0.015)
        let backgroundMaterial = SimpleMaterial(
            color: .black.withAlphaComponent(0.5),
            roughness: .init(floatLiteral: 1),
            isMetallic: false
        )
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        background.position = [0, 0, 0.005]
        self.addChild(background)

        
        let textMesh = MeshResource.generateText(
            "posX: 0.00\nposY: 0.00\nposZ: 0.00",
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.02),
            containerFrame: CGRect(x: 0, y: 0, width: 0.2, height: 0.1),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [-0.1, -0.05, 0.02]
        self.addChild(textEntity)
    }
    
    func updateText(x: Float, y: Float, z: Float) {
        let text = String(format: "posX: %.2f\nposY: %.2f\nposZ: %.2f", z, x, y)
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.02),
            containerFrame: CGRect(x: 0, y: 0, width: 0.2, height: 0.1),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        textEntity.model?.mesh = textMesh
    }
}

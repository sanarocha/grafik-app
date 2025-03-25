//
//  FloatingPanelEntity.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 24/03/25.
//

import RealityKit
import UIKit

class FloatingPanelEntity: Entity, HasModel, HasAnchoring {
    
    private var textEntity: ModelEntity!
    
    required init() {
        super.init()
        
        let backgroundMesh = MeshResource.generatePlane(width: 0.2, height: 0.1)
        let backgroundMaterial = SimpleMaterial(color: .black.withAlphaComponent(0.6), isMetallic: false)
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        
        let textMesh = MeshResource.generateText(
            "Informações em tempo real",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.02),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [-0.09, 0.0, 0.01]

        self.addChild(background)
        self.addChild(textEntity)
    }
}

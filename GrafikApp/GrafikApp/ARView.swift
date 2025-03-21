//
//  ARView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 17/03/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var message: String?
    @Binding var hasAddedAxes: Bool
    @Binding var currentAnchor: AnchorEntity?

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ARViewContainer
        weak var arView: ARView?

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)

            if let firstResult = results.first, !parent.hasAddedAxes {
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                arView.scene.addAnchor(anchor)

                let axis = createAxis()
                axis.position.y += 0.01
                anchor.addChild(axis)

                let plane = createPlane()
                anchor.addChild(plane)

                parent.currentAnchor = anchor
                parent.hasAddedAxes = true

                showMessage("Eixos adicionados com sucesso!", duration: 4)
            } else if !parent.hasAddedAxes {
                showMessage("Tente apontar a câmera para uma área mais iluminada", duration: 4)
            }
        }

        func showMessage(_ text: String, duration: TimeInterval) {
            DispatchQueue.main.async {
                self.parent.message = text
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if text != "Selecione um plano para adicionar os eixos!" {
                        self.parent.message = nil
                    }
                }
            }
        }

        func createAxis() -> ModelEntity {
            let axisLength: Float = 0.3
            let xAxis = MeshResource.generateBox(size: [0.01, 0.01, axisLength])
            let yAxis = MeshResource.generateBox(size: [axisLength, 0.01, 0.01])
            let zAxis = MeshResource.generateBox(size: [0.01, axisLength, 0.01])

            let xMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let yMaterial = SimpleMaterial(color: .green, isMetallic: false)
            let zMaterial = SimpleMaterial(color: .blue, isMetallic: false)

            let xModel = ModelEntity(mesh: xAxis, materials: [xMaterial])
            let yModel = ModelEntity(mesh: yAxis, materials: [yMaterial])
            let zModel = ModelEntity(mesh: zAxis, materials: [zMaterial])

            xModel.position = SIMD3(0, 0, axisLength / 2)
            yModel.position = SIMD3(axisLength / 2, 0, 0)
            zModel.position = SIMD3(0, axisLength / 2, 0)

            let axisEntity = Entity()
            axisEntity.addChild(xModel)
            axisEntity.addChild(yModel)
            axisEntity.addChild(zModel)

            let entity = ModelEntity()
            entity.addChild(axisEntity)

            return entity
        }

        func createPlane() -> ModelEntity {
            let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
            let planeMaterial = SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)
            let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            planeEntity.position = SIMD3(0, 0, 0)
            return planeEntity
        }
    }
}

struct ARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String? = "Selecione um plano para adicionar os eixos!"
    @State private var hasAddedAxes = false
    @State private var currentAnchor: AnchorEntity?

    var body: some View {
        ZStack {
            ARViewContainer(
                message: $message,
                hasAddedAxes: $hasAddedAxes,
                currentAnchor: $currentAnchor
            )
            .edgesIgnoringSafeArea(.all)

            if let message = message {
                MessageOverlay(message: message)
                    .transition(.opacity)
            }

            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 20, height: 30)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}


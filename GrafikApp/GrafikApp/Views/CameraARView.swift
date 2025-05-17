//
//  ARView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 17/03/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct CameraARViewContainer: UIViewRepresentable {
    @Binding var message: String?
    @Binding var hasAddedAxes: Bool
    @Binding var currentAnchor: AnchorEntity?
    @Binding var showPanel: Bool
    @Binding var coordinatorRef: Coordinator?
    
    var cameraModel: CameraPositionModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        config.isLightEstimationEnabled = true
        arView.session.delegate = context.coordinator
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinatorRef = coordinator
        return coordinator
    }
    
    class Coordinator: NSObject {
        var parent: CameraARViewContainer
        weak var arView: ARView?
        var floatingPanel: FloatingPanelEntity?
        
        var sceneContainer: Entity?
        private var cancellables = Set<AnyCancellable>()
        var cameraModel: CameraPositionModel?
        var virtualCameraEntity: Entity?
        var targetEntity: Entity?
        var cameraIndicator: ModelEntity?

        
        init(_ parent: CameraARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)

            if let firstResult = results.first, !parent.hasAddedAxes {
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                arView.scene.addAnchor(anchor)

                let plane = createPlane()
                anchor.addChild(plane)

                let axisWithLettersContainer = Entity()
                let axisEntity = createAxis()
                axisEntity.position.y += 0.01
                axisWithLettersContainer.addChild(axisEntity)
                anchor.addChild(axisWithLettersContainer)

                do {
                    let model = try Entity.loadModel(named: "words")
                    model.scale = [0.0001, 0.0001, 0.0001]
                    model.position = [0.1, 0.1, 0.1]
                    anchor.addChild(model)
                } catch {
                    print("Erro ao carregar modelo: \(error)")
                    showMessage("Erro ao carregar o modelo 3D", duration: 4)
                }

                parent.currentAnchor = anchor
                parent.hasAddedAxes = true

                showMessage("Tente encontrar a posição certa para descobrir as palavras escondidas!", duration: 4)
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

            let xAxis = MeshResource.generateBox(size: [axisLength, 0.01, 0.01])
            let yAxis = MeshResource.generateBox(size: [0.01, axisLength, 0.01])
            let zAxis = MeshResource.generateBox(size: [0.01, 0.01, axisLength])

            let redTransparent = SimpleMaterial(color: UIColor.red.withAlphaComponent(0.3), isMetallic: false)
            let greenTransparent = SimpleMaterial(color: UIColor.green.withAlphaComponent(0.3), isMetallic: false)
            let blueTransparent = SimpleMaterial(color: UIColor.blue.withAlphaComponent(0.3), isMetallic: false)

            let xMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let yMaterial = SimpleMaterial(color: .green, isMetallic: false)
            let zMaterial = SimpleMaterial(color: .blue, isMetallic: false)

            let xModel = ModelEntity(mesh: xAxis, materials: [xMaterial])
            xModel.position = SIMD3(axisLength / 2, 0, 0)
            xModel.addChild(makeDashedLine(axis: [1, 0, 0], color: redTransparent))
            xModel.addChild(makeArrow(color: xMaterial, axis: [1, 0, 0]))

            let yModel = ModelEntity(mesh: yAxis, materials: [yMaterial])
            yModel.position = SIMD3(0, axisLength / 2, 0)
            yModel.addChild(makeDashedLine(axis: [0, 1, 0], color: greenTransparent))
            yModel.addChild(makeArrow(color: yMaterial, axis: [0, 1, 0]))

            let zModel = ModelEntity(mesh: zAxis, materials: [zMaterial])
            zModel.position = SIMD3(0, 0, axisLength / 2)
            zModel.addChild(makeDashedLine(axis: [0, 0, 1], color: blueTransparent))
            zModel.addChild(makeArrow(color: zMaterial, axis: [0, 0, 1]))

            let axisEntity = Entity()
            axisEntity.addChild(xModel)
            axisEntity.addChild(yModel)
            axisEntity.addChild(zModel)

            let entity = ModelEntity()
            entity.addChild(axisEntity)

            return entity
        }
        
        func makeArrow(color: SimpleMaterial, axis: SIMD3<Float>, arrowRadius: Float = 0.01, arrowHeight: Float = 0.05, axisLength: Float = 0.3) -> Entity {
            let arrow = ModelEntity(mesh: .generateCone(height: arrowHeight, radius: arrowRadius), materials: [color])
            
            var orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            
            if axis == [1, 0, 0] {
                orientation = simd_quatf(angle: -.pi/2, axis: [0, 0, 1])
            } else if axis == [0, 1, 0] {
                orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            } else if axis == [0, 0, 1] {
                orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
            }
            
            let direction = normalize(axis)
            arrow.orientation = orientation
            arrow.position = direction * (axisLength + arrowHeight / 2 - 0.15)
            
            return arrow
        }
        
        func createPlane() -> ModelEntity {
            let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
            let planeMaterial = SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)
            let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            planeEntity.position = SIMD3(0, 0, 0)
            return planeEntity
        }
        
        func makeDashedLine(
            axis: SIMD3<Float>,
            color: SimpleMaterial,
            segments: Int = 10,
            segmentLength: Float = 0.02,
            gap: Float = 0.01,
            shaftRadius: Float = 0.005
        ) -> Entity {
            let container = Entity()
            let initialOffset: Float = 0.15
            
            for i in 0..<segments {
                let segment = ModelEntity(
                    mesh: .generateBox(size: [shaftRadius * 2, shaftRadius * 2, segmentLength]),
                    materials: [color]
                )
                
                let offset = initialOffset + Float(i) * (segmentLength + gap) + segmentLength / 2
                segment.position = -axis * offset
                
                if axis == [1,0,0] {
                    segment.orientation = simd_quatf(angle: -.pi/2, axis: [0,1,0])
                } else if axis == [0,1,0] {
                    segment.orientation = simd_quatf(angle: 0, axis: [0,0,0])
                } else if axis == [0,0,1] {
                    segment.orientation = simd_quatf(angle: .pi/2, axis: [1,0,0])
                }
                
                container.addChild(segment)
            }
            return container
        }
    }
}

struct CameraARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String? = "Selecione um plano para adicionar os eixos!"
    @State private var hasAddedAxes = false
    @State private var currentAnchor: AnchorEntity?
    @State private var showExercisePanel = false
    @State private var exerciseCompleted = false

    @State private var arCoordinator: CameraARViewContainer.Coordinator?

    var body: some View {
        ZStack {
            CameraARViewContainer(
                message: $message,
                hasAddedAxes: $hasAddedAxes,
                currentAnchor: $currentAnchor,
                showPanel: .constant(false), // desativa sliders
                coordinatorRef: $arCoordinator,
                cameraModel: CameraPositionModel()
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

                    Button(action: {
                        showExercisePanel.toggle()
                    }) {
                        Image(systemName: showExercisePanel ? "xmark.circle.fill" : "doc.text.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }

                Spacer()

                if showExercisePanel {
                    ExercisePanelWords {
                        showMessageInAR("Exercício completo!", .green)
                    }
                }

            }
        }
    }
    
    func showMessageInAR(_ text: String, _ color: SimpleMaterial.Color) {
        guard let anchor = currentAnchor else {
            print("🚫 Anchor não existe")
            return
        }

        let backgroundMesh = MeshResource.generatePlane(width: 0.4, height: 0.08, cornerRadius: 0.01)
        let backgroundMaterial = SimpleMaterial(color: .black.withAlphaComponent(0.75), isMetallic: false)
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        background.position = [0, 0, 0.005]

        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.020),
            containerFrame: CGRect(x: 0, y: 0, width: 0.35, height: 0.07),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = SimpleMaterial(color: color, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [-0.18, -0.05, 0.01]

        let container = Entity()
        container.addChild(background)
        container.addChild(textEntity)
        container.position = [0, 0.3, -0.2]

        anchor.addChild(container)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            container.removeFromParent()
        }
    }
}


extension CameraARViewContainer.Coordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard !parent.hasAddedAxes else { return }
        
        for anchor in anchors {
            if anchor is ARPlaneAnchor {
                DispatchQueue.main.async {
                    self.parent.message = "Plano detectado! Toque para adicionar os eixos."
                }
            }
        }
    }
}

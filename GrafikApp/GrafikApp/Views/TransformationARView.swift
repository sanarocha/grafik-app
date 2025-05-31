//
//  TransformationARView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct TransformationsARView: UIViewRepresentable {
    @Binding var message: String?
    @Binding var hasAddedElements: Bool
    @Binding var currentAnchor: AnchorEntity?
    
    @ObservedObject var transformModel: TransformationModel
    
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
        context.coordinator.bindTransformUpdates(model: transformModel)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var matrixPanel: TransformationFloatingPanelEntity?
        var parent: TransformationsARView
        weak var arView: ARView?
        private var cancellables = Set<AnyCancellable>()
        
        var cubeEntity: ModelEntity?

        init(_ parent: TransformationsARView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first, !parent.hasAddedElements {
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                arView.scene.addAnchor(anchor)
                
                let container = Entity()
                
                let axisContainer = createAxis()
                axisContainer.position.y += 0.01
                container.addChild(axisContainer)
                
                let axis = createAxis()
                axis.position.y += 0.01
                anchor.addChild(axis)
                
                let plane = createPlane()
                anchor.addChild(plane)
                
                let cube = ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .purple, isMetallic: false)])
                cube.position = [0.1, 0.05, 0.1]
                anchor.addChild(cube)
                cubeEntity = cube
                
                let matrixPanelEntity = TransformationFloatingPanelEntity()
                matrixPanelEntity.position = [0, 0.6, 0]
                anchor.addChild(matrixPanelEntity)
                self.matrixPanel = matrixPanelEntity
                
                parent.currentAnchor = anchor
                parent.hasAddedElements = true
            } else if !parent.hasAddedElements {
                showMessage("Tente apontar a câmera para uma área mais iluminada e escanear o ambiente!", duration: 4)
            }
        }
        
        func createPlane() -> ModelEntity {
            let mesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
            let material = SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)
            return ModelEntity(mesh: mesh, materials: [material])
        }
        
        func showMessage(_ text: String, duration: TimeInterval) {
            DispatchQueue.main.async {
                self.parent.message = text
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if text != "Toque para adicionar o plano!" {
                        self.parent.message = nil
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !parent.hasAddedElements else { return }
            for anchor in anchors {
                if anchor is ARPlaneAnchor {
                    DispatchQueue.main.async {
                        self.parent.message = "Plano detectado! Toque para adicionar."
                    }
                }
            }
        }

        func bindTransformUpdates(model: TransformationModel) {
            Publishers.CombineLatest3(
                Publishers.CombineLatest3(model.$posX, model.$posY, model.$posZ),
                Publishers.CombineLatest3(model.$rotX, model.$rotY, model.$rotZ),
                model.$scale
            )
            .sink { [weak self] position, rotation, scale in
                let (x, y, z) = position
                let (rx, ry, rz) = rotation

                let tempModel = TransformationModel()
                tempModel.posX = x
                tempModel.posY = y
                tempModel.posZ = z
                tempModel.rotX = rx
                tempModel.rotY = ry
                tempModel.rotZ = rz
                tempModel.scale = scale

                self?.updateCubeTransform(with: tempModel)
            }
            .store(in: &cancellables)
        }

        func updateCubeTransform(with model: TransformationModel) {
            guard let cube = cubeEntity else { return }

            let translation = SIMD3<Float>(
                model.posX,
                model.posY,
                model.posZ
            )

            let rotX = simd_quatf(angle: degreesToRadians(model.rotX), axis: [1, 0, 0])
            let rotY = simd_quatf(angle: degreesToRadians(model.rotY), axis: [0, 1, 0])
            let rotZ = simd_quatf(angle: degreesToRadians(model.rotZ), axis: [0, 0, 1])

            let rotation = rotX * rotY * rotZ

            let scale = SIMD3<Float>(repeating: model.scale)

            cube.transform = Transform(scale: scale, rotation: rotation, translation: translation)
            matrixPanel?.updateTextFromModel(model: model, matrix: cube.transform.matrix)
        }

        private func degreesToRadians(_ degrees: Float) -> Float {
            return degrees * .pi / 180
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

struct TransformationsARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String? = "Toque para adicionar o plano!"
    @State private var hasAddedElements = false
    @State private var currentAnchor: AnchorEntity?
    @State private var showExercisePanel = false
    @State private var exercises: [ExerciseData] = []

    @StateObject private var transformModel = TransformationModel()
    @State private var showPanel = false


    func setupExercises() {
        exercises = [
            ExerciseData(id: 1, title: "Translação", instruction: "Mova o cubo para X: 0.2, Y: 0.1, Z: 0.3.", isCompleted: false, onCheck: { checkTranslationExercise() }),
            ExerciseData(id: 2, title: "Rotação", instruction: "Rotacione o cubo para Pitch: 45°, Yaw: 0°, Roll: 90°.", isCompleted: false, onCheck: { checkRotationExercise() }),
            ExerciseData(id: 3, title: "Escala", instruction: "Defina a escala do cubo como 1.5.", isCompleted: false, onCheck: { checkScaleExercise() })
        ]
    }
    
    func checkTranslationExercise() {
        let x = transformModel.posX
        let y = transformModel.posY
        let z = transformModel.posZ

        let isCompleted = abs(x - 0.2) < 0.01 &&
                          abs(y - 0.1) < 0.01 &&
                          abs(z - 0.3) < 0.01

        if isCompleted {
            markExerciseCompleted(id: 1)
            showMessageInAR("Exercício de Translação completo!", .green)
        } else {
            showMessageInAR("Exercício ainda não foi completado!", .red)
            triggerHapticFeedback(.error)
        }
    }

    func checkRotationExercise() {
        let pitch = transformModel.rotX
        let yaw = transformModel.rotY
        let roll = transformModel.rotZ

        let isCompleted = abs(pitch - 45) < 2 &&
                          abs(yaw) < 2 &&
                          abs(roll - 90) < 2

        if isCompleted {
            markExerciseCompleted(id: 2)
            showMessageInAR("Exercício Rotação completo!", .green)
        }  else {
            showMessageInAR("Exercício ainda não foi completado!", .red)
            triggerHapticFeedback(.error)
        }
    }

    func checkScaleExercise() {
        let scale = transformModel.scale

        let isCompleted = abs(scale - 1.5) < 0.01

        if isCompleted {
            markExerciseCompleted(id: 3)
            showMessageInAR("Exercício Escala completo!", .green)
        }  else {
            showMessageInAR("Exercício ainda não foi completado!", .red)
            triggerHapticFeedback(.error)
        }
    }
    
    func markExerciseCompleted(id: Int) {
        if let index = exercises.firstIndex(where: { $0.id == id }) {
            exercises[index].isCompleted = true
            triggerHapticFeedback(.success)
        }
    }
    
    func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func showMessageInAR(_ text: String, _ color: SimpleMaterial.Color) {
        guard let anchor = currentAnchor else { return }

        // ---------- BORDA BRANCA ----------
        let borderMesh = MeshResource.generatePlane(width: 0.42, height: 0.1, cornerRadius: 0.012)
        let borderMaterial = SimpleMaterial(
            color: .white,
            roughness: 1,
            isMetallic: false
        )
        let border = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
        border.position = [0, 0, 0.004]

        let backgroundMesh = MeshResource.generatePlane(width: 0.4, height: 0.08, cornerRadius: 0.01)
        let backgroundMaterial = SimpleMaterial(
            color: .black.withAlphaComponent(0.75),
            roughness: 1,
            isMetallic: false
        )
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
        container.addChild(border)
        container.addChild(background)
        container.addChild(textEntity)

        container.position = SIMD3<Float>(0, 0.3, -0.2)

        anchor.addChild(container)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            container.removeFromParent()
        }
    }


    var body: some View {
        ZStack {
            TransformationsARView(
                message: $message,
                hasAddedElements: $hasAddedElements,
                currentAnchor: $currentAnchor,
                transformModel: transformModel 
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
                        if !showExercisePanel {
                                showExercisePanel = true
                                showPanel = false
                            } else {
                                showExercisePanel = false
                            }
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
                    
                    Button(action: {
                        if !showPanel {
                             showPanel = true
                             showExercisePanel = false
                         } else {
                             showPanel = false
                         }
                    }) {
                        Image(systemName: showPanel ? "xmark.circle.fill" : "slider.horizontal.3")
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

                if showPanel {
                    TransformationControlsPanel(
                        model: transformModel,
                        onReset: {
                            transformModel.posX = 0
                            transformModel.posY = 0
                            transformModel.posZ = 0
                            transformModel.rotX = 0
                            transformModel.rotY = 0
                            transformModel.rotZ = 0
                            transformModel.scale = 1.0
                        }
                    )
                }
                
                if showExercisePanel {
                    ExercisePanel(exercises: $exercises)
                }
            }
            .onAppear {
                setupExercises()
            }
        }
    }
}

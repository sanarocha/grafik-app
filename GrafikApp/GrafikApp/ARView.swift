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
    @Binding var hasAddedObject: Bool
    @Binding var currentAnchor: AnchorEntity?
    @Binding var isTranslationActive: Bool
    @Binding var showExercisePopup: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
        arView.addGestureRecognizer(panGesture)

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
        var selectedObject: ModelEntity?

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)

            if let firstResult = results.first {
                if !parent.hasAddedAxes {
                    let anchor = AnchorEntity(world: firstResult.worldTransform)
                    arView.scene.addAnchor(anchor)

                    let axis = createAxis()
                    axis.position.y += 0.01
                    anchor.addChild(axis)

                    let plane = createPlane()
                    anchor.addChild(plane)

                    parent.currentAnchor = anchor
                    parent.hasAddedAxes = true

                    showMessage("Selecione o eixo para adicionar o objeto 3D", duration: 5)
                }
                else if parent.hasAddedAxes && !parent.hasAddedObject {
                    guard let anchor = parent.currentAnchor else { return }

                    let cube = createCube()
                    anchor.addChild(cube)

                    parent.hasAddedObject = true
                    selectedObject = cube

                    DispatchQueue.main.async {
                        self.parent.isTranslationActive = true
                    }
                }
            } else if !parent.hasAddedAxes {
                showMessage("Tente apontar a câmera para uma área mais iluminada", duration: 4)
            }
        }


        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard parent.isTranslationActive, let object = selectedObject, let arView = arView else { return }

            let translation = sender.translation(in: arView)

            let newPosition = SIMD3<Float>(
                object.position.x + Float(translation.x) * 0.001,
                object.position.y - Float(translation.y) * 0.001,
                object.position.z
            )

            object.position = newPosition
            sender.setTranslation(.zero, in: arView)
        }

        func showMessage(_ text: String, duration: TimeInterval, completion: (() -> Void)? = nil) {
            DispatchQueue.main.async {
                self.parent.message = text
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if text != "Selecione um plano para adicionar os eixos!" {
                        self.parent.message = nil
                    }
                    completion?()
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

        func createCube() -> ModelEntity {
            let cubeSize: Float = 0.1
            let cubeMesh = MeshResource.generateBox(size: cubeSize)
            let cubeMaterial = SimpleMaterial(color: .gray, isMetallic: false)
            let cubeEntity = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
            cubeEntity.position = SIMD3(0.15, 0.15, 0.15)
            return cubeEntity
        }
    }
}

struct ARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String? = "Selecione um plano para adicionar os eixos!"
    @State private var hasAddedAxes = false
    @State private var hasAddedObject = false
    @State private var isTranslationActive = false
    @State private var currentAnchor: AnchorEntity?
    @State private var showExercisePopup = false

    var body: some View {
        ZStack {
            ARViewContainer(message: $message, hasAddedAxes: $hasAddedAxes, hasAddedObject: $hasAddedObject, currentAnchor: $currentAnchor, isTranslationActive: $isTranslationActive, showExercisePopup: $showExercisePopup)
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

            VStack {
                HStack {
                    Spacer()
                    
                    if hasAddedObject {
                        Button(action: {
                            message = "Dica: Arraste com um dedo para mover o objeto"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                message = nil
                            }
                        }) {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Spacer().frame(width: 10)

                        Button(action: {
                            showExercisePopup.toggle()
                        }) {
                            Image(systemName: "play.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding()
                Spacer()
            }
            }
            ExercisePopup(isPresented: $showExercisePopup)
        }
    }

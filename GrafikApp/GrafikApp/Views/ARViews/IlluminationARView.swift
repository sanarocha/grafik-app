//
//  IlluminationARView.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 30/03/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct IlluminationARViewContainer: UIViewRepresentable {
    @Binding var message: String?
    @Binding var hasAddedAxes: Bool
    @Binding var currentAnchor: AnchorEntity?
    @Binding var coordinatorRef: Coordinator?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        
        if let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionObjects = referenceObjects        }
        
        arView.session.delegate = context.coordinator
        arView.session.run(configuration)
        
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
        var parent: IlluminationARViewContainer
        weak var arView: ARView?
        var sceneContainer: Entity?
        var lightEntity: Entity?
        private var cancellables = Set<AnyCancellable>()
        var objectAnchorId: UUID?
        var beamEntity: ModelEntity?
        var debugLineEntity: ModelEntity?
        
        init(_ parent: IlluminationARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            
            if let firstResult = results.first, !parent.hasAddedAxes {
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
                sceneContainer = container
                anchor.addChild(container)
                
                let targetCube = ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .purple, isMetallic: false)])
                targetCube.position = [0.1, 0.05, 0.1]
                anchor.addChild(targetCube)
                
                parent.currentAnchor = anchor
                parent.hasAddedAxes = true
                
                showMessage("Eixos adicionados com sucesso!", duration: 4)
            } else if !parent.hasAddedAxes {
                showMessage("Tente apontar a câmera para uma área mais iluminada e escanear o ambiente!", duration: 3)
            }
        }
        
        func updateLightFromObject(anchor: ARObjectAnchor) {
            guard let targetAnchor = parent.currentAnchor else { return }
            
            let transform = anchor.transform
            let worldPosition = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )

            let forward = -SIMD3<Float>(
                transform.columns.2.x,
                transform.columns.2.y,
                transform.columns.2.z
            )

            let worldTargetPosition = worldPosition + forward * 0.3

            let position = targetAnchor.convert(position: worldPosition, from: nil)
            let targetPosition = targetAnchor.convert(position: worldTargetPosition, from: nil)

            let direction = normalize(targetPosition - position)

            if let spotLightEntity = lightEntity {
                spotLightEntity.position = position
                let rotation = simd_quatf(from: [0, 0, -1], to: direction)
                spotLightEntity.orientation = rotation
            }

            if let beam = beamEntity {
                let length = simd_length(direction)
                beam.position = (position + targetPosition) / 2
                let up = SIMD3<Float>(0, 1, 0)
                beam.orientation = simd_quatf(from: up, to: direction)
            }
            
            updateDebugLine(from: worldPosition)
        }

        func handleObjectDetection(anchor: ARObjectAnchor) {
            guard let arView = arView else { return }
            guard let targetAnchor = parent.currentAnchor else {
                print("⚠️ Nenhum anchor do cubo presente ainda.")
                return
            }

            let transform = anchor.transform

            let worldPosition = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )

            let forward = -SIMD3<Float>(
                transform.columns.2.x,
                transform.columns.2.y,
                transform.columns.2.z
            )

            let worldTargetPosition = worldPosition + forward * 0.3
            objectAnchorId = anchor.identifier

            let position = targetAnchor.convert(position: worldPosition, from: nil)
            let targetPosition = targetAnchor.convert(position: worldTargetPosition, from: nil)

            addSpotLight(from: position, to: targetPosition, in: targetAnchor)
            updateDebugLine(from: worldPosition)
        }

        func makeDebugLine(length: Float = 0.15, color: UIColor = .cyan) -> ModelEntity {
            let thickness: Float = 0.003
            let mesh = MeshResource.generateBox(size: [thickness, length, thickness])
            let material = SimpleMaterial(color: color.withAlphaComponent(0.5), isMetallic: false)
            let line = ModelEntity(mesh: mesh, materials: [material])
            
            line.position.y += length / 2

            return line
        }
        
        func updateDebugLine(from worldPosition: SIMD3<Float>) {
            guard let targetAnchor = parent.currentAnchor else { return }

            let position = targetAnchor.convert(position: worldPosition, from: nil)

            if let debugLine = debugLineEntity {
                debugLine.position = position
            } else {
                let line = makeDebugLine(length: 0.15, color: .cyan)
                line.position = position
                targetAnchor.addChild(line)
                debugLineEntity = line
            }
        }

        func addSpotLight(from position: SIMD3<Float>, to target: SIMD3<Float>, in anchor: AnchorEntity) {
            lightEntity?.removeFromParent()
            
            let spotLightEntity = Entity()
            spotLightEntity.position = position

            let direction = normalize(target - position)
            let rotation = simd_quatf(from: [0, -1, 0], to: direction) 
            spotLightEntity.orientation = rotation

            var spotLight = SpotLightComponent()
            spotLight.color = .white
            spotLight.intensity = 2000
            spotLight.innerAngleInDegrees = 15
            spotLight.outerAngleInDegrees = 45
            spotLight.attenuationRadius = 2.0
            spotLightEntity.components.set(spotLight)

            anchor.addChild(spotLightEntity)

            let beam = createLightBeam(from: position, to: target)
            beamEntity = beam
            anchor.addChild(beam)

            self.lightEntity = spotLightEntity
        }
        
        func createLightBeam(from start: SIMD3<Float>, to end: SIMD3<Float>) -> ModelEntity {
            let direction = end - start
            let length = simd_length(direction)
            let midPoint = (start + end) / 2

            let cylinderMesh = MeshResource.generateCylinder(height: length, radius: 0.002)
            let cylinderMaterial = SimpleMaterial(color: .yellow.withAlphaComponent(0.8), isMetallic: false)

            let beamEntity = ModelEntity(mesh: cylinderMesh, materials: [cylinderMaterial])
            beamEntity.position = midPoint

            let up = SIMD3<Float>(0, 1, 0)
            let rotation = simd_quatf(from: up, to: normalize(direction))
            beamEntity.orientation = rotation

            return beamEntity
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
        
        func createPlane() -> ModelEntity {
            let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
            let planeMaterial = SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)
            let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            planeEntity.position = SIMD3(0, 0, 0)
            return planeEntity
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
    }
}

struct IlluminationARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String? = "Toque para adicionar o plano!"
    @State private var hasAddedAxes = false
    @State private var currentAnchor: AnchorEntity?
    @State private var showPanel = false
    @State private var arCoordinator: IlluminationARViewContainer.Coordinator?
    
    var body: some View {
        ZStack {
            IlluminationARViewContainer(
                message: $message,
                hasAddedAxes: $hasAddedAxes,
                currentAnchor: $currentAnchor,
                coordinatorRef: $arCoordinator
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

extension IlluminationARViewContainer.Coordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let objectAnchor = anchor as? ARObjectAnchor {
                    let transform = objectAnchor.transform
                    let position = SIMD3<Float>(
                        transform.columns.3.x,
                        transform.columns.3.y,
                        transform.columns.3.z
                    )
                    handleObjectDetection(anchor: objectAnchor)
                } else if let planeAnchor = anchor as? ARPlaneAnchor, !parent.hasAddedAxes {
                    DispatchQueue.main.async {
                        self.parent.message = "Plano detectado! Toque para adicionar os eixos."
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let objectAnchor = anchor as? ARObjectAnchor {
                    print("🔄 Atualizando posição da lanterna.")
                    updateLightFromObject(anchor: objectAnchor)
                }
            }
        }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let objectAnchor = anchor as? ARObjectAnchor {
                if objectAnchor.identifier == objectAnchorId {
                    lightEntity?.removeFromParent()
                    beamEntity?.removeFromParent()
                    debugLineEntity?.removeFromParent()
                    lightEntity = nil
                    beamEntity = nil
                    debugLineEntity = nil
                }
            }
        }
    }
}

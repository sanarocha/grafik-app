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
        context.coordinator.bindPositionUpdates(cameraModel: cameraModel)
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
        var targetEntity: Entity? // referência ao cubo que será olhado
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
                self.targetEntity = targetCube
                
                // painel em RA para mostrar as coordenadas em tempo real definidas no painel auxiliar
                let panel = FloatingPanelEntity()
                panel.position = [0, 0.5, 0]
                anchor.addChild(panel)
                floatingPanel = panel

                
                // Cria o cone visualizando o ponto de vista da câmera
                let coneMesh = MeshResource.generateCone(height: 0.1, radius: 0.04)
                let coneMaterial = SimpleMaterial(color: .cyan, isMetallic: false)
                let coneEntity = ModelEntity(mesh: coneMesh, materials: [coneMaterial])
                coneEntity.name = "cameraViewIndicator"

                anchor.addChild(coneEntity)
                self.cameraIndicator = coneEntity

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
        
        func updatePreviewPanel() {
            guard let target = targetEntity,
                  let arView = arView else { return }
            
            // Aqui vamos simular o "conteúdo da câmera" desenhando uma versão miniatura do cubo
            let cubePreview = ModelEntity(mesh: .generateBox(size: 0.05), materials: [SimpleMaterial(color: .purple, isMetallic: false)])
            cubePreview.position = [0, 0, 0.01] // um pouquinho à frente do painel
            
            // Encontrar o painel na cena
            if let panel = arView.scene.anchors.flatMap({ $0.children }).first(where: { $0.name == "previewPanel" }) {
                panel.children.removeAll() // limpa antes
                panel.addChild(cubePreview)
            }
        }
        
        func showFloatingPanel() {
            guard let arView = arView, floatingPanel == nil else { return }
            
            let panel = FloatingPanelEntity()
            panel.position = [0, 0.1, -0.3]
            
            let anchor = AnchorEntity(world: [0, 0, -0.3])
            anchor.addChild(panel)
            arView.scene.anchors.append(anchor)
            
            floatingPanel = panel
        }
        
        
        func hideFloatingPanel() {
            if let panel = floatingPanel {
                panel.removeFromParent()
                floatingPanel = nil
            }
        }
        
        func bindPositionUpdates(cameraModel: CameraPositionModel) {
            self.cameraModel = cameraModel
            
            cameraModel.$posX
                .sink { [weak self] _ in self?.updateCameraIndicator() }
                .store(in: &cancellables)
            
            cameraModel.$posY
                .sink { [weak self] _ in self?.updateCameraIndicator() }
                .store(in: &cancellables)
            
            cameraModel.$posZ
                .sink { [weak self] _ in self?.updateCameraIndicator() }
                .store(in: &cancellables)
            
            updatePreviewPanel()
            
        }
        
        func updateCameraIndicator() {
            guard let indicator = cameraIndicator,
                  let target = targetEntity,
                  let model = cameraModel else { return }

            indicator.position = [model.posX, model.posY, model.posZ]

            // isso faz o cone ficar girando em cima do cubo
//            indicator.look(at: target.position(relativeTo: nil), from: indicator.position(relativeTo: nil), relativeTo: nil)

            floatingPanel?.updateText(x: model.posX, y: model.posY, z: model.posZ)
        }

        func resetCameraPosition() {
            cameraModel?.posX = 0
            cameraModel?.posY = 0
            cameraModel?.posZ = 0
            updateCameraIndicator()
        }
        
        
        func createAxis() -> ModelEntity {
            let axisLength: Float = 0.3
            let xAxis = MeshResource.generateBox(size: [0.01, 0.01, axisLength])
            let yAxis = MeshResource.generateBox(size: [axisLength, 0.01, 0.01])
            let zAxis = MeshResource.generateBox(size: [0.01, axisLength, 0.01])
            
            let redTransparent = SimpleMaterial(color: UIColor.red.withAlphaComponent(0.3), isMetallic: false)
            let greenTransparent = SimpleMaterial(color: UIColor.green.withAlphaComponent(0.3), isMetallic: false)
            let blueTransparent = SimpleMaterial(color: UIColor.blue.withAlphaComponent(0.3), isMetallic: false)
            
            let xMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let yMaterial = SimpleMaterial(color: .green, isMetallic: false)
            let zMaterial = SimpleMaterial(color: .blue, isMetallic: false)
            
            let xModel = ModelEntity(mesh: xAxis, materials: [xMaterial])
            let yModel = ModelEntity(mesh: yAxis, materials: [yMaterial])
            let zModel = ModelEntity(mesh: zAxis, materials: [zMaterial])
            
            xModel.position = SIMD3(0, 0, axisLength / 2)
            xModel.addChild(makeDashedLine(axis: [0,0,1], color: redTransparent))
            xModel.addChild(makeArrow(color: xMaterial, axis: [0,0,1]))
            
            yModel.position = SIMD3(axisLength / 2, 0, 0)
            yModel.addChild(makeDashedLine(axis: [1,0,0], color: greenTransparent))
            yModel.addChild(makeArrow(color: yMaterial, axis: [1,0,0]))
            
            zModel.position = SIMD3(0, axisLength / 2, 0)
            zModel.addChild(makeDashedLine(axis: [0,1,0], color: blueTransparent))
            zModel.addChild(makeArrow(color: zMaterial, axis: [0,1,0]))
            
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
            
            let direction = normalize(axis)
            var orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            
            if axis == [1, 0, 0] {
                orientation = simd_quatf(angle: -.pi/2, axis: [0, 0, 1])
            } else if axis == [0, 0, 1] {
                orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
            }
            
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
    @State private var showPanel = false
    @State private var arCoordinator: CameraARViewContainer.Coordinator?
    
    
    @StateObject private var cameraModel = CameraPositionModel()
    
    var body: some View {
        ZStack {
            CameraARViewContainer(
                message: $message,
                hasAddedAxes: $hasAddedAxes,
                currentAnchor: $currentAnchor,
                showPanel: $showPanel,
                coordinatorRef: $arCoordinator,
                cameraModel: cameraModel
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
                        showPanel.toggle()
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
                    VStack {
                        Spacer()
                        CameraControlsPanel(
                            cameraModel: cameraModel,
                            onReset: {
                                cameraModel.posX = 0
                                cameraModel.posY = 0
                                cameraModel.posZ = 0
                                arCoordinator?.resetCameraPosition()
                            }
                        )
                        
                    }
                }
            }
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

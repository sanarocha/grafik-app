import RealityKit
import UIKit

class TransformationFloatingPanelEntity: Entity, HasModel {
    private var textEntity: ModelEntity!

    required init() {
        super.init()
        
        // ---------- BORDA BRANCA ----------
        let borderMesh = MeshResource.generatePlane(width: 0.42, height: 0.32, cornerRadius: 0.018)
        let borderMaterial = SimpleMaterial(
            color: .white,
            roughness: 1,
            isMetallic: false
        )
        let border = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
        border.position = [0, 0, 0.003]
        self.addChild(border)

        // ---------- FUNDO PRETO ----------
        let backgroundMesh = MeshResource.generatePlane(width: 0.4, height: 0.3, cornerRadius: 0.015)
        let backgroundMaterial = SimpleMaterial(
            color: .black.withAlphaComponent(0.85),
            roughness: 1,
            isMetallic: false
        )
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        background.position = [0, 0, 0.004]
        self.addChild(background)

        // ---------- TEXTO INICIAL ----------
        let initialText = Self.generateText(
            matrix: matrix_identity_float4x4,
            position: SIMD3<Float>(repeating: 0),
            rotation: SIMD3<Float>(repeating: 0),
            scale: 1.0
        )

        let textMesh = MeshResource.generateText(
            initialText,
            extrusionDepth: 0.002,
            font: UIFont(name: "Menlo", size: 0.015) ?? .systemFont(ofSize: 0.015),
            containerFrame: CGRect(x: 0, y: 0, width: 0.38, height: 0.28),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [-0.18, -0.17, 0.02]
        self.addChild(textEntity)
    }
    
    func updateTextFromModel(model: TransformationModel, matrix: float4x4) {
        let position = SIMD3<Float>(model.posX, model.posY, model.posZ)
        let rotation = SIMD3<Float>(model.rotX, model.rotY, model.rotZ)
        let scale = model.scale

        let textString = Self.generateText(matrix: matrix, position: position, rotation: rotation, scale: scale)

        let mesh = MeshResource.generateText(
            textString,
            extrusionDepth: 0.002,
            font: UIFont(name: "Menlo", size: 0.015) ?? .systemFont(ofSize: 0.015),
            containerFrame: CGRect(x: 0, y: 0, width: 0.38, height: 0.28),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: .white, isMetallic: false)
        textEntity.model = ModelComponent(mesh: mesh, materials: [material])
    }

    func updateText(matrix: float4x4, position: SIMD3<Float>, rotation: SIMD3<Float>, scale: Float) {
        let textString = Self.generateText(matrix: matrix, position: position, rotation: rotation, scale: scale)

        let mesh = MeshResource.generateText(
            textString,
            extrusionDepth: 0.002,
            font: UIFont(name: "Menlo", size: 0.015) ?? .systemFont(ofSize: 0.015),
            containerFrame: CGRect(x: 0, y: 0, width: 0.38, height: 0.28),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: .white, isMetallic: false)
        textEntity.model = ModelComponent(mesh: mesh, materials: [material])
    }

    func updateTransformMatrix(_ transform: Transform) {
        let matrix = transform.matrix
        let pos = transform.translation
        let rot = transform.rotation
        let scale = transform.scale.x

        let euler = rotationToEulerAngles(rot)

        let correctedPos = SIMD3<Float>(
            pos.x,
            pos.y,
            pos.z
        )

        let correctedRot = SIMD3<Float>(
            euler.x,
            euler.y,
            euler.z
        )

        let text = Self.generateText(matrix: matrix, position: correctedPos, rotation: correctedRot, scale: scale)

        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: UIFont(name: "Menlo", size: 0.015) ?? .systemFont(ofSize: 0.015),
            containerFrame: CGRect(x: 0, y: 0, width: 0.38, height: 0.28),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        textEntity.model?.mesh = textMesh
    }
    
    private static func generateText(matrix: float4x4, position: SIMD3<Float>, rotation: SIMD3<Float>, scale: Float) -> String {
        let matrixText = (0..<4).map { row in
            String(format: "[%7.2f %7.2f %7.2f %7.2f]",
                matrix.columns.0[row],
                matrix.columns.1[row],
                matrix.columns.2[row],
                matrix.columns.3[row])
        }.joined(separator: "\n")

        let infoText = String(format:
        """
        
        📍 Posição
        X: %.2f  Y: %.2f  Z: %.2f

        🔁 Rotação (°)
        X (Pitch): %.2f
        Y (Yaw):   %.2f
        Z (Roll):  %.2f

        📏 Escala: %.2f
        """, position.x, position.y, position.z,
            rotation.x, rotation.y, rotation.z,
           scale)

        return "\(matrixText)\n\(infoText)"
    }

    private func rotationToEulerAngles(_ q: simd_quatf) -> SIMD3<Float> {
        let sinr_cosp = 2 * (q.real * q.imag.x + q.imag.y * q.imag.z)
        let cosr_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        let sinp = 2 * (q.real * q.imag.y - q.imag.z * q.imag.x)
        let pitch: Float
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp)
        } else {
            pitch = asin(sinp)
        }

        let siny_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
        let cosy_cosp = 1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        return SIMD3<Float>(pitch, yaw, roll) * 180 / .pi
    }
}

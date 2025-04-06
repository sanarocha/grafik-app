//
//  TransformExercise.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 06/04/25.
//

struct TransformExpectation {
    var position: SIMD3<Float>
    var rotation: SIMD3<Float>
    var scale: Float
}

struct TransformationExercise {
    var id: Int
    var title: String
    var description: String
    var expected: TransformExpectation
    var status: TransformExerciseStatus = .pending
}

enum TransformExerciseStatus {
    case pending, completed, failed
}


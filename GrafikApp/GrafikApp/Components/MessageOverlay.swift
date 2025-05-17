//
//  MessageOverlay.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 19/03/25.
//
import SwiftUI

struct MessageOverlay: View {
    let message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .allowsTightening(false)
    }
}

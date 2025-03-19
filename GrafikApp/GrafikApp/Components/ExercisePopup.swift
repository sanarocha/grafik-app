//
//  ExercisePopup.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 19/03/25.
//
import SwiftUI

struct ExercisePopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.top, 20) 
                    .padding(.trailing, 20) 
                }

                Spacer()

                Text("Exercício 1 - Objetos 3D podem ser manipulados de diferentes formas para criar animações, cenas interativas, etc. Neste exercício você aprenderá sobre as três transformações fundamentais!")
                    .padding()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Transformação 1 - Translação: Mova o objeto pelo espaço sem alterar seu tamanho ou orientação.")
                    .padding()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.7))
            .edgesIgnoringSafeArea(.all)
        }
    }
}


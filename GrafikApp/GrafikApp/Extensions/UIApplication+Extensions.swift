//
//  UIApplication+Extensions.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 21/04/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

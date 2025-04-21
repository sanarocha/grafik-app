//
//  Font+Extensions.swift
//  GrafikApp
//
//  Created by Rossana Rocha on 18/04/25.
//

import SwiftUI

extension Font {
    static func balooBold(size: CGFloat) -> Font {
        return .custom("Baloo2-Bold", size: size)
    }

    static func balooRegular(size: CGFloat) -> Font {
        return .custom("Baloo2-Regular", size: size)
    }

    static func balooMedium(size: CGFloat) -> Font {
        return .custom("Baloo2-Medium", size: size)
    }

    static func balooSemiBold(size: CGFloat) -> Font {
        return .custom("Baloo2-SemiBold", size: size)
    }

    static func balooExtraBold(size: CGFloat) -> Font {
        return .custom("Baloo2-ExtraBold", size: size)
    }
}


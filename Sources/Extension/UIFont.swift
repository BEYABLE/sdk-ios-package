//
//  UIFont.swift
//
//
//  Created by MarKinho on 05/08/2024.
//

import UIKit

extension UIFont.Weight {
    static func fromString(_ weight: String) -> UIFont.Weight {
        switch weight.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }
}

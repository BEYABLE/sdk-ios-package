//
//  ImageUtils.swift
//
//
//  Created by MarKinho on 26/07/2024.
//

import UIKit

class ImageUtils {

    static func pxToDp(px: Int) -> CGFloat {
        let scale = UIScreen.main.scale
        return CGFloat(px) / scale
    }

    static func decodeBase64ToImage(_ base64Str: String) -> UIImage? {
        var base64Str = base64Str.replacingOccurrences(of: "data:image/png;base64,", with: "")
        base64Str = base64Str.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        guard let data = Data(base64Encoded: base64Str, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: data)
    }
}

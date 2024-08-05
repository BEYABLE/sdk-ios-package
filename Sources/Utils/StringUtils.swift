//
//  StringUtils.swift
//
//
//  Created by Markinho on 05/07/2024.
//

import Foundation

class StringUtils {
    
    static func secureRandomString(length: Int) -> String {
        let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: length)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            
            if status == errSecSuccess {
                for byte in randomBytes {
                    if remainingLength == 0 {
                        break
                    }
                    result.append(characters[Int(byte) % characters.count])
                    remainingLength -= 1
                }
            } else {
                fatalError("Unable to generate random string")
            }
        }
        
        return result
    }
    
    /// This function takes the combined HTML/CSS received by the WebService and separates them.
    /// - Parameters:
    ///   - combinedString:
    ///   - idk: id campaing needs to be included on the top of html
    /// - Returns: css and html separed
    static func makeHtmlContain(combinedString : String, idk : String) -> (String, String) {        
        var htmlString = ""
        var css = ""
        let input = combinedString
        //Regular expression to extract the CSS.
        let cssPattern = "<style[^>]*>(.*?)</style>"
        if let cssRegex = try? NSRegularExpression(pattern: cssPattern, options: .dotMatchesLineSeparators) {
            let cssMatches = cssRegex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            css = cssMatches.map {
                String(input[Range($0.range, in: input)!])
            }.joined()
        }
        
        //Delete css from html
        var htmlWithoutCSS = input.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Delete comments from html
        htmlWithoutCSS = htmlWithoutCSS.replacingOccurrences(of: "(?s)<!--.*?-->", with: "", options: .regularExpression)
        
        htmlString = "<html><head></head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <body><div id=\"by_r_\(idk)\">\(htmlWithoutCSS) </div></body></html>";
        
        css = WebViewUtils.instance.cleanCss(cssToClean: css)
        
        return (htmlString, css)
        
    }
    
    static func parseHtmlContent(combinedString : String, idk : String) -> String {
        var htmlString = ""
        var css = ""
        let input = combinedString
        //Regular expression to extract the CSS.
        let cssPattern = "<style[^>]*>(.*?)</style>"
        if let cssRegex = try? NSRegularExpression(pattern: cssPattern, options: .dotMatchesLineSeparators) {
            let cssMatches = cssRegex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            css = cssMatches.map {
                String(input[Range($0.range, in: input)!])
            }.joined()
        }
        
        //Delete css from html
        var htmlWithoutCSS = input.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Delete comments from html
        htmlWithoutCSS = htmlWithoutCSS.replacingOccurrences(of: "(?s)<!--.*?-->", with: "", options: .regularExpression)
        htmlString = "<html><head></head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,user-scalable=no\"><body><div id=\"by_r_\(idk)\">\(htmlWithoutCSS)</div></body></html>";
        css = WebViewUtils.instance.cleanCss(cssToClean: css)
        htmlString += css
        
        return htmlString
        
    }
    
    
    static func getCurrentISO8601Date() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentDate = Date()
        let iso8601String = dateFormatter.string(from: currentDate)
        return iso8601String
    }

}

//
//  MessageJavascript.swift
//
//
//  Created by Ouamassi Brahim on 30/01/2024.
//

import Foundation

/// Contains the identifiers that JavaScript will send to the native code when it performs certain actions
public enum MessageJavascript : String {
    /// When close pressed on the javascript popup
    case CLOSE = "closePopup"
    /// When redirection must be performed on the sdk 
    case REDIRECTION_LINK = "linkRedirection"
}

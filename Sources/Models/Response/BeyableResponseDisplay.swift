//
//  BeyableResponseDisplay.swift
//
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
import SwiftUI
/// The response of the request that will be sent to the server for the '/api/v3/display' request.
struct BeyableResponseDisplay : Codable {
    let uniqueId: String?
    let trackingId: String?
    let sessionId: String?
    let sessionToken: String?
    let crossSessionToken: String?
    var messages: [BeyableResponseCampaign]?
}
/// Camaign response
public struct BeyableResponseCampaign : Codable {
    public var campaignId: String?
    public var campaignName: String?
    public var associatedJavascript: String?
    public var content: String?
    public var slideId: String?
    var mustBeDisplayed : Bool?
    var variation : String?
    var variant : String?
    ///Time delay in milliseconds to display the campaign 
    var displayAfter : Int?
    var displayOnScroll : Int?
    ///The identifier of the element relative to which it should be positioned in the inPage campaign.
    var inPagePosition : InPagePosition?
    var displayType: String?
    var displayComponentsLayout : DisplayComponentLayout?
    var displayComponents: [DisplayComponent]?
    var inCollectionElement: InCollectionComponentLayout?
}

///The identifier of the element relative to which it should be positioned in the inPage campaign.
public struct InPagePosition : Codable {
    public var elementSelector: String?
    public var relativePlacement: String?
    public var orientation: String?
}

public struct DisplayComponentLayout : Codable {
    public var layoutType: String?
}

public struct DisplayComponent : Codable {
    public var componentType: String?
    public var htmlJavascript: HtmlJsDisplayComponent?
    public var imageFromUrl: ImgUrlDisplayComponent?
    public var imageFromBinary: ImgB64DisplayComponent?
    public var text: TextDisplayComponent?    
    public var cta: CtaOnDisplay?
}


public struct HtmlJsDisplayComponent : Codable {
    public var associatedJavascript: String?
    public var content: String?
}

public struct ImgUrlDisplayComponent : Codable {
    public var url: String?
    public var width: Int?
    public var height: Int?
}

public struct ImgB64DisplayComponent : Codable {
    public var content: String?
    public var width: Int?
    public var height: Int?
}

public struct TextDisplayComponent : Codable {
    public var text: String?
    public var fontSize: String?
    public var fontWeight: String?
    public var textDecoration: String?
    public var color: String?
    public var backgroundColor: String?
    
    enum CodingKeys: String, CodingKey {
        case text               = "text"
        case fontSize           = "fontSize"
        case fontWeight         = "fontWeight"
        case textDecoration     = "text-decoration"
        case color              = "color"
        case backgroundColor    = "backgroundColor"
    }
}

public struct CtaOnDisplay : Codable {
    public var url: String?
    public var callback: String?
    public var interactionName: String?
}

public struct InCollectionComponentLayout : Codable {
    public var targetedCollectionElementIds: [String]?
    public var placementSelector: String?
    public var relativePlacement: String?
    public var orientation: String?
}


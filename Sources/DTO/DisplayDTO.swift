//
//  DisplayDTO.swift
//
//
//  Created by MarKinho on 22/07/2024.
//

import Foundation


/// Relative placements of a campaign for InPage and InCollection
public enum DisplayComponentType {
    case HTML
    case IMG_URL
    case IMG_B64
    case TEXT
    case EMPTY
}


public class DisplayDTO {
    
    let campaignId: String
    let slideId: String
    let layoutType: String
    let componentType: DisplayComponentType?
    let associatedJavascript: String
    let content: String
    let css: String
    let imageUrl: String
    let imageB64: String
    var cta: String?
    var ctaIsUrl: Bool = false
    var ctaIsCallback: Bool = false
    var ctaHasInteraction = false
    var ctaInteractionValue: String = ""
    var imageWidthPx: Int = 0
    var imageHeightPx: Int = 0
    var textDisplay: TextDisplayComponent? = nil
    var currentTarget = ""
    

    init(campaignId: String, slideId: String, layoutType: String, displayComponent: DisplayComponent) {
        self.campaignId     = campaignId
        self.slideId        = slideId
        self.layoutType     = layoutType
        let componentType   = displayComponent.componentType!
        
        if componentType.caseInsensitiveCompare("ImageFromBinary") == .orderedSame {
            self.componentType          = .IMG_B64
            self.associatedJavascript   = ""
            self.content                = ""
            self.imageUrl               = ""
            self.imageB64               = (displayComponent.imageFromBinary?.content)!
            self.imageWidthPx           = (displayComponent.imageFromBinary?.width)!
            self.imageHeightPx          = (displayComponent.imageFromBinary?.height)!
            self.css                    = ""
        } else if componentType.caseInsensitiveCompare("ImageFromUrl") == .orderedSame {
            self.componentType          = .IMG_URL
            self.associatedJavascript   = ""
            self.content                = ""
            self.imageB64               = ""
            self.imageUrl               = (displayComponent.imageFromUrl?.url)!
            self.imageWidthPx           = (displayComponent.imageFromUrl?.width)!
            self.imageHeightPx          = (displayComponent.imageFromUrl?.height)!
            self.css                    = ""
        } else if componentType.caseInsensitiveCompare("HtmlJavascript") == .orderedSame {
            self.componentType          = .HTML
            let (html , css) = StringUtils.makeHtmlContain(combinedString: displayComponent.htmlJavascript?.content ?? "", idk: "")
            let javaScriptFormated = WebViewUtils.instance.makeJavascriptCorrection( script: displayComponent.htmlJavascript?.associatedJavascript ?? "", css: css, attributes: nil)
            self.associatedJavascript   = javaScriptFormated
            self.content                = html+css
            self.imageUrl               = ""
            self.imageB64               = ""
            self.css                    = ""
        } else if componentType.caseInsensitiveCompare("Text") == .orderedSame {
            self.componentType          = .TEXT
            self.textDisplay            = displayComponent.text!
            self.associatedJavascript   = ""
            self.content                = ""
            self.imageUrl               = ""
            self.imageB64               = ""
            self.css                    = ""
        } else if componentType.caseInsensitiveCompare("Empty") == .orderedSame {
            self.componentType          = .EMPTY
            self.associatedJavascript   = ""
            self.content                = ""
            self.imageUrl               = ""
            self.imageB64               = ""
            self.css                    = ""
        } else {
            self.componentType          = nil
            self.associatedJavascript   = ""
            self.content                = ""
            self.imageUrl               = ""
            self.imageB64               = ""
            self.css                    = ""
        }
        if displayComponent.cta != nil {
            // CTA url/deeplink
            var ctaUrl = displayComponent.cta?.url;
            // CTA callback
            var callback = displayComponent.cta?.callback;
            if (ctaUrl != nil && !(ctaUrl!.isEmpty) && !(ctaUrl!.caseInsensitiveCompare("null") == .orderedSame)) {
                self.cta = ctaUrl;
                self.ctaIsUrl = true;
            } else if (callback != nil && !(callback!.isEmpty) && !(callback!.caseInsensitiveCompare("null") == .orderedSame)) {
                self.cta = callback;
                self.ctaIsCallback = true;
            } else {
                self.cta = nil
            }
            // CTA Interaction
            if let interaction = displayComponent.cta?.interactionName {
                ctaHasInteraction = true
                ctaInteractionValue = interaction
            }            
        } else {
            self.cta = nil;
        }
    }
    
    init(campaignId: String, slideId: String, layoutType: String, html: String, css: String, javascript: String) {
        self.campaignId             = campaignId
        self.slideId                = slideId
        self.componentType          = .HTML
        self.layoutType             = layoutType
        self.associatedJavascript   = javascript
        self.content                = html
        self.css                    = css
        self.imageUrl               = ""
        self.imageB64               = ""
        self.imageWidthPx           = 0
        self.imageHeightPx          = 0
        self.cta                    = nil
    }
}

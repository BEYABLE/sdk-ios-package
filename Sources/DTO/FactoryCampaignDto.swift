//
//  FactoryCampaignDto.swift
//
//
//  Created by Ouamassi Brahim on 29/01/2024.
//

import Foundation

///  FactoryCampaignDto it's take the Campagn received from WebService and return the campagn used to be displayed on screen
class FactoryCampaignDto {
    /// Will be integrated to javascript
    public var attributes : BYAttributes?
    public static let instance = FactoryCampaignDto()
    
    ///  it's take the Campagn received from WebService and return the campagn used to be displayed on screen
    /// - Parameter campagnResponse: Campaign received from webService
    /// - Returns: Campaign that will be used for displaying on the screen
    public func makeCompaingDto(campagnResponse : BeyableResponseCampaign) -> CampaignDTO{
        let campaign = CampaignDTO()
        
        // DISPLAYS
        let idCompaign = (campagnResponse.slideId ?? "").replacingOccurrences(of: "-", with: "")
        let (html , css) = StringUtils.makeHtmlContain(combinedString: campagnResponse.content ?? "", idk: idCompaign)
        let javaScriptFormated = WebViewUtils.instance.makeJavascriptCorrection( script: campagnResponse.associatedJavascript ?? "", css: css, attributes: attributes ?? nil)
        
        // Type de campagen. En principe, y a le champs referencer,
        // mais sinon, on essaye de l'identifier avec les classes CSS
        let tp = getDisplayType(layoutType: campagnResponse.displayType!)
        if tp == TypeCampaign.OTHER {
            campaign.typeCampagne = findDisplayType(css: css)
        } else {
            campaign.typeCampagne = tp
        }
        
        
        campaign.campagnId           = campagnResponse.campaignId ?? ""
        campaign.variant             = campagnResponse.variant ?? ""
        campaign.variation           = campagnResponse.variation ?? ""
        campaign.slideId             = campagnResponse.slideId ?? ""
        campaign.mustBeDisplayed     = campagnResponse.mustBeDisplayed ?? false
        campaign.campaignName        = campagnResponse.campaignName ?? ""
        campaign.displayAfter        = Double(campagnResponse.displayAfter ?? 0)
        campaign.displayOnScroll     = campagnResponse.displayOnScroll ?? 0
        campaign.elementSelector     = campagnResponse.inPagePosition?.elementSelector ?? ""
        
      
        var displays = [DisplayDTO]()
        if let displayComponents = campagnResponse.displayComponents {
            if displayComponents.count > 0 {
                for displayResponse in displayComponents {
                    let displayDto = DisplayDTO(layoutType: campagnResponse.displayComponentsLayout?.layoutType ?? "", displayComponent: displayResponse)
                    campaign.displays.append(displayDto)
                }
            } else {
                let displayDto = DisplayDTO(layoutType: "", html: html, css: css, javascript: javaScriptFormated)
                campaign.displays.append(displayDto)
            }
        }
        
        // In Page Components
        if campaign.typeCampagne == TypeCampaign.IN_PAGE {
            let placement = (campagnResponse.inPagePosition?.relativePlacement)!
            if placement.caseInsensitiveCompare("Above") == .orderedSame ||
                placement.caseInsensitiveCompare("AdjacentBeforeBegin") == .orderedSame ||
                placement.caseInsensitiveCompare("AdjacentBeforeEnd") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.ABOVE
            }
            else if placement.caseInsensitiveCompare("Right") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.RIGHT
            }
            else if placement.caseInsensitiveCompare("Below") == .orderedSame ||
                        placement.caseInsensitiveCompare("AdjacentAfterBegin") == .orderedSame ||
                        placement.caseInsensitiveCompare("AdjacentAfterEnd") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.BELOW
            }
            else if placement.caseInsensitiveCompare("Left") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.LEFT
            }
            else if placement.caseInsensitiveCompare("Replace") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.REPLACE
            }
        }
        // In collection Components
        else if campaign.typeCampagne == TypeCampaign.IN_COLLECTION {
            campaign.inCollectionTargets = (campagnResponse.inCollectionElement?.targetedCollectionElementIds)!
            campaign.inCollectionPlacementId = (campagnResponse.inCollectionElement?.placementSelector)!
            let placement = (campagnResponse.inCollectionElement?.relativePlacement)!
            if placement.caseInsensitiveCompare("Above") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.ABOVE
            }
            else if placement.caseInsensitiveCompare("Right") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.RIGHT
            }
            else if placement.caseInsensitiveCompare("Below") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.BELOW
            }
            else if placement.caseInsensitiveCompare("Left") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.LEFT
            }
            else if placement.caseInsensitiveCompare("Replace") == .orderedSame {
                campaign.inCollectionPlacement = RelativePlacement.REPLACE
            }
        }
        
        
        return campaign;
    }
    ///  it's take the list Campagns received from WebService and return the campagns list used to be displayed on screen
    /// - Parameter campagnsResponse: Campaign list received from webService
    /// - Returns: Campaign list that will be used for displaying on the screen
    public func makeCompaingsDto(campagnsResponse : [BeyableResponseCampaign]) -> [CampaignDTO]{
        var listCampaings = [CampaignDTO]()
        for campaignResponse in campagnsResponse {
            let campaignDto = makeCompaingDto(campagnResponse: campaignResponse)
            listCampaings.append(campaignDto)
        }
        
        return listCampaings
    }
    
        
    private func getDisplayType(layoutType: String) -> TypeCampaign {
        if layoutType.caseInsensitiveCompare("Overlay") == .orderedSame {
            return TypeCampaign.OVERLAY
        }
        else if layoutType.caseInsensitiveCompare("InPage") == .orderedSame {
            return TypeCampaign.IN_PAGE
        }
        else if layoutType.caseInsensitiveCompare("StickyHeaderBar") == .orderedSame {
            return TypeCampaign.HEADER
        }
        else if layoutType.caseInsensitiveCompare("HeaderBar") == .orderedSame {
            return TypeCampaign.HEADER
        }
        else if layoutType.caseInsensitiveCompare("StickyFooterBar") == .orderedSame {
            return TypeCampaign.FOOTER
        }
        else if layoutType.caseInsensitiveCompare("InCollection") == .orderedSame {
            return TypeCampaign.IN_COLLECTION
        }
        return TypeCampaign.OTHER
    }
    
    private func findDisplayType(css: String) -> TypeCampaign {
        if css.contains("by_HB_G") {
            return TypeCampaign.HEADER
        }
        else if css.contains("by_O_G") {
            return TypeCampaign.OVERLAY
        }
        else if css.contains("by_COL_G") {
            return TypeCampaign.IN_COLLECTION
        }
        else if css.contains("by_IP_G_") {
            return TypeCampaign.IN_PAGE
        }
        return TypeCampaign.OTHER
    }
}

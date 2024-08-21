//
//  CampaignDTO.swift
//
//
//  Created by Ouamassi Brahim on 28/01/2024.
//

import Foundation

/// CampagnDto is used to display information on the screen
public class CampaignDTO: Identifiable, Hashable  {
    var campagnId = ""
    /// =``BeyableResponseCampaign.slideId``
    var slideId = ""
    /// =``BeyableResponseCampaign.mustBeDisplayed``
    var mustBeDisplayed = false
    /// =``BeyableResponseCampaign.campaignName``
    var campaignName = ""
    /// =``BeyableResponseCampaign.variation``
    var variation : String = ""
    /// =``BeyableResponseCampaign.variant``
    var variant : String = ""
    /// =``BeyableResponseCampaign.displayAfter``
    var displayAfter : Double = 0
    /// =``BeyableResponseCampaign.displayOnScroll``
    var displayOnScroll : Int = 0
    /// we get this value from css, by trying to find some key word  for example  if(css.contains("by_HB_G")){ typeCampagne = HEADER for now it's a temporary solution
    var typeCampagne : TypeCampaign?
    /// Field for the campaing inPage
    var elementSelector : String?
    /// Show campain only one time
    var alreadyShowen : Bool = false
    // Relative placement for InPage
    var positionInPage : RelativePlacement = RelativePlacement.ABOVE
    var inPageHeight: CGFloat = 0.0
    /// Liste des objects avec les informations d'affichage
    var displays: [DisplayDTO] = []
    
    var inCollectionTargets: [String] = []
    var inCollectionPlacementId: String = ""
    var inCollectionPlacement: RelativePlacement = RelativePlacement.ABOVE
    
        
    func isTarget(_ elementId: String) -> Bool {
        for target in self.inCollectionTargets {
            if target.caseInsensitiveCompare(elementId) == .orderedSame {
                return true
            }
        }
        return false
    }


    func isPlaceHolder(_ placeHolderId: String) -> Bool {
        return placeHolderId.caseInsensitiveCompare(self.inCollectionPlacementId) == .orderedSame
    }
    
    // Implémentez `Hashable`
    public static func == (lhs: CampaignDTO, rhs: CampaignDTO) -> Bool {
        return lhs.campagnId == rhs.campagnId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Type Of Campaign
public enum TypeCampaign {
    case HEADER
    case FOOTER
    case OVERLAY
    case IN_PAGE
    case IN_COLLECTION
    /// TODO next step handle other type
    case OTHER
}

/// Relative placements of a campaign for InPage and InCollection
public enum RelativePlacement {
    case ABOVE
    case RIGHT
    case BELOW
    case LEFT
    case REPLACE
}

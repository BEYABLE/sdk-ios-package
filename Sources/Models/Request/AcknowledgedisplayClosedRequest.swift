//
//  AcknowledgedisplayClosedRequest.swift
//
//
//  Created by Ouamassi Brahim on 29/01/2024.
//

import Foundation
///  The body of the request that will be sent to the server for the 'acknowledgeslideclosed' request.
class AcknowledgedisplayClosedRequest : Codable {
    
    var uniqueId : String?
    var trackingId : String?
    var sessionId : String?
    var sessionToken : String?
    var displayProcess : DisplayProcess?
    var crossSessionToken : String?
    var tenant: String = ""
    var slides : [Slide]?
    
    init(uniqueId: String? = nil, trackingId: String? = nil, sessionId: String? = nil, sessionToken: String? = nil, displayProcess: DisplayProcess? = nil) {
        self.uniqueId = DataStorageHelper.getData(type: String.self, forKey: .uniqueId) ?? ""
        self.trackingId = DataStorageHelper.getData(type: String.self, forKey: .trackingId) ?? ""
        self.sessionId = DataStorageHelper.getData(type: String.self, forKey: .sessionId) ?? ""
        self.sessionToken = DataStorageHelper.getData(type: String.self, forKey: .sessionToken) ?? ""
        self.crossSessionToken = DataStorageHelper.getData(type: String.self, forKey: .crossSessionToken) ?? ""        
        self.displayProcess = DataStorageHelper.getObjectFromDataString(forKey: .displayProcess)
    }
    
    func setSlidesByCampaings(){
        var listSlides = [Slide]()
        guard let displayP = displayProcess?.campaignHistory else {
            self.slides = listSlides
            return
        }
        for display in displayP {
            let slide = Slide()
            slide.slideId = display.slideId
            slide.campaignId = display.campaignId
            slide.variant = ""
            slide.variation = display.variation
            
            listSlides.append(slide)
        }
        self.slides = listSlides
    }

}


class Slide : Codable {
    var slideId : String?
    var campaignId : String?
    var variant : String?
    var variation : String?
    
}

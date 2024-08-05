//
//  File.swift
//  
//
//  Created by Ouamassi Brahim on 29/01/2024.
//

import Foundation
///  The body of the request that will be sent to the server for the 'acknowledgeslideclosed' request /api/v3/acknowledgedisplay
class AcknowledgedisplayRequest : Codable {
    
    var uniqueId : String?
    var trackingId : String?
    var sessionId : String?
    var sessionToken : String?
    var tenant : String = ""
    var messageDisplays : [MessageDisplays]? = nil
    var crossSessionToken : String?
    var displayProcess : DisplayProcess?
    
    static public func getMessageDisplays(campaignDTO : [CampaignDTO]) -> [MessageDisplays]{
        var messages = [MessageDisplays]()
        
        for campagne in campaignDTO {
            let message = MessageDisplays()
            message.campaignId = campagne.campagnId
            message.campaignName = campagne.campaignName
            message.hasBeenDisplayed = campagne.mustBeDisplayed
            message.slideId = campagne.slideId
            message.variant = campagne.variant
            message.variation = campagne.variation
            messages.append(message)
        }
        
        return messages
    }
    
    init(uniqueId: String? = nil, trackingId: String? = nil, sessionId: String? = nil, sessionToken: String? = nil, 
         messageDisplays: [MessageDisplays]? = nil, displayProcess: DisplayProcess? = nil) {
        self.uniqueId           = DataStorageHelper.getData(type: String.self, forKey: .uniqueId) ?? ""
        self.trackingId         = DataStorageHelper.getData(type: String.self, forKey: .trackingId) ?? ""
        self.sessionId          = DataStorageHelper.getData(type: String.self, forKey: .sessionId) ?? ""
        self.sessionToken       = DataStorageHelper.getData(type: String.self, forKey: .sessionToken) ?? ""
        self.crossSessionToken  = DataStorageHelper.getData(type: String.self, forKey: .crossSessionToken) ?? ""
        self.displayProcess     = DataStorageHelper.getObjectFromDataString(forKey: .displayProcess)
    }
    
}


class MessageDisplays : Codable {
    var campaignId = ""
    var slideId = ""
    var hasBeenDisplayed = false
    var campaignName = ""
    var variant = ""
    var variation = ""
    
}

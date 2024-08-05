//
//  SaveInteractionRequestModel.swift
//
//
//  Created by MarKinho on 05/08/2024.
//

import Foundation


class SaveInteractionRequestModel : Codable {
    
    var sessionToken: String
    var uniqueId: String
    var trackingId: String
    var campaignId: String
    var tenant: String
    var slideId: String
    var pageViewDate: String
    var pageUrl: String
    var interactions: [BYInteraction]
    
    init(sessionToken: String, uniqueId: String, trackingId: String, tenant: String, campaignId: String, slideId: String, pageViewDate: String, pageUrl: String, interactions: [BYInteraction]) {
        self.sessionToken   = sessionToken
        self.uniqueId       = uniqueId
        self.trackingId     = trackingId
        self.tenant         = tenant
        self.campaignId     = campaignId
        self.slideId        = slideId
        self.pageViewDate   = pageViewDate
        self.pageUrl        = pageUrl
        self.interactions   = interactions
    }
    
}


public class BYInteraction : Codable {
    var eventName: String
    var eventValue: String
    
    init(eventName: String, eventValue: String) {
        self.eventName = eventName
        self.eventValue = eventValue
    }
}

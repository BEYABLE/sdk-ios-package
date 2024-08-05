//
//  SaveObjectiveRequestModel.swift
//
//
//  Created by MarKinho on 05/08/2024.
//

import Foundation


class SaveObjectiveRequestModel: Codable {
    
    
    var sessionToken: String
    var uniqueId: String
    var trackingId: String
    
    var lastClickCampaignId: String
    var amount: CGFloat
    var numberOfItems: Int
    var reference: String
    var payment: String
    var promoCode: String
    var paymentStatus: String
    var paymentDate: String
    var isNewClient: Bool
    var pseudoId: String
    var tenant: String
    var tags: [String]
    
    init(sessionToken: String, uniqueId: String, trackingId: String, lastClickCampaignId: String, amount: CGFloat, numberOfItems: Int, reference: String, payment: String, promoCode: String, paymentStatus: String, paymentDate: String, isNewClient: Bool, pseudoId: String, tenant: String, tags: [String]) {
        self.sessionToken = sessionToken
        self.uniqueId = uniqueId
        self.trackingId = trackingId
        self.lastClickCampaignId = lastClickCampaignId
        self.amount = amount
        self.numberOfItems = numberOfItems
        self.reference = reference
        self.payment = payment
        self.promoCode = promoCode
        self.paymentStatus = paymentStatus
        self.paymentDate = paymentDate
        self.isNewClient = isNewClient
        self.pseudoId = pseudoId
        self.tenant = tenant
        self.tags = tags
    }
}

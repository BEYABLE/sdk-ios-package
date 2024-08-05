//
//  BeyableResponseAcknowledgedisplay.swift
//  
//
//  Created by Ouamassi Brahim on 29/01/2024.
//

import Foundation

///  The body of the response  for the request 'acknowledgeslideclosed' request.
struct RootDisplayProcess: Codable {
    let displayProcess : DisplayProcess
}
///  The body of the response  for the request 'acknowledgeslideclosed' request.
struct DisplayProcess: Codable {
    var campaignHistory: [CampaignHistory]
    let campaignsDisplayedInSession: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.campaignHistory = try container.decode([CampaignHistory].self, forKey: .campaignHistory)
        } catch {
            LogHelper.instance.showLog(logToShow: "Error decoding campaignHistory: \(error)")
            throw error
        }
        self.campaignsDisplayedInSession = try container.decode([String].self, forKey: .campaignsDisplayedInSession)
    }
    
    init(listCampaing : [CampaignHistory]) {
        self.campaignHistory = listCampaing
        self.campaignsDisplayedInSession = [""]
    }
    
    public mutating func setClosed (closed : Bool){
        var listCampagn = [CampaignHistory]()
        for var campagne in campaignHistory {
            campagne.isClosed = true
            listCampagn.append(campagne)
        }
        self.campaignHistory = listCampagn
    }
}

struct CampaignHistory: Codable {
    let campaignId: String
    var isClosed: Bool
    let slideId: String
    let answerId: Int?
    let slideAnswered: Int?
    let numberOfSlideDisplays: Int
    let dateOfLastProcess: String?
    let variation: String
    let mustBeDisplayed: Bool
    
    enum CodingKeys: String, CodingKey {
        case campaignId, isClosed, slideId, answerId, slideAnswered, numberOfSlideDisplays, dateOfLastProcess, variation, mustBeDisplayed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        campaignId = try container.decode(String.self, forKey: .campaignId)
        isClosed = try container.decode(Bool.self, forKey: .isClosed)
        slideId = try container.decode(String.self, forKey: .slideId)
        answerId = try container.decodeIfPresent(Int.self, forKey: .answerId)
        slideAnswered = try container.decodeIfPresent(Int.self, forKey: .slideAnswered)
        numberOfSlideDisplays = try container.decode(Int.self, forKey: .numberOfSlideDisplays)
        dateOfLastProcess = try container.decode(String.self, forKey: .dateOfLastProcess)
        variation = try container.decode(String.self, forKey: .variation)
        mustBeDisplayed = try container.decode(Bool.self, forKey: .mustBeDisplayed)
    }
}


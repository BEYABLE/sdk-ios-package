//
//  BYObservable.swift
//  
//
//  Created by MarKinho on 31/07/2024.
//

import Foundation


class BYObservable: ObservableObject, JavascriptCallback {
    
    static let shared = BYObservable()
    
    @Published var inCollectionCampaigns: [String: InCollectionView] = [:]
    @Published var inPageCampaigns: [String: InPageView] = [:]
    
    
    func getCampaign(_ forId: String) -> InCollectionView? {
        if let c = inCollectionCampaigns[forId] {
            return c;
        } else {
            LogHelper.instance.showLog(logToShow: "No campaing for \(forId)")
        }
        return nil;
    }

    // Fonction pour mettre à jour les campagnes InCollection
    func updateCollectionCampaigns(_ campaigns: [CampaignDTO]) {
        // Make In collection views for all elements
        for campaign in campaigns {
            let elementId = campaign.inCollectionPlacementId
            for target in campaign.inCollectionTargets {
                DispatchQueue.main.async {
                    LogHelper.instance.showLog(logToShow: "Adding InCollectionCampaign for \(elementId+"_"+target)")
                    self.inCollectionCampaigns[elementId+"_"+target] = InCollectionView(campaignDto: campaign, viewParent: nil, callBackJavascript: self)
                }
            }
        }
    }
    
    // Fonction pour mettre à jour les campagnes InPage
    func updateInPageCampaigns(_ campaingsViews: [InPageView]) {
        for campaingView in campaingsViews {
            let elementSelector = campaingView.campaignDto.elementSelector!
            DispatchQueue.main.async {
                self.inPageCampaigns[elementSelector] = campaingView
            }
        }
    }
    
    
        
    func onClose(currentCampaign: CampaignDTO) { }
    
    func onAction() { }
}

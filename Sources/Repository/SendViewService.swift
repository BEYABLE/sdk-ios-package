//
//  SendViewService.swift
//
//
//  Created by Ouamassi Brahim on 27/01/2024.
//

import Foundation
import Combine
#if canImport(UIKit)
    import UIKit
#endif
import WebKit
import SwiftUI

///  It is called by BeyableClient. This class invokes the generic functions of BeyableService, handles the responses, and performs some factory operations to display them on the screen.
@available(iOS 13.0, *)
class SendViewService : NSObject, WKNavigationDelegate{
    
    public static let instance = SendViewService()
    
    ///Used for the Combine framework to get notification when calls api ends
    private var subscriptions = Set<AnyCancellable>()
    
    /// Contains user informations ``BYVisitorInfos``
    public var userInfos : BYVisitorInfos?
    public var tenant: String = ""
    
    
    
    /// Called by ``BeyableClient`` and getting responses api from ``BeyableService``
    /// - Parameters:
    ///   - attributes: See ``BYCartAttributes``, ``BYGenericAttributes``, ``BYCategoryAttributes``, ``BYProductAttributes``, ``BYTransactionAttributes``, ``BYHomeAttributes``
    ///   - page: CurrentPage Of the application client
    ///   - cartInfos: ``BYCartInfos``
    ///   - success
    ///   - failure
    public func sendPageview(attributes : BYAttributes?, page : EPageUrlTypeBeyable, cartInfos : BYCartInfos? = nil,
                             success: @escaping (([CampaignDTO]) -> Void),  failure: @escaping ((BeyableDataAPIError) -> Void)){
        var cartAttributes          : BYCartAttributes?
        var category                : BYCategoryAttributes?
        var genericPage             : BYGenericAttributes?
        var homeAttributes          : BYHomeAttributes?
        var transactionAttribues    : BYTransactionAttributes?
        var productAttribues        : BYProductAttributes?
        
        if(attributes is BYCartAttributes){
            cartAttributes = attributes as? BYCartAttributes
        }
        else if(attributes is BYCategoryAttributes){
            category = attributes as? BYCategoryAttributes
        }
        else if(attributes is BYGenericAttributes){
            genericPage = attributes as? BYGenericAttributes
        }
        else if(attributes is BYHomeAttributes){
            homeAttributes = attributes as? BYHomeAttributes
        }
        else if(attributes is BYTransactionAttributes){
            transactionAttribues = attributes as? BYTransactionAttributes
        }
        else if(attributes is BYProductAttributes){
            productAttribues = attributes as? BYProductAttributes
        }
        
        let pageData = BYPageRequest(
            urlType: page.rawValue,
            pageReferrer: "",
            url: "",
            homePageInfo: homeAttributes,
            genericPageInfo: genericPage,
            transactionPageInfo: transactionAttribues,
            productPage: productAttribues,
            categoryPageInfo: category,
            cartPageInfo: cartAttributes)
        
        let uniqueId           = DataStorageHelper.getData(type: String.self, forKey: .uniqueId)            ?? ""
        let trackingId         = DataStorageHelper.getData(type: String.self, forKey: .trackingId)          ?? ""
        let sessionId          = DataStorageHelper.getData(type: String.self, forKey: .sessionId)           ?? ""
        let sessionToken       = DataStorageHelper.getData(type: String.self, forKey: .sessionToken)        ?? ""
        let crossSessionToken  = DataStorageHelper.getData(type: String.self, forKey: .crossSessionToken)   ?? ""
        
        let instanceBYRequestPageView = BYRequestPageView(
            page: pageData,
            device: BYDeviceInfos(integratorAppVersion: nil),
            visitor: userInfos,
            cartInfos: cartInfos,
            uniqueId: uniqueId,
            trackingId: trackingId,
            sessionId: sessionId,
            sessionToken: sessionToken,
            crossSessionToken: crossSessionToken,
            tenant: self.tenant)
        
        BeyableService.shared.sendRequest(from: EndpointUrl.display.rawValue, body: instanceBYRequestPageView)
            .sink { completion in
                if case let .failure(error) = completion {
                    LogHelper.instance.showLog(logToShow: error.localizedDescription)
                    failure(error)
                }
            }
            receiveValue: { completion in
                let response : BeyableResponseDisplay = completion
                DataStorageHelper.setData(value: response.crossSessionToken,    key: .crossSessionToken)
                DataStorageHelper.setData(value: response.sessionId,            key: .sessionId)
                DataStorageHelper.setData(value: response.sessionToken,         key: .sessionToken)
                DataStorageHelper.setData(value: response.trackingId,           key: .trackingId)
                DataStorageHelper.setData(value: response.uniqueId,             key: .uniqueId)
                guard let campaings = response.messages
                else{
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: "Campagins received from request \(EndpointUrl.display.rawValue) is empty")
                    return
                }
                LogHelper.instance.showLogForSDKDevelopper(logToShow: "Campaigns received \(campaings)")
                
                FactoryCampaignDto.instance.attributes = attributes
                
                let listCampagns = FactoryCampaignDto.instance.makeCompaingsDto(campagnsResponse: campaings)
                
                BeyableService.shared.handleCompletion(endpoint: EndpointUrl.display.rawValue)
                success(listCampagns)
            }
            .store(in: &self.subscriptions)
        }
    
    
    /// Send AcknowledgeDisplay reqeust to Beyable Api
    /// - Parameters:
    ///   - campaign: Just displayed
    ///   - success
    ///   - failure
    public func sendAcknowledgeDisplay(campaign : CampaignDTO, 
                                       success: @escaping (([CampaignHistory]) -> Void), failure: @escaping ((BeyableDataAPIError) -> Void)) {
        let body = AcknowledgedisplayRequest()
        body.tenant = tenant
        
        body.messageDisplays = AcknowledgedisplayRequest.getMessageDisplays(campaignDTO: [campaign])
        BeyableService.shared.sendRequest(from: EndpointUrl.acknowledgedisplay.rawValue, body: body)
            .sink { completion in
                if case let .failure(error) = completion {
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: error.localizedDescription)
                    failure(error)
                }
            }
            receiveValue: { completion in
                let response : RootDisplayProcess = completion
                let displayP = response.displayProcess
        
                DataStorageHelper.setObjectPref(data: displayP, type: DisplayProcess.self, forKey: .displayProcess)
                    success(displayP.campaignHistory)
                    BeyableService.shared.handleCompletion(endpoint: EndpointUrl.acknowledgedisplay.rawValue)
            }
            .store(in: &self.subscriptions)
    }
    
    
    /// Send AcknowledgeClosed request to Beyable Api
    public func sendAcknowledgeClosed(){
        let body = AcknowledgedisplayClosedRequest()
        body.tenant = tenant
        body.displayProcess?.setClosed(closed: true)
        body.setSlidesByCampaings()
        
        BeyableService.shared.sendRequest(from: EndpointUrl.acknowledgeslideclosed.rawValue, body: body)
            .sink {completion in
                if case let .failure(error) = completion {
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: error.localizedDescription)                    
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request acknowledgedisplayClosed just failed \(error.errorDescription ?? "")")
                }
            }
            receiveValue: { completion in
                let response : RootDisplayProcess = completion
                let displayP = response.displayProcess
                if(displayP.campaignHistory.count > 0){
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request acknowledgedisplayClosed suceed we just received a new displayProcess")
                }
                BeyableService.shared.handleCompletion(endpoint: EndpointUrl.acknowledgeslideclosed.rawValue)
            }
            .store(in: &self.subscriptions)
    }
    
    public func saveInteraction(campaignId: String, slideId: String, pageViewDate: String, pageUrl: String, interactions: [BYInteraction]) {
        let uniqueId           = DataStorageHelper.getData(type: String.self, forKey: .uniqueId)            ?? ""
        let trackingId         = DataStorageHelper.getData(type: String.self, forKey: .trackingId)          ?? ""
        let sessionToken       = DataStorageHelper.getData(type: String.self, forKey: .sessionToken)        ?? ""
        
        let body = SaveInteractionRequestModel(
            sessionToken: sessionToken,
            uniqueId: uniqueId,
            trackingId: trackingId,
            tenant: tenant,
            campaignId: campaignId,
            slideId: slideId,
            pageViewDate: pageViewDate,
            pageUrl: pageUrl,
            interactions: interactions)
        body.tenant = tenant
                
        BeyableService.shared.sendRequest(from: EndpointUrl.saveInteraction.rawValue, body: body)
            .sink {completion in
                if case let .failure(error) = completion {
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: error.localizedDescription)
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request saveInteraction just failed \(error.errorDescription ?? "")")
                }
            }
            receiveValue: { completion in
                let _ : RootDisplayProcess = completion
                BeyableService.shared.handleCompletion(endpoint: EndpointUrl.saveInteraction.rawValue)
            }
            .store(in: &self.subscriptions)
    }
    
    
    public func saveObjective(amount: CGFloat, numberOfItems: Int, reference: String, payment: String, promoCode: String, paymentStatus: String,
                              paymentDate: String, isNewClient: Bool, pseudoId: String, tags: [String]){
        let uniqueId           = DataStorageHelper.getData(type: String.self, forKey: .uniqueId)            ?? ""
        let trackingId         = DataStorageHelper.getData(type: String.self, forKey: .trackingId)          ?? ""
        let sessionToken       = DataStorageHelper.getData(type: String.self, forKey: .sessionToken)        ?? ""
        
        let body = SaveObjectiveRequestModel(
            sessionToken: sessionToken,
            uniqueId: uniqueId,
            trackingId: trackingId,
            lastClickCampaignId: "",
            amount: amount,
            numberOfItems: numberOfItems,
            reference: reference,
            payment: payment,
            promoCode: promoCode,
            paymentStatus: paymentStatus,
            paymentDate: paymentDate,
            isNewClient: isNewClient,
            pseudoId: pseudoId,
            tenant: self.tenant,
            tags: tags)
        
        BeyableService.shared.sendRequest(from: EndpointUrl.saveObjective.rawValue, body: body)
            .sink {completion in
                if case let .failure(error) = completion {
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: error.localizedDescription)
                    LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request saveObjective just failed \(error.errorDescription ?? "")")
                }
            }
            receiveValue: { completion in
                let _ : RootDisplayProcess = completion
                BeyableService.shared.handleCompletion(endpoint: EndpointUrl.saveInteraction.rawValue)
            }
            .store(in: &self.subscriptions)
    }
}

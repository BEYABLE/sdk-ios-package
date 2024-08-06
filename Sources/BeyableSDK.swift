//
//  BeyableSDK.swift
//
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
import Combine
#if canImport(UIKit)
    import UIKit
#endif
import WebKit
import SwiftUI
protocol CallBackService {
    /// If the campaign is received and showed we call this function to send aknowledge request
    /// - Parameter campaignDto: Campaign just been displayed
    func sendAkn(campaignDto : CampaignDTO)
}
///  This class contains exposed methods which are called by the application clients.
@available(iOS 13.0, *)
public class BeyableSDK : NSObject, WKNavigationDelegate, CallBackService{
    
    
    static private(set) var instance: BeyableSDK! = nil
    
    private var subscriptions = Set<AnyCancellable>()
    /// Handles displaying views campaing
    let byHandleViews = BYHandleViews()
    
    /**
     This function initializes the Beyable SDK.
     - parameter tokenClient: The client token used for authentication.
     - parameter loggingEnabledUser: Optional. By default, it's false. Set it to true if you want to enable logging for the SDK.
     - parameter environment: By default it's production
     */
    
    public convenience init(tokenClient: String, environment: EnvironmentBeyable? = EnvironmentBeyable.production, loggingEnabledUser: Bool? = true) {
        self.init(tokenClient: tokenClient, tenant: "", environment: environment, loggingEnabledUser: loggingEnabledUser)
    }
    
    /**
     This function initializes the Beyable SDK.
     - parameter tokenClient: The client token used for authentication.
     - parameter tenant: The tenant to be send on each request
     - parameter loggingEnabledUser: Optional. By default, it's false. Set it to true if you want to enable logging for the SDK.
     - parameter environment: By default it's production
     */
    public init(tokenClient: String, tenant: String, environment: EnvironmentBeyable? = EnvironmentBeyable.production, loggingEnabledUser: Bool? = true) {
        LogHelper.instance.showLog = loggingEnabledUser
        // Set the keys on Storage
        DataStorageHelper.setData(value: tokenClient, key: .apiKey)
        // Set the base url
        BeyableService.shared.setBaseUrlApi(baseUrl: environment?.rawValue ?? EnvironmentBeyable.production.rawValue)
        // Set tenant
        SendViewService.instance.tenant = tenant
        // Warm up some Webviews on init
        WKWebViewWarmUper.shared.prepare()
    }
    
    /// Inform the Beyable API that a page was viewed.
    /// - Parameters:
    ///   - page: the BYPage with the information needed
    ///   - currentView: The current View
    ///   - attributes: The optional page-related information such as ``BYHomeAttributes``, ``BYTransactionAttributes``, ``BYCartInfos``, ``BYProductInfos``, ``BYCategory``, ``BYGenericAttributes``
    public func sendPageview(page : EPageUrlTypeBeyable, currentView : UIView?, attributes : BYAttributes?, cartInfos : BYCartInfos? = nil, callback: OnSendPageView?) {
        SendViewService.instance.sendPageview(attributes: attributes, page : page, cartInfos : cartInfos,  success: { (campaignsDTO) in
            self.byHandleViews.currentView = currentView
            self.byHandleViews.setCampagns(listCampagns: campaignsDTO, callBackService: self)
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.global().async {
                    // Background work done
                    DispatchQueue.main.async {
                        // Call the completion handler on the main thread
                        callback!.onBYSuccess()
                    }
                }
            }
        }) { (error) in
            LogHelper.instance.showLog(logToShow: "Request sendPageview just failed \(error.errorDescription ?? "")")
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.global().async {
                    // Background work done
                    DispatchQueue.main.async {
                        // Call the completion handler on the main thread
                        callback!.onBYError()
                    }
                }
            }
        }
    }
    
    
    /// This function is called after showing the campaign to tell the API Beyable that the campaing was showed
    /// - Parameters:
    ///   - attributes: The campaign  ``CampaignDTO`` that has been shown.
    private func sendAcknowledge(campaignDTO : CampaignDTO){
        SendViewService.instance.sendAcknowledgeDisplay(campaign: campaignDTO, success: { campagneHistory in
            if(campagneHistory.count > 0) {
                LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request acknowledgedisplay suceed we just received displayProcess")
            }
            
        }) { (error) in
            LogHelper.instance.showLogForSDKDevelopper(logToShow: "Request acknowledgedisplay just failed \(error.errorDescription ?? "")")
        }
    }
    
    
    /// Set the user infos to be send at each request
    /// - Parameter visitorInfos:the infos of the user ``BYVisitorInfos``
    public func setVisitorInfos(visitorInfos : BYVisitorInfos? = nil){
        if let u = visitorInfos{
            SendViewService.instance.userInfos = u
        }
        else{
            SendViewService.instance.userInfos = BYVisitorInfos(isConnectedToAccount: false, isClient: false, pseudoId: "", favoriteCategory: "")
        }
    }
    
    public func setTenant(tenant: String) {
        SendViewService.instance.tenant = tenant
    }
    
    
    /// Inform the Beyable API that a page was viewed.
    /// - Parameters:
    ///   - page: the BYPage with the information needed
    ///   - currentView: The current View SwiftUI
    ///   - attributes: The optional page-related information such as ``BYHomeAttributes``, ``BYTransactionAttributes``, ``BYCartInfos``, ``BYProductInfos``, ``BYCategory``, ``BYGenericAttributes``
    public func sendPageview(page : EPageUrlTypeBeyable, currentView : (some View)?, attributes : BYAttributes?, cartInfos : BYCartInfos? = nil, callback: OnSendPageView?) {
        
        /*let vc = UIHostingController(rootView: currentView)
         
         self.sendPageview(
         page : page, currentView : vc.view, attributes : attributes, cartInfos : cartInfos)*/
        
        byHandleViews.swiftUiCurrentView = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let currentWindow = windowScene.windows.first {
            let currentViewController = currentWindow.rootViewController
            
            self.sendPageview(
                page : page, currentView : currentViewController?.view, attributes : attributes, cartInfos : cartInfos, callback: callback)
            
        }
        
    }
    
    func sendAkn(campaignDto : CampaignDTO){
        sendAcknowledge(campaignDTO: campaignDto)
    }
    
    
    // MARK: - UITableView cells binding for InCollection campaigns
    
    public func sendCellBinded(cell: UITableViewCell, elemementId: String, callback: OnCtaDelegate?) {
        self.byHandleViews.cellBinded(cell: cell, elementId: elemementId, callback: callback);
    }
    
    public func sendCellUnbinded(cell: UITableViewCell, elemementId: String) {
        self.byHandleViews.cellUnbinded(cell: cell, elementId: elemementId);
    }
    
    ///
    /// Cette méthode enregistre un objectif de transaction en envoyant les détails relatifs à la transaction à un service.
    ///
    /// Paramètres:
    ///     amount (CGFloat): Le montant de la transaction.
    ///     numberOfItems (Int): Le nombre d'articles achetés.
    ///     reference (String): La référence de la transaction.
    ///     payment (String): Le mode de paiement utilisé.
    ///     promoCode (String): Le code promotionnel appliqué, s'il y en a un.
    ///     paymentStatus (String): Le statut du paiement (ex. : "Completed", "Pending").
    ///     paymentDate (String): La date du paiement au format String.
    ///     isNewClient (Bool): Indique si le client est nouveau (true) ou non (false).
    ///     pseudoId (String): Un identifiant pseudonyme pour le client.
    ///     tags ([String]): Une liste de balises associées à la transaction.
    ///
    public func saveObjectif(amount: CGFloat, numberOfItems: Int, reference: String, payment: String, promoCode: String, paymentStatus: String,
                             paymentDate: String, isNewClient: Bool, pseudoId: String, tags: [String]) {
        SendViewService.instance.saveObjective(amount: amount, numberOfItems: numberOfItems, reference: reference, payment: payment, promoCode: promoCode, paymentStatus: paymentStatus, paymentDate: paymentDate, isNewClient: isNewClient, pseudoId: pseudoId, tags: tags)
    }
    
    /// Cette méthode enregistre une interaction utilisateur sur une page spécifique en envoyant les détails de l'interaction à un service.
    ///
    /// Paramètres:
    ///     pageViewDate (String): La date de la vue de la page au format String.
    ///     pageUrl (String): L'URL de la page où l'interaction a eu lieu.
    ///     interactions ([BYInteraction]): Une liste d'interactions utilisateur. BYInteraction est un type représentant une interaction spécifique.

    public func saveInteraction(pageViewDate: String, pageUrl: String, interactions: [BYInteraction]) {
        SendViewService.instance.saveInteraction(campaignId: "", slideId: "", pageViewDate: pageViewDate, pageUrl: pageUrl, interactions: interactions)
    }
}

// MARK: - Protocols for callbacks

public protocol OnSendPageView {
    func onBYSuccess()
    func onBYError()
}

public protocol OnCtaDelegate {
    func onBYClick(cellId: String, value: String)
}

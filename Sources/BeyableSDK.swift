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

    private var subscriptions = Set<AnyCancellable>()
    
    /// Handles displaying views campaing
    private let displayers  = NSMapTable<NSString, BYHandleViews>(keyOptions: .strongMemory, valueOptions: .strongMemory)

    /**
     This function initializes the Beyable SDK.
     - parameter tokenClient: The client token used for authentication.
     - parameter loggingEnabledUser: Optional. By default, it's false. Set it to true if you want to enable logging for the SDK.
     - parameter environment: By default it's production
     */
    
    public convenience init(tokenClient: String, environment: EnvironmentBeyable? = EnvironmentBeyable.production, loggingEnabledUser: Bool? = true) {
        self.init(tokenClient: tokenClient, tenant: "", baseUrl: environment?.rawValue ?? EnvironmentBeyable.preprod.rawValue, loggingEnabledUser: loggingEnabledUser)
    }
    
    public convenience init(tokenClient: String, baseUrl: String, loggingEnabledUser: Bool? = true) {
        self.init(tokenClient: tokenClient, tenant: "", baseUrl: baseUrl, loggingEnabledUser: loggingEnabledUser)
    }
    
    public convenience init(tokenClient: String, loggingEnabledUser: Bool? = true) {
        self.init(tokenClient: tokenClient, tenant: "", baseUrl: EnvironmentBeyable.preprod.rawValue, loggingEnabledUser: loggingEnabledUser)
    }
    
    public convenience init(tokenClient: String, baseUrl: String) {
        self.init(tokenClient: tokenClient, tenant: "", baseUrl: baseUrl, loggingEnabledUser: false)
    }
    
    public convenience init(tokenClient: String) {
        self.init(tokenClient: tokenClient, tenant: "", baseUrl: EnvironmentBeyable.preprod.rawValue, loggingEnabledUser: false)
    }
    
    
    /**
     This function initializes the Beyable SDK.
     - parameter tokenClient: The client token used for authentication.
     - parameter tenant: The tenant to be send on each request
     - parameter loggingEnabledUser: Optional. By default, it's false. Set it to true if you want to enable logging for the SDK.
     - parameter environment: By default it's production
     */
    public init(tokenClient: String, tenant: String, baseUrl: String, loggingEnabledUser: Bool? = true) {
        LogHelper.instance.showLog = loggingEnabledUser
        // Set the keys on Storage
        DataStorageHelper.setData(value: tokenClient, key: .apiKey)
        // Set the base url
        BeyableService.shared.setBaseUrlApi(baseUrl: baseUrl)
        // Set tenant
        SendViewService.instance.tenant = tenant
        // Warm up some Webviews on init
        WKWebViewWarmUper.shared.prepare()
    }
    
    
    /** 
     Set the base url for BeYable servers
     - parameter baseUrl : url Beyable
     */
    public func setBaseUrl(_ baseUrl: String) {
        BeyableService.shared.setBaseUrlApi(baseUrl: baseUrl)
    }
    
    /**
     Set the tenant to be send on each requests
     - parameter tenant: A arbitrary string that identify the tenant
     */
    public func setTenant(tenant: String) {
        SendViewService.instance.tenant = tenant
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
    
        
    /// Inform the Beyable API that a page was viewed.
    /// - Parameters:
    ///   - page: the BYPage with the information needed
    ///   - currentView: The current View
    ///   - attributes: The optional page-related information such as ``BYHomeAttributes``, ``BYTransactionAttributes``, ``BYCartInfos``, ``BYProductInfos``, ``BYCategory``, ``BYGenericAttributes``
    public func sendPageview(url: String, page : EPageUrlTypeBeyable, currentView : UIView, attributes : BYAttributes?, cartInfos : BYCartInfos? = nil,
                             callback: OnSendPageView?) {
        SendViewService.instance.sendPageview(url: url, page: page, attributes: attributes, cartInfos : cartInfos,  success: { (campaignsDTO) in
            let displayer = self.getOrCreateDisplayer(for: url, and: currentView)
            displayer.setCampagns(listCampagns: campaignsDTO, callBackService: self)
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.main.async {
                    // Call the completion handler on the main thread
                    callback!.onBYSuccess()
                }
            }
        }) { (error) in
            LogHelper.instance.showLog(logToShow: "Request sendPageview just failed \(error.errorDescription ?? "")")
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.main.async {
                    // Call the completion handler on the main thread
                    callback!.onBYError()
                }
            }
        }
    }
    
    
    /// Inform the Beyable API that a page was viewed.
    ///
    /// - Parameters:
    ///   - page: the BYPage with the information needed
    ///   - currentView: The current View SwiftUI
    ///   - attributes: The optional page-related information such as ``BYHomeAttributes``, ``BYTransactionAttributes``, ``BYCartInfos``, ``BYProductInfos``, ``BYCategory``, ``BYGenericAttributes``
    public func sendPageview(url: String, page: EPageUrlTypeBeyable, currentView: any View,
                             attributes : BYAttributes?, cartInfos: BYCartInfos? = nil,
                             callback: OnSendPageView?) {
        SendViewService.instance.sendPageview(url: url, page: page, attributes: attributes, cartInfos : cartInfos,  success: { (campaignsDTO) in
            let displayer = self.getOrCreateDisplayer(for: url, and: nil)
            displayer.setCampagns(listCampagns: campaignsDTO, callBackService: self)
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.main.async {
                    callback!.onBYSuccess()
                }
            }
        }) { (error) in
            LogHelper.instance.showLog(logToShow: "Request sendPageview just failed \(error.errorDescription ?? "")")
            if callback != nil {
                // When background work is done, call the completion handler on the main thread
                DispatchQueue.main.async {
                    callback!.onBYError()
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
    
    
    func sendAkn(campaignDto : CampaignDTO){
        sendAcknowledge(campaignDTO: campaignDto)
    }
    
    
    // MARK: - UITableView cells binding for InCollection campaigns
    
    public func sendCellBinded(url: String, cell: UITableViewCell, elementId: String, callback: OnCtaDelegate?) {
        LogHelper.instance.showLog(logToShow: "Binding cell on page '\(url)' for element '\(elementId)'")
        let displayer = self.getOrCreateDisplayer(for: url, and: nil)
        displayer.cellBinded(cell: cell, elementId: elementId, callback: callback)
    }
    
    public func sendCellUnbinded(url: String, cell: UITableViewCell, elementId: String) {
        LogHelper.instance.showLog(logToShow: "Uninding cell on page '\(url)' for element '\(elementId)'")
        let displayer = self.getOrCreateDisplayer(for: url, and: nil)
        displayer.cellUnbinded(cell: cell, elementId: elementId)
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
    
    /// Retrieve the current UIView form the curent UIViewController
    private func getCurrentView() -> UIView? {
//        DispatchQueue.main.async {
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let currentWindow = windowScene.windows.first {
//                if let currentViewController = currentWindow.rootViewController {
//                    return currentViewController.view
//                }
//            }
//        }
        return nil
    }
    
    private func getOrCreateDisplayer(for key:String, and view: UIView?) -> BYHandleViews {
        let nsKey = key as NSString
        // Vérifier si l'objet existe déjà dans le NSMapTable
        if let displayer = displayers.object(forKey: nsKey) {
            LogHelper.instance.showLog(logToShow: "Getting displayer for '\(key)'")
            displayer.currentView = view
            return displayer
        } else {
            LogHelper.instance.showLog(logToShow: "Creating displayer for '\(key)'")
            // Si l'objet n'existe pas, en créer un nouveau
            let newDisplayer = BYHandleViews(currentView: view)
            // Ajouter le nouvel objet à la NSMapTable
            displayers.setObject(newDisplayer, forKey: nsKey)
            return newDisplayer
        }
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

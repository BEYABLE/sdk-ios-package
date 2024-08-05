//
//  PopinView.swift
//  
//
//  Created by Ouamassi Brahim on 09/02/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit
/// Handle Overlay View 
@available(iOS 13.0, *)
class OverlayView : CampaignView {
    /// Current Webview Containing the Overlay Campaing
    var webView : WKWebView!
    ///
    /// Initialize a new Header View
    ///- Parameter campaignDto : Current Campaign toe show
    ///- Parameter viewParent : Current View Parent
    ///- Parameter callBackJavascript : Variable used when there will be interactions in JavaScript.
    override init(campaignDto: CampaignDTO?, viewParent: UIView?, callBackJavascript : JavascriptCallback) {
        super.init(campaignDto: campaignDto, viewParent: viewParent, callBackJavascript : callBackJavascript)
        self.webView = self.initWebView(campaignCallBack: nil)
        self.addPopin()
    }
    
    /// Add Popin to the viewController view
    public func addPopin(){
        if(webView == nil){
            return
        }
        // If viewController passed is nil we take the root viewController to show popin
        if self.viewParent == nil, let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let currentWindow = windowScene.windows.first {
            let currentViewController = currentWindow.rootViewController
            if(currentViewController == nil)
            {
                return
            }
        }
        // add the popinView to the ViewController view
        if let webView = webView {
            viewParent.addSubview(webView)
            self.webView?.frame.size = CGSize(width: self.viewParent.frame.width, height: self.viewParent.frame.height)
        }
        
    }
    /// Rmove WebView from parents View
    public func dismissWebView(){
        webView?.removeFromSuperview()
        webView = nil
    }
}

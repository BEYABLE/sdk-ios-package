//
//  HeaderView.swift
//
//
//  Created by Ouamassi Brahim on 08/02/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit

/// The class responsible for displaying the header bar campaign.
@available(iOS 13.0, *)
class HeaderView : CampaignView, CampaignViewProtocol{
    /// Current Webview Containing the header Campaing
    var webView : WKWebView!
    /// True if we are on a view SwiftUi
    var swiftUiCurrentView = false
    
    var heightStatusBar : CGFloat = 0
    
    var currentViewController : UIViewController!
    /**
     Initialize a new Header View
     - Parameter campaignDto : Current Campaign toe show
     - Parameter viewParent : Current View Parent
     - Parameter callBackJavascript : Variable used when there will be interactions in JavaScript.
     */
    override init(campaignDto: CampaignDTO?, viewParent: UIView?, callBackJavascript : JavascriptCallback) {
        super.init(campaignDto: campaignDto, viewParent: viewParent, callBackJavascript : callBackJavascript)
        self.webView = self.initWebView(campaignCallBack: self)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let currentWindow = windowScene.windows.first {
            let currentViewController = currentWindow.rootViewController
            self.currentViewController = currentViewController
            heightStatusBar = currentWindow.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
            self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    /// Show header at the top of View
    /// - Parameter height: We need this to shift view
    func showStickyHeaderView(){
        if(currentViewController == nil || viewParent == nil){
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.webView.evaluateJavaScript("document.getElementsByClassName('by_position_header')[0].offsetHeight") { [weak self] result, error in
                guard let self = self else { return }
                if let height = result as? CGFloat {
                    // Convertir la taille en points
                    let scale = UIScreen.main.scale
                    let heightInPoints: CGFloat
                    if(scale == 3) {
                        heightInPoints = height * 0.87
                    }
                    else if(scale == 2) {
                        heightInPoints = height * 0.85
                    }
                    else {
                        heightInPoints = height
                    }
                    self.shiftView(heightBanner: heightInPoints, valueShift: heightInPoints)
                } else if let error = error {
                    NSLog("Error evaluating JavaScript: \(error)")
                }
            }
        }
    }
    
    /// This function is intended for the sticky header. We move the view downwards and place the header at the top of the view.
    /// - Parameter height:The height of the offset of the main view to make place for the sticky header.
    func shiftView(heightBanner : CGFloat, valueShift : CGFloat){
        LogHelper.instance.showLogForSDKDevelopper(logToShow: "heightBanner = \(heightBanner), valueShift : \(valueShift)")
        
        if(!swiftUiCurrentView){
            if(webView != nil){
                viewParent.addSubview(webView!)
                
                webView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: viewParent.safeAreaLayoutGuide.topAnchor),
                    webView!.leadingAnchor.constraint(equalTo: viewParent.leadingAnchor),
                    webView!.trailingAnchor.constraint(equalTo: viewParent.trailingAnchor),
                    webView!.heightAnchor.constraint(equalToConstant: heightBanner) //
                ])
            }
            viewParent.subviews.first!.translatesAutoresizingMaskIntoConstraints = false
            //shift view parent
            viewParent.subviews.first!.transform  = CGAffineTransform(translationX: viewParent.subviews.first!.transform.tx, y: heightBanner)
            
        }
        // Case swift Ui
        else{
            AddSafeArea(heightBanner: heightBanner, valueShift: valueShift)
        }
        
    }
    
    /// For application Swiftui we add safe Area
    /// - Parameters:
    ///   - heightBanner:
    ///   - valueShift: shift the view with the value valueShift
    func AddSafeArea (heightBanner : CGFloat, valueShift : CGFloat){
        if(heightBanner == 0){
            deleteSafeArea()
        }
        
        
        LogHelper.instance.showLogForSDKDevelopper(logToShow: "\(heightBanner)")
        var newSafeArea = UIEdgeInsets()
        
        newSafeArea.top += valueShift
        
        currentViewController?.children[0].additionalSafeAreaInsets = newSafeArea
        if(webView != nil){
            viewParent.subviews.first!.translatesAutoresizingMaskIntoConstraints = false
            let popupSize = CGSize(width: currentViewController!.view.frame.width, height: heightBanner)
            self.webView?.frame.size = popupSize
            currentViewController?.view.addSubview(self.webView)
        }
    }
    /// When we close Header Bar we delete safe area
    func deleteSafeArea (){
        var newSafeArea = UIEdgeInsets()
        newSafeArea.top = 0.0
        currentViewController?.children[0].additionalSafeAreaInsets = newSafeArea
        
    }
    
    func showInPageView() {
        
    }
    
    /// Rmove WebView from parents View
    public func dismissWebView(){
        webView?.removeFromSuperview()
        webView = nil
    }
}

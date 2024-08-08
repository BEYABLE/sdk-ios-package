//
//  CampaignView.swift
//
//
//  Created by Ouamassi Brahim on 12/02/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit
/// Callback interface for event from the Javascript code
protocol JavascriptCallback {
    func onClose(currentCampaign : CampaignDTO)
    func onAction ()
}
/// used to send information from ``CampaignView`` to others views like ``HeadrView`` ``InPageView`` ...
protocol CampaignViewProtocol {
    func showStickyHeaderView()
    func showInPageView()
}

///  This class manages the web view that will be displayed for Popin, InPage, and header campaigns. It also handles the calls made from JavaScript to the native code.
class CampaignView : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
    /// Current Compaing
    let campaignDto : CampaignDTO!
    /// The Current view
    let viewParent : UIView!
    
    /// ``JavascriptCallback``
    let callBackJavascript : JavascriptCallback?
    
    /// ``CampaignViewProtocol``
    var campaignViewProtocol : CampaignViewProtocol?
    
    lazy var warmUper: WKWebViewWarmUper = {
        return WKWebViewWarmUper { [weak self] in
            let configuration = WKWebViewConfiguration()
            configuration.preferences.javaScriptEnabled = true
            let contentController = WKUserContentController()
            contentController.add(self!, name: "callbackHandler")
            configuration.userContentController = contentController
            return WKWebView(frame: UIView().bounds, configuration: configuration)
        }
    }()

    /**
     Initialize a new Header View
     - Parameter webView: The current WebView
     - Parameter campaignDto : Current Campaign toe show
     - Parameter viewParent : Current View Parent
     */
    init(campaignDto: CampaignDTO?, viewParent: UIView?, callBackJavascript : JavascriptCallback) {
        self.campaignDto = campaignDto
        self.viewParent = viewParent
        self.callBackJavascript = callBackJavascript
    }
    
    
    /// IInitialize the webview that will be used for different types of campaign displays.
    /// - Parameter campaignCallBack: used to send information from ``CampaignView`` to others views like ``HeadrView`` ``InPageView`` ...
    /// - Returns: The instance of webView just created and configurated
    func initWebView(campaignCallBack : CampaignViewProtocol?) -> WKWebView {
        self.campaignViewProtocol = campaignCallBack
            
        // Some time after.
        // let webView = self.warmUper.dequeue()
        
       let contentController = WKUserContentController();
       contentController.add(
           self,
           name: "callbackHandler"
       )
       
       let config = WKWebViewConfiguration()
       config.userContentController = contentController
       
       
       // End Configuration
       
       let webView = WKWebView(frame: UIView().bounds, configuration: config)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false;
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = UIColor.clear
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        };
        webView.navigationDelegate = self
        
        // We need to have one DisplayDTO
        if campaignDto.displays.count > 0 {
            let display = campaignDto.displays[0]
            var htmlContent = display.content
            /// hmmmmmmm
            htmlContent += "\n<script>console.log(\"This is a message from JavaScript!\");\(display.associatedJavascript)</script>"
            webView.loadHTMLString(display.content, baseURL: nil)
        }
        
        return webView
    }
    
    /**
     This function is called after a JavaScript function has invoked the native code.
     - Parameters:
     - userContentController:
     - message: Message received from javascript
     */
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        LogHelper.instance.showLogForSDKDevelopper(logToShow: "\(message.body)")
        if(message.body as? String == MessageJavascript.CLOSE.rawValue){
            callBackJavascript?.onClose(currentCampaign: campaignDto)
            campaignViewProtocol?.showStickyHeaderView()
        }
        else {
            WebViewUtils.instance.handleRedirectionLink(message: message)
        }
    }
    
    /**
     Function called after webview load all it's contains
     Sometimes this function is called two times, so we have to detect if the campaign has already been shown so we don't show it two times.
     - Parameters:
     - webView: Current WebView
     - navigation:
     */
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var jsCode = ""
        if campaignDto.displays.count > 0 {
            jsCode = campaignDto.displays[0].associatedJavascript
            LogHelper.instance.showLog(logToShow: jsCode)
        }
        var byDataString = "{}";
        var byContextDataString = "{}";
        //byContextDataString = attributes.getContextData().toString();
        //    byDataString = attributes.toJSONObject().toString();
        
        let jsScript = "function() {\nvar node = document.createElement('style');\nnode.type = 'text/css';\nwindow.by_data = \(byDataString);\nwindow.by_context_data = \(byContextDataString);\ndocument.head.appendChild(node);\n\(jsCode)\n}";
        // Execute JavaScript code
        webView.evaluateJavaScript(jsCode, completionHandler: { (result, error) in
            if(self.campaignDto?.alreadyShowen == true){
                LogHelper.instance.showLogForSDKDevelopper(logToShow: "You try to show this campagn two times")
                return
            }
            if let error = error {
                LogHelper.instance.showLogForSDKDevelopper(logToShow: "Error injecting JavaScript: \(error)")
            } else {
                LogHelper.instance.showLogForSDKDevelopper(logToShow: "JavaScript injected successfully")
                if(self.campaignDto?.typeCampagne == .HEADER){
                    self.campaignViewProtocol?.showStickyHeaderView()
                }
                else if(self.campaignDto?.typeCampagne == .OVERLAY){
                    // Overlay Already Added
                    
                }
                else if(self.campaignDto?.typeCampagne == .IN_PAGE){
                    self.campaignViewProtocol?.showInPageView()
                }
            }
        })
    }
    
    
    func setZoomLevel(_ zoomLevel: CGFloat, for webView: WKWebView) {
        let zoomCSS = """
        <style>
        body {
            zoom: \(zoomLevel);
        }
        </style>
        """
        let js = "document.head.insertAdjacentHTML('beforeend', '\(zoomCSS)');"
    }
}

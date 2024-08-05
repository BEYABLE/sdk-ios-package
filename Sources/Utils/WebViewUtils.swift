//
//  JavaScriptCleaner.swift
//
//
//  Created by Ouamassi Brahim on 01/02/2024.
//

import Foundation
import WebKit

/// Some formating and cleaning javascript
class WebViewUtils {
    
    public static var instance = WebViewUtils()
    /// Combine javascript and css
    /// - Parameters:
    ///   - script: Javascript body
    ///   - css: css body
    /// - Returns: the javascript with css that will be included to the webview
    func makeJavascriptCorrection(script : String, css : String, attributes : BYAttributes?) -> String{
        var javascript = script
        javascript =  javascript.replacingOccurrences(of: "isDebug: !! localStorage.getItem('by_debug'),", with: "")
        javascript =  javascript.replacingOccurrences(of: "isDebug: !!localStorage.getItem('by_debug'),", with: "")
        javascript =  javascript.replacingOccurrences(of: "\"\"", with: "''")
        javascript =  javascript.replacingOccurrences(of: "\'", with: "'")
        javascript =  javascript.replacingOccurrences(of: "\"\"", with: "''")
        javascript =  javascript.replacingOccurrences(of: "\n", with: "")
        javascript =  javascript.replacingOccurrences(of: "\r", with: "")
        let callBackNativeAppClose = "var callNativeAppClose  = function(message) { try {webkit.messageHandlers.callbackHandler.postMessage('\(MessageJavascript.CLOSE.rawValue)'); } catch(err) { console.log('The native context does not exist yet');} ;};"
        
        let callBackNativeAppRedirectionUrl = "var callBackNativeAppRedirectionUrl  = function(link, action, sid) { try {webkit.messageHandlers.callbackHandler.postMessage({type : '\(MessageJavascript.REDIRECTION_LINK.rawValue)', \(MessageJavascript.REDIRECTION_LINK.rawValue) : link, action : action, sid : sid}); } catch(err) { console.log('The native context does not exist yet');} ;};"
        
        let byDataString = getStringfromAttributes(attributes: attributes)
        let byContextDataString = DataStorageHelper.getStringJsonFromObject(data : attributes?.contextData)
        let jsScriptByData =  " window.by_data = \(byDataString); window.by_context_data = \(byContextDataString);"
        
        var jsScript = jsScriptByData + callBackNativeAppClose + callBackNativeAppRedirectionUrl +
        " var injectCode = function() { " +
        " var node = document.createElement('style');  node.type = 'text/css'; node.innerHTML =\" \(css)\"" +
        "; document.head.appendChild(node);\n \(javascript)" + "}; injectCode()";
        
        
        ///Set the javascript string so it will include the callback function for native application
        jsScript =  jsScript.replacingOccurrences(of: "BY.by_CloseCampaign", with: "callNativeAppClose")
        jsScript =  jsScript.replacingOccurrences(of: "BY.by_SendViewForCTAWithRedirection", with: "callBackNativeAppRedirectionUrl")
        
        /**TODO call another function native like by_SendInteractionForCampaign  by_SendViewForCTA **/
      /*  jsScript =  jsScript.replacingOccurrences(of: "BY.by_SendInteractionForCampaign", with: "callBackNativeAppRedirectionUrl")
        jsScript =  jsScript.replacingOccurrences(of: "BY.by_SendViewForCTA", with: "callBackNativeAppRedirectionUrl")*/
        /**End TODO*/

        
        return jsScript
        
    }
    
    /// Correct css so it can be accepted by webview
    /// - Parameter cssToClean
    /// - Returns: css cleaned
    func cleanCss( cssToClean : String) -> String{
        var css = cssToClean
        css = css.replacingOccurrences(of: "\"", with: "\\\"")
        css = css.replacingOccurrences(of: "\'", with: "\\\'")
        css = css.replacingOccurrences(of: "\t", with: "")
        css = css.replacingOccurrences(of: "\r", with: "")
        css = css.replacingOccurrences(of: "\n", with: "")
        css =  css.replacingOccurrences(of: "\\\"\\\"", with: "\'\'")
        return css
    }

    /// After clicking for a button for exemple the native function will be called, and in Case we have a redirection link on the javascript this function will be called and redirect to the correct page
    /// - Parameter message: sended from javascript after clicking in a button for exemple
    public func handleRedirectionLink(message: WKScriptMessage){
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String else {
            return
        }
        if(type == MessageJavascript.REDIRECTION_LINK.rawValue){
            // Call the corresponding native function with parameters
            if let link = body[MessageJavascript.REDIRECTION_LINK.rawValue] as? String {
                if let url = URL(string: link) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else {
                        LogHelper.instance.showLog(logToShow:"The application can't handle this kind of URL \(url), please check your configuration")
                    }
                }
            }
        }
    }
    func getStringfromAttributes(attributes : BYAttributes?)->String{
        var byDataString = "{}"
        if(attributes is BYCartAttributes){
            let cartAttributes = attributes as? BYCartAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: cartAttributes)
        }
        else if(attributes is BYCategoryAttributes){
            let category = attributes as? BYCategoryAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: category)
        }
        else if(attributes is BYGenericAttributes){
           let genericPage = attributes as? BYGenericAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: genericPage)
        }
        else if(attributes is BYHomeAttributes){
            let homeAttributes = attributes as? BYHomeAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: homeAttributes)
        }
        else if(attributes is BYTransactionAttributes){
            var transactionAttribues = attributes as? BYTransactionAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: transactionAttribues)
        }
        else if(attributes is BYProductAttributes){
            var productAttribues = attributes as? BYProductAttributes
            byDataString = DataStorageHelper.getStringJsonFromObject(data: productAttribues)
        }
        return byDataString
        
    }
}

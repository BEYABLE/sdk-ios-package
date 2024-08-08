//
//  BYInPagePlaceHolder.swift
//  
//
//  Created by MarKinho on 01/08/2024.
//

import SwiftUI
import WebKit

public struct BYInPagePlaceHolder: View {
    let placeHolderId: String
    
    // Observable object
    @ObservedObject var beyableObservable = BYObservable.shared
    @State private var webViewHeight: CGFloat = 0.0;
    
    // Initialiseur public
    public init(placeHolderId: String) {
        self.placeHolderId = placeHolderId
        //self.callback = callback
    }
    
    public var body: some View {
        let campaignView = beyableObservable.inPageCampaigns[placeHolderId]
        if campaignView != nil {
            BYInPageViewRepresentable(campaignView: campaignView!, webViewHeight: $webViewHeight)
                .frame(height: webViewHeight)
                .onDisappear {
                    // Clear or reset the view when it disappears
                    LogHelper.instance.showLog(logToShow: "Removing campaing \(placeHolderId)")
                    beyableObservable.inPageCampaigns.removeValue(forKey: placeHolderId)
                }
        }
        else {
            EmptyView().frame(height: 0)
        }
    }
}

struct BYInPageViewRepresentable: UIViewRepresentable {
    let campaignView: InPageView
        @Binding var webViewHeight: CGFloat
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = campaignView.webView!
            webView.navigationDelegate = context.coordinator
            
            // Observer pour la taille du contenu
            webView.scrollView.addObserver(
                context.coordinator,
                forKeyPath: "contentSize",
                options: .new,
                context: nil
            )
            
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            // Si besoin, vous pouvez mettre à jour la webview ici
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var parent: BYInPageViewRepresentable
            
            init(_ parent: BYInPageViewRepresentable) {
                self.parent = parent
            }
            
            override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                if keyPath == "contentSize", let scrollView = object as? UIScrollView {
                    DispatchQueue.main.async {
                        self.parent.webViewHeight = scrollView.contentSize.height
                    }
                }
            }
            
            deinit {
                if let webView = parent.campaignView.webView {
                    webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
                }
            }
        }
}




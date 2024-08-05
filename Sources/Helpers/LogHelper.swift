//
//  LogHelper.swift
//
//
//  Created by Ouamassi Brahim on 27/01/2024.
//

import Foundation

/// Handle log for SDK developper And for the developper of the application who use this sdk
class LogHelper {
    
    public static let instance = LogHelper()
    
    /// if true log sdk will be showen for developper of the application
    public var showLog : Bool?
    /// if true log sdk will be showen for developper of the SDK
    private var showLogDev = false
    
    let LOG = "BEYABLE_SDK"
    
    let LOGDEV = "BEYABLE_DEV"
    
    
    public func showLog(logToShow : String){
        if(self.showLog ?? false){
            print("\(LOG)  :  \(logToShow)")
        }
    }
    
    /// This function show log only for sdk developper this logs will be disabled for production
    /// - Parameter logToShow
    public func showLogForSDKDevelopper(logToShow : String){
        if(showLogDev){
            print("\(LOGDEV)  :  \(logToShow)")
        }
        
    }
}

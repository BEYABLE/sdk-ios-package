//
//  Endpoint.swift
//  
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
///  Endpoints use for WS requests
enum EndpointUrl: String {
    case acknowledgeslideclosed     = "/api/v3-app/acknowledgeslideclosed"
    case acknowledgecalltoaction    = "/api/v3-app/acknowledgecalltoaction/"
    case acknowledgedisplay         = "/api/v3-app/acknowledgedisplay"
    case display                    = "/api/v3-app/display"
    case saveInteraction            = "/api/v3-app/saveinteraction"
    case saveObjective              = "/api/v3-app/saveobjective"
}


/// For now we can use preproduction or production environement
public enum EnvironmentBeyable : String{
    case preprod        = "https://front-app.preprod.activation.beyable.com"
    case production     = "https://front-app.activation.beyable.com"
    case production2    = "https://fd.front-app.activation.beyable.com"
}

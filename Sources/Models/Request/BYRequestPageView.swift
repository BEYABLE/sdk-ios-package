//
//  BeyableRequestPageView.swift
//
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

///  The body of the request that will be sent to the server for the 'acknowledgeslideclosed' request /api/v3/display
public struct BYRequestPageView: Codable {
    let page : BYPageRequest
    let device : BYDeviceInfos
    let visitor : BYVisitorInfos?
    let cartInfos : BYCartInfos?
    var uniqueId : String?
    var trackingId : String?
    var sessionId : String?
    var sessionToken : String?
    var crossSessionToken : String?
    var tenant: String
    
    init(page: BYPageRequest,
         device: BYDeviceInfos,
         visitor: BYVisitorInfos?,
         cartInfos: BYCartInfos?,
         uniqueId: String? = nil,
         trackingId: String? = nil,
         sessionId: String? = nil,
         sessionToken: String? = nil,
         crossSessionToken: String? = nil,
         tenant: String = "") {
            self.page = page
            self.device = device
            self.visitor = visitor
            self.cartInfos = cartInfos
            self.uniqueId = uniqueId
            self.trackingId = trackingId
            self.sessionId = sessionId
            self.sessionToken = sessionToken
            self.crossSessionToken = crossSessionToken
            self.tenant = tenant
    }
}

public protocol BYAttributes : Codable{
    var contextData : [String: String]? { get set }
}


///  * Model for the information of a page.
public struct BYPageRequest : Codable {
    var urlType: String
    var pageReferrer: String
    var url: String
    var homePageInfo: BYHomeAttributes?
    var genericPageInfo: BYGenericAttributes?
    var transactionPageInfo: BYTransactionAttributes?
    var productPage: BYProductAttributes?
    var categoryPageInfo: BYCategoryAttributes?
    var cartPageInfo: BYCartAttributes?
    
    init(urlType: String,
         pageReferrer: String,
         url: String,
         homePageInfo: BYHomeAttributes? = nil,
         genericPageInfo: BYGenericAttributes? = nil,
         transactionPageInfo: BYTransactionAttributes? = nil,
         productPage: BYProductAttributes? = nil,
         categoryPageInfo: BYCategoryAttributes? = nil,
         cartPageInfo: BYCartAttributes? = nil) {
            self.urlType                = urlType
            self.pageReferrer           = pageReferrer
            self.url                    = url
            self.homePageInfo           = homePageInfo
            self.genericPageInfo        = genericPageInfo
            self.transactionPageInfo    = transactionPageInfo
            self.productPage            = productPage
            self.categoryPageInfo       = categoryPageInfo
            self.cartPageInfo           = cartPageInfo
    }
}

///  * Model for the information of a page.
public struct BYPage : BYAttributes{
    public var contextData: [String : String]?
    let urlType : String?
    init(urlType: String?) {
        self.urlType = urlType
    }
}
/**
 *     "HomePageInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "Tags": {
 *           "type": "array",
 *           "items": {
 *             "type": "string"
 *           }
 *         }
 *       }
 *     }
 **/
public struct BYHomeAttributes: BYAttributes{
    
    public var contextData: [String : String]?
    private let tags : [String]?
    public init(tags: [String]?) {
        self.tags = tags
    }
}
/**
 * <p>
 *     "TransactionPageInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "Tags": {
 *           "type": "array",
 *           "description": "Tags",
 *           "items": {
 *             "type": "string"
 *           }
 *         }
 *       }
 *     }
 **/
public struct BYTransactionAttributes: BYAttributes{
    
    public var contextData: [String : String]?
    private let tags : [String]?
    public init(tags: [String]?) {
        self.tags = tags
    }
}

struct BYDeviceInfos : Codable{
    var latitude = 0
    var longitude = 0
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    var serial = ""
    var model = ""
    var deviceId = ""
    var manufacturer = "Apple"
    var brand = ""
    var deviceType = ""
    var deviceUser = ""
    var versionBase = ""
    var versionIncremental = ""
    var board = ""
    var host = ""
    var fingerprint = ""
    var orientation = ""
    var sdk = ""
    var integratorAppVersion = ""
    
    init(integratorAppVersion: String?) {
        if integratorAppVersion != nil {
            self.integratorAppVersion = integratorAppVersion!
        }
        let device = UIDevice.current
        let screen = UIScreen.main.bounds
        serial              = "unknown"  // iOS does not provide serial number
        model               = device.model
        deviceId            = device.identifierForVendor?.uuidString ?? "unknown"
        manufacturer        = "Apple"
        brand               = "Apple"
        deviceType          = device.userInterfaceIdiom == .phone ? "phone" : "tablet"
        deviceUser          = "unknown"  // No equivalent in iOS
        versionBase         = device.systemVersion
        versionIncremental  = "unknown"  // No direct equivalent in iOS
        sdk                 = "unknown"  // No direct equivalent in iOS
        board               = "unknown"  // No direct equivalent in iOS
        host                = "unknown"  // No direct equivalent in iOS
        fingerprint         = "unknown"  // No direct equivalent in iOS
        screenWidth         = screen.width * UIScreen.main.scale
        screenHeight        = screen.height * UIScreen.main.scale
        orientation         = UIDevice.current.orientation.isLandscape ? "Landscape" : "Portrait"
    }
}

/**
 * <p>
 *     "CartInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "Items": {
 *           "type": "array",
 *           "description": "Items in the cart",
 *           "items": {
 *             "$ref": "#/definitions/CartItemInfo"
 *           }
 *         },
 *         "TotalAmount": {
 *           "type": [
 *             "null",
 *             "number"
 *           ],
 *           "description": "Total amount of the cart (if not set, the sum of the items will be used)",
 *           "format": "decimal"
 *         }
 *       }
 *     }
 **/
public struct BYCartInfos : Codable{
    private var totalAmount : Double = 0.0
    private let items : [BYCartItemInfos]?
    public init(items: [BYCartItemInfos]?) {
        self.items = items
        for item in self.items ?? [BYCartItemInfos]() {
            totalAmount = totalAmount + (item.productPrice ?? 0.0)
        }
    }
}

public struct BYCartItemInfos : Codable{
    let productReference : String?
    let productName : String?
    let productUrl : String?
    let productPrice : Double?
    let quantity : Int?
    let thumbnailUrl : String?
    let tags : [String]??
    
    public init(productReference: String?, productName: String?, productUrl: String?,
                productPrice: Double?, quantity: Int?, thumbnailUrl: String?, tags: [String]?) {
        self.productReference = productReference
        self.productName = productName
        self.productUrl = productUrl
        self.productPrice = productPrice
        self.quantity = quantity
        self.thumbnailUrl = thumbnailUrl
        self.tags = tags
    }
}

/**
 * <p>
 *     "ProductPageInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "ProductReference": {
 *           "type": "string",
 *           "description": "Id of the product (reference, sku)"
 *         },
 *         "ProductName": {
 *           "type": "string",
 *           "description": "Name of the product"
 *         },
 *         "ProductUrl": {
 *           "type": "string",
 *           "description": "Url of the product"
 *         },
 *         "ProductPriceBeforeDiscount": {
 *           "type": [
 *             "null",
 *             "number"
 *           ],
 *           "description": "Product Price before the discount if any",
 *           "format": "decimal"
 *         },
 *         "ProductSellingPrice": {
 *           "type": "number",
 *           "description": "Product selling price",
 *           "format": "decimal"
 *         },
 *         "ThumbnailUrl": {
 *           "type": "string",
 *           "description": "Thumbnail url"
 *         },
 *         "ProductStock": {
 *           "type": [
 *             "null",
 *             "number"
 *           ],
 *           "description": "Stock of the product if available",
 *           "format": "decimal"
 *         },
 *         "Tags": {
 *           "type": "array",
 *           "description": "Tags",
 *           "items": {
 *             "type": "string"
 *           }
 *         }
 *       }
 *     },
 **/
public struct BYProductAttributes : BYAttributes{
    public var contextData: [String : String]?
    private let productReference : String?
    private let productName : String?
    private let productUrl : String?
    private let productPriceBeforeDiscount : Double?
    private let productSellingPrice : Double?
    private let productStock : Int?
    private let thumbnailUrl : String?
    private let tags : [String]?
    
    public init(reference: String?, name: String?, url: String?, priceBeforeDiscount: Double?, 
                sellingPrice: Double?, stock: Int?, thumbnailUrl: String?, tags: [String]?) {
        self.productReference           = reference
        self.productName                = name
        self.productUrl                 = url
        self.productPriceBeforeDiscount = priceBeforeDiscount
        self.productSellingPrice        = sellingPrice
        self.productStock               = stock
        self.thumbnailUrl               = thumbnailUrl
        self.tags                       = tags
    }
}
/**
 * <p>
 *     "CategoryPageInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "CategoryId": {
 *           "type": "string",
 *           "description": "Id of the category"
 *         },
 *         "CategoryName": {
 *           "type": "string",
 *           "description": "Name of the category"
 *         },
 *         "Tags": {
 *           "type": "array",
 *           "description": "Tags",
 *           "items": {
 *             "type": "string"
 *           }
 *         }
 *       }
 *     }
 **/
public struct BYCategoryAttributes : BYAttributes{
    public var contextData: [String : String]?
    let CategoryId : String?
    let CategoryName : String?
    let tags : [String]?
    
    public init(CategoryId: String?, CategoryName: String?, tags: [String]?) {
        self.CategoryId = CategoryId
        self.CategoryName = CategoryName
        self.tags = tags
    }
}
/**
 *
 *     "CartPageInfo": {
 "type": "object",
 "additionalProperties": false,
 "properties": {
 "Tags": {
 "type": "array",
 "description": "Tags",
 "items": {
 "type": "string"
 }
 }
 }
 },
 **/
public struct BYCartAttributes : BYAttributes{
    public var contextData: [String : String]?
    let tags : [String]?
    
    public init(tags: [String]?) {
        self.tags = tags
    }
}

/**
 * <p>
 *     "GenericPageInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "Id": {
 *           "type": "string",
 *           "description": "Id of the item on the page"
 *         },
 *         "CustomValue1": {
 *           "type": "string",
 *           "description": "Slot for a custom value"
 *         },
 *         "CustomValue2": {
 *           "type": "string",
 *           "description": "Slot for a custom value"
 *         },
 *         "CustomValue3": {
 *           "type": "string",
 *           "description": "Slot for a custom value"
 *         },
 *         "CustomValue4": {
 *           "type": "string",
 *           "description": "Slot for a custom value"
 *         },
 *         "CustomValue5": {
 *           "type": "string",
 *           "description": "Slot for a custom value"
 *         },
 *         "Stock": {
 *           "type": [
 *             "null",
 *             "number"
 *           ],
 *           "description": "Slot for a value corresponding to a stock",
 *           "format": "decimal"
 *         },
 *         "Tags": {
 *           "type": "array",
 *           "description": "Tags",
 *           "items": {
 *             "type": "string"
 *           }
 *         }
 *       }
 *     }
 **/
public struct BYGenericAttributes : BYAttributes {
    public var contextData: [String : String]?
    let id : String?
    let customValue1 : String?
    let customValue2 : String?
    let customValue3 : Double?
    let customValue4 : Int?
    let customValue5 : String?
    let stock : String?
    let tags : [String]?
    
    public init(id: String?, customValue1: String?, customValue2: String?, customValue3: Double?, customValue4: Int?, customValue5: String?, stock: String?, tags: [String]?) {
        self.id = id
        self.customValue1 = customValue1
        self.customValue2 = customValue2
        self.customValue3 = customValue3
        self.customValue4 = customValue4
        self.customValue5 = customValue5
        self.stock = stock
        self.tags = tags
    }
}

/**
 * <p>
 * Class to reprents VisitorInfo.
 *
 *     "VisitorInfo": {
 *       "type": "object",
 *       "additionalProperties": false,
 *       "properties": {
 *         "IsConnectedToAccount": {
 *           "type": [
 *             "boolean",
 *             "null"
 *           ],
 *           "description": "Is the visitor connected to its account"
 *         },
 *         "IsClient": {
 *           "type": [
 *             "boolean",
 *             "null"
 *           ],
 *           "description": "Is the visitor a client"
 *         },
 *         "PseudoId": {
 *           "type": "string",
 *           "description": "Pseudo Id of the visitor (eg hashed email)"
 *         },
 *         "FavoriteCategory": {
 *           "type": "string",
 *           "description": "Favorite category of the visitor"
 *         }
 *       }
 *     },
 **/
public struct BYVisitorInfos : Codable {
    let isConnectedToAccount : Bool?
    let isClient : Bool?
    let pseudoId : String?
    let favoriteCategory : String?
    public init(isConnectedToAccount: Bool?, isClient: Bool?, pseudoId: String?, favoriteCategory: String?) {
        self.isConnectedToAccount = isConnectedToAccount
        self.isClient = isClient
        self.pseudoId = pseudoId
        self.favoriteCategory = favoriteCategory
    }
    
}


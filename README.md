# SDK BeYable iOS

## Intégration

Avant tout appel au SDK, il est nécessaire de l'initialiser avec les clefs fournies par BeYable
```
let beyableClient = BeyableSDK(tokenClient: "apiKey")
```

D'autres méthodes 'init' sont disponibles :
```
public convenience init(tokenClient: String, environment: EnvironmentBeyable? = EnvironmentBeyable.production, loggingEnabledUser: Bool? = true)
    
public convenience init(tokenClient: String, baseUrl: String, loggingEnabledUser: Bool? = true)
    
public convenience init(tokenClient: String, loggingEnabledUser: Bool? = true)
    
public convenience init(tokenClient: String, baseUrl: String)
    
public convenience init(tokenClient: String)
```
### Méthodes de configuration
```
/** 
 Set the base url for BeYable servers
 - parameter baseUrl : url Beyable
 */
public func setBaseUrl(_ baseUrl: String)


/**
 Set the tenant to be send on each requests
 - parameter tenant: A arbitrary string that identify the tenant
 */
public func setTenant(tenant: String)

    
/// Set the user infos to be send at each request
/// - Parameter visitorInfos:the infos of the user ``BYVisitorInfos`` (Can be nil to clean)
public func setVisitorInfos(visitorInfos : BYVisitorInfos? = nil)

```



## Usage
À chaque affichage d'une vue, on informe le SDK.</br>

### Exemple 'ViewController' - Page 'Home'
```
override func viewDidLoad() {
super.viewDidLoad()
let homePageAttributes = BYHomeAttributes(tags: ["screenTitle":"\(self.screenTitle)", "numberCategory":"\(self.productCollections.count)"])

AppDelegate.instance.beyableClient.sendPageview(page: EPageUrlTypeBeyable.HOME, currentView: self.view, attributes: homePageAttributes)
}
```

### Exemple page ViewController produit 
```
let productBY : BYProductAttributes = BYProductAttributes(reference: productObject?.id, name: productObject?.name, url: productObject?.imageUrl, priceBeforeDiscount: productObject?.price.value ?? 0.0, sellingPrice: productObject?.price.value ?? 0, stock: 1, thumbnailUrl: "", tags: ["type":"\(productObject?.type ?? "")","materiel":"\(productObject?.info?.material ?? "")"])

AppDelegate.instance.beyableClient.sendPageview(page: EPageUrlTypeBeyable.PRODUCT, currentView: self.view, attributes: productBY)
```

### Exemple page en SwiftUI
```
struct ProductsCollectionPageView: View, OnSendPageView {
    
    let products: [Product]
    @State private var count = 0
        
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        BasketProductCardView(viewModel: product, index: index)
                    }
                }
            }
            .navigationTitle("SwiftUI Collection")
        }
        .onAppear() {
            // Send page to Beyable
             AppDelegate.instance.beyableClient.sendPageview(
                page: EPageUrlTypeBeyable.CART,
                attributes: BYCartAttributes(tags: []),
                cartInfos: BYCartInfos(items: []),
                callback: self)
        }
    }
    
    func onBYSuccess() {
    
    }
    
    func onBYError() {
        
    }
    
}
```


## Affichage des campagnes 

#### InCollection (UIKit / UITableView)

```
// Delegate methods
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let index = indexPath.row
    // Product to load in the current cell
    let product = shoppingCartProducts[index]
    // Send the cell to the BeyableSDK
    AppDelegate.instance.beyableClient.sendCellBinded(cell: cell, elemementId: product.name!, callback: self)
  }
   
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    // Réinitialisez l'état de la cellule lorsqu'elle est retirée de l'écran
    let index = indexPath.row
    let product = shoppingCartProducts[index]
    AppDelegate.instance.beyableClient.sendCellUnbinded(cell: cell, elemementId: product.name!)
  }
   
  func onBYClick(cellId: String, value: String) {
    NSLog("Campaing clicked for cell \(cellId) with value \(value)")
  }
```

#### InCollection (SwiftUI)
Pour du SwiftUI, il faut avoir des placeholder dans la structure de la vue
```
    ...
    VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading, spacing: 4) {
            ...
            BYInCollectionPlaceHolder(
                placeHolderId: "cart_product_title",
                elementId: viewModel.name,
                delegate: self)
            ...
        }
    }
    ...
    

func onBYClick(cellId: String, value: String) {
    NSLog("Campaing clicked for cell \(cellId) with value \(value)")
}
```

#### InPage (SwiftUI)
Pour du SwiftUI, il faut avoir des placeholder dans la structure de la vue
```
VStack(alignment: .leading, spacing: 10) {
    ...
    BYInPagePlaceHolder(placeHolderId: "placholer01")
    ...
}

``

# SDK BeYable iOS

## Installation
Ajouter la ligne suivante au fichier pod
```
pod 'BeyableClient'
```

## Intégration

Avant tout appel au SDK, il est nécessaire de l'initialiser avec les clefs fournies par BeYable
```
let beyableClient = BeyableClientiOS(tokenClient: "apiKey")
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

## Exemple page ViewController produit 
```
  let productBY : BYProductAttributes = BYProductAttributes(reference: productObject?.id, name: productObject?.name, url: productObject?.imageUrl, priceBeforeDiscount: productObject?.price.value ?? 0.0, sellingPrice: productObject?.price.value ?? 0, stock: 1, thumbnailUrl: "", tags: ["type":"\(productObject?.type ?? "")","materiel":"\(productObject?.info?.material ?? "")"])
  AppDelegate.instance.beyableClient.sendPageview(page: EPageUrlTypeBeyable.PRODUCT, currentView: self.view, attributes: productBY)
```


## Affichage des campagnes 

#### InCollection

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

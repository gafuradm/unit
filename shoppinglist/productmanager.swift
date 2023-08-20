import Foundation
import RealmSwift
class ProductManager {
    private let realm = try! Realm()
    func getAllProducts() -> Results<Product> {
        return realm.objects(Product.self)
    }
    func createProduct(name: String, price: Double, qua: Int) {
        let product = Product(name: name, price: price, qua: qua)
        try! realm.write {
            realm.add(product)
        }
    }
    func deleteProduct(_ product: Product) {
        try! realm.write {
            realm.delete(product)
        }
    }
}

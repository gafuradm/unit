import XCTest
@testable import shoppinglist
class shoppinglistTests: XCTestCase {
    var viewController: ViewController!
    override func setUp() {
        super.setUp()
        viewController = ViewController()
        _ = viewController.view
    }
    override func tearDown() {
        super.tearDown()
        viewController = nil
    }
    func testProductCreation() {
        let productName = "test"
        let productPrice = 10.0
        let productQuantity = 5
        viewController.product.name = productName
        viewController.product.price = productPrice
        viewController.product.qua = productQuantity
        viewController.createProduct()
        let products = viewController.products
        XCTAssertEqual(products?.count, 12)
    }
    func testProductDeletion() {
        let productName = "test2"
        let productPrice = 16.0
        let productQuantity = 6
        viewController.product.name = productName
        viewController.product.price = productPrice
        viewController.product.qua = productQuantity
        viewController.createProduct()
        viewController.loadProducts()
        let initialProductCount = viewController.products.count
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.tableView(viewController.tableView, commit: .delete, forRowAt: indexPath)
        let updatedProductCount = viewController.products.count
        XCTAssertEqual(updatedProductCount, initialProductCount - 1)
    }
    func testTotalPriceCalculation() {
        let productName = "test3"
        let productPrice = 15.0
        let productQuantity = 7
        viewController.product.name = productName
        viewController.product.price = productPrice
        viewController.product.qua = productQuantity
        viewController.createProduct()
        viewController.loadProducts()
        let totalPrice = viewController.calculateTotalPrice()
        XCTAssertEqual(totalPrice, 1278.0)
    }
    func testSearchFunctionality() {
        let productName = "test1"
        let productPrice = 17.0
        let productQuantity = 8
        viewController.product.name = productName
        viewController.product.price = productPrice
        viewController.product.qua = productQuantity
        viewController.createProduct()
        viewController.loadProducts()
        viewController.searchController.searchBar.text = "test1"
        viewController.updateSearchResults(for: viewController.searchController)
        let filteredCount = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(filteredCount, 3)
    }
}

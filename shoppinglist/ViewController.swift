import UIKit
import RealmSwift
import SnapKit

class Product: Object {
    @Persisted var name: String
    @Persisted var price: Double
    @Persisted var qua: Int
    convenience init(name: String, price: Double, qua: Int) {
        self.init()
        self.name = name
        self.price = price
        self.qua = qua
    }
}
class ViewController: UIViewController {
    let realm = try! Realm()
    var products: Results<Product>!
    let tableView = UITableView()
    let totalPriceLabel = UILabel()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredProducts: Results<Product>!
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupTotalPriceLabel()
        loadProducts()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск товаров"
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.title = "Список покупок"
    }
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    func setupTotalPriceLabel() {
        view.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom).offset(-50)
            $0.height.equalTo(30)
        }
        totalPriceLabel.text = "Итоговая стоимость товаров: 0.00"
    }
    func loadProducts() {
        products = realm.objects(Product.self)
        tableView.reloadData()
        updateTotalPrice()
    }
    let product = Product()
    func createProduct() {
        try! self.realm.write {
            self.realm.add(product)
        }
    }
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Добавить товар", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addTextField()
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "Название товара"
        alertController.textFields?[1].placeholder = "Цена товара"
        alertController.textFields?[2].placeholder = "Количество товара"
        let submitAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            let name = alertController.textFields?[0].text ?? ""
            let price = Double(alertController.textFields?[1].text ?? "") ?? 0
            let qua = Int(alertController.textFields?[2].text ?? "") ?? 0
            self.product.name = name
            self.product.price = price
            self.product.qua = qua
            self.createProduct()
            self.loadProducts()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        self.present(alertController, animated: true)
    }
    func updateTotalPrice() {
        let totalPrice = calculateTotalPrice()
        totalPriceLabel.text = "Итоговая стоимость товаров: \(totalPrice.format(f: ".2"))"
    }
    func calculateTotalPrice() -> Double {
        var totalPrice: Double = 0
        for product in products {
            totalPrice += product.price
        }
        return totalPrice
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredProducts.count
        } else {
            return products.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product: Product
        if isSearching {
            product = filteredProducts[indexPath.row]
        } else {
            product = products[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Название товара: \(product.name), Цена товара: \(product.price), Количество товара: \(product.qua)"
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let object = products?[indexPath.row] else { return }
            try! realm.write {
                realm.delete(object)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateTotalPrice()
        }
    }
}
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            isSearching = false
            tableView.reloadData()
        } else {
            isSearching = true
            filteredProducts = products.filter("name CONTAINS[c] %@", searchText)
            tableView.reloadData()
        }
    }
}
extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

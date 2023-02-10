//
//  ProductsTableViewController.swift
//  my_ios_storeAPP
//
//  Created by 危末狂龍 on 2023/2/9.
//

import Foundation
import UIKit
import SwiftUI

class ProductsTableViewController: UITableViewController {
    
    private var category: Category
    private var client = StoreHTTPClient()
    private var products: [Product] = []
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var addProductBarItemButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductButtonPressed))
        return barButtonItem
    }()
    
    @objc private func addProductButtonPressed(_ sender: UIBarButtonItem) {
        let addProductVC = AddProductViewController()
        addProductVC.delegate = self
        let navigationController = UINavigationController(rootViewController: addProductVC)
        present(navigationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductTableViewCell")
        navigationItem.rightBarButtonItem = addProductBarItemButton
        
        Task {
            await populateProducts()
        }
    }
    
    private func populateProducts() async {
        do {
            products = try await client.getProductsByCategory(categoryID: category.id)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath)
        
        let product = products[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration(content: {
            ProductCellView(product: product)
        })
        
        return cell
    }
}

extension ProductsTableViewController: AddProductViewControllerDelegate {
    
    func addProductViewControllerDidCancel(controller: AddProductViewController) {
        controller.dismiss(animated: true)
    }
    
    func addProductViewControllerDidSave(product: Product, controller: AddProductViewController) {
        
        let createProductRequest = CreateProductRequest(product: product)
        
        Task {
            do {
                let newProduct = try await client.createProduct(productRequest: createProductRequest)
                products.insert(newProduct, at: 0)
                tableView.reloadData()
                controller.dismiss(animated: true)
            } catch {
                print(error)
            }
        }
        
    }
    
}



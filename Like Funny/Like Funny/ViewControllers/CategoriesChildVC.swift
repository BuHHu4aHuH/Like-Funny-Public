//
//  CategoriesChildVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/21/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import SQLite

class CategoriesChildVC: UIViewController  {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var categoriesMass = [WorkWithDataSingleton.categoriesModel]()
    
    var navigationTitle: String?
    var categoryKeyy: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: categoryKeyy!)
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
    }
}

extension CategoriesChildVC: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: CategoryCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: CategoryCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        
        let data = categoriesMass[indexPath.row]
        
        cell.txtLabel?.text = data.name
        cell.arroyImage.image = UIImage(named: "arroy")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let desVC = storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC
        
        desVC.navigationTitle = categoriesMass[indexPath.item].name
        desVC.category = categoriesMass[indexPath.item].key
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(UIViewController.tableViewCellHeight)
    }
}

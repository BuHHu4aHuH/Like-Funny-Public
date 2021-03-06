//
//  ArticleVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/17/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData
import SQLite
import Firebase
import GoogleMobileAds

class ArticleVC: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var textsArray = [String]()
    private var interstitial: GADInterstitial?
    
    var navigationTitle: String?
    var category: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTableWithAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        textsArray = readingData(categorySearching: category!)
        
        fetchRequest()
        setupTableView()
    }
    
    //MARK: Setup full screen add
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9685005451826961/2965885986")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    //MARK: Setup NavigationBar
    
    private func setupNavigationBar() {
        self.navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
    }
    
    //Fetch Request
    
   private func fetchRequest() {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let article = try PersistenceServce.context.fetch(fetchRequest)
            WorkWithDataSingleton.savedArticles = article
        } catch {
            
        }
    }
    
    //Open Saved ViewController
    
    @objc private func addTapped() {
        let desVC = storyboard?.instantiateViewController(withIdentifier: "SavedArticlesController") as! SavedArticlesController
        interstitial = createAndLoadInterstitial()
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    //Alert
    
    private func createAlert(title: String, message: String, indexPath: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Соглас(на/ен)", style: .default, handler: { (action: UIAlertAction!) in
            UIPasteboard.general.string = self.textsArray[indexPath]
        })
        let cancelAction = UIAlertAction(title: "Нет", style: .destructive, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated:  true, completion: nil)
    }
    
    //ReadData from SQLite
    
    private func readingData(categorySearching: String) -> [String] {
        var categoriesModel = [String]()
        
        do {
            let articles = try SQLiteArticleSingleton.articleDatabase.prepare(SQLiteArticleSingleton.articleTable)
            for article in articles {
                if article[SQLiteArticleSingleton.articleKey] == categorySearching {
                    categoriesModel.append(article[SQLiteArticleSingleton.textArticleTable])
                }
            }
            
        } catch {
            print(error)
        }
        
        return categoriesModel
    }
    
    private func reloadTableWithAnimation() {
        
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }
}

extension ArticleVC: GADInterstitialDelegate {
    private func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    private func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
}

extension ArticleVC: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        let nibName = UINib(nibName: ArticleCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: ArticleCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as! ArticleCell
        
        cell.displayedView.isHidden = indexPath.item % 6 == 0 && indexPath.item != 0 ? true : false
        cell.bannerView.isHidden = indexPath.item % 6 == 0 && indexPath.item != 0 ? false : true
        
        cell.prepareForReuse()
        
        if indexPath.item % 6 == 0 && indexPath.item != 0 {
            cell.bannerView.adUnitID = "ca-app-pub-9685005451826961/7782646746"
            cell.bannerView.rootViewController = self
            cell.bannerView.load(GADRequest())
        } else {
            cell.articleLabel.text = textsArray[indexPath.item]
            let image = cell.setupSaveButton(isSaved: false)
            cell.saved.setImage(image, for: .normal)
    
            for saved in WorkWithDataSingleton.savedArticles {
                if cell.articleLabel.text == saved.article {
                    let image = cell.setupSaveButton(isSaved: true)
                    cell.saved.setImage(image, for: .normal)
                }
            }
            
            cell.selectionStyle = .none
            
            cell.sharingSwitchHandler = { [weak self] in
                
                guard let `self` = self else { return }
                
                let textShare = self.textsArray[indexPath.item]
                let activityViewController = UIActivityViewController(activityItems: [textShare], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
            
            cell.saveToCoreDataSwitchHandler = { [weak self] in
                
                guard let `self` = self else { return }
                
                var imageForButton: UIImage
                
                if cell.saved.imageView?.image == UIImage(named: "BlackStar95") {
                    imageForButton = cell.setupSaveButton(isSaved: false)
                    cell.saved.setImage(imageForButton, for: .normal)
                    
                    for article in WorkWithDataSingleton.savedArticles {
                        if article.article == self.textsArray[indexPath.item] {
                            PersistenceServce.persistentContainer.viewContext.delete(article)
                        }
                    }
                    
                    WorkWithDataSingleton.savedArticles.removeAll(where: { (article) -> Bool in
                        article.article == self.textsArray[indexPath.item]
                    })
                    
                    PersistenceServce.saveContext()
                    
                } else {
                    imageForButton = cell.setupSaveButton(isSaved: true)
                    cell.saved.setImage(imageForButton, for: .normal)
                    
                    let article = Article(context: PersistenceServce.context)
                    article.article = self.textsArray[indexPath.item]
                    PersistenceServce.saveContext()
                    
                    WorkWithDataSingleton.savedArticles.append(article)
                }
            }
            
            cell.copyTextSwitchHandler = { [weak self] in
                
                guard let `self` = self else { return }
                
                self.createAlert(title: "Пользовательское соглашение и правила копирования", message: "1. Настоящее Соглашение является публичной офертой. Получая доступ к поздравлениям данного приложения, Пользователь считается присоединившимся к настоящему Соглашению. \n2. Никакой Контент не может быть скопирован (воспроизведен), переработан, распространен, опубликован или иным способом использован целиком или по частям, без указанния источника. \n3. В случае необходимости использования текстовых  материалов, права на которые принадлежат нашим авторам, Пользователям необходимо обращаться через обратную связь www.likefunny.org. \n4. При копировании прямая ссылка на сайт и указание авторов обязательна! Копирование в коммерческих целях допускается только при письменном разрешении администрации сайта www.likefunny.org.", indexPath: indexPath.item)
            }
        }
        
        return cell
    }
}

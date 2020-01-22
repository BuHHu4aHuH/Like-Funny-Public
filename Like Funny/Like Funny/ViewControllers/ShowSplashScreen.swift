//
//  ShowSplashScreen.swift
//  Like Funny
//
//  Created by Maksim Shershun on 12/13/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class ShowSplashScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SQLiteArticleSingleton.setupTables()
        SQLiteArticleSingleton.createTables()
        
        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
       
        RunLoop.current.run(until: Date(timeIntervalSinceNow : 1.0))
        self.showMainVC()
    }
    
    private func showMainVC() {
        DispatchQueue.main.async {
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "NavVC") as! UINavigationController
            self.present(navVC, animated: true, completion: nil)
        }
    }
}

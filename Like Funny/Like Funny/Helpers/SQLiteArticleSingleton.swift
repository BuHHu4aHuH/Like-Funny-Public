//
//  SQLiteArticleSingleton.swift
//  Like Funny
//
//  Created by Maksim Shershun on 12/14/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import SQLite

class SQLiteArticleSingleton {
    
    static var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    
    //SQLite Database
    
    static var categoriesDatabase: Connection!
    
    static let categoriesTable = Table("categories")
    static let idCategoriesTable = Expression<Int>("id")
    static let nameCategoriesTable = Expression<String>("name")
    static let parentCategoriesTable = Expression<String>("parent")
    static let keyCategoriesTable = Expression<String>("key")
    
    static var articleDatabase: Connection!
    
    static let articleTable = Table("article")
    static let idArticleTable = Expression<Int>("id")
    static let textArticleTable = Expression<String>("text")
    static let articleKey = Expression<String>("key")
    
    //SetupingTables
    
    static func setupTables() {
        
        do {
            let fileUrl = Bundle.main.path(forResource: "categories", ofType: "sqlite3")
            let database = try Connection(fileUrl!)
            SQLiteArticleSingleton.categoriesDatabase = database
        } catch {
            print(error)
        }
        
        do {
            let fileUrl = Bundle.main.path(forResource: "article", ofType: "sqlite3")
            let database = try Connection(fileUrl!)
            SQLiteArticleSingleton.articleDatabase = database
        } catch {
            print(error)
        }
    }
    
    //Create DB
    
    static func createTables() {
        print("CREATE TABLE")
        
        //CategoriesTable
        
        let createCategoriesTable = SQLiteArticleSingleton.categoriesTable.create { (table) in
            table.column(SQLiteArticleSingleton.idCategoriesTable, primaryKey: true)
            table.column(SQLiteArticleSingleton.parentCategoriesTable)
            table.column(SQLiteArticleSingleton.keyCategoriesTable)
            table.column(SQLiteArticleSingleton.nameCategoriesTable)
        }
        
        do {
            try SQLiteArticleSingleton.categoriesDatabase.run(createCategoriesTable)
            print("CREATED CATEGORIES TABLE")
        } catch {
            print(error)
        }
        
        //ArticleTable
        
        let createArticleTable = SQLiteArticleSingleton.articleTable.create { (table) in
            table.column(SQLiteArticleSingleton.idArticleTable, primaryKey: true)
            table.column(SQLiteArticleSingleton.textArticleTable)
            table.column(SQLiteArticleSingleton.articleKey)
        }
        
        do {
            try SQLiteArticleSingleton.articleDatabase.run(createArticleTable)
            print("CREATED ARTICLE TABLE")
        } catch {
            print(error)
        }
    }
    
    static func readingData(categorySearching: String) -> [WorkWithDataSingleton.categoriesModel] {
        var categoriesModel: [WorkWithDataSingleton.categoriesModel] = []
        
        do {
            let categories = try SQLiteArticleSingleton.categoriesDatabase.prepare(SQLiteArticleSingleton.categoriesTable)
            for category in categories {
                if category[SQLiteArticleSingleton.parentCategoriesTable] == categorySearching {
                    let elem = WorkWithDataSingleton.categoriesModel(name: category[SQLiteArticleSingleton.nameCategoriesTable], key: category[SQLiteArticleSingleton.keyCategoriesTable])
                    
                    if let element = elem {
                        categoriesModel.append(element)
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        return categoriesModel
    }
}

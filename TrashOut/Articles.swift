//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import Foundation

class ArticlesManager {

    init() {}

    /**
     sorted articles to display
     */
    var news: [Article] = []

    /**
     fetched articles from api
     */
    var articles: [String: [Article]] = [:]

	var paging: [
		String: (page: Int, isLast: Bool)
		] = [:]

    var limit = 10


    func availableLanguages() -> [String] {
        let availableLanguages: [String] = ["en_US", "cs_CZ", "de_DE", "es_ES", "sk_SK", "ru_RU"]
        var languages = Bundle.preferredLocalizations(from: availableLanguages).prefix(1)
        if languages.contains("en_US") == false {
            languages.append("en_US")
        }
        return Array(languages)
    }
    
	/**
	Load articles (news) for curent phone language and for english
	*/
    func loadData(callback: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let languages = availableLanguages()
		var downloadBlocks: [Async.Block] = languages.map { self.downloadBlock(for: $0) }
        downloadBlocks.append { [weak self] (completion: @escaping () -> Void, _: @escaping (Error) -> Void) in
            self?.showArticles()
            callback()
            completion()
        }
		Async.waterfall(downloadBlocks, failure: failure)
    }

	func reload(callback: @escaping () -> Void, failure: @escaping (Error) -> Void) {
		self.paging = [:]
		self.loadData(callback: callback, failure: failure)
	}

	/**
	Download block for given language (to be processed later)
	*/
	func downloadBlock(for lang: String) -> (_ completion: @escaping () -> Void, _ failure: @escaping (Error) -> Void) -> () {
		return { [weak self] (_ completion: @escaping () -> Void, _ failure: @escaping (Error) -> Void) in
			if self?.articles[lang] == nil {
				self?.articles[lang] = []
			}
			self?.loadArticles(for: lang, completion: completion, failure: failure)
		}
	}

	/**
	Download articles from api for given language
	*/
    func loadArticles(for lang: String, completion: @escaping () -> Void, failure: @escaping (Error) -> Void) {
		if let p = self.paging[lang], p.isLast == true {
			completion()
			return
		}
        let page = (self.articles[lang]?.count ?? 0) / limit + 1
        print("Downloading page \(page) for language \(lang)")
        Networking.instance.news(page: page, limit: limit, language: lang) { [weak self] articles, error in
            if let error = error {
                failure(error)
                return
            }
            if let articles = articles {
				if articles.count < (self?.limit ?? 10) {
					self?.paging[lang] = (page: page, isLast: true)
				} else {
					self?.paging[lang] = (page: page, isLast: false)
				}
                self?.articles[lang]?.append(contentsOf: articles)
            }
            completion()
        }
    }

	/**
	Sort articles by time
	*/
    func showArticles() {
        for (_, articles) in self.articles {
            let others = articles.filter { (a) -> Bool in
                return news.contains(where: { (art) -> Bool in
                    return art.id == a.id
                }) == false
            }
            news.append(contentsOf: others)
        }
        news = news.sorted(by: { (a1, a2) -> Bool in
            guard let ta2 = a2.published else { return true }
            guard let ta1 = a1.published else { return false }
            return ta1 > ta2
        })
    }
    
    
    func removeAllData() {
        news.removeAll()
        articles.removeAll()
    }
    
    func lastPageLoaded() -> Bool {
        let languages = availableLanguages()
        let boolArray = languages.map { self.paging[$0]!.isLast }
        let isAllTrue = boolArray.reduce(true, {$0 && $1}) // true
        return isAllTrue
    }

}

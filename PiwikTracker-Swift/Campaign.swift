//
//  Campaign.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

public struct Campaign {
    
    let name: String
    let keyword: String?
    let url: URL
    
    init?(_ string: String) {
        if let url = URL(string: string) {
            self.init(url)
        }
        return nil
    }
    
    init?(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let queryItems = urlComponents?.queryItems {
            let nameItem = queryItems.filter({$0.name == PiwikConstants.URLCampaignName}).first
            let keywordItem = queryItems.filter({$0.name == PiwikConstants.URLCampaignKeyword}).first
            if let name = nameItem?.value {
                self.init(name: name, keyword: keywordItem?.value, url: url)
            }
        }
        return nil
    }
    
    init(name: String, keyword: String?, url: URL) {
        self.name = name
        self.keyword = keyword
        self.url = url
    }
}

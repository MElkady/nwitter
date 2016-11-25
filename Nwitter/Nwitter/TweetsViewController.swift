//
//  ViewController.swift
//  Nwitter
//
//  Created by MAK on 11/25/16.
//  Copyright © 2016 MAK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

class TweetsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var tweets: Tweets?
    var searchKeyWord: String?
    var timer: Timer?
    var refreshInterval: Double = 0.0
    
    @IBOutlet weak var btnChangeRefeshInterval: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.statuses.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TweetRow", for: indexPath) as? TweetRow, let ts = self.tweets {
            let t = ts.statuses[indexPath.row]
            cell.lblTweetText.setText(text: t.text!, withHashtagColor: UIColor.blue, andMentionColor: UIColor.green)
            cell.lblTweetAuthor.text = t.user?.name
            //cell.lblTweetText.text = t.created_at!
            return cell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let ts = self.tweets {
            let refreshIndex = ts.statuses.count - 3
            if indexPath.row == refreshIndex {
                self.searchTwitter(text: self.searchKeyWord!, maxId: ts.statuses[ts.statuses.count - 1].id!, sinceId: nil) { newTweets in
                    ts.statuses.append(contentsOf: newTweets.statuses)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
        
        
        if let t = searchBar.text {
            print("searchBarSearchButtonClicked: \(t)")
            self.searchKeyWord = t
            self.searchTwitter(text: t, maxId: nil, sinceId: nil){ newTweets in
                self.tweets = newTweets
                self.tableView.reloadData()
                if self.refreshInterval > 0 {
                    self.timer = Timer.scheduledTimer(timeInterval: self.refreshInterval, target: self, selector: #selector(self.autoRefresh), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    func autoRefresh(){
        if let x  = self.searchKeyWord, let ts = self.tweets {
            let lastId:String? = (ts.statuses.count > 0) ? ts.statuses[0].id : nil
            self.searchTwitter(text: x, maxId: nil, sinceId: lastId) { newTweets in
//                let currentRow = self.tableView.indexPathsForVisibleRows?[0]
                newTweets.statuses.append(contentsOf: ts.statuses)
                ts.statuses = newTweets.statuses
                
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
//                if let cr = currentRow {
//                    print("It was at row \(cr.row)")
//                    let newIndexPath = IndexPath(row: cr.row + newTweets.statuses.count - 1, section: 0)
//                    self.tableView.scrollToRow(at: newIndexPath, at: .none, animated: false)
//                }

//                let currentCount = ts.statuses.count
//                self.tableView.beginUpdates()
//                newTweets.statuses.append(contentsOf: ts.statuses)
//                ts.statuses = newTweets.statuses
//
//                var indexPaths: [IndexPath] = []
//                for i in currentCount..<newTweets.statuses.count {
//                    indexPaths.append(IndexPath(row: i, section: 0))
//                }
//                self.tableView.insertRows(at: indexPaths, with: .none)
//                self.tableView.endUpdates()
//
//                if let cr = currentRow {
//                    let newIndexPath = IndexPath(row: cr.row + newTweets.statuses.count, section: 0)
//                    self.tableView.scrollToRow(at: newIndexPath, at: .none, animated: false)
//                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if let _ = self.timer {
            sender.endRefreshing()
            return
        }
        
        if let x  = self.searchKeyWord, let ts = self.tweets {
            self.searchTwitter(text: x, maxId: nil, sinceId: ts.statuses[0].id) { newTweets in
                sender.endRefreshing()
                self.tableView.reloadData()
            }
        } else {
            sender.endRefreshing()
        }
    }
    
    @IBAction func changeRefreshInterval(_ sender: UIBarButtonItem) {
        switch(self.refreshInterval) {
        case 0.0:
            self.refreshInterval = 2.0
            break
            
        case 2.0:
            self.refreshInterval = 5.0
            break
            
        case 5.0:
            self.refreshInterval = 30.0
            break
            
        case 30.0:
            self.refreshInterval = 60.0
            break
            
        case 60.0:
            self.refreshInterval = 0.0
            break
            
        default:
            break
        }
        
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
        
        if self.refreshInterval > 0 {
            if let _ = self.searchKeyWord {
                self.timer = Timer.scheduledTimer(timeInterval: self.refreshInterval, target: self, selector: #selector(self.autoRefresh), userInfo: nil, repeats: true)
            }
            self.btnChangeRefeshInterval.title = "\(Int(self.refreshInterval)) sec"
        } else {
            self.btnChangeRefeshInterval.title = "Manual"
        }
    }
    
    
    func searchTwitter(text: String, maxId: String?, sinceId: String?, callback: ((Tweets) -> Void)?) {
        let searchText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print("Searching for \(searchText), maxId: \(maxId), after: \(sinceId)")
        var url = "https://twitter-wrapper.herokuapp.com/api/tweets?q=\(searchText)"
        if let mi = maxId {
            url = url + "&max_id=" + mi
        } else if let si = sinceId {
            url = url + "&since_id=" + si
        } else {
            url = url + "&count=20"
        }
        Alamofire.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    let j = JSON(object: response.result.value!)
                    if let st = j["tweets"].rawString(), let newTweets = Mapper<Tweets>().map(JSONString: st) {
                        if let c = callback {
                            c(newTweets)
                        }
                        print("Got \(newTweets.statuses.count) tweets")
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

}

class TweetRow : UITableViewCell {
    @IBOutlet weak var lblTweetText: UILabel!
    @IBOutlet weak var lblTweetAuthor: UILabel!
    
}

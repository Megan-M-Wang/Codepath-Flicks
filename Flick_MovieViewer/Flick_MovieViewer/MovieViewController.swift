//
//  MovieViewController.swift
//  Flick_MovieViewer
//
//  Created by Megan on 1/11/17.
//  Copyright © 2017 Megan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl = UIRefreshControl()
    var endpoint: String = ""
    
    
    func netRequest(ifLoad: Bool) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        if( ifLoad ) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                
                if( ifLoad ) {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    
                }
            }
        }
        task.resume()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        netRequest(ifLoad: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
    }
    
    public func refreshControlAction(refreshControl: UIRefreshControl) {
        netRequest(ifLoad: false)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
      
        cell.selectionStyle = .blue

        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
        
            cell.posterView.setImageWith(imageURL as! URL)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
}

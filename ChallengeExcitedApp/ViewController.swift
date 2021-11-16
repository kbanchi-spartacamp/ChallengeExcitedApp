//
//  ViewController.swift
//  ChallengeExcitedApp
//
//  Created by 伴地慶介 on 2021/11/14.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var challeges: [Challenge] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getChallengesInfo()
    }
    
    func getChallengesInfo() {
        let url = "http://localhost/api/challenges"
        let headers: HTTPHeaders = []
        // Alamofireでリクエスト
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.challeges = []
                let json = JSON(value).arrayValue
//                print(json)
                for challeges in json {
                    let challege = Challenge(
                        id: challeges["id"].int!,
                        user_id: challeges["user_id"].int!,
                        title: challeges["title"].string!,
                        description: challeges["description"].string!,
                        close_flg: challeges["close_flg"].int!,
                        created_at: challeges["created_at"].string ?? "",
                        updated_at: challeges["updated_at"].string ?? ""
                    )
                    self.challeges.append(challege)
                }
                // print(self.myArticles)
                self.tableView.reloadData()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challeges.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = challeges[indexPath.row].title
        return cell
    }
    
}

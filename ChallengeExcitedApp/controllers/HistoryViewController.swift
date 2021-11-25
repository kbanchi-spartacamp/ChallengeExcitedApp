//
//  HistoryViewController.swift
//  ChallengeExcitedApp
//
//  Created by 伴地慶介 on 2021/11/19.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class HistoryViewController: UIViewController {

    let consts = Constants.shared
    var challenges: [Challenge] = []
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        getChallengeHistoryInfo()
    }
    
    func getChallengeHistoryInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        guard let user_id = keychain["user_id"] else { return }
        let url = URL(string: consts.baseUrl + "/challenges/history?user_id=" + user_id)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.challenges = []
                let json = JSON(value).arrayValue
                print(json)
                for challenges in json {
                    let user = User(
                        id: challenges["user"]["id"].int!,
                        name: challenges["user"]["name"].string!,
                        email: challenges["user"]["email"].string!,
                        profile_photo_url: challenges["user"]["profile_photo_url"].string!
                    )
                    let challenge = Challenge(
                        id: challenges["id"].int!,
                        user_id: challenges["user_id"].int!,
                        title: challenges["title"].string!,
                        description: challenges["description"].string!,
                        close_flg: challenges["close_flg"].int!,
                        created_at: challenges["created_at"].string ?? "",
                        updated_at: challenges["updated_at"].string ?? "",
                        user: user
                    )
                    self.challenges.append(challenge)
                }
                // print(self.myArticles)
                self.historyTableView.reloadData()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        challenges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let titleLabel = cell.viewWithTag(1) as! UILabel
        titleLabel.text = challenges[indexPath.row].title
        return cell
    }
    
    
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "challengeDetailViewController") as! ChallengeDetailViewController
        vc.challengeId = String(challenges[indexPath.row].id)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

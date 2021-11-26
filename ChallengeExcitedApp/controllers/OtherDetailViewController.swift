//
//  OtherDetailViewController.swift
//  ChallengeExcitedApp
//
//  Created by 伴地慶介 on 2021/11/20.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class OtherDetailViewController: UIViewController {

    let consts = Constants.shared
    var challengeId = ""
    var comments: [Comment] = []
    var good: Good!
    var goods: [Good] = []
    let alert = Alert()
    var goodFlg = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var baclButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        goodButton.layer.cornerRadius = 10.0
        commentButton.layer.cornerRadius = 10.0
        baclButton.layer.cornerRadius = 10.0
        userImageView.layer.cornerRadius  = 30.0
        
        commentTableView.dataSource = self
        
        getChallengeInfo(challengeId: challengeId)
        getCommentsInfo()
        getGoodInfo()
        
    }
    
    func getChallengeInfo(challengeId: String) {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let user = User(
                    id: json["user"]["id"].int!,
                    name: json["user"]["name"].string!,
                    email: json["user"]["email"].string!,
                    profile_photo_url: json["user"]["profile_photo_url"].string!
                )
                let challenge = Challenge(
                    id: json["id"].int!,
                    user_id: json["user_id"].int!,
                    title: json["title"].string!,
                    description: json["description"].string!,
                    close_flg: json["close_flg"].int!,
                    created_at: json["created_at"].string ?? "",
                    updated_at: json["updated_at"].string ?? "",
                    user: user
                )
                self.setChallenge(challenge: challenge)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    func getCommentsInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId + "/comments")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.comments = []
                let json = JSON(value).arrayValue
                print(json)
                for comments in json {
                    let comment = Comment(
                        id: comments["id"].int!,
                        user_id: comments["user_id"].int!,
                        comment: comments["comment"].string!
                    )
                    self.comments.append(comment)
                }
                // print(self.myArticles)
                self.commentTableView.reloadData()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    func setChallenge(challenge: Challenge) {
        nameLabel.text = challenge.user.name + " さん"
        titleLabel.text = challenge.title
        descriptionLabel.text = challenge.description
        let imageUrl = URL(string: challenge.user.profile_photo_url)
        do {
            let data = try Data(contentsOf: imageUrl!)
            let image = UIImage(data: data)
            userImageView.image = image
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getGoodInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        guard let user_id = keychain["user_id"] else { return }
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId + "/goods?user_id" + user_id)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.goods = []
                let json = JSON(value).arrayValue
                print(json)
                for goods in json {
                    let good = Good(
                        id: goods["id"].int!,
                        user_id: goods["user_id"].int!,
                        challenge_id: goods["challenge_id"].int!
                    )
                    self.goods.append(good)
                }
                self.setGoodInfo(goods: self.goods)
                if self.goods.count != 0 {
                    self.good = self.goods[0]
                }
                // fail
            case .failure(let err):
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    func setGoodInfo(goods: [Good]) {
        if goods.count == 0 {
            goodFlg = 0
            goodButton.titleLabel?.text = "Like"
            goodButton.backgroundColor = UIColor.blue
        } else {
            goodFlg = 1
            goodButton.titleLabel?.text = "Unlike"
            goodButton.backgroundColor = UIColor.red
        }
    }
    
    @IBAction func tapGoodButton(_ sender: Any) {
        if self.goodFlg == 0 {
            postGood()
        } else {
            postNoGood()
        }
    }
    
    func postGood() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId + "/goods")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        let parameters: Parameters = [
            "user_id": user_id,
            "challenge_id": challengeId
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.alert.showAlert(title: "Good", messaage: "you did good this challenge", viewController: self)
                self.goodFlg = 1
                self.goodButton.titleLabel?.text = "Unlike"
                self.goodButton.backgroundColor = UIColor.red
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }

    func postNoGood() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId + "/goods/" + String(self.good.id))!
        print(url)
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        let parameters: Parameters = [
            "user_id": user_id,
            "challenge_id": challengeId
        ]
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.alert.showAlert(title: "No Good", messaage: "you did no good this challenge", viewController: self)
                self.goodFlg = 0
                self.goodButton.titleLabel?.text = "Like"
                self.goodButton.backgroundColor = UIColor.blue
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    @IBAction func tapCommentButton(_ sender: Any) {
        if (commentTextField.text != "") {
            comment()
        }
    }
    
    func comment() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        let url = URL(string: consts.baseUrl + "/challenges/" + challengeId + "/comments")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        let parameters: Parameters = [
            "user_id": user_id,
            "challenge_id": challengeId,
            "comment": commentTextField.text!
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.alert.showAlert(title: "Comment", messaage: "you did new comment this challenge", viewController: self)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
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

extension OtherDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row].comment
        return cell
    }
        
}

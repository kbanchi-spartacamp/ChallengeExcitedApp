//
//  ChallengeViewController.swift
//  ChallengeExcitedApp
//
//  Created by 伴地慶介 on 2021/11/19.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess
import PKHUD

class ChallengeViewController: UIViewController {

    let consts = Constants.shared
    let alert = Alert()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var challengeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleTextField.layer.cornerRadius = 10.0
        descriptionTextView.layer.cornerRadius = 10.0
        challengeButton.layer.cornerRadius = 10.0
        
    }
    
    @IBAction func tapChallengeButton(_ sender: Any) {
        postChallenge(title: titleTextField.text!, description: descriptionTextView.text!)
    }
    
    func postChallenge(title: String, description: String) {
        HUD.show(.progress)
        let keychain = Keychain(service: consts.service)
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        let url = URL(string: consts.baseUrl + "/challenges")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        let parameters: Parameters = [
            "user_id": user_id,
            "title": title,
            "description": description
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.alert.showAlert(title: "Create", messaage: "create challenge", viewController: self)
                self.clearTextField()
                HUD.hide()
            case .failure(let err):
                self.alert.showAlert(title: "Error", messaage: err.localizedDescription, viewController: self)
                print(err.localizedDescription)
            }
        }
    }
    
    func clearTextField() {
        titleTextField.text = ""
        descriptionTextView.text = ""
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

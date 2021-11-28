//
//  SettingTableViewController.swift
//  ChallengeExcitedApp
//
//  Created by 伴地慶介 on 2021/11/25.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess
import PKHUD

class SettingTableViewController: UITableViewController {

    let consts = Constants.shared
    var user: User!
    var user_avator: UserAvator!
    var avator_category: AvatorCategory!
    let alert = Alert()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var skillCategoryLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        setUserInfo()
        setSkillInfo()
        setVersionInfo()
        
    }
    
    func setUserInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        let url = URL(string: consts.baseUrl + "/user")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let user = User(
                    id: json["id"].int!,
                    name: json["name"].string!,
                    email: json["email"].string!,
                    profile_photo_url: json["profile_photo_url"].string!
                )
                self.user = user
                self.nameLabel.text = self.user.name
                self.emailLabel.text = self.user.email
                self.tableView.reloadData()
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    func setSkillInfo() {
        let keychain = Keychain(service: consts.service)
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        let url = URL(string: consts.baseUrl + "/user_avators?user_id=" + user_id)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let avator_category = AvatorCategory(
                    id: json["avator_category"]["id"].int!,
                    name: json["avator_category"]["name"].string!
                )
                let user_avator = UserAvator(
                    id: json["id"].int!,
                    user_id: json["user_id"].int!,
                    avator_category_id: json["avator_category_id"].int!,
                    level: json["level"].int!,
                    avator_category: avator_category
                )
                self.user_avator = user_avator
                self.avator_category = avator_category
                self.skillCategoryLabel.text = self.avator_category.name
                self.levelLabel.text = String(self.user_avator.level)
                self.tableView.reloadData()
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
                self.alert.showAlert(title: "ERROR", messaage: "an error occured", viewController: self)
            }
        }
    }
    
    func setVersionInfo() {
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

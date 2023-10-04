//
//  ConnectVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 08/09/2023.
//

import UIKit
import Starscream

class ConnectVC: UIViewController, ConnectTableViewCellDelegate, UITextFieldDelegate {

    //MARK: - Variables
    @IBOutlet weak var connectTableView: UITableView!
    @IBOutlet weak var chatView: GradientView!
    @IBOutlet weak var chatTextField: UITextField!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ConnectVC>()
    var connection: [Connection] = []

    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionAPICall()
        chatView.isHidden = true
        chatTextField.layer.cornerRadius = 5
        chatTextField.layer.borderWidth = 1.0
        chatTextField.layer.borderColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: - API Call
    func connectionAPICall() {
        let endPoint = APIConstants.Endpoints.connection
        let urlString = APIConstants.baseURL + endPoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=dca13b75c98d0a3adb35f00b8a053c47e285d746", forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                self.showAlert(title: "Alert", message: "No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(ConnectModel.self, from: data)
                self.connection = responseData.body.connection

                DispatchQueue.main.async {
                    self.connectTableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    //MARK: - Helper functions
    func chatImageViewTapped(in cell: ConnectTableViewCell) {
            chatView.isHidden = false
    }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    
    //MARK: - Actions
    @IBAction func chatCancelButton(_ sender: UIButton) {
        chatView.isHidden = true
    }
}

   //MARK: - Extension TableView
extension ConnectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connection.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConnectTableViewCell
//        cell.delegate = self
        let connection = connection[indexPath.row]
        cell.connectCellLabel?.text = connection.title
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatView.isHidden = true
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            vc.delegate = self
            vc.isProfileBackButtonHidden = false
            vc.isFollowButtonHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

  //MARK: - Extension ProfileDelegate
  extension ConnectVC: ProfileDelegate {
      
    func didTapUserProfileSettingButton() {
       if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
           if profileVC.userSettingStackView.isHidden {
              profileVC.userSettingStackView.isHidden = false
              profileVC.settingStackView.isHidden = true
           } else {
              profileVC.userSettingStackView.isHidden = true
              profileVC.settingStackView.isHidden = true
          }
       }
   }
}


//func numberOfSections(in tableView: UITableView) -> Int {
//    return 3
//}

//func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    return 8
//}
//func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    let footer = UIView()
//        footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
//    return footer
//}

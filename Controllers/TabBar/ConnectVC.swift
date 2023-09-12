//
//  ConnectVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 08/09/2023.
//

import UIKit

class ConnectVC: UIViewController, ConnectTableViewCellDelegate, UITextFieldDelegate {

    @IBOutlet weak var connectTableView: UITableView!
    @IBOutlet weak var chatView: GradientView!
    @IBOutlet weak var chatTextField: UITextField!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ConnectVC>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatView.isHidden = true
        chatTextField.layer.cornerRadius = 5
        chatTextField.layer.borderWidth = 1.0
        chatTextField.layer.borderColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.isHidden = true
    }
    func chatImageViewTapped(in cell: ConnectTableViewCell) {
            chatView.isHidden = false
        }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
        }
    @IBAction func chatCancelButton(_ sender: UIButton) {
        chatView.isHidden = true
    }
}

extension ConnectVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
            footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        return footer
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConnectTableViewCell
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatView.isHidden = true
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

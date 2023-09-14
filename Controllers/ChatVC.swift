//
//  ChatVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 14/09/2023.
//

import UIKit
import MessageKit

class ChatVC: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

    }
    
    @IBAction func chatBackButton(_ sender: UIButton) {
        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.selectedIndex = 3
            self.present(tabBarController, animated: false, completion: nil)
       }
    }
    
}

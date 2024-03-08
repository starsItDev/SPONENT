//
//  TabBarVC.swift
//  MakeupLaVie
//
//  Created by Apple on 14/07/2023.
//

class TabBarVC: UITabBarController {
    
   
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if homeTabBar.selectedItem?.title == "Connect" {
            if UserInfo.shared.isUserLoggedIn == false {
                if let loginNavController = storyboard?.instantiateViewController(withIdentifier: "LoginNavigationController") as? LoginNavigationController {
                    if let selectedVC = selectedViewController {
                        selectedVC.present(loginNavController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

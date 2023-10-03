////
////  ChatViewVC.swift
////  SPONENT
////
////  Created by Rao Ahmad on 14/09/2023.
////
//
//import UIKit
//
//class ChatViewVC: UIViewController {
//    
//
//    //MARK: - Override Function
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
//    }
//    
//    //MARK: - Actions
//    @IBAction func userProfileButton(_ sender: UIButton) {
//        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
////            vc.delegate = self
//            vc.isProfileBackButtonHidden = false
//            vc.isFollowButtonHidden = false
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    @IBAction func chatBackButton(_ sender: UIButton) {
//        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
//            tabBarController.modalPresentationStyle = .fullScreen
//            tabBarController.selectedIndex = 3
//            self.present(tabBarController, animated: false)
//         }
//     }
// }
//
//  //MARK: - Extension ProfileDelegate
//// extension ChatViewVC: ProfileDelegate {
////    func didTapUserProfileSettingButton() {
////        if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
////            if profileVC.userSettingStackView.isHidden {
////                profileVC.userSettingStackView.isHidden = false
////                profileVC.settingStackView.isHidden = true
////            } else {
////                profileVC.userSettingStackView.isHidden = true
////                profileVC.settingStackView.isHidden = true
////            }
////        }
////     }
//// }
////

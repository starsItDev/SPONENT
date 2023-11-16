//
//  RootViewController.swift
//  SPONENT
//
//  Created by Rao Ahmad on 15/11/2023.
//

import Foundation
import UIKit

func setRootViewController(storyboardName: String, VCIdentifier: String){
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    let homeViewController = storyboard.instantiateViewController(withIdentifier: VCIdentifier)
    appdelegate.window?.rootViewController = homeViewController
    appdelegate.window?.makeKeyAndVisible()
}

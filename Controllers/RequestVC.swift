//
//  RequestVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class RequestVC: UIViewController {
    
    //MARK: - Variables
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var pendingImage: UIButton!
    var isImageRotated = false
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Actions
    @IBAction func requestBackButton(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    @IBAction func pendingButton(_ sender: UIButton) {
        isImageRotated.toggle()
        if isImageRotated {
            pendingImage.rotate180Degrees()
            requestTableView.isHidden = true
        } else {
            pendingImage.transform = CGAffineTransform(rotationAngle: 0)
            requestTableView.isHidden = false
        }
    }
}

  //MARK: - TableView Extension
extension RequestVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        return footer
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
}

   //MARK: - UIView Extension
extension UIView {
    func rotate180Degrees(duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.transform = self.transform.rotated(by: CGFloat.pi)
        }
    }
}

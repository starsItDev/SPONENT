//
//  ActivityVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class ActivityVC: UIViewController {

    //MARK: - Variables
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var activitySegmentController: UISegmentedControl!

    @IBOutlet weak var lineView: UIView!
    //MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let whiteImage = UIImage(ciImage: .white)
        activitySegmentController.setBackgroundImage(whiteImage, for: .normal, barMetrics: .default)
       
        moveLineToSegment(0)

    }
    @IBAction func activitySegmentControl(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
              moveLineToSegment(selectedSegmentIndex)
    }
    func moveLineToSegment(_ segmentIndex: Int) {
        let segmentTitle = activitySegmentController.titleForSegment(at: segmentIndex) ?? ""
               
               // Calculate the width needed to cover the title
               let font = activitySegmentController.titleTextAttributes(for: .normal)?[NSAttributedString.Key.font] as? UIFont
               let titleWidth = (segmentTitle as NSString).size(withAttributes: [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 17)]).width
               
               // Calculate the line's new position and width
               let segmentWidth = activitySegmentController.frame.width / CGFloat(activitySegmentController.numberOfSegments)
               let lineCenterX = CGFloat(segmentIndex) * segmentWidth + segmentWidth / 2
               
               UIView.animate(withDuration: 0.2) {
                   self.lineView.center.x = lineCenterX
                   self.lineView.frame.size.width = titleWidth // Adjust the width
               }
           }
  
}

   //MARK: - Extension TableView
extension ActivityVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
//        footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        return footer
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
}

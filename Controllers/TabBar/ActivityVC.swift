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
    
    //MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        activitySegmentController.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentApiCall()
    }
    
    //MARK: - API CAllING
    func segmentApiCall() {
        let endPoint = APIConstants.Endpoints.activityMine
        let urlString = APIConstants.baseURL + endPoint
        guard let url = URL(string: urlString) else {
           showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        if let apikey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apikey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=7b88733d4b8336873c2371ae16760bf4ee9b5b9f", forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                    self.updateCounter(with: data)
                }
           }
               task.resume()
      }
    func updateCounter(with responseData: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let body = jsonObject["body"] as? [String: Any] {
                DispatchQueue.main.async {
                    let pendingRequests = body["pending"] as? Int ?? 0
                    let currentRequests = body["current"] as? Int ?? 0
                    let FollowedRequests = body["followed"] as? Int ?? 0
                    let pastRequests = body["past"] as? Int ?? 0
                    
                    self.activitySegmentController.setTitle("Pending(\(pendingRequests))", forSegmentAt: 0)
                    self.activitySegmentController.setTitle("Current(\(currentRequests))", forSegmentAt: 1)
                    self.activitySegmentController.setTitle("Following(\(FollowedRequests))", forSegmentAt: 2)
                    self.activitySegmentController.setTitle("Past(\(pastRequests))", forSegmentAt: 3)
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    //MARK: - Actions
    @IBAction func activitySegmentControl(_ sender: UISegmentedControl) {
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

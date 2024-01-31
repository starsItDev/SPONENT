import UIKit

class nagtiveCV: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title for the navigation bar
        self.title = "Your Title"

        // Add a back button to the navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-back-96"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        // Set the title font size
                if let navigationBar = self.navigationController?.navigationBar {
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0)
                    ]
                    navigationBar.titleTextAttributes = titleAttributes
                }
        // Add a button to the navigation bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }

    // Action for the back button tap
    @objc func backButtonTapped() {
        // Perform any action you want when the back button is tapped
        // For example, you can use self.navigationController?.popViewController(animated: true) to go back
        print("Back button tapped")
    }

    // Action for the add button tap
    @objc func addButtonTapped() {
        // Perform any action you want when the add button is tapped
        print("Add button tapped")
    }

    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

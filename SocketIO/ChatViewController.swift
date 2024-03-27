//
//  ChatViewController.swift
//  SPONENT
//
//  Created by StarsDev on 30/01/2024.
//
import Foundation
import UIKit
import Photos
import AVKit
import AVFoundation
import GSImageViewerController

class ChatViewController: UIViewController,SocketIOManagerDelegate, UITextFieldDelegate, ProfileDelegate{
    
    // MARK: - IBOutlet Properties
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var typingLbl: UILabel!
    @IBOutlet weak var imageSenderView: UIImageView!
    @IBOutlet weak var fixedProfileView: GradientView!
    
    // MARK: - Variable Properties
    let socketManager = SocketIOManager.sharedInstance
    var chatMessages: [ChatMessage] = []
    var accessToken = "2a5b7d1b0f6a4ff9341d60d1eb2cef12c7be12d00e9be368a6afb6f9a044c9cd83f58619323925141ce4fe042832e6bd7d06697a43055373"
    var userName = "raoahmad"
    var sendMessagetoID = "31136"
    //    var messageSenderName = "Ali Sher"
    var messageSenderName: String?
    var messageSenderImage: String?
    var receiverID: String?
    private var typingBubbleView: TypingBubbleView!
    var selectedFileURL: URL?
    var message: MessageModelBody?
    var selectedReceiverID: String?

    // MARK: - OverRide Func
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        socketManager.delegate = self
        messageTextField.delegate = self
        userNameLbl.text = messageSenderName
        addTapGestureToDismissKeyboard()
        socketManager.connectSocket()
        joinSocket()
        setupTypingBubbleView()
        if let imageUrl = messageSenderImage {
            loadImage(from: imageUrl) { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.imageSenderView.image = image
                }
            }
        }
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor.white
//            navigationBar.barTintColor = UIColor.red
//            navigationBar.backgroundColor = UIColor.init(named: "LoginPageTwo")
        }
        // Create a UILabel for the title
        let titleLabel = UILabel()
        titleLabel.text = messageSenderName
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        navigationItem.titleView = titleLabel

        let userImage = UIImage(systemName: "person.fill")
        let userImageView = UIImageView(image: userImage)
        userImageView.tintColor = UIColor.white

        userImageView.contentMode = .scaleAspectFit
        userImageView.clipsToBounds = true
        let rightBarButton = UIBarButtonItem(customView: userImageView)
        navigationItem.rightBarButtonItem = rightBarButton

        // Add a tap gesture to the user image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGesture)
    }

    @objc func addButtonTapped() {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            vc.delegate = self
            vc.showTabBar = false
            vc.isProfileBackButtonHidden = false
            vc.isFollowButtonHidden = false
            vc.receiverID = receiverID
            let selectedText = "Profile"
            vc.labelText = selectedText
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    // MARK: - SocketIOManagerOrAPI Func
    func joinSocket() {
        let recipientID = ""
        let userID = accessToken
        let messageID = ""
        socketManager.joinSocket(recipientID: recipientID, userID: userID, messageID: messageID) { success in
            if success {
                print("Join event sent successfully!")
            } else {
                print("Failed to send join event.")
            }
        }
    }
    func sendMediaMessageAPI() {
        guard let imageUrl = selectedFileURL else {
            print("Image URL is nil.")
            return
        }
        let url = URL(string: "https://social.untamedoutback.com.au/api/send-media-message")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        do {
            let imageData = try Data(contentsOf: imageUrl)
            body.append(imageData)
        } catch {
            print("Error converting image to Data: \(error)")
            return
        }
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        request.addValue("4041afa70851c6a3bdbe81dc032c3105d62c57a80e544de7cb69ec02a8c0aa7c218ccfc172444021bc05ca60f2f0d67d0525f41d1d8f8717", forHTTPHeaderField: "access-token")
        request.addValue("d4e8b720bc18f4a5151771982ab2a9195bd66323-f8150098d8df212f472329a755a6b628-56899340", forHTTPHeaderField: "server-key")
        request.addValue("_us=1705753409; ad-con=%7B%26quot%3Bdate%26quot%3B%3A%26quot%3B2024-01-19%26quot%3B%2C%26quot%3Bads%26quot%3B%3A%5B%5D%7D; PHPSESSID=6iljbg3hpahmdhtb9evvu8tf3t; access=1; mode=night", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let apiStatus = jsonResponse["api_status"] as? Int,
                       apiStatus == 200,
                       let responseData = jsonResponse["data"] as? [String: Any] {
                        if let filename = responseData["filename"] as? String,
                           let name = responseData["name"] as? String,
                           let size = responseData["size"] as? Int,
                           let duration = responseData["duration"] as? Int {
                            // Now you can use these values as needed
                            print("Filename: \(filename)")
                            print("Name: \(name)")
                            print("Size: \(size)")
                            print("Duration: \(duration)")
                            self.mediaMessagesOnSocket(filename: filename, name: name)
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
                print("Response: \(responseString)")
            }
        }
        task.resume()
    }
    func mediaMessagesOnSocket(filename: String, name: String) {
        let toID = sendMessagetoID
        let fromID = accessToken
        let username = userName
        let message = " "
        let color = "#056bba"
        let isSticker = false
        let messageReplyID = ""
        let media = "https://untamed-vod-v1-source71e471f1-o72av4ghlldb.s3.amazonaws.com/\(filename)"
        
        let mediaFileName = filename
        let mediaFileSize = 278851
        let duration = 0
        socketManager.sendPrivateMessage(
            withMedia: toID,
            fromID: fromID,
            username: username,
            message: message,
            color: color,
            isSticker: isSticker,
            messageReplyID: messageReplyID,
            media: media,
            mediaFileName: mediaFileName,
            mediaFileSize: mediaFileSize,
            duration: duration
        ) { success in
            if success {
                // Handle success
                print("Private message with media sent successfully!")
            } else {
                // Handle failure
                print("Failed to send private message with media.")
            }
        }
    }
    // MARK: - Custom Methods
    func textViewDidChange(_ textView: UITextView) {
        // Adjust the height of the text view dynamically
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: textView.frame.width, height: newSize.height)
        // Update other layout constraints if needed
    }
    func setupTypingBubbleView() {
        typingBubbleView = TypingBubbleView(frame: CGRect(x: 20, y: tableView.frame.maxY, width: 70, height: 32))
        // typingBubbleView = TypingBubbleView(frame: CGRect(x: 20, y: 565, width: 70, height: 32))
        view.addSubview(typingBubbleView)
        typingBubbleView.stopAnimating()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        socketManager.sendTypingEvent(recipientID: sendMessagetoID, userID: accessToken)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        socketManager.sendTypingDoneEvent(recipientID: sendMessagetoID, userID: accessToken)
        textField.resignFirstResponder()
        return true
    }
    func handleTypingEvent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.typingBubbleView.startAnimating()
            // Animate the typing label with a fade effect
            UIView.animate(withDuration: 0.9, animations: {
                self.typingLbl.alpha = 1.0
                self.typingLbl.text = "Typing..."
            }) { (_) in
                // Optional: You can add additional animation completion logic here
            }
        }
    }
    func handleTypingDoneEvent() {
        self.typingBubbleView.stopAnimating()
        self.typingLbl.text = ""
    }
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
    // MARK: - SocketIOManagerDelegate
    func addMessage(_ message: String, senderID: Int, receiverID: Int, time: String, mediaLink: String) {
        print(senderID)
        print(time)
        if let formattedTime = formatHTMLTime(htmlTime: time) {
            print("Formatted Time: \(formattedTime)")
            let chatMessage = ChatMessage(message: message, time: formattedTime, senderId: "\(senderID)" , messageType: .text)
            chatMessages.append(chatMessage)
        } else {
            print("Error formatting time")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    func formatHTMLTime(htmlTime: String) -> String? {
        // Extract the time string from the HTML
        guard let timeString = htmlTime.extractTimeFromHTML() else {
            let errorMessage = "Error formatting time. Failed to extract time from HTML. HTML Time: \(htmlTime)"
            print(errorMessage)
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedTime = dateFormatter.string(from: date)
            return formattedTime
        } else {
            let errorMessage = "Error formatting time. Failed to parse date. Time String: \(timeString)"
            print(errorMessage)
            return nil
        }
    }
    func addImages(_ images: String , senderID: Int) {
        print(images)
        loadImage(from: images) { (image) in
            if let image = image {
                let chatMessage = ChatMessage(message: "", time: "", senderId: "\(senderID)", messageType: .image, image: image)
                self.chatMessages.append(chatMessage)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    func sendImageFunction(image: UIImage, imageUrl: URL?){
        self.selectedFileURL = imageUrl
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let currentTimeString = dateFormatter.string(from: currentDate)
        let chatMessage = ChatMessage(message: "", time: currentTimeString, senderId: "", messageType: .image, image: image)
        chatMessages.append(chatMessage)
        print(image)
        if let imageUrl = imageUrl {
            print("Image URL: \(imageUrl)")
        } else {
            print("Image URL is nil.")
        }
        tableView.reloadData()
        let indexPath = IndexPath(row: chatMessages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    // MARK: - IBAction Methods
    @IBAction private func sendButtonTapped(_ sender: Any) {
        if socketManager.isSocketConnected {
            if let messageText = messageTextField.text, !messageText.isEmpty {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let currentTimeString = dateFormatter.string(from: currentDate)
                socketManager.sendPrivateMessage(
                    toID: sendMessagetoID,
                    fromID: accessToken,
                    username: userName,
                    message: messageText,
                    color: "#056bba",
                    isSticker: false,
                    messageReplyID: ""
                ){ success in
                    if success {
                        print("Private message sent successfully!")
                    } else {
                        print("Failed to send private message.")
                    }
                }
                socketManager.sendTypingDoneEvent(recipientID: sendMessagetoID, userID: accessToken)
                let chatMessage = ChatMessage(message: messageText, time: currentTimeString, senderId: "")
                chatMessages.append(chatMessage)
                tableView.reloadData()
                let indexPath = IndexPath(row: chatMessages.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                messageTextField.resignFirstResponder()
                messageTextField.text = ""
            } else {
                print("Message text is empty.")
            }
        } else {
            print("Socket is not connected.")
        }
    }
    @IBAction func backBtn(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    @IBAction func imageBtn(_ sender: UIButton) {
        let imagePickerAlert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imagePickerAlert.addAction(galleryAction)
        imagePickerAlert.addAction(cameraAction)
        imagePickerAlert.addAction(cancelAction)
        if let popoverController = imagePickerAlert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        present(imagePickerAlert, animated: true, completion: nil)
    }
    @IBAction func profileBtn(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
//            self.tabBarController?.tabBar.isHidden = true
            vc.showTabBar = false
            vc.delegate = self
            vc.isProfileBackButtonHidden = false
            vc.isFollowButtonHidden = false
            vc.receiverID = receiverID
            let selectedText = "Profile"
            vc.labelText = selectedText
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - Extension Table View
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = chatMessages[indexPath.row]
        var cell: UITableViewCell
        if chatMessage.messageType == .text {
            if chatMessage.senderId == sendMessagetoID {
                let senderCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
                senderCell.messageLabel.text = chatMessage.message
                senderCell.timeLabel.text = chatMessage.time
                senderCell.messageLabel.numberOfLines = 0
                senderCell.layer.borderWidth = 2
                senderCell.layer.cornerRadius = 22
                senderCell.layer.masksToBounds = true
                if let borderColor = UIColor(named: "ControllerViews") {
                    senderCell.layer.borderColor = borderColor.cgColor
                }
                if let labelColor = UIColor(named: "Black-White") {
                    senderCell.messageLabel.textColor = labelColor
                    senderCell.timeLabel.textColor = labelColor
                }
                senderCell.messageLabel.textAlignment = .left
                if let imageUrl = messageSenderImage {
                    loadImage(from: imageUrl) { [weak self] (image) in
                        DispatchQueue.main.async {
                            senderCell.imageSender.image = image
                        }
                    }
                }
                cell = senderCell
            } else {
                let otherCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell2", for: indexPath) as! MessageCell2
                otherCell.massageLabel2.text = chatMessage.message
                otherCell.timeLabel2.text = chatMessage.time
                otherCell.layer.borderWidth = 4
                otherCell.layer.cornerRadius = 22
                otherCell.layer.masksToBounds = true
                if let borderColor = UIColor(named: "ControllerViews") {
                    otherCell.layer.borderColor = borderColor.cgColor
                }
                if let labelColor = UIColor(named: "Black-White") {
                    otherCell.massageLabel2.textColor = labelColor
                    otherCell.timeLabel2.textColor = labelColor
                }
                otherCell.massageLabel2.textAlignment = .right
                otherCell.massageLabel2.numberOfLines = 0
                cell = otherCell
            }
        } else if chatMessage.messageType == .image {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCellTV", for: indexPath) as! ImageCellTV
            imageCell.imgView.image = chatMessage.image
            imageCell.imageBtnTap.addTarget(self, action: #selector(imgBtnTapped(sender:)), for: .touchUpInside)
            imageCell.imageBtnTap.tag = indexPath.row
            imageCell.layer.borderWidth = 4
            imageCell.layer.masksToBounds = true
            if let borderColor = UIColor(named: "ControllerViews") {
                imageCell.layer.borderColor = borderColor.cgColor
            }
            if chatMessage.senderId == sendMessagetoID {
                print("left side")
                imageCell.viewUIView.backgroundColor = #colorLiteral(red: 0.999405086, green: 0.6648295522, blue: 0.3512707949, alpha: 1)
                imageCell.leadingConstraint.constant = 42
                imageCell.trailingConstraint.constant = 110
            } else {
                imageCell.viewUIView.backgroundColor = #colorLiteral(red: 0.7954370379, green: 0.9536443353, blue: 0.9464041591, alpha: 1)
                imageCell.leadingConstraint.constant = 80
                imageCell.trailingConstraint.constant = 5
                print("Right side")
            }
            cell = imageCell
        }else {
            // Handle other message types if needed
            cell = UITableViewCell()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // Handle delete action here
               chatMessages.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)

               // You may also want to delete the corresponding data from your backend or perform any other necessary actions.
           }
       }
}
// MARK: - Extension for Image Handling
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Image Picker Methods
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        //        imagePicker.mediaTypes = ["public.image", "public.movie"]
        if sourceType == .camera {
            imagePicker.cameraCaptureMode = .photo
        }
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let imageUrl = info[.imageURL] as? URL {
                // Image picked from the gallery
                sendImageFunction(image: pickedImage, imageUrl: imageUrl)
                sendMediaMessageAPI()
            } else {
                // Image picked from the camera
                if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                    let cameraImageUrl = saveImageLocally(imageData: imageData)
                    sendImageFunction(image: pickedImage, imageUrl: cameraImageUrl)
                    sendMediaMessageAPI()
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK: - Image Handling Methods
    func handleSelectedImage(asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
            if let image = image {
                // Retrieve the image URL separately
                PHImageManager.default().requestImageData(for: asset, options: nil) { (data, _, _, _) in
                    if let imageData = data {
                        let imageUrl = self.saveImageLocally(imageData: imageData)
                        // Assuming you have a function to send a single image
                        self.sendImageFunction(image: image, imageUrl: imageUrl)
                    }
                }
            }
        })
    }
    
    func saveImageLocally(imageData: Data) -> URL? {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // MARK: - Image Button Tap
    @objc func imgBtnTapped(sender: UIButton) {
        guard let index = sender.tag as? Int, index < chatMessages.count else {
            return
        }
        let chatMessage = chatMessages[index]
        if let image = chatMessage.image {
            let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: sender)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            imageViewer.dismissCompletion = {
                // Optional: Add any completion logic after image viewer dismissal
            }
            present(imageViewer, animated: true, completion: nil)
        } else {
            print("Image is nil for the selected chat message.")
            // Handle the case where the image is nil, perhaps show an alert or log a message.
        }
    }
}

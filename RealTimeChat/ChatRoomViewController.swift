//
//  ChatRoomViewController.swift
//  RealTimeChat
//
//  Created by Solji Kim on 13/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class ChatRoomViewController: UIViewController {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var scrollDownBtn: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    var chatMessages = [Messages]()
    var room: Room?
    let noti = NotificationCenter.default
    
    let notiManager = UNNotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = room?.roomName
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        chatTextView.delegate = self
//        chatTextView.text = "텍스트를 입력하세요..."
//        chatTextView.textColor = .lightGray
        chatTextView.autocorrectionType = .no
        chatTextView.layer.borderWidth = 0.5
        chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        chatTextView.layer.cornerRadius = 5
        chatTextView.isScrollEnabled = false // 입력할때마다 텍스트들이 위로 올라가면서 윗부분이 잘리는것을 막기위해서
        
        textViewDidChange(chatTextView)
        
        scrollDownBtn.isHidden = true
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
//        view.bringSubviewToFront(scrollDownBtn)
        
        observeMessages()
        addNotificationObserver()
    }
    
    func addNotificationObserver() {
        noti.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        noti.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func didReceiveKeyboardNotification(_ sender: Notification) {
        
        guard let userInfo = sender.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }
        
        
        let floatingTextFieldConst = chatStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height)
        floatingTextFieldConst.priority = .defaultLow
        floatingTextFieldConst.isActive = true
        
        let downTextFieldConst = chatStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        downTextFieldConst.priority = .defaultLow
        downTextFieldConst.isActive = true
        
        let keyboardHeightWithoutSafeInset = keyboardFrame.height - self.view.safeAreaInsets.bottom
        
        if keyboardFrame.minY >= self.view.frame.maxY {  // 키보드 내려갈때

            UIView.animate(withDuration: duration) {
                downTextFieldConst.priority = .defaultHigh  // 테이블뷰가 원래 크기로 커짐
            }
            self.chatTableView.contentOffset.y -= keyboardHeightWithoutSafeInset
            self.view.layoutIfNeeded()

        } else {    // 키보드가 올라올때
            
            UIView.animate(withDuration: duration) {
                floatingTextFieldConst.priority = .defaultHigh  // 테이블뷰가 작아짐
            }
            self.view.layoutIfNeeded()
            
            if chatTableView.contentSize.height >= chatTableView.frame.height {
                self.chatTableView.contentOffset.y += keyboardHeightWithoutSafeInset
            }
        }
    }
    
    @objc func hideKeyboard(_ sender: Any) {
//        view.endEditing(true)
        chatTextView.resignFirstResponder()
    }
    
    
    func observeMessages() {
        
        guard let roomId = room?.roomId else { return }
        
        let dbRef = Database.database().reference()
        
        dbRef.child("rooms").child(roomId).child("messages").observe(.childAdded) { (snapshot) in
            print("***** [ observeMessages ] ***** :", snapshot)
            
            if let dataArray = snapshot.value as? [String : Any] {
                
                guard let senderName = dataArray["senderName"] as? String,
                    let messageText = dataArray["text"] as? String,
                    let userId = dataArray["senderId"] as? String
                    else { return }
                
                let message = Messages(messageKey: snapshot.key, senderName: senderName, messageText: messageText, userId: userId)
                
                self.chatMessages.append(message)
                self.chatTableView.reloadData()
                
                // scroll down to the very bottom page when we get any msg while checking the previous msg
                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                
                let notificationTitle = message.senderName ?? ""
                let notificationMessage = message.messageText ?? ""
                
                self.notiManager.triggerMsgNotification(with: notificationTitle, msg: notificationMessage)
            }
        }
    }
    
    func getUsernameWithId(id: String, completion: @escaping (_ userName: String?) -> () ) {
        
        let dbRef = Database.database().reference()
        let user = dbRef.child("users").child(id)
        
        user.child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let userName = snapshot.value as? String {
                completion(userName)
            } else {
                completion(nil)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping (_ isSuccess: Bool) -> () ) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let dbRef = Database.database().reference()
        
        getUsernameWithId(id: userId) { (userName) in
            if let userName = userName {
//                print("username is \(userName)")
                if let roomId = self.room?.roomId {
                    
                    let dataArray: [String : Any] = ["senderName" : userName, "text" : text,
                                                     "senderId" : userId]
                    
                    let room = dbRef.child("rooms").child(roomId)
                    
                    room.child("messages").childByAutoId().setValue(dataArray, withCompletionBlock:
                        
                        { (error, ref) in
                            if error == nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                    })
                }
            }
        }
    }
    
    @IBAction func didPressSendButton(_ sender: UIButton) {
        
        guard let chatText = chatTextView.text, !chatText.isEmpty else { return }
        
        sendMessage(text: chatText) { (isSuccess) in
            if isSuccess {
                self.chatTextView.text = ""
                print("message sent")
                
                self.textViewDidChange(self.chatTextView)
            }
        }
    }
    
    @IBAction func didTapScrollDownBtn(_ sender: Any) {
        
        guard chatMessages.count > 0 else { return }
        
        self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "사진찍기", style: .default) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            self.imagePickerController.sourceType = .camera
            self.imagePickerController.mediaTypes = [kUTTypeImage as String]
            self.present(self.imagePickerController, animated: true)
        }
        
        let galleryAction = UIAlertAction(title: "사진 불러오기", style: .default) { _ in
            self.imagePickerController.sourceType = .savedPhotosAlbum
            self.present(self.imagePickerController, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)

    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let message = chatMessages[indexPath.row]
        
        cell.setMessageData(message: message)
       
        if message.userId == Auth.auth().currentUser!.uid {
            cell.setBubbleType(type: .outgoing)
        } else {
            cell.setBubbleType(type: .incoming)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("1", scrollView.contentOffset)
//        print("ContentSize :", scrollView.contentSize)
//        print("2", scrollView.contentLayoutGuide)
//        print("3", scrollView.contentInset)
//        print("4", scrollView.frame.size)

        let lastPageOffset = scrollView.contentSize.height - chatTableView.frame.height
        
        scrollView.contentOffset.y < lastPageOffset - 100
            ? (scrollDownBtn.isHidden = false) : (scrollDownBtn.isHidden = true)
    }
}

// MARK: - UITextViewDelegate

extension ChatRoomViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        print("TextViewDidChange : ", textView.text)

        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }

//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        let currentText: String = textView.text
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
//
//        print("currentText :", currentText)
//        print("updatedText :", updatedText)
//
//        // If updated text view will be empty, add the placeholder
//        // and set the cursor to the beginning of the text view
//        if updatedText.isEmpty {
//
//            textView.text = "텍스트를 입력하세요..."
//            textView.textColor = UIColor.lightGray
//
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//        }
//            // Else if the text view's placeholder is showing and the
//            // length of the replacement string is greater than 0, set
//            // the text color to black then set its text to the
//            // replacement string
//        else if textView.textColor == UIColor.lightGray, !text.isEmpty {
//            textView.textColor = UIColor.black
//            textView.text = text
//
//        }else {
//            return true
//        }
//        return false
//    }

    // to prevent the user from changing the position of the cursor while the placeholder's visible.
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
//    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var testImage: UIImage?
        
        let mediaType = info[.mediaType] as! NSString
        
        if UTTypeEqual(mediaType, kUTTypeImage) {
            
            let originalImage = info[.originalImage] as! UIImage
            let editedImage = info[.editedImage] as? UIImage
            let selectedImage = editedImage ?? originalImage

            picker.dismiss(animated: true)
        }
        
        func uploadImageToFirebaseStorage() {
            
        }
    }
}

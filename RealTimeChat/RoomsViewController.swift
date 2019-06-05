//
//  RoomsViewController.swift
//  RealTimeChat
//
//  Created by Solji Kim on 12/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UIViewController {
    
    @IBOutlet weak var roomsTable: UITableView!
    @IBOutlet weak var newRoomTextField: UITextField!
    
    var rooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomsTable.delegate = self
        roomsTable.dataSource = self
        
        newRoomTextField.autocorrectionType = .no
        
        observeRooms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            presentLoginScreen()
        }
    }
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        presentLoginScreen()
    }
    
    func presentLoginScreen() {
        let formScreen = storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! ViewController
        present(formScreen, animated: true)
    }
    
    func  observeRooms() {
        let dbRef = Database.database().reference()
        
        dbRef.child("rooms").observe(.childAdded) { (snapshot) in
//            print("***** [ snapshot ] ***** :", snapshot)
//            print("***** [ snapshot.value ] ***** :", snapshot.value)
            
            if let dataArray = snapshot.value as? [String : Any] {
//                print("***** [ dataArray ] ***** :", dataArray["roomName"])
                
                if let roomName = dataArray["roomName"] as? String {
                    let room = Room(roomName: roomName, roomId: snapshot.key)
                    self.rooms.append(room)
                    self.roomsTable.reloadData()
                }
            }
        }
    }
    
    @IBAction func didPressCreateNewRoom(_ sender: UIButton) {
        
        guard let roomName = newRoomTextField.text, !roomName.isEmpty else {
            makeAlert(title: "Message", message: "채팅방의 이름을 입력해주세요.")
            return
        }
        
        let dbRef = Database.database().reference()
        
        let room = dbRef.child("rooms").childByAutoId()
        let dataArray: [String: Any] = ["roomName": roomName]
        room.setValue(dataArray) { (error, ref) in
            if error == nil {
                self.newRoomTextField.text = ""
            }
        }
    }

    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in }
        //        let action2 = UIAlertAction(title: “Cancel”, style: .cancel, handler: nil)
        
        alert.addAction(action1);
        present(alert, animated: true)
    }
    
    @IBAction func didEndOnExit(_ sender: UITextField) {}
}

// MARK - UITableViewDataSource, UITableViewDelegate

extension RoomsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        let room = rooms[indexPath.row]
        cell.textLabel?.text = room.roomName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomVC = storyboard?.instantiateViewController(withIdentifier: "chatRoom") as! ChatRoomViewController
        chatRoomVC.room = rooms[indexPath.row]
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
}

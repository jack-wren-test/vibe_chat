//
//  ViewController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

protocol HomeDelegate {
    func updateUserData(data: User)
    func updateChatters(chatters: [User])
    func performLogOut()
}

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var newChatButton: UIButton!
    
    
    // MARK:- Properties
    
    var authenticationNeeded: Bool = true
    var user: User?
    var chatters = [User]()
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if authenticationNeeded {
            presentAuthenticationScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK:- TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatters.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChatterCellTableViewCell
        cell.user = chatters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MessagesSegue", sender: self)
    }
    
    // MARK:- Methods
    
    fileprivate func presentAuthenticationScreen() {
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
        chatters = []
        user = nil
        tableView.reloadData()
        authenticationNeeded = !authenticationNeeded
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AuthenticateSegue" {
            if let vc = segue.destination as? AuthenticationController {
                vc.homeDelegate = self
            }
        }
        if segue.identifier == "ProfileSegue" {
            if let vc = segue.destination as? ProfileController {
                vc.user = user
                vc.homeDelegate = self
            }
        } else if segue.identifier == "MessagesSegue" {
            if let vc = segue.destination as? MessagesController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    vc.user = user
                    vc.chatter = self.chatters[indexPath.row]
                }
            }
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ProfileSegue", sender: self)
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIButton) {
        print("New chat button pressed!")
    }
    
    
}

extension HomeController: HomeDelegate {
    func updateChatters(chatters: [User]) {
        self.chatters = chatters
    }
    func updateUserData(data: User) {
        self.user = data
    }
    func performLogOut() {
        AuthenticationManager.shared.logOut {
            self.presentAuthenticationScreen()
        }
    }
}

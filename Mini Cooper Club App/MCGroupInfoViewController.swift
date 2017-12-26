//
//  MCGroupInfoViewController.swift
//  Mini Cooper Club App
//
//  Created by Олег Минков on 12.09.16.
//  Copyright © 2016 Oleg Minkov. All rights reserved.
//

import UIKit

class MCGroupInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var appDelegate:AppDelegate = AppDelegate()
    var groupID = String()
    var groupName = String()
    var myID = String()
    var adminID = String()
    var participants = [(name: String, detail:String, id:String)]()
    let group:DispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "back_arrow@2x.png"), for: .normal)
        button.addTarget(self, action: #selector(MCMessageViewController.returnToChats), for: .touchUpInside)
        button.frame = CGRect(x: 10, y: 22, width: 13, height: 22)
        let newBackButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.participants = []
        self.send_request_chat_group(self.groupID)
        
        self.group.notify(queue: DispatchQueue.main, execute: {
            
            if self.isAmIAdmin() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MCGroupInfoViewController.addNewParpicipants))
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(colorLiteralRed: 43/255, green: 184/255, blue: 231/255, alpha: 1)
            }
            
            self.groupNameLabel.text = self.groupName
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Информация о группе"
    }
    
    @IBAction func exitGroup(_ sender: AnyObject) {
    
        let alertController = UIAlertController(title: "Выйти из '" + self.groupName + "' ?", message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Покинуть группу", style: .destructive, handler: { (UIAlertAction) in
            
            let postString = "&id=" + self.groupID + "&act=chat_group_exit"
            self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupExit) in
            
                let error = Error()
                if !error.exist(responseFromActionChatGroupExit) {
                
                    var index = 0
                    for i in 0..<self.participants.count {
                        let participantID = self.participants[i].id
                        if self.myID == participantID {
                            index = i
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.participants.remove(at: index)
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("MCGroupInfoViewController | exitGroup | " + error.getDesc())
                    
                    if error.getDesc() == "Пользователь не авторизован \n" {
                        self.appDelegate.goToSignInViewController(currentViewController: self)
                    }
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }

        cell!.textLabel?.text = participants[(indexPath as NSIndexPath).row].name
        cell!.detailTextLabel?.text = participants[(indexPath as NSIndexPath).row].detail
        cell!.detailTextLabel?.textColor = UIColor.red
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if isAmIAdmin() {
            if self.participants[(indexPath as NSIndexPath).row].detail != "Админ группы" {
                self.showAlertControlerWithIndex((indexPath as NSIndexPath).row)
            }
        }
    }
    
    func send_request_chat_group(_ id: String) {
        
        self.group.enter()
        
        let postString = "&id=" + id + "&act=chat_group"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroup) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroup) {
                
                let group = responseFromActionChatGroup["group"] as! NSDictionary
                let allUsers = group["u"] as! [Int]
                let res = group["res"] as! NSDictionary
                self.myID = String(responseFromActionChatGroup["id"] as! Int)
                self.groupName = res["name"] as! String
                self.adminID = String(res["idUser"] as! Int)
                
                for user in allUsers {
                    
                    let postString = "&id_list=" + String(describing: user) + "&act=user_get"
                    self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionUserGet) in
                        
                        let error = Error()
                        if !error.exist(responseFromActionUserGet) {
                            
                            let users = responseFromActionUserGet["u"] as! [NSDictionary]
                            self.participants.append(self.getCorrectName(users.last!))
                            
                            if user == allUsers.last {
                                self.group.leave()
                            }
                            
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
                            
                        } else {
                            print("MCGroupInfoViewController | send_request_chat_group(userGet) | " + error.getDesc())
                            
                            if error.getDesc() == "Пользователь не авторизован \n" {
                                self.appDelegate.goToSignInViewController(currentViewController: self)
                            }
                        }
                        
                        
                    })
                }
                
            } else {
                print("MCGroupInfoViewController | send_request_chat_group | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func getCorrectName(_ user: NSDictionary) -> (String, String, String) {
        
        var correctName = (user["car_number"] as! String).lowercased()
        if user["nickname"] as! String != "" {
            correctName = correctName + "\u{2022}" + (user["nickname"] as! String)
        } else if user["name"] as! String != "" {
            correctName = correctName + "\u{2022}" + (user["name"] as! String)
        }
        
        return self.currectTuple(user["id"] as! String, name: correctName)
    }
    
    func currectTuple(_ id: String, name: String) -> (String, String, String) {
        
        var correctItem = ("", "", "")
        if id == self.adminID {
            correctItem = (name, "Админ группы", id)
        } else { correctItem = (name, "", id) }
        
        return correctItem
    }
    
    func removeParticipantWithIndex(_ index: Int) {
        
        let postString = "&group=" + self.groupID + "&id_list=" + self.participants[index].id + "&act=chat_group_drop"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGrouupDrop) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGrouupDrop) {
            
                DispatchQueue.main.async {
                    self.participants.remove(at: index)
                    self.tableView.reloadData()
                }
                
            } else {
                print("MCGroupInfoViewController | removeParticipantWithIndex | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func showAlertControlerWithIndex(_ index: Int) {
        
        let alertController = UIAlertController(title: "Удалить " + self.participants[index].name + " ?", message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Удалить", style: .destructive, handler: { (UIAlertAction) in
            self.removeParticipantWithIndex(index)
        })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func addNewParpicipants() {
        self.performSegue(withIdentifier: "toMCAddParticipantsViewController", sender: self)
    }
    
    func isAmIAdmin() -> Bool{
        
        for currentParticipant in self.participants {
            
            if currentParticipant.id == self.myID  && currentParticipant.detail == "Админ группы" {
                return true
            }
        }
        
        return false
    }
    
    func returnToChats() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? MCAddParticipantsViewController {
            
            var participantsName = [String]()
            for currentParticipant in self.participants {
                participantsName.append(currentParticipant.name)
            }
            
            viewController.alreadyExistParticipants = participantsName
            viewController.groupID = self.groupID
        }
    }

}

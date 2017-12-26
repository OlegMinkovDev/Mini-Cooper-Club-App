import UIKit

extension MCAddParticipantsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class MCAddParticipantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addCreateB: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate:AppDelegate = AppDelegate()
    var filteredContacts = [Chat]()
    var contacts:[String] = []
    var chats:[Chat] = []
    var index = Int()
    var alreadyExistParticipants:[String]? = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var subjectGroup = ""
    var groupID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.send_request_all()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.alreadyExistParticipants?.count == 0 {
            self.addCreateB.setTitle("Создать", for: .normal)
        } else {
            self.addCreateB.setTitle("Добавить", for: .normal)
        }
    }

    @IBAction func back(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCreate(_ sender: AnyObject) {
        
        if self.alreadyExistParticipants?.count == 0 {
            self.create()
        } else { self.add() }
    }
    
    func create() {
        
        let ids = self.getCorrectIDList()
        
        let postString = "&name=" + self.subjectGroup + "&id_list=" + ids + "&act=chat_group_create"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupCreate) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupCreate) {
                
                UserDefaults.standard.set(true, forKey: "isNewGroup")
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! MCNavigationController
                
                DispatchQueue.main.async(execute: {
                    // Dismiss the search tableview
                    self.searchController.dismiss(animated: true, completion: nil)
                    self.searchController.view.removeFromSuperview()
                    
                    self.present(controller, animated: false, completion: nil)
                })

                
            } else {
                print("MCAddParticipant | create | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func add() {
        
        let ids = self.getCorrectIDList()
        
        let postString = "&group=" + self.groupID + "&id_list=" + ids + "&act=chat_group_add"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupAdd) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupAdd) {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("MCAddParticipant | add | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func getCorrectIDList() -> String {
        
        var ids = ""
        
        let indexPaths = self.tableView.indexPathsForSelectedRows
        for indexPath in indexPaths! {
            
            if ids != "" {
                ids += ","
            }
            
            var chat = Chat()
            if searchController.isActive && searchController.searchBar.text != "" {
                chat = self.filteredContacts[(indexPath as NSIndexPath).row]
            } else {
                chat = self.chats[(indexPath as NSIndexPath).row]
            }
            
            ids += chat.identifier()
        }
        
        return ids
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        let contact: String
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filteredContacts[(indexPath as NSIndexPath).row].contact.name
        } else {
            contact = contacts[(indexPath as NSIndexPath).row]
        }
        cell!.textLabel?.text = contact
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.tableView.indexPathsForSelectedRows!.count > 0 {
            self.addCreateB.isEnabled = true
        } else { self.addCreateB.isEnabled = false }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    
        if self.tableView.indexPathsForSelectedRows != nil {
            self.addCreateB.isEnabled = true
        } else { self.addCreateB.isEnabled = false }
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = self.chats.filter { chat in
            return chat.contact.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func send_request_all() {
        
        let postString = "&act=all"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionAll) in
            
            let error = Error()
            if !error.exist(responseFromActionAll) {
                
                let allUserFromServer = (responseFromActionAll["u"] as? [NSDictionary])!
                for currentUser in allUserFromServer {
                    
                    if self.isItMyCar(user: currentUser) == false {
                        
                        var flag = false
                        for participantName in self.alreadyExistParticipants! {
                            
                            if participantName == self.getCorrectName(user: currentUser) {
                                flag = true
                            }
                        }
                        
                        if flag == false {
                            self.createChatWithName(name: self.getCorrectName(user: currentUser), id: currentUser["id"] as! String)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            } else {
                print("MCAddParticipant | send_request_all | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func isItMyCar(user: NSDictionary) -> Bool {
        
        if (user["car_number"] as! String).lowercased() == self.appDelegate.car_namber.lowercased() {
            return true
        }
        
        return false
    }
    
    func getCorrectName(user: NSDictionary) -> String {
        
        var correctName = (user["car_number"] as? String)!.lowercased()
        if user["nickname"] as? String != "" {
            correctName = correctName + "\u{2022}" + (user["nickname"] as? String)!
        } else if user["name"] as? String != "" {
            correctName = correctName + "\u{2022}" + (user["name"] as? String)!
        }
        
        return correctName
    }
    
    func createChatWithName(name: String, id: String) {
        
        let contact = Contact()
        contact.name = name.lowercased()
        contact.identifier = id
        
        let chat = Chat()
        chat.contact = contact
        
        self.contacts.append(contact.name.lowercased())
        self.chats.append(chat)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

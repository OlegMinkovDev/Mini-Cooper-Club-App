import UIKit

extension MCNewChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class MCNewChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate:AppDelegate = AppDelegate()
    var filteredContacts = [Chat]()
    var chats:[Chat] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
            
        let postString = "&act=all"
        
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionAll) in
            
            let error = Error()
            if !error.exist(responseFromActionAll) {
                
                let u:NSArray = (responseFromActionAll["u"] as? NSArray)!
                
                for item in u {
                    
                    let dict = item as! NSDictionary
                    
                    if (dict["car_number"] as! String).lowercased() != self.appDelegate.car_namber.lowercased() {
                        
                        let contact = Contact()
                        contact.name = (dict["car_number"] as? String)!.lowercased()
                        
                        if dict["nickname"] as? String != "" {
                            contact.name = contact.name + "\u{2022}" + (dict["nickname"] as? String)!
                        } else if dict["name"] as? String != "" {
                            contact.name = contact.name + "\u{2022}" + (dict["name"] as? String)!
                        }
                        
                        contact.identifier = (dict["id"] as? String)!
                        
                        let chat = Chat()
                        chat.contact = contact
                        
                        self.chats.append(chat)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            } else {
                print("MCNewChatViewController | viewDidLoad | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    @IBAction func Cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        return self.chats.count
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
            contact = self.chats[(indexPath as NSIndexPath).row].contact.name
        }
        cell!.textLabel?.text = contact
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(true, forKey: "isNewChat")
        UserDefaults.standard.set(true, forKey: "isSaveOldCoordinatesAndZoom")
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! MCNavigationController
        let mcTabBarContrller = controller.topViewController as? MCTabBarController
        
        if searchController.isActive && searchController.searchBar.text != "" {
            mcTabBarContrller!.chat = filteredContacts[(indexPath as NSIndexPath).row]
        } else {
            mcTabBarContrller!.chat = self.chats[(indexPath as NSIndexPath).row]
        }
        mcTabBarContrller?.user = nil
        
        // Dismiss the search tableview
        searchController.dismiss(animated: true, completion: nil)
        searchController.view.removeFromSuperview()
        
        let mcMapViewController = mcTabBarContrller?.viewControllers![0] as! MCMapViewController
        mcMapViewController.dismiss(animated: true, completion: nil)

        DispatchQueue.main.async {
            self.present(controller, animated: false, completion: nil)
        }
}
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = self.chats.filter { chat in
            return chat.contact.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if let viewController = segue.destinationViewController as? MCNavigationController {
            viewController.isNewChat = true
        }
    }
    */
}

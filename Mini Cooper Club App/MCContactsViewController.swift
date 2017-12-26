import UIKit

extension MCContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class MCContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate:AppDelegate = AppDelegate()
    
    var filteredContacts = [NSDictionary]()
    var allContacts = [NSDictionary]()
    var currentContact = NSDictionary()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Контакты"
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.send_request_all()
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
        return self.allContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        var contact = ""
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = self.filteredContacts[(indexPath as NSIndexPath).row]["car_number"] as! String
        } else {
            contact = self.allContacts[(indexPath as NSIndexPath).row]["car_number"] as! String
        }
        cell!.textLabel?.text = contact
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            self.currentContact = self.filteredContacts[(indexPath as NSIndexPath).row]
        } else {
            self.currentContact = self.allContacts[(indexPath as NSIndexPath).row]
        }
        
        self.performSegue(withIdentifier: "toMCContactDetailViewController", sender: self)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredContacts = self.allContacts.filter { contact in
            return (contact["car_number"] as! String).lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func send_request_all() {
        
        self.allContacts = []
        self.appDelegate.sendPostRequest("&act=all", completionHandler: { (responseFromActionAll) in
            
            let error = Error()
            if !error.exist(responseFromActionAll) {
                
                let u:NSArray = (responseFromActionAll["u"] as? [NSDictionary])! as NSArray
                
                for item in u {
                    
                    let dict = item as! NSDictionary
                    
                    var name = ""
                    if dict["nickname"] as? String != "" {
                        name = name + "\u{2022}" + (dict["nickname"] as? String)!
                    }
                    if dict["name"] as? String != "" {
                        name = name + "\u{2022}" + (dict["name"] as? String)!
                    }
                    
                    let contact: NSDictionary = [
                        "car_number" : (dict["car_number"] as! String).lowercased() + name,
                        "name" : (dict["name"] as? String)!,
                        "nickname" : (dict["nickname"] as! String),
                        "id" : (dict["id"] as? String)!,
                        ]
                    
                    self.allContacts.append(contact)
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            } else {
                print("MCContactViewController | viewDidLoad | " + error.getDesc())
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? MCContactDetailViewController {
            viewController.contact = self.currentContact
        }
        
    }
}

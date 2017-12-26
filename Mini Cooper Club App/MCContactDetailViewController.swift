import UIKit

class MCContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var goToChatButton: UIButton!
    
    var contact = NSDictionary()
    var tableData = [String]()
    var name = ""
    var nickname = ""
    
    var appDelegate:AppDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isUserInteractionEnabled = false
        
        self.parseContactAndAddToTableData()
        self.setTableViewHeight()
        
        if self.isMyNumber(contact["car_number"] as! String) {
            self.goToChatButton.isEnabled = false
            self.goToChatButton.backgroundColor = UIColor.gray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Информация о пользователе"
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func goToChat(_ sender: AnyObject) {
        
        UserDefaults.standard.set(true, forKey: "isNewChat")
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! MCNavigationController
        let mcTabBarContrller = controller.topViewController as? MCTabBarController
    
        mcTabBarContrller!.chat = self.createChat()
        mcTabBarContrller!.user = nil
        
        self.present(controller, animated: false, completion: nil)
    }
    
    // MARK: - Table View Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        cell!.textLabel?.text = self.tableData[(indexPath as NSIndexPath).row]
        
        return cell!
    }
    
    func parseContactAndAddToTableData() {
    
        self.tableData.append("Номер авто: " + self.getCorrectAutoNumber())
        if self.contact["name"] as! String != "" {
            
            self.tableData.append("Имя: " + (self.contact["name"] as! String))
            self.name = self.contact["name"] as! String
        }
        if self.contact["nickname"] as! String != "" {
            
            self.tableData.append("Ник: " + (self.contact["nickname"] as! String))
            self.nickname = self.contact["nickname"] as! String
        }
    }
    
    func setTableViewHeight() {
        self.tableViewHeight.constant = CGFloat(self.tableData.count * 44)
    }
    
    func isMyNumber(_ number: String) -> Bool {
        var number = number
        number = self.getCorrectAutoNumber()
        return number == self.appDelegate.car_namber
    }
    
    func getCorrectAutoNumber() -> String {
        
        let space: Character = "\u{2022}"
        let endIndex = (self.contact["car_number"] as! String).lowercased().characters.index(of: space)
        var correctAutoNumber = ""
        
        if endIndex == nil {
            correctAutoNumber = self.contact["car_number"] as! String
        } else {
            correctAutoNumber = (self.contact["car_number"] as! String).substring(with: ((self.contact["car_number"] as! String).startIndex ..< endIndex!))
        }
    
        return correctAutoNumber
    }
    
    func getCorrectName() -> String {
        
        var correctName = (self.contact["car_number"] as! String)
        
        if correctName.contains(self.name) && correctName.contains(self.nickname) {
            
            let range = correctName.index(correctName.endIndex, offsetBy: -(self.name.characters.count + 2))..<correctName.endIndex
            correctName.removeSubrange(range)
        }
        
        return correctName
    }
    
    func createChat() -> Chat {
        
        let cont = Contact()
        cont.name = self.getCorrectName()
        cont.identifier = contact["id"] as! String
        
        let chat = Chat()
        chat.contact = cont
        
        return chat
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

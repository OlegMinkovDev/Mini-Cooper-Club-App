import UIKit

class MCChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var chat = Chat()
    var tableData:[Chat] = []
    var contacts:[Contact] = []
    var user:User? = User()
    
    var appDelegate:AppDelegate = AppDelegate()
    
    var isEdit = false
    var newGroupStatus = 0
    var newGroupTitle = ""
    var timerWaitGettingChats = Timer()
    var timerUpdateTableData = Timer()
    var tickCount = 0
    var myIdentifier = Int()
    var messagesArrayInfo: [(time:Int, text:String, name:String?, sender:MessageSender, status:MessageStatus)] = []
    var titleTextField = UITextField()
    let groupPrivateChat:DispatchGroup  = DispatchGroup();
    let groupGroupChat:DispatchGroup  = DispatchGroup();
    var allGroupUsers:[NSDictionary] = []
    var currentGroupNumber = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.setTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        timerWaitGettingChats.invalidate()
        timerUpdateTableData.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Чаты"
        
        
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Ред.", style: .plain, target: self, action: #selector(MCChatViewController.edit))
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(MCChatViewController.newChat))
        
        UserDefaults.standard.set(false, forKey: "isNewGroup")
        
        if UserDefaults.standard.bool(forKey: "isNewChat") {
            timerWaitGettingChats = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MCChatViewController.waitForGettingChats), userInfo: nil, repeats: true)
        }
        
        //timerUpdateTableData = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(MCChatViewController.clearAndSetTableData), userInfo: nil, repeats: true)
        
        self.clearAndSetTableData()
        self.indicatorView.hidesWhenStopped = true
    }
    
    func waitForGettingChats() {
        self.indicatorView.startAnimating()
        tickCount += 1
        
        var id = String()
        
        if self.user != nil {
            id = self.user!.id
        } else { id = self.chat.identifier() }
        
        if self.returnChatWithId(id) != nil {
            
            self.chat = self.returnChatWithId(id)!
            timerWaitGettingChats.invalidate()
            self.indicatorView.stopAnimating()
            
            self.performSegue(withIdentifier: "toMCMessageViewController", sender: self)
        
        } else if tickCount > 1 {
            
            if self.user != nil {
                self.chat = self.createEmptyChat()
            }
            
            self.performSegue(withIdentifier: "toMCMessageViewController", sender: self)
            timerWaitGettingChats.invalidate()
            self.indicatorView.stopAnimating()
        }
    }
    
    func createEmptyChat() -> Chat {
        
        var correctName = user?.car_number.lowercased()
        if user?.nickname != "" {
            correctName! += "\u{2022}" + (user?.nickname)!
        } else if user?.name != "" {
            correctName! += "\u{2022}" + (user?.name)!
        }
        
        let contact = Contact()
        contact.name = correctName
        contact.identifier = user?.id
        
        let chat = Chat()
        chat.contact = contact
        
        return chat
    }
    
    func refreshTableView() {
        
        //self.clearAndSetTableData()
    }
    
    func newChat() {
        self.performSegue(withIdentifier: "toMCNewChatViewController", sender: self)
    }
    
    func edit() {
        
        if !isEdit {
        
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(MCChatViewController.edit))
            isEdit = true
        
        } else {
            
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Ред.", style: .plain, target: self, action: #selector(MCChatViewController.edit))
            isEdit = false

        }
    }
    
    func setTableView() {
        self.tableData = []
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        self.tableView.backgroundColor = UIColor.clear
    }
    
    func clearAndSetTableData() {
        
        (LocalStorage.sharedInstance() as AnyObject).clear()
        self.tableData = []
        
        self.indicatorView.startAnimating()
        self.tableView.isUserInteractionEnabled = false
        
        self.setPrivateChats()
        self.setGroupChats()
        
        self.groupPrivateChat.notify(queue: DispatchQueue.main, execute: {
            
            self.groupGroupChat.notify(queue: DispatchQueue.main, execute: {
            
                self.sortAndReloadData()
                self.indicatorView.stopAnimating()
                self.tableView.isUserInteractionEnabled = true
            })
        })
    }
    
    func removeDuplicates(_ arrayWithDublicates: [Int]?) -> [Int] {
        
        var arrayWithoutDublicates:[Int] = []
        if arrayWithDublicates != nil {
            
            for id in arrayWithDublicates! {
                
                if !arrayWithoutDublicates.contains(id) {
                    arrayWithoutDublicates.append(id)
                }
            }
        }
        
        return arrayWithoutDublicates
    }
    
    func parseMessagesInfoAndAddToArray(_ allMessages: [NSDictionary], isGroup: Bool) {
        
        for message in allMessages {
            
            let text = message["text"] as! String
            let time = message["time"] as! Int
            
            if self.isISentMessage(message) {
                if !self.isReadMessage(message) {
                    self.messagesArrayInfo.append((time, text, nil, MessageSender.myself, MessageStatus.received))
                } else { // message is read
                    self.messagesArrayInfo.append((time, text, nil, MessageSender.myself, MessageStatus.read))
                }
            } else { // message sent someone
                if isGroup {
                    self.messagesArrayInfo.append((time, text, self.getSenderNameById(message["from"] as! Int), MessageSender.someone, MessageStatus.read))
                } else { // is private chat
                    self.messagesArrayInfo.append((time, text, nil, MessageSender.someone, MessageStatus.read))
                }
            }
        }
    }
    
    func isISentMessage(_ message: NSDictionary) -> Bool {
        
        if message["from"] as! Int == self.myIdentifier {
            return true
        }
        
        return false
    }
    
    func isReadMessage(_ message: NSDictionary) -> Bool {
        
        if message["readed"] as! Int == 1 {
            return true
        }
        
        return false
    }
    
    func setUnreadMessageIndicator(_ newMessagesCount: NSArray?) {
        
        for currentChat in self.tableData {
            for fromID in newMessagesCount! {
                
                let id = ((fromID as! NSDictionary)["id"]) as? Int
                
                if currentChat.identifier() == String(id!) {
                    currentChat.numberOfUnreadMessages = (fromID as! NSDictionary)["c"]! as! Int
                }
            }
        }
    }
    
    func getImageColorForUser(_ user: NSDictionary) -> String {
        
        var correctColor = ""
        if user["name"] as! String != "" && user["nickname"] as! String != "" {
            correctColor = "blueCircle" //"greenCircle"
        } else if user["name"] as! String != "" || user["nickname"] as! String != "" {
            correctColor = "blueCircle" //"yellowCircle"
        } else { correctColor = "blueCircle" /*"redCircle"*/ }
        
        return correctColor
    }
    
    func sortAndReloadData() {
        
        DispatchQueue.main.async(execute: {
            self.tableData.sort(by: self.sortByTime)
            self.tableView.reloadData()
        })
    }
    
    func send_request_chat_get_me_new(_ isLastObject: Bool) {
        
        self.appDelegate.sendPostRequest("&act=chat_get_me_new", completionHandler: { (responseFromActionChatGetMeNew) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGetMeNew) {
            
                let chat = responseFromActionChatGetMeNew["chat"] as? NSDictionary
                let new = chat!["new"] as? NSArray
                if new != nil {
                    self.setUnreadMessageIndicator(new)
                }
                
                if isLastObject {
                    self.groupPrivateChat.leave()
                }
            }
            
        })
    }
    
    func send_request_chat_get(_ userID: String, isLastObject: Bool) {
        
        let postRequestForActionChatGet = "&id=" + userID + "&marked=0&act=chat_get"
        self.appDelegate.sendPostRequest(postRequestForActionChatGet, completionHandler: { (responseFromActionChatGet) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGet) {
            
                let currentPrivateChat = responseFromActionChatGet["chat"] as? NSDictionary
                
                let user = currentPrivateChat?["u"] as? NSDictionary
                let allMessagesFromServer = currentPrivateChat?["res"] as? [NSDictionary]
                
                self.parseMessagesInfoAndAddToArray(allMessagesFromServer!, isGroup: false)
                
                self.createChat((self.getCorrectName(user!), id: String(userID), self.getImageColorForUser(user!)), messages: self.messagesArrayInfo)
                self.messagesArrayInfo = []
                
                self.send_request_chat_get_me_new(isLastObject)
            
            } else {
                print("MCChatViewController | send_request_chat_get | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func getCorrectName(_ user: NSDictionary) -> String {
        
        var correctName = (user["car_number"] as! String).lowercased()
        if user["nickname"] as! String != "" {
            correctName = correctName + "\u{2022}" + (user["nickname"] as! String)
        } else if user["name"] as! String != "" {
            correctName = correctName + "\u{2022}" + (user["name"] as! String)
        }
        
        return correctName
    }
    
    func getSenderNameById(_ senderId: Int) -> String {
        
        for user in  self.allGroupUsers {
            if user["id"] as! String == String(senderId) {
                return correctUserName(user)
            }
        }
        
        return "Error: User must be found"
    }
    
    func correctUserName(_ user: NSDictionary) -> String {
        
        var correctName = (user["car_number"] as! String).lowercased()
        if user["nickname"] as! String != "" {
            correctName += "\u{2022}" + String(user["nickname"] as! String)
        } else if user["name"] as! String != "" {
            correctName += "\u{2022}" + String(user["name"] as! String)
        }
        
        return correctName
    }
    
    func send_request_chat_group(_ id: String, allGroupCount: Int) {
        
        let postString = "&id=" + id + "&act=chat_group"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroup) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroup) {
            
                let group = responseFromActionChatGroup["group"] as? NSDictionary
                let res  = group!["res"] as? NSDictionary
                let groupName = res!["name"] as? String
                
                self.send_request_chat_group_get(String(res!["id"] as! Int), name: groupName!, allGroupCount: allGroupCount)
            
            } else {
                print("MCChatViewController | send_request_chat_group | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
        })
    }
    
    func setUnreadMessagesIndicator(_ id: String, unreadCount: Int) {
        
        for c in self.tableData {
            
            if c.identifier() == "g" + id {
                c.numberOfUnreadMessages = unreadCount
            }
        }
    }
    
    func send_request_chat_group_get_me_new(_ id: String, allGroupCount: Int) {
        
        let postString:String = "&id=" + id + "&act=chat_group_get_me_new"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupGetMeNew) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupGetMeNew) {
            
                self.currentGroupNumber += 1
                
                let chat = responseFromActionChatGroupGetMeNew["chat_group"] as! NSDictionary
                let idGroup = String(chat["id"] as! Int)
                let newMessageCount = chat["new"] as? NSArray
                
                var allUnreadMessagesCount = 0
                if newMessageCount != nil {
                    for unreadMessageCountInCurrentGroup in newMessageCount! {
                        allUnreadMessagesCount += (unreadMessageCountInCurrentGroup as! NSDictionary)["c"] as! Int
                    }
                }
                self.setUnreadMessagesIndicator(idGroup, unreadCount: allUnreadMessagesCount)
                
                if self.currentGroupNumber == allGroupCount {
                    self.currentGroupNumber = 0
                    self.groupGroupChat.leave()
                }
            
            } else {
                print("MCChatViewController | send_request_chat_group_get_me_new | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
            
        })
    }
    
    func send_request_chat_group_get(_ id: String, name: String, allGroupCount: Int) {
        
        let postString = "&id=" + id + "&marked=0&act=chat_group_get"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupGet) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupGet) {
                
                let currentGroupChat = responseFromActionChatGroupGet["chat"] as! NSDictionary
                let allServerMessagesCount = currentGroupChat["c"] as! Int
                
                if allServerMessagesCount > 0 {
                    
                    let allMessagesFromServer = currentGroupChat["res"] as? [NSDictionary]
                    self.allGroupUsers = (currentGroupChat["u"] as? [NSDictionary])!
                    
                    if allMessagesFromServer != nil {
                        self.parseMessagesInfoAndAddToArray(allMessagesFromServer!, isGroup: true)
                    }
                }
                
                self.createChat((name, "g" + id, nil), messages: self.messagesArrayInfo)
                self.messagesArrayInfo = []
                
                self.send_request_chat_group_get_me_new(id, allGroupCount: allGroupCount)
            
            } else {
                print("MCChatViewController | send_request_chat_group_get | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
        })
    }
    
    func setPrivateChats() {
        
        self.groupPrivateChat.enter()
        self.appDelegate.sendPostRequest("&act=chat_get_me_all", completionHandler: { (responseFromActionChatGetMeAll) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGetMeAll) {
            
                self.myIdentifier = responseFromActionChatGetMeAll["id"] as! Int
                let allPrivateChats = responseFromActionChatGetMeAll["chat"] as? NSDictionary
                var idUsersWhoISentMessage = allPrivateChats!["from_me"] as? [Int]
                var idUsersWhoSentMeMessage = allPrivateChats!["to_me"] as? [Int]
                
                idUsersWhoISentMessage = self.removeDuplicates(idUsersWhoISentMessage)
                idUsersWhoSentMeMessage = self.removeDuplicates(idUsersWhoSentMeMessage)
                
                let allUsersID = self.removeDuplicates(idUsersWhoISentMessage! + idUsersWhoSentMeMessage!)
                
                if allUsersID.count == 0 {
                    self.groupPrivateChat.leave()
                }
                
                for userID in allUsersID {
                    if userID == allUsersID.last! {
                        self.send_request_chat_get(String(userID), isLastObject: true)
                    } else {
                        self.send_request_chat_get(String(userID), isLastObject: false)
                    }
                }
            
            } else {
                print("MCChatViewController | setPrivateChats | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func setGroupChats() {
        
        self.groupGroupChat.enter()
        self.appDelegate.sendPostRequest("&act=chat_group_all_me", completionHandler: { (responseFromActionChatGroupAllMe) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupAllMe) {
            
                let group = responseFromActionChatGroupAllMe["group"] as! NSDictionary
                let allGroupsID  = group["res"] as! [NSDictionary]
                
                if allGroupsID.count == 0 {
                    self.groupGroupChat.leave()
                }
                
                for groupID in allGroupsID {
                    self.send_request_chat_group(String(groupID["id"] as! Int), allGroupCount: allGroupsID.count)
                }
            
            } else {
                print("MCChatViewController | setGroupChats | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
            
        })
    }
    
    func sortByTime(_ x:Chat, y:Chat) -> Bool {
        return x.last_message.time > y.last_message.time
    }
    
    func createChat(_ contactInfo:(name:String, id:String, imageColor:String?), messages:[(time:Int, text:String, name:String?, sender:MessageSender, status:MessageStatus)]) {
        
        let contact = Contact()
        contact.name = contactInfo.name
        contact.identifier = contactInfo.id
        contact.imageColor = contactInfo.imageColor
        
        let chat = Chat()
        chat.contact = contact
        
        var last_message = Message()
        for currentMessage in messages {
            
            let message = Message()
            message.time = currentMessage.time
            message.text = currentMessage.text
            message.name = currentMessage.name
            message.sender = currentMessage.sender
            message.status = currentMessage.status
            message.date = Date(timeIntervalSince1970: Double(currentMessage.time)) // !!!
            message.chat_id = chat.identifier()
            
            (LocalStorage.sharedInstance() as AnyObject).store(message)
            last_message = message
        }
        
        chat.last_message = last_message
        chat.date = Date()
        
        DispatchQueue.main.async(execute: {
            self.tableData.append(chat)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "ChatListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! ChatCell
        cell.separatorInset = UIEdgeInsets()
        cell.separatorInset.left = 73
        cell.layoutMargins = UIEdgeInsets.zero
    
        if self.tableData.count > 0 && self.tableData.count > (indexPath as NSIndexPath).row {
            
            if self.tableData[(indexPath as NSIndexPath).row].identifier()[self.tableData[(indexPath as NSIndexPath).row].identifier().startIndex] == "g" {
                cell.picture.image = UIImage(named: "group")
            } else { cell.picture.image = UIImage(named: self.tableData[(indexPath as NSIndexPath).row].contact.imageColor) }
            
            cell.chat = self.tableData[(indexPath as NSIndexPath).row]
            cell.setChatInfo(cell.chat)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
             
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Message") as! MCMessageViewController
        
        if self.tableData.count > 0 && self.tableData.count > (indexPath as NSIndexPath).row {
        
            controller.chat = self.tableData[(indexPath as NSIndexPath).row]
            
            if controller.chat.identifier()[controller.chat.identifier().startIndex] == "g" {
                controller.isGroup = true
            } else {
                controller.isGroup = false
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? MCMessageViewController {
            viewController.chat = self.chat
        }
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var postString = ""
            if self.tableData[(indexPath as NSIndexPath).row].identifier()[self.tableData[(indexPath as NSIndexPath).row].identifier().startIndex] == "g" {
                
                var id:String = self.tableData[(indexPath as NSIndexPath).item].identifier()
                id.remove(at: id.startIndex)
                postString = "&id=" + id + "&act=chat_group_exit"
                
            } else { postString = "&id=" + self.tableData[(indexPath as NSIndexPath).item].identifier() + "&act=chat_del" }
            
            self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatDelGroupExit) in
                
                let error = Error()
                if !error.exist(responseFromActionChatDelGroupExit) {
                   
                    DispatchQueue.main.async(execute: {
                        self.tableData.remove(at: (indexPath as NSIndexPath).row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    })
                
                } else {
                    print("MCChatViewController | tableViewEditingStyle | " + error.getDesc())
                    
                    if error.getDesc() == "Пользователь не авторизован \n" {
                        self.appDelegate.goToSignInViewController(currentViewController: self)
                    }
                }
                
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func returnChatWithId(_ id:String) -> Chat? {
        
        for c in self.tableData {
            
            if c.identifier() == id {
                return c
            }
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

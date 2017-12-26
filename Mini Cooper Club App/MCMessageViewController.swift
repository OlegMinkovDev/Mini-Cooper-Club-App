import AVFoundation

class MCMessageViewController: UIViewController, InputbarDelegate, MessageGatewayDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // global 
    var chat = Chat()
    let UPDATE_TIME = 2.0

    @IBOutlet weak var inputbar: Inputbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var tableArray = TableArray()
    var gateway = MessageGateway()
    var messageCell = MessageCell()
    var timer = Timer()
    var prevText = Int()
    var isMe = false
    var isGroup = false
    var backButtonWasPressed = false
    var isMessageViewControllerWasLeftOrFirstVisit = true
    var oldAllMessagesFromServerCount = Int()
    var usersWhoSentMessages = NSArray()
    var myIdentifier = Int()
    let group:DispatchGroup  = DispatchGroup();
    var bombSoundEffect: AVAudioPlayer!
    var correctContentHeight = CGFloat();
    
    var appDelegate:AppDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UserDefaults.standard.set(false, forKey: "isNewChat")
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MCMessageViewController.userDidTapScreen))
        self.view.addGestureRecognizer(tap)
        
        self.navigationItem.hidesBackButton = true
        
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "back_arrow@2x.png"), for: .normal)
        button.addTarget(self, action: #selector(MCMessageViewController.returnToChats), for: .touchUpInside)
        button.frame = CGRect(x: 10, y: 22, width: 13, height: 22)
        let newBackButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.group.enter()
        
        if !self.isGroup {
            self.timer = Timer.scheduledTimer(timeInterval: Double(UPDATE_TIME), target: self, selector: #selector(MCMessageViewController.updatePrivateChat), userInfo: nil, repeats: true)
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: Double(UPDATE_TIME), target: self, selector: #selector(MCMessageViewController.updateGroupChat), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weak var inputbar = self.inputbar
        weak var tableView = self.tableView
        weak var controller = self
        
        self.view.keyboardTriggerOffset = (inputbar?.frame.size.height)!
        self.view.addKeyboardPanning { (keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            
            inputbar?.translatesAutoresizingMaskIntoConstraints = true
            
            var toolBarFrame = inputbar?.frame
            toolBarFrame?.origin.y = keyboardFrameInView.origin.y - (toolBarFrame?.size.height)!
            inputbar?.frame = toolBarFrame!
            
            var tableViewFrame = tableView?.frame
            tableViewFrame?.size.height = (toolBarFrame?.origin.y)! - 64
            tableView?.frame = tableViewFrame!
            
            //controller?.tableViewScrollToBottomAnimated(false)
            self.tableViewScrollToBottomAnimated(false)
        }
        
        self.setInputbar()
        self.setTableView()
        self.setGateway()
        self.setChatInfo(chat)
        
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < self.tableView.contentSize.height {
            self.tableView.setContentOffset(CGPoint.init(x: 0, y: self.tableView.contentSize.height - screenHeight), animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.endEditing(true)
        self.view.removeKeyboardControl()
        self.gateway.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.tableArray.numberOfMessages() != 0 {
            self.chat.last_message = self.tableArray.lastObject()
        }
        
        self.timer.invalidate()
    }
    
    func setInputbar() {
        
        self.inputbar.placeholder = nil
        self.inputbar.delegate = self
        //self.inputbar.leftButtonImage = UIImage(named: "share")
        self.inputbar.rightButtonText = "Send"
        self.inputbar.rightButtonTextColor = UIColor(red: 0, green: 124/255, blue: 1, alpha: 1)
    }
    
    func setTableView() {
        
        self.tableArray = TableArray()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    }
    
    func setGateway() {
        
        self.gateway = MessageGateway.sharedInstance() as! MessageGateway
        self.gateway.delegate = self
        self.gateway.chat = self.chat
        self.gateway.loadOldMessages()
    }
    
    func setChatInfo(_ chat:Chat) {
        
        self.chat = chat
        
        if self.chat.contact != nil {
            //self.title = chat.contact.name
            self.createNavigationBarButtonWithText(chat.contact.name)
        }
    }
    
    func createNavigationBarButtonWithText(_ text: String) {
    
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40) as CGRect
        button.backgroundColor = UIColor.clear
        button.setTitle(text, for: UIControlState())
        button.addTarget(self, action: #selector(MCMessageViewController.goToGroupInfo), for: UIControlEvents.touchUpInside)
        self.navigationItem.titleView = button
    }
    
    func goToGroupInfo() {
        
        if self.isGroup {
            self.performSegue(withIdentifier: "toMCGroupInfoViewController", sender: self)
        }
    }
    
    func updatePrivateChat() {
        
        let postRequestForActionChatGet = "&id=" + self.chat.identifier() + "&act=chat_get"
        self.appDelegate.sendPostRequest(postRequestForActionChatGet, completionHandler: { (responseFromActionChatGet) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGet) {
            
                if self.backButtonWasPressed {
                    self.group.leave()
                }
                
                self.myIdentifier = responseFromActionChatGet["id"] as! Int
                let currentPrivateChat = responseFromActionChatGet["chat"] as? NSDictionary
                
                if currentPrivateChat != nil {
                    
                    let allMessagesFromServer = currentPrivateChat!["res"] as! NSArray
                    
                    
                    if self.isMessageViewControllerWasLeftOrFirstVisit {
                        self.isMessageViewControllerWasLeftOrFirstVisit = false
                        self.oldAllMessagesFromServerCount = allMessagesFromServer.count
                    }
                    
                    if self.oldAllMessagesFromServerCount != allMessagesFromServer.count {
                        self.oldAllMessagesFromServerCount = allMessagesFromServer.count
                        
                        let lastMessageFromServer = allMessagesFromServer.lastObject
                        if !self.isISentMessage(lastMessageFromServer as! NSDictionary) {
                            
                            self.playSound(soundName: "SndMENU_online_login.mp3")
                            
                            let text = (lastMessageFromServer as! NSDictionary)["text"]! as? String
                            
                            if text != nil {
                                
                                let senderID = (lastMessageFromServer as! NSDictionary)["from"]! as! Int
                                
                                self.createAndAddToTableArrayMessageUIWithText(text!, senderId: senderID)
                                self.reloadDataAndScrollTableView()
                            }
                        }
                    }
                    
                    let lastMessageFromServer = allMessagesFromServer.lastObject
                    if lastMessageFromServer != nil && self.isReadMessage(lastMessageFromServer as! NSDictionary) {
                        self.updateMessagesStatus()
                    }
                }
            
            } else {
                print("MCMessageViewController | updatePrivateChat | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
            
        })
    }
    
    func createAndAddToTableArrayMessageUIWithText(_ text: String, senderId: Int) {
        
        let message = Message()
        message.text = text
        message.date = Date()
        message.chat_id = self.chat.identifier()
        message.sender = MessageSender.someone
        
        if self.isGroup {
            message.name = self.getSenderNameById(senderId)
        }
        
        self.chat.last_message = message
        self.tableArray.addObject(message)
    }
    
    func updateMessagesStatus() {
        
        for currentSectionIndex in 0..<self.tableArray.numberOfSections() {
            
            for currentMessageInSectionIndex in 0..<self.tableArray.numberOfMessages(inSection: currentSectionIndex) {
                
                let indexPath = IndexPath(row: currentMessageInSectionIndex, section: currentSectionIndex)
                let currentMessageUI = self.tableArray.object(at: indexPath)
                
                if currentMessageUI?.status != MessageStatus.read {
                    
                    let delayTimeForAnimation = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTimeForAnimation) {
                        self.gateway.updateStatus(for: currentMessageUI)
                    }
                }
            }
        }
    }
    
    func reloadDataAndScrollTableView() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage(), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    func isISentMessage(_ message: NSDictionary) -> Bool {
        
        if self.myIdentifier == message["from"] as! Int {
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
    
    func getSenderNameById(_ senderId: Int) -> String {
        
        for user in self.usersWhoSentMessages {
            if (user as! NSDictionary)["id"] as! String == String(senderId) {
                return correctUserName(user as! NSDictionary)
            }
        }
        
        return "Error: User must be found"
    }
    
    func correctUserName(_ user: NSDictionary) -> String {
    
        var correctName = (user["car_number"] as! String).lowercased()
        if user["nickname"] as! String != "" {
            correctName += " " + String(user["nickname"] as! String)
        } else if user["nickname"] as! String == "" {
            correctName += " " + String(user["car_number"] as! String)
        }
        
        return correctName
    }
    
    func updateGroupChat() {
        
        var id:String = self.chat.identifier()
        id.remove(at: id.startIndex)
        
        let postRequestForActionChatGroupGet = "&id=" + id + "&act=chat_group_get"
        self.appDelegate.sendPostRequest(postRequestForActionChatGroupGet, completionHandler: { (responseFromActionChatGroupGet) in
            
            let error = Error()
            if !error.exist(responseFromActionChatGroupGet) {
            
                if self.backButtonWasPressed {
                    self.group.leave()
                }
                
                let currentChatGroup = responseFromActionChatGroupGet["chat"] as? NSDictionary
                let allMessagesFromServer:NSArray? = currentChatGroup?["res"] as? NSArray
                self.myIdentifier = responseFromActionChatGroupGet["id"] as! Int
                
                if allMessagesFromServer != nil {
                    
                    self.usersWhoSentMessages = currentChatGroup!["u"] as! NSArray
                    
                    if self.isMessageViewControllerWasLeftOrFirstVisit {
                        self.isMessageViewControllerWasLeftOrFirstVisit = false
                        self.oldAllMessagesFromServerCount = allMessagesFromServer!.count
                    }
                    
                    if self.oldAllMessagesFromServerCount != allMessagesFromServer!.count {
                        self.oldAllMessagesFromServerCount = allMessagesFromServer!.count
                        
                        let lastMessageFromServer = allMessagesFromServer!.lastObject
                        if !self.isISentMessage(lastMessageFromServer as! NSDictionary) {
                            
                            let text = (lastMessageFromServer as! NSDictionary)["text"] as? String
                            let senderID = (lastMessageFromServer as! NSDictionary)["from"] as! Int
                            
                            if text != nil {
                                
                                self.createAndAddToTableArrayMessageUIWithText(text!, senderId: senderID)
                                self.reloadDataAndScrollTableView()
                            } else {
                                print("text is nil")
                                print(lastMessageFromServer as! NSDictionary)
                            }
                        }
                    }
                    
                    let lastMessageFromServer = allMessagesFromServer!.lastObject
                    if self.isReadMessage(lastMessageFromServer as! NSDictionary) {
                        self.updateMessagesStatus()
                    }
                }
                
            } else {
                print("MCMessageViewController | updateGroupChat | " + error.getDesc())
                
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
        })
    }
    
    func userDidTapScreen() {
        self.inputbar.resignFirstResponder()
    }
    
    // MARK: - TableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.numberOfMessages(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "MessageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! MessageCell
        
        cell.message = self.tableArray.object(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let message = self.tableArray.object(at: indexPath)
        return message!.heigh
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableArray.title(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        let label = UILabel()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.sizeToFit()
        label.center = view.center
        label.font = UIFont(name: "Helvetica", size: 13)
        label.backgroundColor = UIColor(red: 207/255, green: 220/255, blue: 252/255, alpha: 1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.autoresizingMask = UIViewAutoresizing()
        view.addSubview(label)
        
        return view
    }
    
    func tableViewScrollToBottomAnimated(_ animated:Bool) {
        
        if self.tableArray.numberOfMessages() > 0 {
        
            self.tableView.translatesAutoresizingMaskIntoConstraints = true
            self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage(), at: UITableViewScrollPosition.bottom, animated: animated) // !!!
        }
        
    }
    
    func inputbarDidPressRightButton(_ inputbar: Inputbar!) {
        
        self.playSound(soundName: "sfx_message_sent.mp3")
        
        self.isMe = true
        
        let message = Message()
        message.text = inputbar.text()
        message.chat_id = self.chat.identifier()
        message.status = MessageStatus.sending

        // Store Message in memory
        self.tableArray.addObject(message)
        
        // Insert Message in UI
        let indexPath = self.tableArray.indexPath(for: message)

        self.tableView.beginUpdates()
        
        if self.tableArray.numberOfMessages(inSection: (indexPath?.section)!) == 1 {
            self.tableView.insertSections(IndexSet.init(integer: (indexPath?.section)!), with: UITableViewRowAnimation.none)
        }
        
        self.tableView.insertRows(at: [indexPath!], with: UITableViewRowAnimation.bottom)
        
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage(), at: UITableViewScrollPosition.bottom, animated: true)
        
        // update message status
        self.gateway.updateStatus(for: message)
        
        if !isGroup {
            
            let postString = "&id=" + self.chat.contact.identifier + "&txt=" + message.text + "&act=chat_send"
            self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatSend) in
                
                let error = Error()
                if !error.exist(responseFromActionChatSend) {
                
                    // update message status
                    let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.gateway.updateStatus(for: message)
                    }
                    
                } else {
                    print("MCMessageViewController | inputbarDidPressRightButton | " + error.getDesc())
                    
                    if error.getDesc() == "Пользователь не авторизован \n" {
                        self.appDelegate.goToSignInViewController(currentViewController: self)
                    }
                }
            })
        
        } else {
            
            var id:String = self.chat.identifier()
            id.remove(at: id.startIndex)
            
            let postString = "&id=" + id + "&txt=" + message.text + "&act=chat_group_send"
            self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionChatGroupSend) in
                
                let error = Error()
                if !error.exist(responseFromActionChatGroupSend) {
                 
                    // update message status
                    let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.gateway.updateStatus(for: message)
                    }
                    
                } else {
                    print("MCMessageViewController | inputbarDidPressRightButton(group) | " + error.getDesc())
                    
                    if error.getDesc() == "Пользователь не авторизован \n" {
                        self.appDelegate.goToSignInViewController(currentViewController: self)
                    }
                }
            })
        }
    }
    
    func returnToChats() {
        
        self.backButtonWasPressed = true
        self.indicatorView.startAnimating()
        
        self.group.notify(queue: DispatchQueue.main, execute: {
            self.indicatorView.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            self.backButtonWasPressed = false
        })
    }
    
    func inputbarDidPressLeftButton(_ inputbar: Inputbar!) {
        
        let alertController = UIAlertController(title: "Message", message: "Left Button Pressed", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func inputbarDidChangeHeight(_ new_height: CGFloat) {
        self.view.keyboardTriggerOffset = new_height
    }
    
    func gatewayDidUpdateStatus(for message: Message!) {
        
        let indexPath = self.tableArray.indexPath(for: message)
        
        let cell:MessageCell? = self.tableView.cellForRow(at: indexPath!) as? MessageCell
        
        if cell != nil {
            cell!.updateMessageStatus()
        }
    }
    
    func gatewayDidReceiveMessages(_ array: [AnyObject]!) {
        
        self.tableArray.addObjects(from: array)
        self.tableView.reloadData()
    }
    
    func playSound(soundName: String) {
        
        let path = Bundle.main.path(forResource: soundName, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var id:String = self.chat.identifier()
        id.remove(at: id.startIndex)
        
        if let viewController = segue.destination as? MCGroupInfoViewController {
            viewController.groupID = id
        }
        
    }
}

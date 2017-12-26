//
//  ChatCell.swift
//  WahtsApp Swift
//
//  Created by Олег Минков on 06.06.16.
//  Copyright © 2016 Oleg Minkov. All rights reserved.
//

class ChatCell: UITableViewCell {

    var chat = Chat()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    
    override func awakeFromNib() {
        
        self.picture.layer.cornerRadius = self.picture.frame.size.width/2
        self.picture.layer.masksToBounds = true
        self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.width/2
        self.notificationLabel.layer.masksToBounds = true
        self.nameLabel.text = ""
        self.messageLabel.text = ""
        self.timeLabel.text = ""
    }
    
    func setChatInfo(_ chat: Chat) {
        
        self.chat = chat
        self.nameLabel.text = chat.contact.name
        self.messageLabel.text = chat.last_message.text
        updateTimeLabelWithDate(chat.last_message.date)
        updateUnreadMessagesIcon(chat.numberOfUnreadMessages)
    }
    
    func updateTimeLabelWithDate(_ date: Date) {
        
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.short
        df.dateStyle = DateFormatter.Style.none
        df.doesRelativeDateFormatting = false
        self.timeLabel.text = df.string(from: date)
    }
    
    func updateUnreadMessagesIcon(_ numberOfUnreadMessages: NSInteger) {
        
        self.notificationLabel.isHidden = numberOfUnreadMessages == 0
        self.notificationLabel.text = String(numberOfUnreadMessages)
    }
    
    func getImageView() -> UIImageView {
        return self.picture
    }
}

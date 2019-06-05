//
//  ChatCell.swift
//  RealTimeChat
//
//  Created by Solji Kim on 13/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    enum BubbleType {
        case incoming
        case outgoing
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var chatTextBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatTextBubble.layer.cornerRadius = 6
    }
    
    func setMessageData(message: Messages) {
        userNameLabel.text = message.senderName
        chatTextView.text = message.messageText
    }

    func setBubbleType(type: BubbleType) {
        if type == .incoming {
            chatStack.alignment = .leading
            chatTextBubble.backgroundColor = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 0.568947988)
            chatTextView.textColor = .black
        } else if type == .outgoing {
            chatStack.alignment = .trailing
            chatTextBubble.backgroundColor = #colorLiteral(red: 0.5837836159, green: 0.9230139579, blue: 1, alpha: 1)
            chatTextView.textColor = .black
        }
    }
    
    
    // 왜 이걸로 사용 못하지???
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        chatTextBubble.layer.cornerRadius = 10
//    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

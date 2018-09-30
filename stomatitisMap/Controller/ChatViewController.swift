//
//  chatViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/07/03.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

final class ChatViewController: MessagesViewController {
    
    private var databaseReference: DatabaseReference! //RealmTimeDatabase宣言
    private var messageList = [Message]()
    private let deviceID = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseReference = Database.database().reference() //RealmTimeDatabaseの初期化
        
        databaseReference.child("chat").observe(.value) { snap in
            self.updateChat(snap)
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = UIColor(red: 255/255, green: 205/255, blue: 210/255, alpha: 0.3)
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
        
        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        messagesCollectionView.keyboardDismissMode = .interactive
    }
    
    private func updateChat(_ snap: (DataSnapshot)) {
        messageList.removeAll()
        guard let chats = snap.value as? [String: [String: String]] else { return }
        chats.forEach {
            var sender: Sender
            guard let uuid = $0.value["uuid"],
                let text = $0.value["text"],
                let time = $0.value["date"] else {
                    return
            }
            guard let timeStanmp = AppData.shared.dateFormater.date(from: time) else { return }
            
            if deviceID == uuid {
                sender = currentSender()
            } else {
                sender = otherSender(uuid: uuid)
            }
            let message = Message(messageId: "",
                                  sender: sender,
                                  sentDate: timeStanmp,
                                  kind: .text(text))
            if !AppData.shared.blocks.contains(uuid) {  //ブロックリストにuuidが含まれていなかったら追加
                messageList.append(message)
            }
        }
        messageList.sort { $0.sentDate < $1.sentDate }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tap")
    }
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: deviceID, displayName: "自分という口内炎患者")
    }
    
    func otherSender(uuid: String) -> Sender {
        return Sender(id: uuid, displayName: "知らない口内炎患者")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = AppData.shared.dateFormater.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatViewController: MessagesDisplayDelegate {
    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: UIImage(named: "kounaien_small"))
        avatarView.set(avatar: avatar)
    }
}

// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        showReport(title: .empty, massage: "", reportHandler: {
            self.showAlert(title: .warning, massage: "このユーザを本当に通報しますか？", button: .ok, isCancel: true, handler: {
                self.databaseReference.child("block").childByAutoId().setValue(message.sender.id)
                self.showAlert(title: .empty, massage: "通報しました", button: .ok)
            })
        }, blockHandler: {
            self.showAlert(title: .warning, massage: "このユーザを本当にブロックしますか？", button: .ok, isCancel: true, handler: {
                var blocks = AppData.shared.blocks
                blocks.append(message.sender.id)
                AppData.shared.blocks = blocks
                self.databaseReference.child("chat").observeSingleEvent(of: .value, with: { (snap) in
                    self.updateChat(snap)
                    self.showAlert(title: .empty, massage: "ブロックしました", button: .ok)
                })
            })
        })
    }
    
    func didTapCell(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

extension ChatViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let timestamp = AppData.shared.dateFormater.string(from: Date())
        let chat = ["date": timestamp,
                    "text": text,
                    "uuid": deviceID,
                    "name": UIDevice.current.name]
        databaseReference.child("chat").childByAutoId().setValue(chat)
        inputBar.inputTextView.text = ""
    }
}

struct Message: MessageType {
    let messageId: String
    let sender: Sender
    let sentDate: Date
    let kind: MessageKind
}


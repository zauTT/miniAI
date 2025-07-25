//
//  ChatViewController.swift
//  miniAI
//
//  Created by Giorgi Zautashvili on 25.07.25.
//

import Foundation
import UIKit

class ChatViewController: UIViewController {
    
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let inputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "miniAI - Chatbot"
        
        setupTableView()
        setupInputBar()
        setupConstraints()
        setupKeyboardObservers()
        
    }
    
    // MARK: - Setup TableView
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupInputBar() {
        view.addSubview(inputContainerView)
        inputContainerView.backgroundColor = .secondarySystemBackground
        
        inputTextField.placeholder = "Ask away..."
        inputTextField.borderStyle = .roundedRect
        
        sendButton.setTitle("↑", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            inputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextField.heightAnchor.constraint(equalToConstant: 38),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
        ])
    }
    
    //MARK: - Keyboard handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            view.frame.origin.y = -keyboardFrame.height + view.safeAreaInsets.bottom
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    //MARK: - Actions
    
    @objc private func sendButtonTapped() {
        guard let text = inputTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        inputTextField.text = ""
        let newMessage = ChatMessage(text: text, sender: .user)
        messages.append(newMessage)
        tableView.reloadData()
        scrollToBottom()
    }
    
    @objc private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let IndexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: IndexPath, at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as! ChatMessageCell
        cell.configure(with: message)
        return cell
    }
}

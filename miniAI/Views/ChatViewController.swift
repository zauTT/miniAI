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
    
    private var inputContainerBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        inputTextField.layer.cornerRadius = 8
        inputTextField.layer.masksToBounds = true
        
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
        
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerBottomConstraint,
            
            inputTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 6),
            inputTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -6),
            inputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
        ])
        sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    //MARK: - Keyboard handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let keyboardHeigth = keyboardFrame.height - view.safeAreaInsets.bottom
        
        inputContainerBottomConstraint.constant = -keyboardHeigth
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        inputContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
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

//MARK: - Extensions

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

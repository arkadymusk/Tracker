//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 09.03.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    var onCategoryCreated: ((String) -> Void)?

    private let titleTextField = UITextField()
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("newCategory.title", comment: "")

        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        titleTextField.placeholder = NSLocalizedString("newCategory.textField.placeholder", comment: "")
        titleTextField.backgroundColor = .secondarySystemBackground
        titleTextField.layer.cornerRadius = 16
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        titleTextField.leftViewMode = .always
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        doneButton.setTitle(NSLocalizedString("newCategory.doneButton.title", comment: ""), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .systemGray
        doneButton.layer.cornerRadius = 16
        doneButton.isEnabled = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        view.addSubview(titleTextField)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    private func textChanged() {
        let text = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let enabled = !text.isEmpty
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ? .black : .systemGray
    }

    @objc
    private func doneTapped() {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else { return }
        onCategoryCreated?(title)
        navigationController?.popViewController(animated: true)
    }
}

//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 11.02.2026.
//

import UIKit
import Foundation

extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "optionCell")
        cell.accessoryType = .disclosureIndicator

        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = categoryTitle
        } else {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = selectedDays.isEmpty ? "" : "\(selectedDays.count) дн."
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            return
        } else {
            openSchedule()
        }
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays days: [Weekday]) {
        selectedDays = days
    }
}


protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(_ vc: NewHabitViewController,
                                didCreate tracker: Tracker,
                                categoryTitle: String)
}

final class NewHabitViewController: UIViewController {

    weak var delegate: NewHabitViewControllerDelegate?

    private let nameTextField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)

    private var selectedDays: [Weekday] = [] {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }

    private var categoryTitle: String = "Дом"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая привычка"
        view.backgroundColor = .systemBackground

        setupNameField()
        setupTableView()
        setupBottomButtons()

        updateCreateButtonState()
    }

    private func setupNameField() {
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.backgroundColor = .secondarySystemBackground
        nameTextField.layer.cornerRadius = 16
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nameTextField.leftViewMode = .always
        nameTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
    }

    private func setupBottomButtons() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .systemGray
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    private func textChanged() {
        updateCreateButtonState()
    }

    private func updateCreateButtonState() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasName = !name.isEmpty

        let hasSchedule = !selectedDays.isEmpty

        let enabled = hasName && hasSchedule
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? .black : .systemGray
    }

    @objc
    private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc
    private func didTapCreate() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let tracker = Tracker(
            id: UUID(),
            title: name,
            color: .ypBlue,
            emoji: "🙂",
            schedule: selectedDays
        )

        delegate?.newHabitViewController(self, didCreate: tracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
    }

    private func openSchedule() {
        let vc = ScheduleViewController(selectedDays: selectedDays)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}


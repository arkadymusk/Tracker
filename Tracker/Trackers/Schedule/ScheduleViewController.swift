//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 11.02.2026.
//

import UIKit

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        let day = Weekday.allCases[indexPath.row]

        cell.textLabel?.text = day.title
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGroupedBackground
        cell.alpha = 0.3

        let sw = UISwitch()
        sw.isOn = selectedDays.contains(day)
        sw.tag = day.rawValue
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = sw

        return cell
    }
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays days: [Weekday])
}

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let doneButton = UIButton(type: .system)

    private var selectedDays: Set<Weekday>

    init(selectedDays: [Weekday]) {
        self.selectedDays = Set(selectedDays)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        navigationItem.hidesBackButton = true

        setupDoneButton()
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47)
        ])
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.rowHeight = 75
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
    }

    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)

        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    private func didTapDone() {
        delegate?.scheduleViewController(self, didSelectDays: Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue }))
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func switchChanged(_ sender: UISwitch) {
        guard let day = Weekday(rawValue: sender.tag) else { return }

        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}


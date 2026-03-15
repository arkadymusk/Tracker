//
//  EditHabitViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 15.03.2026.
//

import UIKit

protocol EditHabitViewControllerDelegate: AnyObject {
    func editHabitViewController(_ vc: EditHabitViewController,
                                 didUpdate tracker: Tracker,
                                 categoryTitle: String)
}

final class EditHabitViewController: UIViewController {

    weak var delegate: EditHabitViewControllerDelegate?

    private let originalTracker: Tracker
    private let originalCategoryTitle: String
    private let completedDaysCount: Int

    private let completedDaysLabel = UILabel()
    private let nameTextField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private let emojiTitleLabel = UILabel()
    private let emojiCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private let colorTitleLabel = UILabel()
    private let colorCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private let emojis: [String] = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😪"
    ]

    private let colors: [UIColor] = [
        UIColor(0xFD4C49), UIColor(0xFF881E), UIColor(0x007BFA), UIColor(0x6E44FE), UIColor(0x33CF69), UIColor(0xE66DD4),
        UIColor(0xF9D4D4), UIColor(0x34A7FE), UIColor(0x46E69D), UIColor(0x35347C), UIColor(0xFF674D), UIColor(0xFF99CC),
        UIColor(0xF6C48B), UIColor(0x7994F5), UIColor(0x832CF1), UIColor(0xAD56DA), UIColor(0x8D72E6), UIColor(0x2FD058)
    ]

    private var selectedDays: [Weekday] = [] {
        didSet {
            tableView.reloadData()
            updateSaveButtonState()
        }
    }

    private var selectedEmoji: String?
    private var selectedColorIndex: Int?
    private var categoryTitle: String?

    init(tracker: Tracker, categoryTitle: String, completedDaysCount: Int) {
        self.originalTracker = tracker
        self.originalCategoryTitle = categoryTitle
        self.completedDaysCount = completedDaysCount
        self.categoryTitle = categoryTitle
        self.selectedDays = tracker.schedule
        self.selectedEmoji = tracker.emoji
        super.init(nibName: nil, bundle: nil)

        if let colorIndex = colors.firstIndex(where: { $0.isEqual(tracker.color) }) {
            self.selectedColorIndex = colorIndex
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("editHabit.title", comment: "")
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .secondarySystemBackground

        addSubviews()
        setupConstraints()
        setupCompletedDaysLabel()
        setupNameField()
        setupTableView()
        setupEmojiCollection()
        setupColorCollection()
        setupBottomButtons()
        fillInitialData()
        updateSaveButtonState()
    }

    private func fillInitialData() {
        nameTextField.text = originalTracker.title
        categoryTitle = originalCategoryTitle
        selectedDays = originalTracker.schedule
        selectedEmoji = originalTracker.emoji

        if let colorIndex = colors.firstIndex(where: { $0.isEqual(originalTracker.color) }) {
            selectedColorIndex = colorIndex
        }

        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        tableView.reloadData()
    }

    private func setupCompletedDaysLabel() {
        completedDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("tracker.daysCount", comment: ""),
            completedDaysCount
        )
        completedDaysLabel.font = .systemFont(ofSize: 32, weight: .bold)
        completedDaysLabel.textAlignment = .center
    }

    private func setupColorCollection() {
        colorTitleLabel.text = NSLocalizedString("newHabit.colorCollection.title", comment: "")
        colorTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)

        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
    }

    private func setupEmojiCollection() {
        emojiTitleLabel.text = NSLocalizedString("newHabit.emojiCollection.title", comment: "")
        emojiTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)

        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
    }

    private func setupNameField() {
        nameTextField.placeholder = NSLocalizedString("newHabit.nameField.placeholder", comment: "")
        nameTextField.backgroundColor = .secondarySystemBackground
        nameTextField.layer.cornerRadius = 16
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nameTextField.leftViewMode = .always
        nameTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
    }

    private func setupBottomButtons() {
        cancelButton.setTitle(NSLocalizedString("newHabit.cancelButton.title", comment: ""), for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

        saveButton.setTitle(NSLocalizedString("editHabit.saveButton.title", comment: ""), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .systemGray
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }

    private func addSubviews() {
        view.addSubview(completedDaysLabel)
        completedDaysLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emojiTitleLabel)
        emojiTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(colorTitleLabel)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(colorCollectionView)
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completedDaysLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            completedDaysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 70),

            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 140),

            emojiTitleLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 150),

            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            colorTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 150),

            stack.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    @objc
    private func textChanged() {
        updateSaveButtonState()
    }

    private func updateSaveButtonState() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasName = !name.isEmpty
        let hasSchedule = !selectedDays.isEmpty
        let hasCategory = !(categoryTitle?.isEmpty ?? true)

        let enabled = hasName && hasSchedule && hasCategory
        saveButton.isEnabled = enabled
        saveButton.backgroundColor = enabled ? .black : .systemGray
    }

    @objc
    private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc
    private func didTapSave() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let updatedTracker = Tracker(
            id: originalTracker.id,
            title: name,
            color: colors[selectedColorIndex ?? 0],
            emoji: selectedEmoji ?? originalTracker.emoji,
            schedule: selectedDays
        )

        delegate?.editHabitViewController(
            self,
            didUpdate: updatedTracker,
            categoryTitle: categoryTitle ?? originalCategoryTitle
        )
        dismiss(animated: true)
    }

    private func openSchedule() {
        let vc = ScheduleViewController(selectedDays: selectedDays)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openCategories() {
        let viewModel = CategoriesViewModel(selectedCategoryTitle: categoryTitle)
        let vc = CategoriesViewController(viewModel: viewModel)

        vc.onCategorySelected = { [weak self] title in
            self?.categoryTitle = title
            self?.tableView.reloadData()
            self?.updateSaveButtonState()
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension EditHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "optionCell")
        cell.accessoryType = .disclosureIndicator

        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("newHabit.table.category", comment: "")
            cell.detailTextLabel?.text = categoryTitle ?? ""
            cell.backgroundColor = .systemGroupedBackground
            cell.alpha = 0.3
        } else {
            cell.textLabel?.text = NSLocalizedString("newHabit.table.schedule", comment: "")

            if selectedDays.isEmpty {
                cell.detailTextLabel?.text = ""
            } else if selectedDays.count == 7 {
                cell.detailTextLabel?.text = NSLocalizedString("newHabit.table.everyday", comment: "")
            } else {
                let titles = selectedDays
                    .sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortTitle }
                    .joined(separator: ", ")
                cell.detailTextLabel?.text = titles
            }

            cell.backgroundColor = .systemGroupedBackground
            cell.alpha = 0.3
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            openCategories()
        } else {
            openSchedule()
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {

        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1

        if indexPath.row == lastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension EditHabitViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath)

            guard let cell = cell as? EmojiCell else {
                return cell
            }

            let emoji = emojis[indexPath.item]
            cell.configure(emoji: emoji, isSelected: selectedEmoji == emoji)

            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath)

        guard let cell = cell as? ColorCell else {
            return cell
        }

        let color = colors[indexPath.item]
        let isSelected = (selectedColorIndex == indexPath.item)
        cell.configure(color: color, isSelected: isSelected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let tapped = emojis[indexPath.item]
            selectedEmoji = (selectedEmoji == tapped) ? nil : tapped
            emojiCollectionView.reloadData()
            return
        }

        let tapped = indexPath.item
        selectedColorIndex = (selectedColorIndex == tapped) ? nil : tapped
        colorCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 50)
    }
}

extension EditHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays days: [Weekday]) {
        selectedDays = days
    }
}

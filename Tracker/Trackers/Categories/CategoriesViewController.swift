//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 09.03.2026.
//

import UIKit

final class CategoriesViewController: UIViewController {
    var onCategorySelected: ((String) -> Void)?

    private let viewModel: CategoriesViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    private var tableViewHeightConstraint: NSLayoutConstraint?

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категория"

        setupUI()
        setupConstraints()
        bindViewModel()
        viewModel.loadCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateTableHeight()
        }

        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            self?.tableView.isHidden = isEmpty
            self?.placeholderImageView.isHidden = !isEmpty
            self?.placeholderLabel.isHidden = !isEmpty
        }

        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelected?(title)
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        

        placeholderImageView.image = UIImage(resource: .dizzy)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false

        placeholderLabel.text = "Привычки и события можно объединить по смыслу"
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        

        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .black
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addButton)
    }

    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint!,

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateTableHeight() {
        tableView.layoutIfNeeded()

        let topY = tableView.frame.minY
        let bottomLimit = addButton.frame.minY - 16
        let availableHeight = bottomLimit - topY
        let contentHeight = tableView.contentSize.height

        guard availableHeight > 0 else { return }

        tableViewHeightConstraint?.constant = min(contentHeight, availableHeight)
        tableView.isScrollEnabled = contentHeight > availableHeight
    }

    @objc
    private func addButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] title in
            do {
                try self?.viewModel.createCategory(title: title)
            } catch {
                assertionFailure("Failed to create category: \(error)")
            }
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        let isLast = indexPath.row == viewModel.numberOfRows() - 1
        cell.configure(with: cellViewModel, isLast: isLast)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}

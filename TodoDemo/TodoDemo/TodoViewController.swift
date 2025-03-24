//
//  TodoViewController.swift
//  TodoDemo
//
//  Created by 강보현 on 3/21/25.
//

import UIKit
import CoreData

class TodoViewController: UIViewController{
    private var todos: [TodoItem] = []
    private var showCompletedOnly = false

    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }

    var activeTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    private var persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let addTodoView = UIView()
    let todoLabel = UILabel()
    let todoTitleTextField = UITextField()
    let todoAddButton = UIButton(type: .system)
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigation()
        configureSearchController()
        setupAddTodoView()
        configureTableView()
        loadTodoItems()
        
        
        // 키보드 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupAddTodoView() {
        addTodoView.layer.borderColor = UIColor.lightGray.cgColor
        addTodoView.layer.cornerRadius = 8
        addTodoView.layer.borderWidth = 1
        addTodoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addTodoView)
        
        todoLabel.text = "Todo 추가"
        todoLabel.font = .systemFont(ofSize: 16)
        todoLabel.textColor = UIColor.black
        todoLabel.translatesAutoresizingMaskIntoConstraints = false
        addTodoView.addSubview(todoLabel)
        
        todoTitleTextField.borderStyle = .roundedRect
        todoTitleTextField.placeholder = "Todo 제목을 입력하세요."
        todoTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        addTodoView.addSubview(todoTitleTextField)
        
        todoAddButton.setImage(UIImage.add, for: .normal)
        todoAddButton.setTitleColor(.black, for: .normal)
        todoAddButton.tintColor = .black
        todoAddButton.translatesAutoresizingMaskIntoConstraints = false
        addTodoView.addSubview(todoAddButton)
        todoAddButton.addTarget(self, action: #selector(addNewTodo), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        
        NSLayoutConstraint.activate([
            addTodoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            addTodoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addTodoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            todoLabel.topAnchor.constraint(equalTo: addTodoView.topAnchor, constant: 10),
            todoLabel.leadingAnchor.constraint(equalTo: addTodoView.leadingAnchor, constant: 10),
            todoLabel.trailingAnchor.constraint(equalTo: addTodoView.trailingAnchor, constant: -10),
            
            todoTitleTextField.topAnchor.constraint(equalTo: todoLabel.bottomAnchor, constant: 10),
            todoTitleTextField.leadingAnchor.constraint(equalTo: addTodoView.leadingAnchor, constant: 10),
            todoTitleTextField.trailingAnchor.constraint(equalTo: todoAddButton.leadingAnchor, constant: -10),
            todoAddButton.trailingAnchor.constraint(equalTo: addTodoView.trailingAnchor, constant: -10),
            todoAddButton.centerYAnchor.constraint(equalTo: todoTitleTextField.centerYAnchor),
            
            todoTitleTextField.heightAnchor.constraint(equalToConstant: 50),
            todoTitleTextField.bottomAnchor.constraint(equalTo: addTodoView.bottomAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: addTodoView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
        ])
        
        
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("키보드 표시")
        //        moveGroupBox(forEditing: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("키보드 숨김")
        //        moveGroupBox(forEditing: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 키보드 알림 해제
        NotificationCenter.default.removeObserver(self)
    }
    
    func configureNavigation() {
        title = "또두리스트"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    @objc func addNewTodo() {
        guard let title = todoTitleTextField.text, !title.isEmpty else {
            print("제목 비어있음")
            return
        }
        let newTodo = TodoItem(title: title, isCompleted: false)
        saveTodoItem(newTodo)
        
        todoTitleTextField.text = ""
        tableView.reloadData()
    }
    
    func saveTodoItem(_ item: TodoItem) {
        let _ = item.toManagedObject(in: viewContext)
        do {
            try viewContext.save()
            loadTodoItems()
        } catch {
            print("저장실패: \(error)")
        }
        
    }
    
    private func loadTodoItems() {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let result = try viewContext.fetch(request)
            todos = result.compactMap { TodoItem.from($0)}
            tableView.reloadData()
            
        } catch {
            print("데이터 로드 실패 \(error)")
        }
    }
    
    // 데이터 삭제
    private func deleteTodoItem(_ item: TodoItem) {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", item.id as CVarArg)
        
        do {
            let result = try viewContext.fetch(request)
            guard let object = result.first else { return }
            
            viewContext.delete(object)
            try viewContext.save()
            
            // 삭제 후 UI 업데이트
            loadTodoItems()
        } catch {
            print("삭제 실패: \(error)")
        }
    }
    
    func updateTodoItem(_ item: TodoItem, with newTitle: String) {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.title = newTitle
                try viewContext.save()
                loadTodoItems()
            }
        } catch {
            print("업데이트 실패: \(error)")
        }
    }
    
    
    func updateTodoItemCompletion(_ item: TodoItem) {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.isCompleted = item.isCompleted
                try viewContext.save()
                loadTodoItems()
            }
        } catch {
            print("완료 상태 업데이트 실패: \(error)")
        }
    }
}

extension TodoViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "해야 할 일" : "완료"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeTodos.count : completedTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let todo = indexPath.section == 0 ? activeTodos[indexPath.row] : completedTodos[indexPath.row]
        
        let attributedText = NSMutableAttributedString(string: todo.title)
        if todo.isCompleted {
            attributedText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSMakeRange(0, attributedText.length))
        }
        
        cell.textLabel?.attributedText = attributedText
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var item = indexPath.section == 0 ? activeTodos[indexPath.row] : completedTodos[indexPath.row]
        item.isCompleted.toggle()
        
        updateTodoItemCompletion(item)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, scuccess) in
            let item = self?.todos[indexPath.row]
            if let item = item {
                self?.deleteTodoItem(item)
            }
            scuccess(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (_, _, success) in
            guard let self = self else { return }
            let item = self.todos[indexPath.row]
            
            let alert = UIAlertController(
                title: "Todo 수정",
                message: "내용을 수정하세요",
                preferredStyle: .alert
            )
            
            alert.addTextField { textField in
                textField.text = item.title
            }
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { _ in
                guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
                self.updateTodoItem(item, with: newTitle)
            }))
            
            self.present(alert, animated: true)
            success(true)
        }
        
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}


// 검색 기능 구현
extension TodoViewController: UISearchResultsUpdating {

  // 검색 컨트롤러 설정
  func configureSearchController() {
    let searchController = UISearchController()
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "검색"
    navigationItem.searchController = searchController

    // 네비게이션 바에 검색바가 숨겨지지 않도록 설정
    navigationItem.hidesSearchBarWhenScrolling = false

    // 검색 결과 화면을 현재 뷰 컨트롤러로 설정
    definesPresentationContext = true
  }

  // 검색 기능 구현
  func searchTodoItems(_ text: String) {

    // 검색어가 없을 때 전체 데이터 로드
    if text.isEmpty {
        loadTodoItems()
      return
    }

      let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()

    request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
    
    do {
      let result = try viewContext.fetch(request)
      todos = result.compactMap { TodoItem.from($0) }
      tableView.reloadData()
    } catch {
      print("검색 실패: \(error)")
    }
  }

  func updateSearchResults(for searchController: UISearchController) {
    guard let text = searchController.searchBar.text else { return }
    searchTodoItems(text)
  }


}

#Preview{
    TodoViewController()
}

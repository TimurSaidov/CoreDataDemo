//
//  TableViewController.swift
//  CoreDataDemo
//
//  Created by Timur Saidov on 04.04.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

//    var toDoItems: [String] = []
    var toDoItems: [Task] = [] // Массив задач task типа Task со св-ом taskToDo. Массив экземпляров класса Task.
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Add task", message: "Add new task", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action: UIAlertAction) in
            let textField = ac.textFields?[0] // Добавление в константу задачи, записанной в текстовое поле AlertController.
//            self.toDoItems.insert((textField?.text)!, at: 0) // Добавление этой задачи в массив toDoItems.
            self.saveTask(taskToDo: (textField?.text)!) // Вызывается функция, которая присваивает свойство taskToDo = textField.text объекту (экземпляру) класса Task и сохраняет этот экземпляр в массив toDoItems.
            self.tableView.reloadData() // Обновление данных, таблицы.
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        ac.addTextField { (textField) in // Отображение textField в AlertController.
        }
        ac.addAction(ok) // Отображение кнопки OK в AlertController.
        ac.addAction(cancel) // Отображение кнопки Cancel в AlertController.
        present(ac, animated: true, completion: nil) // Отображение самого AlertController.
    }
    
    func saveTask(taskToDo: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // Добрались до файла AppDelegate.swift
        let context = appDelegate.persistentContainer.viewContext // Создание и обращение к контексту.
//        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) // Создание экземпляра сущноти Task, для которой затем создается объект.
//        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! Task // Cоздание объекта типа сущности Task (т.е. экземпляр класса Task) для сущности entity, которая является экземпляром сущности Task, в контексте.
//        taskObject.taskToDo = taskToDo // Св-ву объекта присваивается задача.
        let task = Task(context: context) // Создание пустого экземпляра типа сущности (класса) Task в контексте.
        task.taskToDo = taskToDo
        // Сохранение контекста, чтобы сохранился объект.
        do {
            try context.save()
//            toDoItems.append(taskObject) // Сохранение объекта класса Task taskObject в массив toDoItems.
            toDoItems.append(task)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Загрузка данных из CoreData до загрузки TableView, т.е. до выполнения метода viewDidLoad.
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // Добрались до файла AppDelegate.swift
        let context = appDelegate.persistentContainer.viewContext // Обращение к контексту.
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest() // Запрос по Task сущности.
        do {
            toDoItems = try context.fetch(fetchRequest) // Запрос fetchRequest обращается к контексту (базе данных) и просит вернуть сущность типа Task, т.е. все ее объекты. И все полученные объекты сохраняются в массив.
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = toDoItems[indexPath.row]
        cell.textLabel?.text = toDoItems[indexPath.row].taskToDo
        return cell
    }
    
    // Метод удаления задачи из tableView.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить") { (action: UITableViewRowAction, indexPath) -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let task = self.toDoItems[indexPath.row]
            context.delete(task) // Удаление задачи (task типа сущности Task со св-ом taskToDo) из контекста.
            self.toDoItems.remove(at: indexPath.row) // Удаление задачи из массива задач.
            // Пересохранение контекста.
            do {
                try context.save()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade) // Удаление св-ва задачи (taskToDo) из tableView.
                tableView.endUpdates()
                print(self.toDoItems.count)
            } catch let error as NSError {
                print("Error: \(error), description \(error.userInfo)")
            }
        }
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return [delete]
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context = appDelegate.persistentContainer.viewContext
//            let task = self.toDoItems[indexPath.row]
//            context.delete(task) // Удаление задачи (task типа сущности Task со св-ом taskToDo) из контекста.
//            self.toDoItems.remove(at: indexPath.row) // Удаление задачи из массива задач.
//            // Пересохранение контекста.
//            do {
//                try context.save()
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade) // Удаление св-ва задачи (taskToDo) из tableView.
//                tableView.endUpdates()
//                print(self.toDoItems.count)
//            } catch let error as NSError {
//                print("Error: \(error), description \(error.userInfo)")
//            }
//        }
//    }
}

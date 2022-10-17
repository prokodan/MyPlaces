//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Данил Прокопенко on 17.10.2022.
//

import UIKit

class MainViewController: UITableViewController {

    let restarauntNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restarauntNames.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let restaurants = restarauntNames[indexPath.row]
        var content = UIListContentConfiguration.cell()
        
        content.text = "\(restaurants)"
        content.imageProperties.cornerRadius = cell.frame.size.height / 2
        cell.imageView?.clipsToBounds = true
        content.image = UIImage(named: "\(restarauntNames[indexPath.row])")
        
        cell.contentConfiguration = content
        return cell
    }
   
//MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }

//MARK: - Navigation
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
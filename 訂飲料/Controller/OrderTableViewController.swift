import UIKit

class OrderTableViewController: UITableViewController {

    var orders: [OrderModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.fetchOrder() { result in
            switch result {
            case .success(let orders):
                self.orders = orders
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
        let order = orders[indexPath.row]
        cell.drinkLabel.text = order.drink.name + order.size
        cell.detailLabel.text = order.sugar + order.ice
        if let toppings = order.toppings {
            var complement = " / 加"
            for i in 0..<toppings.count {
                complement += toppings[i]
                if i < toppings.count - 1 && toppings.count > 1 {
                    complement += "、"
                }
            }
            cell.detailLabel.text?.append(complement)
        }
        cell.customerLabel.text = order.customerName
        cell.countLabel.text = "\(order.count)杯"
        cell.totalLabel.text = "$\(order.total)"
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.deleteOrder(orders[indexPath.row])
            orders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

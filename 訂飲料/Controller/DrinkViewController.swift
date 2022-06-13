import UIKit

class DrinkViewController: UIViewController {
    
    var drink: DrinkModel
    var order: OrderModel {
        didSet {
            order.updateTotal(count: Int(stepper.value))
            updatePriceLabel()
        }
    }
    
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        order.count = Int(sender.value)
        countLabel.text = "\(order.count) 杯"
    }
    @IBAction func placeOrderButtonPressed(_ sender: UIButton) {
        guard order.customerName != "" else {
            let controller = UIAlertController(title: "請填入訂購人！", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default, handler: nil)
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
            return
        }
        DataManager.shared.uploadOrder(order: order)
    }
    
    init?(coder: NSCoder, selectedDrink: DrinkModel) {
//        print(selectedDrink)
        self.drink = selectedDrink
        self.order = OrderModel(drink: drink, sugar: SugarLevel.allCases[0].rawValue, ice: IceLevel.allCases[0].rawValue, count: 1, size: drink.priceM != nil ? "M" : "L", total: drink.priceM ?? drink.priceL!)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drinkName.text = drink.name
        updatePriceLabel()
    }
    
    func updatePriceLabel() {
        priceLabel.text = "小計：$\(order.total)"
    }
    
    // MARK: - Segue
    @IBSegueAction func showDrinkTableView(_ coder: NSCoder) -> DrinkTableViewController? {
        return DrinkTableViewController(coder: coder, selectedDrink: drink, order: order)
    }
    
    @IBAction func unwindToDrinkView(_ unwindSegue: UIStoryboardSegue) {
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "updateOrder" {
//
//        }
//    }
}

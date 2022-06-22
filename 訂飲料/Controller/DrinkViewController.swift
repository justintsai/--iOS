import UIKit

class DrinkViewController: UIViewController {
    
    var drink: DrinkModel
    var order: OrderModel {
        didSet {
            order.count = Int(stepper.value)
            order.updateTotal(count: order.count)
            updatePriceLabel()
        }
    }
    
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        order.count = Int(stepper.value)
        countLabel.text = "\(order.count) 杯"
    }
    
    @IBAction func placeOrderButtonPressed(_ sender: UIButton) {
        guard order.customerName != "" else {
            showAlert(title: "請填入訂購人！", message: nil)
            return
        }
        
        var message = "\(order.drink.name) \(order.size) 共\(order.count)杯\n\(order.ice)\(order.sugar)"
        if let toppings = order.toppings, toppings != [] {
            message += "\n加"
            for i in 0..<toppings.count {
                message += toppings[i]
                if i < toppings.count - 1 && toppings.count > 1 {
                    message += "、"
                }
            }
        }
        DataManager.shared.uploadOrder(order: order) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "已送出訂單！🎉", message: message)
                }
            case .failure(let networkError):
                switch networkError {
                case .invalidUrl:
                    print(networkError)
                case .requestFailed(let error):
                    print(networkError, error)
                case .invalidData:
                    print(networkError)
                case .invalidResponse:
                    print(networkError)
                }
            }
        }
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
    
    func showAlert(title: String, message: String?) {
        let controller = UIAlertController(title: title, message: message ?? "", preferredStyle: .alert)
        let action = UIAlertAction(title: "確定", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
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

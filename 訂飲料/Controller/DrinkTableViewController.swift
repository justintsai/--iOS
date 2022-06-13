import UIKit

class DrinkTableViewController: UITableViewController {
    
    var drink: DrinkModel
    var order: OrderModel {
        didSet {
            performSegue(withIdentifier: "unwindToDrinkView", sender: nil)
        }
    }
    
    var selectedToppingButtons: [UIButton] = []
    
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var drinkDescription: UILabel!
    @IBOutlet weak var customerName: UITextField!
    @IBOutlet var sizeButtons: [UIButton]!
    @IBOutlet var iceLevel: [UIButton]!
    @IBOutlet var sugarLevel: [UIButton]!
    @IBOutlet var toppingButtons: [UIButton]!
    
    @IBAction func sizeButtonPressed(_ sender: UIButton) {
        order.size = (sender.titleLabel?.text)!
        changeButtonColor(buttons: sizeButtons, selectedButtons: [sender])
    }
    
    @IBAction func iceButtonPressed(_ sender: UIButton) {
        order.ice = (sender.titleLabel?.text)!
        changeButtonColor(buttons: iceLevel, selectedButtons: [sender])
    }
    
    @IBAction func sugarButtonPressed(_ sender: UIButton) {
        order.sugar = (sender.titleLabel?.text)!
        changeButtonColor(buttons: sugarLevel, selectedButtons: [sender])
    }
    
    @IBAction func toppingButtonPressed(_ sender: UIButton) {
        if selectedToppingButtons.contains(sender) {
            selectedToppingButtons.removeAll(where: { $0 == sender} )
        } else {
            selectedToppingButtons.append(sender)
        }
        order.toppings = selectedToppingButtons.map{($0.titleLabel?.text)!}
        changeButtonColor(buttons: toppingButtons, selectedButtons: selectedToppingButtons)
    }
    
    
    init?(coder: NSCoder, selectedDrink: DrinkModel, order: OrderModel) {
        self.drink = selectedDrink
        self.order = order
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        customerName.delegate = self
        customerName.addTarget(self, action: #selector(DrinkTableViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        order.customerName = customerName.text!
    }

    func updateUI() {
        let url = drink.imageURL
        DataManager.shared.fetchImage(url: url) { image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.drinkImage.image = image
            }
        }
        drinkDescription.text = drink.description
        
        if drink.priceM == nil {
            sizeButtons[0].isHidden = true
            sizeButtonPressed(sizeButtons[1])
        } else if drink.priceL == nil {
            sizeButtons[1].isHidden = true
            sizeButtonPressed(sizeButtons[0])
        } else {
            sizeButtonPressed(sizeButtons[0])
        }
        
        if drink.iced ?? false {
            for i in 5...7 {
                iceLevel[i].isHidden = true
            }
        }
        changeButtonColor(buttons: iceLevel, selectedButtons: [iceLevel[0]])
        
        if drink.sweet ?? false {
            for i in 1...6 {
                sugarLevel[i].isHidden = true
            }
        } else {
            sugarLevel[7].isHidden = true
        }
        changeButtonColor(buttons: sugarLevel, selectedButtons: [sugarLevel[0]])
    }
    
    func changeButtonColor(buttons: [UIButton], selectedButtons: [UIButton]) {
        for button in buttons {
            button.configuration?.baseBackgroundColor = UIColor(named: "lightblue")
        }
        for button in selectedButtons {
            button.configuration?.baseBackgroundColor = UIColor(named:"blue")
        }
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToDrinkView" {
            let controller = segue.destination as! DrinkViewController
            controller.order = order
        }
    }
    
}

extension DrinkTableViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

//extension UIImageView {
//    var contentClippingRect: CGRect {
//        guard let image = image else { return bounds }
//        guard contentMode == .scaleAspectFit else { return bounds }
//        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
//
//        let scale: CGFloat
//        if image.size.width > image.size.height {
//            scale = bounds.width / image.size.width
//        } else {
//            scale = bounds.height / image.size.height
//        }
//
//        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
//        let x = (bounds.width - size.width) / 2.0
//        let y = (bounds.height - size.height) / 2.0
//
//        return CGRect(x: x, y: y, width: size.width, height: size.height)
//    }
//}

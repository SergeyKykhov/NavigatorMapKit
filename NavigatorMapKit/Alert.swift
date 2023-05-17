//
//  Alert.swift
//  NavigatorMapKit
//
//  Created by Sergey Kykhov on 17.05.2023.
//

import UIKit

extension UIViewController {

// MARK: - Метод вызывающий окно для ввода адреса
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in

            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }

        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }

        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
        }

        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)

        present(alertController, animated: true, completion: nil)
    }

// MARK: - Метод вызывающий окно из-за ошибки
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)

        alertController.addAction(alertOk)

        present(alertController, animated: true, completion: nil)
    }
}

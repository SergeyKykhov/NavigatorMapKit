//
//  ViewController.swift
//  NavigatorMapKit
//
//  Created by Sergey Kykhov on 17.05.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - Map
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    // MARK: - Buttons
    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    // MARK: - Location array
    var annotationArray = [MKPointAnnotation]()


    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        view.backgroundColor = .gray
        setConstraints()

        // MARK: - ButtonTarget
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTaped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTaped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTaped), for: .touchUpInside)
    }

    // MARK: - Selectors
    @objc func addAdressButtonTaped() {
        alertAddAdress(title: "Добавить", placeholder: "Введите адрес") { [self] (text) in
            setupPlacemark(adressPlace: text)
        }
    }

    @objc func routeButtonTaped() {
        for index in 0...annotationArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index + 1].coordinate)
        }
        //отобоажаем маршрут на карте
        mapView.showAnnotations(annotationArray, animated: true)
    }

    @objc func resetButtonTaped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }

    // MARK: - Placemark (обработка ошибки и установка метки(annotation))
    private func setupPlacemark(adressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                alertError(title: "Ощибка", message: "Сервер недоступен. Попробуйте добавить адрес повторно")
                return
            }

            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate

            // Добавляем точки локации в массив и условие по пявлению кнопок построения маршрута
            annotationArray.append(annotation)

            if annotationArray.count > 1 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            mapView.showAnnotations(annotationArray, animated: true)
        }
    }

    // MARK: - Create direction (Создание маршрута между точками)
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)

        //Делаем запрос
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        //вариант перемещения пешком
        request.transportType = .walking
        //альтернативные маршруты показывать
        request.requestsAlternateRoutes = true

        let diraction = MKDirections(request: request)
        diraction.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }

            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }

            //Ищем минимальный маршрут
            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }

            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}
// MARK: - Route display
// Создаем расширение для настройки отображения маршрута.
extension ViewController :MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .green
        return render
    }
}

// MARK: - Constraints
extension ViewController {
    func setConstraints() {

        //Устанавливаем mapView на View
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        //Устанавливаем кнопки на mapView
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 40),
            addAdressButton.widthAnchor.constraint(equalToConstant: 40)
        ])

        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            routeButton.heightAnchor.constraint(equalToConstant: 40),
            routeButton.widthAnchor.constraint(equalToConstant: 40)
        ])

        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            resetButton.heightAnchor.constraint(equalToConstant: 40),
            resetButton.widthAnchor.constraint(equalToConstant: 40)
        ])

    }
}


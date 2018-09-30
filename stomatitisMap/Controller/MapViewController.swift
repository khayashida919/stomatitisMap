//
//  MapViewController.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/05/16.
//  Copyright © 2018年 khayashida. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleMobileAds
import TwitterKit

final class MapViewController: UIViewController {
    // MARK: Properties
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var count: UILabel!
    
    private var annotations = [MKPointAnnotation]()
    private let locationManager = CLLocationManager() // インスタンスの生成
    private var databaseReference: DatabaseReference! //RealmTimeDatabase宣言
    private var isFirstTime = AppData.shared.isFirstTime //アプリが起動された時はtrue。位置情報を取得し終えマップの表示が終わったらfalse
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self // CLLocationManagerDelegateをselfに指定
        mapView.delegate = self
        databaseReference = Database.database().reference() //RealmTimeDatabaseの初期化

        var admobView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        admobView.frame.origin = CGPoint(x: 0, y: view.frame.size.height - admobView.frame.height)
        admobView.frame.size = CGSize(width: view.frame.width, height: admobView.frame.height)
        admobView.adUnitID = "ca-app-pub-7093305833453939/4127453719" //main
//        admobView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
        admobView.rootViewController = self
        admobView.load(GADRequest())
        addBannerViewToView(admobView)
        
        firebaseCallBack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime {
            startIndicator() {
                self.locationManager.requestLocation() // 位置情報の取得取得
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Method
    @IBAction func stomatitisButtonTapped(_ sender: UIButton) {
        startIndicator() {
            self.locationManager.requestLocation() // 位置情報の取得取得
        }
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        let composer = TWTRComposer()
        composer.setText("口内炎を痛がりました。 #口内炎")
        composer.show(from: self, completion: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        showMenu()
    }
    
    func menu(_ menu: Menu) { //別ViewControllerから呼ばれるためinternal
        performSegue(withIdentifier: menu.info.segue, sender: nil)
    }
    
    //データベースとアクセス
    private func firebaseCallBack() {
        // クラウド上で、ノード location に変更があった場合のコールバック処理
        databaseReference.child("location").observe(.value) { (snap: DataSnapshot) in
            guard let locations = snap.value as? [String: [String: String]] else { return }
            self.annotations.removeAll()
            History.reset()
            locations.forEach {
                guard let latitudeString = $0.value["latitude"] else { return }
                guard let longitudeString = $0.value["longitude"] else { return }
                guard let time = $0.value["timestamp"] else { return }
                guard let letlatitudeDouble = Double(latitudeString) else { return }
                guard let longitudedeDouble = Double(longitudeString) else { return }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(letlatitudeDouble, longitudedeDouble)
                annotation.title = time
                self.annotations.append(annotation)
                
                //受け取った口内炎情報が14日間を過ぎていた場合はデータベースから削除
                guard let date = AppData.shared.dateFormater.date(from: time) else { return }
                let dif = abs(Int(date.timeIntervalSinceNow/60/60/24))
                
                switch dif {
                case 0...4:
                    History.add(day: dif)
                case 14...:
//                    self.databaseReference.child("location").child($0.key).removeValue()
                    break
                default:
                    return
                }
            }
            History.sum = self.annotations.count
            self.count.text = String(self.annotations.count)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
        ])
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showAlert(title: .error, massage: status.discription, button: .ok)
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    // requestLocation()を使用する場合、失敗した際のDelegateメソッドの実装が必須
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopIndicator()
        print("位置情報の取得に失敗しました")
        showAlert(title: .error,
                  massage: "位置情報設定が「無効」になっていないかご確認ください。\n 設定 > プライバシー > 位置情報サービス",
                  button: .ok)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let timestamp = AppData.shared.dateFormater.string(from: location.timestamp)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude,
                                                    location.coordinate.longitude)
        let locationData = ["latitude": String(location.coordinate.latitude),
                        "longitude": String(location.coordinate.longitude),
                        "timestamp": timestamp]
        
        if isFirstTime { //アプリ起動時は位置情報だけ取得して取得できた位置をマップで表示する
            isFirstTime = false
            let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else { //アプリ起動後は位置情報をデータベースで送信
            databaseReference.child("location").childByAutoId().setValue(locationData)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        stopIndicator()
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.image = UIImage(named: "kounaien_small")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let indicatorViewController = mainStoryboard.instantiateViewController(withIdentifier: "toLevelViewController") as? IndicatorViewController else { return }
//        performSegue(withIdentifier: "toLevelViewController", sender: nil)
    }
}


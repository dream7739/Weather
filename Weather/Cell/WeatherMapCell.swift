//
//  WeatherMapCell.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import MapKit
import SnapKit

final class WeatherMapCell: BaseCollectionViewCell {
    private let mapView = MKMapView()
    
    override func configureHierarchy() {
        contentView.addSubview(mapView)
    }
    
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.horizontalEdges.bottom.equalTo(contentView).inset(8)
        }
    }
    override func configureUI() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        mapView.overrideUserInterfaceStyle = .dark
        mapView.isScrollEnabled = false
    }
    
    func configureData(_ data: MapWeather){
        let center = CLLocationCoordinate2D(latitude: data.lat, longitude: data.lon)
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        configureAnnotation(center)
    }
    
    private func configureAnnotation(_ center: CLLocationCoordinate2D){
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
    }
}

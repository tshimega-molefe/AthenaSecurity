//
//  MapView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import MapboxMaps

struct MapViewRepresentable: UIViewControllerRepresentable {
    
     
    func makeUIViewController(context: Context) -> MapViewController {
           return MapViewController()
       }
      
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
}

class MapViewController: UIViewController {
   internal var mapView: MapView!
   override public func viewDidLoad() {
       super.viewDidLoad()
       let coordinate = CLLocationCoordinate2D(latitude: -26.1090427, longitude: 28.05240521558045)

       let iconSize: Double = 0.25
       
       let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1IjoidHNoaW1lZ2EiLCJhIjoiY2xham9qdXY0MDA5dzNxbXZvYnhweHp3eCJ9.AACTDu0VM5PEhfhpejujwA")
       let cameraOptions = CameraOptions(center: coordinate, zoom: 13, bearing: -17.6, pitch: 78)
       
       let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: StyleURI(rawValue: "mapbox://styles/tshimega/clajmjpb9001q14ntt9p6t1wt"))

       mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       self.view.addSubview(mapView)
       
       
       var pointAnnotation = PointAnnotation(coordinate: coordinate)
       
       pointAnnotation.image = .init(image: UIImage(named: "user")!, name: "user")
       pointAnnotation.iconSize = iconSize
       pointAnnotation.iconAnchor = .center
       
       let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
              pointAnnotationManager.annotations = [pointAnnotation]
   }
}

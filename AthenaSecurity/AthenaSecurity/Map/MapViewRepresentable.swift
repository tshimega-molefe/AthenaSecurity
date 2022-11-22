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

public class MapViewController: UIViewController {
    
   internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!
    internal let toggleBearingImageButton: UIButton = UIButton(frame: .zero)
    @objc internal var showsBearingImage: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }
    
   override public func viewDidLoad() {
       super.viewDidLoad()
       
       // Set Map Resource Options
       let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1IjoidHNoaW1lZ2EiLCJhIjoiY2xham9qdXY0MDA5dzNxbXZvYnhweHp3eCJ9.AACTDu0VM5PEhfhpejujwA")
       
       // Set initial camera settings
       let options = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: CameraOptions(zoom: 15.0, pitch: 78), styleURI: StyleURI(rawValue: "mapbox://styles/tshimega/clajmjpb9001q14ntt9p6t1wt"))
       
       mapView = MapView(frame: view.bounds, mapInitOptions: options)
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       self.view.addSubview(mapView)
       
       // Setup and create button for toggling show bearing image
       setupToggleShowBearingImageButton()
       
       cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
       
       // Add user position icon to the map with location indicator layer
       mapView.location.options.puckType = .puck2D()
       
       // Allows the delegate to receive information about map events.
       mapView.mapboxMap.onNext(event: .mapLoaded) { [self]_ in
           // Register the location consumer with the map
           // Note that the location manager holds weak refereences to consumers, which should be retained
           self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)

       }
   }
    
    @objc func showHideBearingImage() {
        showsBearingImage.toggle()
    }
    
    @objc func syncPuckAndButton() {
        // Update puck config
        let configuration = Puck2DConfiguration.makeDefault(showBearing: showsBearingImage)
        
        mapView.location.options.puckType = .puck2D(configuration)
        
        // Update button title
        let title: String = showsBearingImage ? "Hide bearing image" : "Show bearing image"
        toggleBearingImageButton.setTitle(title, for: .normal)
    }
    
    private func setupToggleShowBearingImageButton() {
        // Styling
        toggleBearingImageButton.backgroundColor = .systemBlue
        toggleBearingImageButton.addTarget(self, action:
                                            #selector(setter: showsBearingImage), for: .touchUpInside)
        toggleBearingImageButton.setTitleColor(.white, for: .normal)
        syncPuckAndButton()
        toggleBearingImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleBearingImageButton)
        
        // Constraints
        toggleBearingImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleBearingImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleBearingImageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
    }
}

// Create class which conforms to LocationConsumer, update the camera's centerCoordinate when a locationUpdate is received
public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?
    
    init(mapView: MapView) {
        self.mapView = mapView
    }
    
    public func locationUpdate(newLocation: Location) {
        mapView?.camera.ease(to: CameraOptions(center: newLocation.coordinate, zoom: 15, pitch: 78), duration: 1.3)
    }
}


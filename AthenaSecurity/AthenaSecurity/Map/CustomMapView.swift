//
//  MapView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//


import SwiftUI
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import ComposableArchitecture


struct CustomMapView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        
    }
}

class MapViewController: UIViewController, AnnotationInteractionDelegate {
    // InfoMapView Variables
    internal var infoMapView: MapView!
    
    
    // NavigationMapView Variables
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?

    // Annotations
    var securityAnnotation: PointAnnotation?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationMapView
        navigationMapView = NavigationMapView(frame: view.bounds)
        view.addSubview(navigationMapView)
        
        // InfoMapView Initialisers
        let myResourceOptions = ResourceOptions(accessToken: "Athena's-Access-Token")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        infoMapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        infoMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.view.addSubview(infoMapView)

        // Set the annotation manager's delegate
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }

        // Configure how map displays the user's location
        navigationMapView.userLocationStyle = .puck2D()
        // Switch viewport datasource to track `raw` location updates instead of `passive` mode.
        navigationMapView.navigationCamera.viewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        

        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)
    }

    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }

        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)

        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)

        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            // Calculate the route from the user's location to the set destination
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }

    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")

        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions

                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)

                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                    // Display callout view on destination annotation
                    annotation.textField = "Start navigation"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                    
                    strongSelf.securityAnnotation = annotation
                    strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                }
            }
        }
    }

    func drawRoute(route: Route) {

        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])

        // Show destination waypoint on the map
        navigationMapView.showWaypoints(on: route)
    }

    // Present the navigation view controller when the annotation is selected
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard annotations.first?.id == securityAnnotation?.id,
            let routeResponse = routeResponse, let routeOptions = routeOptions else {
            return
        }
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
}

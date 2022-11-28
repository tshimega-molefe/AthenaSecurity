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
import Combine


struct CustomMapView: UIViewControllerRepresentable {
    var store: StoreOf<MapFeature>

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(store: store)
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        
    }
}

class MapViewController: UIViewController, AnnotationInteractionDelegate {
    open var viewStore: ViewStoreOf<MapFeature>
    var cancellables: Set<AnyCancellable> = []
    
    
    public init(store: StoreOf<MapFeature>) {
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    // InfoMapView Variables
    internal var infoMapView: MapView!
    internal var locationManager: CLLocationManager?
    internal var cameraLocationConsumer: CameraLocationConsumer!
    
    // NavigationMapView Variables
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    
    // Annotations
    var securityAnnotation: PointAnnotation?
    var citizenAnnotation: CircleAnnotation!
    
    var circleAnnotationManager: CircleAnnotationManager!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        view.addSubview(navigationMapView)
        
        let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1IjoidHNoaW1lZ2EiLCJhIjoiY2xham9qdXY0MDA5dzNxbXZvYnhweHp3eCJ9.AACTDu0VM5PEhfhpejujwA")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        infoMapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        infoMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        self.view.addSubview(infoMapView)
        
        cameraLocationConsumer = CameraLocationConsumer(mapView: navigationMapView.mapView, viewStore: self.viewStore)
        
        // Set the annotation manager's delegate
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.navigationMapView.pointAnnotationManager?.delegate = self
            self.navigationMapView.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
            
        }
        
        // Configure how map displays the user's location
        navigationMapView.userLocationStyle = .puck2D()
        // Switch viewport datasource to track `raw` location updates instead of `passive` mode.
        navigationMapView.navigationCamera.viewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        
        // Create the `CircleAnnotationManager` which will be responsible for handling this annotation
        circleAnnotationManager = navigationMapView.mapView.annotations.makeCircleAnnotationManager()

        
        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)
        
        self.viewStore.publisher.tappedCoordinate
            .sink { [weak self] tappedCoordinate in
                
                if let tappedCoordinate = tappedCoordinate {
                    
                    if let origin = self?.navigationMapView.mapView.location.latestLocation?.coordinate {
                        // Calculate the route from the user's location to the set destination
                        //self?.calculateRoute(from: origin, to: tappedCoordinate)
                        
                        //self?.viewStore.send(.calculateRoute(origin: origin, destination: tappedCoordinate))
                        //self?.viewStore.send(.updateCitizenLocation(tappedCoordinate))
                       
                    } else {
                        print("Failed to get user location, make sure to allow location access for this application.")
                    }
                }
            }
            .store(in: &self.cancellables)
        
        
        self.viewStore.publisher.citizenLocation
            .sink { [weak self] citizenLocation in
                
                if let citizenLocation = citizenLocation {
                    
                    (self?.citizenAnnotation == nil) ? self?.addCitizenAnnotation(coordinate: citizenLocation) : self?.updateCitizenAnnotation(coordinate: citizenLocation)
                }
            }
            .store(in: &self.cancellables)
        
        self.viewStore.publisher.route
            .sink { [weak self] route in
                
                if let route = route {
                    
                    self?.drawRoute(route: route)
                    if var annotation = self?.navigationMapView.pointAnnotationManager?.annotations.first {
                        // Display callout view on destination annotation
                        annotation.textField = "Start navigation"
                        annotation.textColor = .init(UIColor.white)
                        annotation.textHaloColor = .init(UIColor.systemBlue)
                        annotation.textHaloWidth = 2
                        annotation.textAnchor = .top
                        annotation.textRadialOffset = 1.0
                        
                        self?.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                    }
                }
            }
            .store(in: &self.cancellables)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = navigationMapView.mapView.mapboxMap.coordinate(for: gesture.location(in: gesture.view))
        
        self.viewStore.send(
            .longPress(location)
        )
    }
    
    private func addCitizenAnnotation(coordinate: CLLocationCoordinate2D) {
        citizenAnnotation = CircleAnnotation(centerCoordinate: coordinate)
        citizenAnnotation.circleColor = StyleColor(.blue)
        circleAnnotationManager.annotations = [citizenAnnotation]
    }
    
    private func updateCitizenAnnotation(coordinate: CLLocationCoordinate2D) {
        citizenAnnotation.point = Point(coordinate)
        circleAnnotationManager.annotations = [citizenAnnotation]
    }
    
    private func drawRoute(route: Route) {
        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])
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

//extension MapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last
//        let loc = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)! )
//        let newCamera = CameraOptions(center: loc, zoom: 18.0, bearing: 180.0, pitch: 15.0)
//        self.citizenAnnotation.point = Point(loc)
//
//        //self.citizenAnnotation.iconRotate = bearing
//        self.circleAnnotationManager.annotations = [self.citizenAnnotation]
//        self.navigationMapView.mapView.camera.ease(to: newCamera, duration: 2.0)
//    }
//
//    func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
//        let x1 = from.longitude * (Double.pi / 180.0)
//        let y1 = from.latitude  * (Double.pi / 180.0)
//        let x2 = to.longitude   * (Double.pi / 180.0)
//        let y2 = to.latitude    * (Double.pi / 180.0)
//
//        let dx = x2 - x1
//        let sita = atan2(sin(dx) * cos(y2), cos(y1) * sin(y2) - sin(y1) * cos(y2) * cos(dx))
//
//        return sita * (180.0 / Double.pi)
//    }
//}

public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?
    weak var viewStore: ViewStoreOf<MapFeature>?
    
    init(mapView: MapView, viewStore: ViewStoreOf<MapFeature>) {
        self.mapView = mapView
        self.viewStore = viewStore
    }
    
    public func locationUpdate(newLocation: Location) {
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 1.3)
        viewStore?.send(.updateUserLocation(newLocation.coordinate))
        
    }
}

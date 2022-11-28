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
    
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(store: Store(
            initialState: MapFeature.State(),
            reducer: AnyReducer(MapFeature()),
            environment: ()))
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
    
    
    // NavigationMapView Variables
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        view.addSubview(navigationMapView)
        
        let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1IjoidHNoaW1lZ2EiLCJhIjoiY2xham9qdXY0MDA5dzNxbXZvYnhweHp3eCJ9.AACTDu0VM5PEhfhpejujwA")
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
        
        self.viewStore.publisher.tappedCoordinate
            .sink { [weak self] tappedCoordinate in
                
                if let tappedCoordinate = tappedCoordinate {
                    
                    if let origin = self?.navigationMapView.mapView.location.latestLocation?.coordinate {
                        // Calculate the route from the user's location to the set destination
                        //self?.calculateRoute(from: origin, to: tappedCoordinate)
                        
                         self?.viewStore.send(.calculateRoute(origin: origin, destination: tappedCoordinate))
                    } else {
                        print("Failed to get user location, make sure to allow location access for this application.")
                    }
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
    
    func drawRoute(route: Route) {
        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])
        navigationMapView.showWaypoints(on: route)
    }
    
    // Present the navigation view controller when the annotation is selected
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let routeResponse = routeResponse, let routeOptions = routeOptions else {
            return
        }
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
}

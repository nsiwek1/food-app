import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isRequestingLocation = false
    @Published var permissionRequested = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Lower accuracy for faster results
        print("📍 LocationManager: Initialized with accuracy: \(locationManager.desiredAccuracy)")
        
        // Check current authorization status
        authorizationStatus = locationManager.authorizationStatus
        print("📍 LocationManager: Initial authorization status: \(authorizationStatus.rawValue)")
    }
    
    func requestLocation() {
        print("📍 LocationManager: requestLocation() called")
        print("📍 LocationManager: Current authorization status: \(authorizationStatus.rawValue)")
        
        isRequestingLocation = true
        
        switch authorizationStatus {
        case .notDetermined:
            print("📍 LocationManager: Requesting permission...")
            permissionRequested = true
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            print("📍 LocationManager: Permission denied or restricted")
            errorMessage = "Location access is required to find restaurants near you. Please enable location access in System Preferences > Security & Privacy > Privacy > Location Services."
            isRequestingLocation = false
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 LocationManager: Permission granted, requesting location...")
            locationManager.requestLocation()
            
        @unknown default:
            print("📍 LocationManager: Unknown authorization status")
            errorMessage = "Unknown location authorization status"
            isRequestingLocation = false
        }
    }
    
    func requestPermission() {
        print("📍 LocationManager: Explicitly requesting permission...")
        permissionRequested = true
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationServicesEnabled() -> Bool {
        let enabled = CLLocationManager.locationServicesEnabled()
        print("📍 LocationManager: Location services enabled: \(enabled)")
        return enabled
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 LocationManager: Location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        self.location = location
        self.errorMessage = nil
        self.isRequestingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 LocationManager: Location error: \(error.localizedDescription)")
        self.errorMessage = error.localizedDescription
        self.isRequestingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📍 LocationManager: Authorization status changed to: \(status.rawValue)")
        self.authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 LocationManager: Permission granted, requesting location...")
            locationManager.requestLocation()
            
        case .denied, .restricted:
            print("📍 LocationManager: Permission denied")
            errorMessage = "Location access denied. Please enable location access in System Preferences."
            isRequestingLocation = false
            
        case .notDetermined:
            print("📍 LocationManager: Permission not determined")
            if !permissionRequested {
                requestPermission()
            }
            
        @unknown default:
            print("📍 LocationManager: Unknown authorization status")
            errorMessage = "Unknown location authorization status"
            isRequestingLocation = false
        }
    }
} 
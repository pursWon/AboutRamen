import UIKit
import MapKit
import CoreLocation

/// 저장된/조회된 라멘 가게들을 지도 위에서 보여주는 화면 (스토리보드 없이 코드로만 구성)
class MapViewController: UIViewController {
    // MARK: - UI
    private let mapView = MKMapView()

    // MARK: - Properties
    /// 지도에 핀으로 표시할 라멘 가게 목록
    var stores: [RamenData] = []
    /// 표시할 가게가 없을 때 지도 중심으로 삼을 위치
    var centerLocation: CLLocation?

    // MARK: - View Life Cycle
    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "지도로 보기"
        mapView.delegate = self
        mapView.showsUserLocation = true

        addAnnotations()
        focusMap()
    }

    // MARK: - Set Up
    private func addAnnotations() {
        let annotations = stores.map { RamenAnnotation(store: $0) }
        mapView.addAnnotations(annotations)
    }

    private func focusMap() {
        if !mapView.annotations.isEmpty {
            mapView.showAnnotations(mapView.annotations, animated: false)
        } else if let centerLocation = centerLocation {
            let region = MKCoordinateRegion(center: centerLocation.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
            mapView.setRegion(region, animated: false)
        }
    }
}

// MARK: - RamenAnnotation
final class RamenAnnotation: NSObject, MKAnnotation {
    let store: RamenData

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: store.y, longitude: store.x)
    }
    var title: String? { store.storeName }
    var subtitle: String? { store.addressName.isEmpty ? "주소 정보 없음" : store.addressName }

    init(store: RamenData) {
        self.store = store
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is RamenAnnotation else { return nil }

        let identifier = "RamenAnnotationView"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        annotationView.annotation = annotation
        annotationView.canShowCallout = true
        annotationView.markerTintColor = CustomColor.accent
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? RamenAnnotation else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }

        detailVC.selectedRamen = annotation.store
        setCustomBackButton(title: "지도로 보기")
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

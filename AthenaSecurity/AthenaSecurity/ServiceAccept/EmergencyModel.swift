//
//  EmergencyModel.swift
//  AthenaSecurity
//
//  Created by Dev Jacobson on 2022/11/21.
//

import Foundation
import CoreLocation

struct EmergencyModel: Equatable, Codable {
    var type: String?
    var id: String?
    var status: String?
    var security: LocationModel?
    var citizen: LocationModel?
}

struct LocationModel: Equatable, Codable {
    var coordinate: CoordinateModel
}

struct CoordinateModel: Equatable, Codable {
    var latitude: Double
    var longitude: Double
}

//
//  Mountain.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright © 2019 Freshworks Studio Inc. All rights reserved.
//

import Foundation

struct Mountain {
    let id: String = UUID().uuidString
    
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    let name: String
}

struct SimpleData_Mountains {
    static let mountains: [Mountain] = [
        Mountain(latitude: 27.98806, longitude: 86.92528, altitude: 8848, name: "Mount Everest"),
        Mountain(latitude: 35.88139, longitude: 76.51333, altitude: 8611, name: "K2"),
        Mountain(latitude: 27.70333, longitude: 88.1475, altitude: 8586, name: "Kangchenjunga"),
        Mountain(latitude: 63.06900, longitude: -151.0063, altitude: 6191, name: "Mount McKinley"),
        Mountain(latitude: 60.56710, longitude: -140.4055, altitude: 5959, name: "Mount Logan")
    ]
}

struct VictoriaLandmark {
    let id: String = UUID().uuidString
    
    let latitude: Double
    let longitude: Double
    
    let name: String
    let details: String?
}

struct VictoriaData_Landmarks {
    static let landmarks: [VictoriaLandmark] = [
        VictoriaLandmark(latitude: 48.419475, longitude: -123.370296, name: "Legislative Assembly of British Columbia", details: "The British Columbia Parliament Buildings are located in Victoria, British Columbia, Canada, and are home to the Legislative Assembly of British Columbia. The Speaker and the Serjeant-at-Arms are amongst those responsible for the legislative precinct, which by statute include the Parliament Buildings and grounds."),
        VictoriaLandmark(latitude: 48.429364, longitude: -123.367335, name: "Victoria's Chinatown", details: "The Chinatown in Victoria, British Columbia is the oldest Chinatown in Canada and the second oldest in North America after San Francisco's. Victoria's Chinatown had its beginnings in the mid-nineteenth century in the mass influx of miners from California to what is now British Columbia in 1858."),
        VictoriaLandmark(latitude: 48.429337, longitude: -123.367932, name: "Fan Tan Alley", details: "Fan Tan Alley is an alley in Victoria, British Columbia's Chinatown. It runs south from Fisgard Avenue to Pandora Avenue in the block between Government Street and Store Street. Named after the Chinese gambling game Fan-Tan, the alley was originally a gambling district with restaurants, shops, and opium dens."),
        VictoriaLandmark(latitude: 48.423296, longitude: -123.366670, name: "Victoria Bug Zoo", details: "The Victoria Bug Zoo is a two-room minizoo that is located in downtown Victoria, British Columbia, Canada, just one block north of the Fairmont Empress Hotel. The Victoria Bug Zoo is owned and operated by Victoria Bug Zoo Incorporated."),
        VictoriaLandmark(latitude: 48.422369, longitude: -123.366920, name: "Miniature World", details: "Miniature-themed dioramas & displays representing historical times & fictional worlds."),
        VictoriaLandmark(latitude: 48.419795, longitude: -123.367462, name: "Royal BC Museum", details: "This museum showcases natural wonders like dinosaurs & includes an IMAX movie theatre."),
        VictoriaLandmark(latitude: 48.420520, longitude: -123.369290, name: "Cenotaph", details: nil),
        VictoriaLandmark(latitude: 48.420505, longitude: -123.369948, name: "Queen Victoria Statue", details: nil),
        
        
        VictoriaLandmark(latitude: 48.423793, longitude: -123.363956, name: "FreshWorks Studio", details: nil),
        VictoriaLandmark(latitude: 48.423798, longitude: -123.364065, name: "The Japanese Village Restaurant", details: nil),
        VictoriaLandmark(latitude: 48.423808, longitude: -123.364187, name: "Bubble Love", details: nil),
        VictoriaLandmark(latitude: 48.423420, longitude: -123.364140, name: "Greater Victoria Public Library", details: nil),
        VictoriaLandmark(latitude: 48.423560, longitude: -123.364738, name: "Parks Canada", details: nil),
        VictoriaLandmark(latitude: 48.423904, longitude: -123.364593, name: "Sussex Building", details: nil),
        VictoriaLandmark(latitude: 48.423622, longitude: -123.365030, name: "Blackapple Cellular", details: nil),
        VictoriaLandmark(latitude: 48.423640, longitude: -123.365362, name: "Island Savings", details: nil),
        VictoriaLandmark(latitude: 48.423934, longitude: -123.365150, name: "La Fiesta Cafe", details: nil)
    ]
}

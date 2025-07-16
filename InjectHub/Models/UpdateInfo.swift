//
//  UpdateInfo.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//


struct UpdateInfo: Decodable {
    let version: String
    let build: String
    let notes: String
    let download_url: String
}

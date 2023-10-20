//
//  DatabaseManager.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 14/10/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Observable storage of ticklist
class DatabaseManager: ObservableObject {
    
    ///Publishing variable containing ticklist
    @Published var ticklist: TickList = TickList()
    
    /**
     Asynchronously load data from db
     
     - Throws error of failing to load
     */
    static func load() async throws -> TickList {
        try await withCheckedThrowingContinuation{ continuation in
            load { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let ticklist):
                    continuation.resume(returning: ticklist)
                }
            }
        }
    }
    
    /**
     Load ticklist from db
     
     - If successfull: completion with data
     - If unsuccesfull: completion with empty array
     - If failure: completion with error
     */
    static func load(completion: @escaping (Result<TickList, Error>) -> Void){
        
        // Is it bad running this whole piece on main thread? Probably
        // Does it work? Fuck yes
        DispatchQueue.main.async{
            
            let coll = Firestore.firestore().collection("test2")
            var res: TickList?
            
            coll.getDocuments { snapshot, error in
                
                guard error == nil && snapshot != nil else {
                    // Handle error
                    return
                }
                
                res = TickList()
                
                // get docs
                for doc in snapshot!.documents{

                    do{
                        let tick = try doc.data(as: Tick.self)
                        res!.add(tickToAdd: tick)
                    } catch {
                        // TODO: Handle error
                        completion(.failure(error))
                    }

                }
                
                completion(.success(res!))
                
            }
            
        }
        
    }
    
    /**
     Asynchronously save data to db
     
     - Throws error if failing to save
     */
    @discardableResult
    static func save(ticklist: TickList) async throws -> Int {
        try await withCheckedThrowingContinuation{ continuation in
            save(ticklist: ticklist){ result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let ticklistSaved):
                    continuation.resume(returning: ticklistSaved)
                }
            }
        }
    }
    
    /**
     Save ticklist to db
     
     - If successfull: completion with data
     - If unsuccesfull: completion with empty array
     - If failure: completion with error
     */
    static func save(ticklist: TickList, completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            do {
                let coll = Firestore.firestore().collection("test2")
                
                for tick in ticklist.ticks {
                    try coll.document(tick.id.uuidString).setData(from: tick)
                }
                
                DispatchQueue.main.async {
                    // TODO: change/remove line under?
                    completion(.success(ticklist.ticks.count))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
    }
}


enum noSnapShot: Error {
    case noSnapShotError(String)
}

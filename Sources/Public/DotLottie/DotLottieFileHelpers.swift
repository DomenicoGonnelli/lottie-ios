//
//  DotLottieFileHelpers.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation

extension DotLottieFile {

  /// Loads a DotLottie model from a bundle by its name. Returns `nil` if a file is not found.
  ///
  /// - Parameter name: The name of the lottie file without the lottie extension. EG "StarAnimation"
  /// - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  /// - Parameter subdirectory: A subdirectory in the bundle in which the lottie is located. Optional.
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
  public static func named(
    _ name: String,
    bundle: Bundle = Bundle.main,
    subdirectory: String? = nil,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
    async throws -> DotLottieFile
  {
    try await withCheckedThrowingContinuation { continuation in
      DotLottieFile.named(name, bundle: bundle, subdirectory: subdirectory, dotLottieCache: dotLottieCache) { result in
        continuation.resume(with: result)
      }
    }
  }

  /// Loads a DotLottie model from a bundle by its name. Returns `nil` if a file is not found.
  ///
  /// - Parameter name: The name of the lottie file without the lottie extension. EG "StarAnimation"
  /// - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  /// - Parameter subdirectory: A subdirectory in the bundle in which the lottie is located. Optional.
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  /// - Parameter handleResult: A closure to be called when the file has loaded.
  public static func named(
    _ name: String,
    bundle: Bundle = Bundle.main,
    subdirectory: String? = nil,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache,
    handleResult: @escaping (Result<DotLottieFile, Error>) -> Void)
  {
    DispatchQueue.global().async {
      /// Create a cache key for the lottie.
      let cacheKey = bundle.bundlePath + (subdirectory ?? "") + "/" + name

      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: cacheKey)
      {
        DispatchQueue.main.async {
          /// If found, return the lottie.
          handleResult(.success(lottie))
        }
        return
      }

      do {
        /// Decode animation.
        guard let data = try bundle.dotLottieData(name, subdirectory: subdirectory) else {
          DispatchQueue.main.async {
            handleResult(.failure(DotLottieError.invalidData))
          }
          return
        }
        let lottie = try DotLottieFile(data: data, filename: name)
        dotLottieCache?.setFile(lottie, forKey: cacheKey)
        DispatchQueue.main.async {
          handleResult(.success(lottie))
        }
      } catch {
        /// Decoding error.
        LottieLogger.shared.warn("Error when decoding lottie \"\(name)\": \(error)")
        DispatchQueue.main.async {
          handleResult(.failure(error))
        }
      }
    }
  }

  /// Loads an DotLottie from a specific filepath.
  /// - Parameter filepath: The absolute filepath of the lottie to load. EG "/User/Me/starAnimation.lottie"
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
  public static func loadedFrom(
    filepath: String,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
    async throws -> DotLottieFile
  {
    try await withCheckedThrowingContinuation { continuation in
      DotLottieFile.loadedFrom(filepath: filepath, dotLottieCache: dotLottieCache) { result in
        continuation.resume(with: result)
      }
    }
  }

  /// Loads an DotLottie from a specific filepath.
  /// - Parameter filepath: The absolute filepath of the lottie to load. EG "/User/Me/starAnimation.lottie"
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  /// - Parameter handleResult: A closure to be called when the file has loaded.
  public static func loadedFrom(
    filepath: String,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache,
    handleResult: @escaping (Result<DotLottieFile, Error>) -> Void)
  {
    DispatchQueue.global().async {
      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: filepath)
      {
        DispatchQueue.main.async {
          handleResult(.success(lottie))
        }
        return
      }

      do {
        /// Decode the lottie.
        let url = URL(fileURLWithPath: filepath)
        let data = try Data(contentsOf: url)
        let lottie = try DotLottieFile(data: data, filename: url.deletingPathExtension().lastPathComponent)
        dotLottieCache?.setFile(lottie, forKey: filepath)
        DispatchQueue.main.async {
          handleResult(.success(lottie))
        }
      } catch {
        /// Decoding Error.
        DispatchQueue.main.async {
          handleResult(.failure(error))
        }
      }
    }
  }

  /// Loads a DotLottie model from the asset catalog by its name. Returns `nil` if a lottie is not found.
  /// - Parameter name: The name of the lottie file in the asset catalog. EG "StarAnimation"
  /// - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  /// - Parameter dotLottieCache: A cache for holding loaded lottie files. Defaults to `LRUDotLottieCache.sharedCache` Optional.
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
  public static func asset(
    named name: String,
    bundle: Bundle = Bundle.main,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
    async throws -> DotLottieFile
  {
    try await withCheckedThrowingContinuation { continuation in
      DotLottieFile.asset(named: name, bundle: bundle, dotLottieCache: dotLottieCache) { result in
        continuation.resume(with: result)
      }
    }
  }

  ///    Loads a DotLottie model from the asset catalog by its name. Returns `nil` if a lottie is not found.
  ///    - Parameter name: The name of the lottie file in the asset catalog. EG "StarAnimation"
  ///    - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  ///    - Parameter dotLottieCache: A cache for holding loaded lottie files. Defaults to `LRUDotLottieCache.sharedCache` Optional.
  ///    - Parameter handleResult: A closure to be called when the file has loaded.
  public static func asset(
    named name: String,
    bundle: Bundle = Bundle.main,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache,
    handleResult: @escaping (Result<DotLottieFile, Error>) -> Void)
  {
    DispatchQueue.global().async {
      /// Create a cache key for the lottie.
      let cacheKey = bundle.bundlePath + "/" + name

      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: cacheKey)
      {
        /// If found, return the lottie.
        DispatchQueue.main.async {
          handleResult(.success(lottie))
        }
        return
      }

      /// Load data from Asset
      guard let data = Data.jsonData(from: name, in: bundle) else {
        DispatchQueue.main.async {
          handleResult(.failure(DotLottieError.invalidData))
        }
        return
      }

      do {
        /// Decode lottie.
        let lottie = try DotLottieFile(data: data, filename: name)
        dotLottieCache?.setFile(lottie, forKey: cacheKey)
        DispatchQueue.main.async {
          handleResult(.success(lottie))
        }
      } catch {
        /// Decoding error.
        DispatchQueue.main.async {
          handleResult(.failure(error))
        }
      }
    }
  }

  /// Loads a DotLottie animation asynchronously from the URL.
  ///
  /// - Parameter url: The url to load the animation from.
  /// - Parameter animationCache: A cache for holding loaded animations. Defaults to `LRUAnimationCache.sharedCache`. Optional.
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
  public static func loadedFrom(
    url: URL,
    session: URLSession = .shared,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
    async throws -> DotLottieFile
  {
    try await withCheckedThrowingContinuation { continuation in
      DotLottieFile.loadedFrom(url: url, session: session, dotLottieCache: dotLottieCache) { result in
        continuation.resume(with: result)
      }
    }
  }

  /// Loads a DotLottie animation asynchronously from the URL.
  ///
  /// - Parameter url: The url to load the animation from.
  /// - Parameter animationCache: A cache for holding loaded animations. Defaults to `LRUAnimationCache.sharedCache`. Optional.
  /// - Parameter handleResult: A closure to be called when the animation has loaded.
  public static func loadedFrom(
    url: URL,
    session: URLSession = .shared,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache,
    handleResult: @escaping (Result<DotLottieFile, Error>) -> Void)
  {
    if let dotLottieCache = dotLottieCache, let lottie = dotLottieCache.file(forKey: url.absoluteString) {
      handleResult(.success(lottie))
    } else {
      let task = session.dataTask(with: url) { data, _, error in
        guard error == nil, let data = data else {
          DispatchQueue.main.async {
            handleResult(.failure(DotLottieError.invalidData))
          }
          return
        }
        do {
          let lottie = try DotLottieFile(data: data, filename: url.deletingPathExtension().lastPathComponent)
          DispatchQueue.main.async {
            dotLottieCache?.setFile(lottie, forKey: url.absoluteString)
            handleResult(.success(lottie))
          }
        } catch {
          DispatchQueue.main.async {
            handleResult(.failure(error))
          }
        }
      }
      task.resume()
    }
  }

}

extension DotLottieFile {

    public static func loadedFromWithJSON(url: String?, json: String?,
                                          session: URLSession = .shared,
                                          dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache,
                                          closure: @escaping (AnimationWithJson?) -> Void) {
        let animation = AnimationWithJson(data: json)
        if let _ = animation.animation{
            closure(animation)
            return
        }
        guard let urlStirng = url, let urlTask = URL(string: urlStirng) else {
            closure(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: urlTask) { (data, response, error) in
            guard error == nil, let jsonData = data else {
                DispatchQueue.main.async {
                    closure(nil)
                }
                return
            }
            do {
                let animation = try JSONDecoder().decode(LottieAnimation.self, from: jsonData)
                let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? Dictionary<String,Any>
                DispatchQueue.main.async {
                    //animationCache?.setAnimation(animation, forKey: url.absoluteString)
                    let anim = AnimationWithJson()
                    anim.animation = animation
                    anim.jsonDictionary = dictionary
                    closure(anim)
                }
            } catch {
                
                if let htlmPage = String(data: jsonData, encoding: .utf8), htlmPage.lowercased().contains("lottie"){
                    if let urlString = getTextIntoTags(string: htlmPage, openTag: "=", closedTag: ".json"){
                        loadedFromWithJSON(url: urlString, json: nil, session: session,closure: closure)
                    } else {
                        DispatchQueue.main.async {
                            closure(nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        closure(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func getTextIntoTags(string: String, openTag: String, closedTag: String) -> String?{
        guard string.contains(openTag) && string.contains(closedTag) else {return nil}
        let pattern = "\(openTag)(.*?)\(closedTag)";
        do {
            let regexMatcher = try NSRegularExpression(pattern: pattern, options: [])
            let matchColl = regexMatcher.matches(in: string, options: [], range: range(of: string))
            
            for match in matchColl {
                guard let matchrange = Range(match.range, in: string) else { return nil }
                let subString = string[matchrange.lowerBound..<matchrange.upperBound]
                let stringAttributed = NSMutableAttributedString(string: String(subString))
                stringAttributed.replaceCharacters(in: range(of: openTag), with: "")
                var stringFinal = stringAttributed.string
                stringFinal = stringFinal.replacingOccurrences(of: "\\", with: "")
                stringFinal = stringFinal.replacingOccurrences(of: "\"", with: "")
                if stringFinal.starts(with: "https") && stringFinal.contains("asset"){
                    print(stringFinal)
                    return stringFinal
                }
            }
            return nil
            
        }
        catch {
            return nil
        }
    }
    
    static func range(of string: String) -> NSRange{
        return NSRange.init(0..<string.count)
        
    }
    
}

public class AnimationWithJson {
    
    public var jsonDictionary: Dictionary<String,Any>?
    public var animation: LottieAnimation?
    
    public init(){}
    
    public init(data: String?){
        guard let json = data?.data(using: .ascii, allowLossyConversion: true) else {
            return
        }
        
        jsonDictionary = try? JSONSerialization.jsonObject(with: json) as? Dictionary<String,Any>
        animation = try? LottieAnimation.from(data: json, strategy: .dictionaryBased)
    }
}

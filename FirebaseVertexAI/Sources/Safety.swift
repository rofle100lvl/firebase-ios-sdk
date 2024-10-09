// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A type defining potentially harmful media categories and their model-assigned ratings. A value
/// of this type may be assigned to a category for every model-generated response, not just
/// responses that exceed a certain threshold.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
public struct SafetyRating: Equatable, Hashable, Sendable {
  /// The category describing the potential harm a piece of content may pose.
  ///
  /// See ``HarmCategory`` for a list of possible values.
  public let category: HarmCategory

  /// The model-generated probability that the content falls under the specified harm ``category``.
  ///
  /// See ``HarmProbability`` for a list of possible values.
  ///
  /// > Important: This does not indicate the severity of harm for a piece of content.
  public let probability: HarmProbability

  /// Initializes a new `SafetyRating` instance with the given category and probability.
  /// Use this initializer for SwiftUI previews or tests.
  public init(category: HarmCategory, probability: HarmProbability) {
    self.category = category
    self.probability = probability
  }

  /// The probability that a given model output falls under a harmful content category.
  ///
  /// > Note: This does not indicate the severity of harm for a piece of content.
  public struct HarmProbability: Sendable, Equatable, Hashable {
    enum Kind: String {
      case negligible = "NEGLIGIBLE"
      case low = "LOW"
      case medium = "MEDIUM"
      case high = "HIGH"
    }

    /// The probability is zero or close to zero.
    ///
    /// For benign content, the probability across all categories will be this value.
    public static var negligible: HarmProbability {
      return self.init(kind: .negligible)
    }

    /// The probability is small but non-zero.
    public static var low: HarmProbability {
      return self.init(kind: .low)
    }

    /// The probability is moderate.
    public static var medium: HarmProbability {
      return self.init(kind: .medium)
    }

    /// The probability is high.
    ///
    /// The content described is very likely harmful.
    public static var high: HarmProbability {
      return self.init(kind: .high)
    }

    /// Returns the raw string representation of the `HarmProbability` value.
    ///
    /// > Note: This value directly corresponds to the values in the [REST
    /// > API](https://cloud.google.com/vertex-ai/docs/reference/rest/v1beta1/GenerateContentResponse#SafetyRating).
    public let rawValue: String

    init(kind: Kind) {
      rawValue = kind.rawValue
    }

    init(rawValue: String) {
      if Kind(rawValue: rawValue) == nil {
        VertexLog.error(
          code: .generateContentResponseUnrecognizedHarmProbability,
          """
          Unrecognized HarmProbability with value "\(rawValue)":
          - Check for updates to the SDK as support for "\(rawValue)" may have been added; see \
          release notes at https://firebase.google.com/support/release-notes/ios
          - Search for "\(rawValue)" in the Firebase Apple SDK Issue Tracker at \
          https://github.com/firebase/firebase-ios-sdk/issues and file a Bug Report if none found
          """
        )
      }
      self.rawValue = rawValue
    }
  }
}

/// A type used to specify a threshold for harmful content, beyond which the model will return a
/// fallback response instead of generated content.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
public struct SafetySetting {
  /// Block at and beyond a specified ``SafetyRating/HarmProbability``.
  public enum HarmBlockThreshold: String, Sendable {
    // Content with `.negligible` will be allowed.
    case blockLowAndAbove = "BLOCK_LOW_AND_ABOVE"

    /// Content with `.negligible` and `.low` will be allowed.
    case blockMediumAndAbove = "BLOCK_MEDIUM_AND_ABOVE"

    /// Content with `.negligible`, `.low`, and `.medium` will be allowed.
    case blockOnlyHigh = "BLOCK_ONLY_HIGH"

    /// All content will be allowed.
    case blockNone = "BLOCK_NONE"
  }

  enum CodingKeys: String, CodingKey {
    case harmCategory = "category"
    case threshold
  }

  /// The category this safety setting should be applied to.
  public let harmCategory: HarmCategory

  /// The threshold describing what content should be blocked.
  public let threshold: HarmBlockThreshold

  /// Initializes a new safety setting with the given category and threshold.
  public init(harmCategory: HarmCategory, threshold: HarmBlockThreshold) {
    self.harmCategory = harmCategory
    self.threshold = threshold
  }
}

/// Categories describing the potential harm a piece of content may pose.
public struct HarmCategory: Sendable, Equatable, Hashable {
  enum Kind: String {
    case harassment = "HARM_CATEGORY_HARASSMENT"
    case hateSpeech = "HARM_CATEGORY_HATE_SPEECH"
    case sexuallyExplicit = "HARM_CATEGORY_SEXUALLY_EXPLICIT"
    case dangerousContent = "HARM_CATEGORY_DANGEROUS_CONTENT"
    case civicIntegrity = "HARM_CATEGORY_CIVIC_INTEGRITY"
  }

  /// Harassment content.
  public static var harassment: HarmCategory {
    return self.init(kind: .harassment)
  }

  /// Negative or harmful comments targeting identity and/or protected attributes.
  public static var hateSpeech: HarmCategory {
    return self.init(kind: .hateSpeech)
  }

  /// Contains references to sexual acts or other lewd content.
  public static var sexuallyExplicit: HarmCategory {
    return self.init(kind: .sexuallyExplicit)
  }

  /// Promotes or enables access to harmful goods, services, or activities.
  public static var dangerousContent: HarmCategory {
    return self.init(kind: .dangerousContent)
  }

  /// Content that may be used to harm civic integrity.
  public static var civicIntegrity: HarmCategory {
    return self.init(kind: .civicIntegrity)
  }

  /// Returns the raw string representation of the `HarmCategory` value.
  ///
  /// > Note: This value directly corresponds to the values in the
  /// > [REST API](https://cloud.google.com/vertex-ai/docs/reference/rest/v1beta1/HarmCategory).
  public let rawValue: String

  init(kind: Kind) {
    rawValue = kind.rawValue
  }

  init(rawValue: String) {
    if Kind(rawValue: rawValue) == nil {
      VertexLog.error(
        code: .generateContentResponseUnrecognizedHarmCategory,
        """
        Unrecognized HarmCategory with value "\(rawValue)":
        - Check for updates to the SDK as support for "\(rawValue)" may have been added; see \
        release notes at https://firebase.google.com/support/release-notes/ios
        - Search for "\(rawValue)" in the Firebase Apple SDK Issue Tracker at \
        https://github.com/firebase/firebase-ios-sdk/issues and file a Bug Report if none found
        """
      )
    }
    self.rawValue = rawValue
  }
}

// MARK: - Codable Conformances

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
extension SafetyRating.HarmProbability: Decodable {
  public init(from decoder: Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    self = SafetyRating.HarmProbability(rawValue: rawValue)
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
extension SafetyRating: Decodable {}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
extension HarmCategory: Codable {
  public init(from decoder: Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    self = HarmCategory(rawValue: rawValue)
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
extension SafetySetting.HarmBlockThreshold: Encodable {}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
extension SafetySetting: Encodable {}

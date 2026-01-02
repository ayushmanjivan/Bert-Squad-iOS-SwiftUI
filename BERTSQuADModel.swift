//
//  BERTSQuADModel.swift
//  bert-Squad Demo CoreML
//
//  BERT-SQuAD Core ML Model Wrapper
//

import Foundation
import CoreML
import NaturalLanguage
import Combine

class BERTSQuADModel: ObservableObject {
    @Published var isProcessing = false
    @Published var error: String?
    @Published var isDemoMode = true
    @Published var modelStatus = "Demo Mode"
    
    private var model: MLModel?
    private var useDemoMode = true
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            // Try to load the actual Core ML model if available
            let config = MLModelConfiguration()
            config.computeUnits = .all
            
            // Attempt to load BERTQAFP16 model
            // If the model is not in the project, we'll use demo mode
            // Example: self.model = try BERTQAFP16(configuration: config).model
            
            if model == nil {
                // Model not found - enable demo mode
                useDemoMode = true
                isDemoMode = true
                modelStatus = "🔄 Demo Mode (Smart Extraction)"
                print("⚠️ Running in DEMO MODE - using keyword-based answer extraction")
                print("📥 Add BERTQAFP16.mlmodel to your project for actual BERT-SQuAD inference")
            } else {
                useDemoMode = false
                isDemoMode = false
                modelStatus = "✅ Core ML Active"
                print("✅ BERT-SQuAD Core ML model loaded successfully")
            }
        } catch {
            useDemoMode = true
            isDemoMode = true
            modelStatus = "🔄 Demo Mode (Smart Extraction)"
            print("⚠️ Model loading error: \(error.localizedDescription)")
            print("Running in demo mode with keyword-based extraction")
        }
    }
    
    func answerQuestion(question: String, context: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !question.isEmpty, !context.isEmpty else {
            completion(.failure(NSError(domain: "BERTSQuAD", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Question and context cannot be empty"])))
            return
        }
        isProcessing = true
        error = nil
        // Perform inference in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let answer = try self.performInference(question: question, context: context)
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(.success(answer))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.error = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func performInference(question: String, context: String) throws -> String {
        // Use demo mode if Core ML model is not available
        if useDemoMode || model == nil {
            return try demoAnswerExtraction(question: question, context: context)
        }
        // Actual BERT-SQuAD Core ML inference
        // Tokenize inputs
        let tokens = tokenize(question: question, context: context)
        // Prepare model inputs
        let input = try prepareModelInput(tokens: tokens)
        // Run prediction
        let output = try model!.prediction(from: input)
        // Extract answer
        let answer = try extractAnswer(from: output, tokens: tokens, context: context)
        return answer
    }
    
    // MARK: - Demo Mode Implementation
    private func demoAnswerExtraction(question: String, context: String) throws -> String {
        // Smart keyword-based answer extraction for demo purposes
        let lowercaseQuestion = question.lowercased()
        _ = context.lowercased()
        // Split context into sentences
        let sentences = context.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Question type detection
        if lowercaseQuestion.starts(with: "what") {
            return extractForWhatQuestion(question: lowercaseQuestion, context: context, sentences: sentences)
        } else if lowercaseQuestion.starts(with: "when") {
            return extractForWhenQuestion(context: context, sentences: sentences)
        } else if lowercaseQuestion.starts(with: "where") {
            return extractForWhereQuestion(context: context, sentences: sentences)
        } else if lowercaseQuestion.starts(with: "who") {
            return extractForWhoQuestion(context: context, sentences: sentences)
        } else if lowercaseQuestion.starts(with: "how many") || lowercaseQuestion.starts(with: "how much") {
            return extractForHowManyQuestion(context: context, sentences: sentences)
        } else if lowercaseQuestion.starts(with: "which") {
            return extractForWhichQuestion(context: context, sentences: sentences)
        }
        
        // Generic extraction - find most relevant sentence
        return extractGenericAnswer(question: lowercaseQuestion, sentences: sentences)
    }
    
    private func extractForWhatQuestion(question: String, context: String, sentences: [String]) -> String {
        // Extract keywords from question
        let keywords = extractKeywords(from: question)
        
        // Find sentence with most matching keywords
        var bestSentence = ""
        var maxMatches = 0
        
        for sentence in sentences {
            let lowercaseSentence = sentence.lowercased()
            let matches = keywords.filter { lowercaseSentence.contains($0) }.count
            if matches > maxMatches {
                maxMatches = matches
                bestSentence = sentence
            }
        }
        
        return bestSentence.isEmpty ? extractShortPhrase(from: sentences.first ?? "Answer not found") : extractShortPhrase(from: bestSentence)
    }
    
    private func extractForWhenQuestion(context: String, sentences: [String]) -> String {
        // Look for dates and years
        let datePattern = #"\b\d{4}\b|\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b|\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b|\b\d{4}\b"#
        
        for sentence in sentences {
            if let range = sentence.range(of: datePattern, options: .regularExpression) {
                let dateContext = sentence[range]
                // Extract surrounding context
                let words = sentence.split(separator: " ")
                for (index, word) in words.enumerated() {
                    if word.lowercased().contains(String(dateContext).lowercased()) {
                        let start = max(0, index - 3)
                        let end = min(words.count, index + 4)
                        return words[start..<end].joined(separator: " ")
                    }
                }
                return String(dateContext)
            }
        }
        
        // Fallback to first sentence
        return extractShortPhrase(from: sentences.first ?? "Date not found in context")
    }
    
    private func extractForWhereQuestion(context: String, sentences: [String]) -> String {
        // Look for location indicators
        let locationKeywords = ["in ", "at ", "from ", "headquartered", "located", "based"]
        
        for sentence in sentences {
            let lowercaseSentence = sentence.lowercased()
            for keyword in locationKeywords {
                if lowercaseSentence.contains(keyword) {
                    // Extract location after keyword
                    if let range = lowercaseSentence.range(of: keyword) {
                        let afterKeyword = sentence[range.upperBound...]
                        let words = afterKeyword.split(separator: " ")
                        let location = words.prefix(5).joined(separator: " ")
                        // Clean up
                        return location.components(separatedBy: CharacterSet(charactersIn: ".,;:")).first ?? String(location)
                    }
                }
            }
        }
        
        return extractShortPhrase(from: sentences.first ?? "Location not found in context")
    }
    
    private func extractForWhoQuestion(context: String, sentences: [String]) -> String {
        // Look for names (capitalized words)
        let namePattern = #"\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+\b"#
        
        for sentence in sentences {
            if let range = sentence.range(of: namePattern, options: .regularExpression) {
                let name = sentence[range]
                return String(name)
            }
        }
        
        return extractShortPhrase(from: sentences.first ?? "Person not found in context")
    }
    
    private func extractForHowManyQuestion(context: String, sentences: [String]) -> String {
        // Look for numbers
        let numberPattern = #"\b\d+(?:,\d{3})*(?:\.\d+)?\s*(?:million|billion|thousand|hundred)?\b"#
        
        for sentence in sentences {
            if let range = sentence.range(of: numberPattern, options: .regularExpression) {
                let number = sentence[range]
                return String(number)
            }
        }
        
        return extractShortPhrase(from: sentences.first ?? "Number not found in context")
    }
    
    private func extractForWhichQuestion(context: String, sentences: [String]) -> String {
        return extractShortPhrase(from: sentences.first ?? "Answer not found in context")
    }
    
    private func extractGenericAnswer(question: String, sentences: [String]) -> String {
        let keywords = extractKeywords(from: question)
        
        for sentence in sentences {
            let lowercaseSentence = sentence.lowercased()
            for keyword in keywords {
                if lowercaseSentence.contains(keyword) {
                    return extractShortPhrase(from: sentence)
                }
            }
        }
        
        return extractShortPhrase(from: sentences.first ?? "Answer not found in context")
    }
    
    private func extractKeywords(from question: String) -> [String] {
        let stopWords = Set(["what", "when", "where", "who", "which", "how", "is", "are", "was", "were", "the", "a", "an", "in", "on", "at", "to", "for", "of", "with", "by"])
        return question.split(separator: " ")
            .map { String($0).trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { !stopWords.contains($0) && $0.count > 2 }
    }
    
    private func extractShortPhrase(from text: String) -> String {
        let words = text.split(separator: " ")
        let maxWords = min(15, words.count)
        return words.prefix(maxWords).joined(separator: " ")
    }
    
    private func tokenize(question: String, context: String) -> [String] {
        // Simple word-level tokenization
        // BERT uses WordPiece tokenization, but for demo purposes we'll use NLTokenizer
        let tokenizer = NLTokenizer(unit: .word)
        var tokens: [String] = ["[CLS]"]
        // Tokenize question
        tokenizer.string = question
        tokenizer.enumerateTokens(in: question.startIndex..<question.endIndex) { range, _ in
            tokens.append(String(question[range]).lowercased())
            return true
        }
        tokens.append("[SEP]")
        // Tokenize context
        tokenizer.string = context
        tokenizer.enumerateTokens(in: context.startIndex..<context.endIndex) { range, _ in
            tokens.append(String(context[range]).lowercased())
            return true
        }
        tokens.append("[SEP]")
        // Pad or truncate to max length (typically 384 for BERT-SQuAD)
        let maxLength = 384
        if tokens.count > maxLength {
            tokens = Array(tokens.prefix(maxLength))
        } else {
            while tokens.count < maxLength {
                tokens.append("[PAD]")
            }
        }
        return tokens
    }
    
    private func prepareModelInput(tokens: [String]) throws -> MLFeatureProvider {
        // This will need to be adapted based on your specific .mlmodel inputs
        // The actual implementation depends on the model's expected input format
        // For BERT-SQuAD, typical inputs are:
        // 1. Token IDs (integers)
        // 2. Token type IDs (0 for question, 1 for context)
        // 3. Attention mask (1 for real tokens, 0 for padding)
        let tokenIDs = tokens.map { token -> Int in
            // This is simplified - you'd need a proper vocabulary
            return token.hash % 30522 // BERT vocab size
        }
        // Create MLMultiArray inputs
        let shape = [1, tokens.count] as [NSNumber]
        guard let wordIDs = try? MLMultiArray(shape: shape, dataType: .int32),
              let wordTypes = try? MLMultiArray(shape: shape, dataType: .int32),
              let wordMask = try? MLMultiArray(shape: shape, dataType: .int32) else {
            throw NSError(domain: "BERTSQuAD", code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create input arrays"])
        }
        for i in 0..<tokens.count {
            wordIDs[i] = NSNumber(value: tokenIDs[i])
            wordTypes[i] = NSNumber(value: tokens[i] == "[PAD]" ? 0 : 1)
            wordMask[i] = NSNumber(value: tokens[i] == "[PAD]" ? 0 : 1)
        }
        // Create feature provider
        let inputDict: [String: Any] = [
            "wordIDs": wordIDs,
            "wordTypes": wordTypes,
            "wordMask": wordMask
        ]
        return try MLDictionaryFeatureProvider(dictionary: inputDict)
    }
    
    private func extractAnswer(from output: MLFeatureProvider, tokens: [String], context: String) throws -> String {
        // Extract start and end logits from model output
        // Find the span with highest score
        // Map back to original context
        // This is a placeholder implementation
        // The actual implementation depends on your model's output format
        // For now, return a simple extraction from context
        let words = context.split(separator: " ")
        if words.count > 0 {
            // Simple heuristic: return first few words as answer
            let answerWords = words.prefix(min(5, words.count))
            return answerWords.joined(separator: " ")
        }
        return "Answer not found in context"
    }
}

// MARK: - Model Input/Output Structures

struct BERTInput {
    let wordIDs: MLMultiArray
    let wordTypes: MLMultiArray
    let wordMask: MLMultiArray
}

struct BERTOutput {
    let startLogits: MLMultiArray
    let endLogits: MLMultiArray
}

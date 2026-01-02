//
//  Vocabulary.swift
//  bert-Squad Demo CoreML
//
//  BERT Vocabulary and Tokenization Support
//

import Foundation

class BERTVocabulary {
    static let shared = BERTVocabulary()
    // Special tokens
    static let clsToken = "[CLS]"
    static let sepToken = "[SEP]"
    static let padToken = "[PAD]"
    static let unkToken = "[UNK]"
    static let maskToken = "[MASK]"
    private var vocabulary: [String: Int] = [:]
    private var reverseVocabulary: [Int: String] = [:]
    
    private init() {
        loadVocabulary()
    }
    
    private func loadVocabulary() {
        // BERT uses a large vocabulary (30,522 tokens)
        // For demo purposes, we'll use a simplified vocabulary
        // In production, you'd load the actual bert-base-uncased vocab.txt
        var vocabList = [
            BERTVocabulary.padToken,
            BERTVocabulary.unkToken,
            BERTVocabulary.clsToken,
            BERTVocabulary.sepToken,
            BERTVocabulary.maskToken
        ]
        // Add common words and tokens
        let commonWords = [
            "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
            "of", "with", "by", "from", "as", "is", "was", "are", "were", "be",
            "been", "being", "have", "has", "had", "do", "does", "did", "will",
            "would", "should", "could", "may", "might", "can", "what", "when",
            "where", "who", "which", "how", "why", "this", "that", "these", "those",
            "i", "you", "he", "she", "it", "we", "they", "them", "their", "his",
            "her", "its", "our", "your", "my", "me", "him", "us", "not", "no",
            "yes", "all", "some", "any", "many", "much", "more", "most", "few",
            "little", "one", "two", "first", "last", "only", "other", "same",
            "new", "old", "good", "bad", "great", "small", "large", "long", "short"
        ]
        vocabList.append(contentsOf: commonWords)
        // Add punctuation
        let punctuation = [".", ",", "?", "!", ";", ":", "'", "\"", "(", ")", "-", "/"]
        vocabList.append(contentsOf: punctuation)
        // Add numbers
        for i in 0...100 {
            vocabList.append(String(i))
        }
        // Build vocabulary dictionary
        for (index, token) in vocabList.enumerated() {
            vocabulary[token] = index
            reverseVocabulary[index] = token
        }
        print("Loaded vocabulary with \(vocabulary.count) tokens")
    }
    
    func tokenize(_ text: String) -> [String] {
        // Basic tokenization - in production, use WordPiece tokenizer
        let lowercased = text.lowercased()
        // Split by whitespace and punctuation
        var tokens: [String] = []
        var currentWord = ""
        
        for char in lowercased {
            if char.isWhitespace {
                if !currentWord.isEmpty {
                    tokens.append(currentWord)
                    currentWord = ""
                }
            } else if char.isPunctuation {
                if !currentWord.isEmpty {
                    tokens.append(currentWord)
                    currentWord = ""
                }
                tokens.append(String(char))
            } else {
                currentWord.append(char)
            }
        }
        
        if !currentWord.isEmpty {
            tokens.append(currentWord)
        }
        
        return tokens
    }
    
    func convertTokensToIds(_ tokens: [String]) -> [Int] {
        return tokens.map { token in
            vocabulary[token] ?? vocabulary[BERTVocabulary.unkToken] ?? 1
        }
    }
    
    func convertIdsToTokens(_ ids: [Int]) -> [String] {
        return ids.map { id in
            reverseVocabulary[id] ?? BERTVocabulary.unkToken
        }
    }
    
    func encodeSequencePair(question: String, context: String, maxLength: Int = 384) -> (tokenIds: [Int], tokenTypeIds: [Int], attentionMask: [Int]) {
        // Tokenize question and context
        let questionTokens = tokenize(question)
        let contextTokens = tokenize(context)
        
        // Build sequence: [CLS] question [SEP] context [SEP]
        var tokens = [BERTVocabulary.clsToken]
        tokens.append(contentsOf: questionTokens)
        tokens.append(BERTVocabulary.sepToken)
        
        // Calculate remaining space for context
        let remainingLength = maxLength - tokens.count - 1 // -1 for final [SEP]
        let contextToAdd = contextTokens.prefix(remainingLength)
        tokens.append(contentsOf: contextToAdd)
        tokens.append(BERTVocabulary.sepToken)
        
        // Convert to IDs
        var tokenIds = convertTokensToIds(tokens)
        
        // Create token type IDs (0 for question, 1 for context)
        var tokenTypeIds = [Int]()
        let questionLength = questionTokens.count + 2 // +2 for [CLS] and [SEP]
        
        for i in 0..<tokenIds.count {
            tokenTypeIds.append(i < questionLength ? 0 : 1)
        }
        
        // Create attention mask (1 for real tokens, 0 for padding)
        var attentionMask = Array(repeating: 1, count: tokenIds.count)
        
        // Pad to max length
        while tokenIds.count < maxLength {
            tokenIds.append(vocabulary[BERTVocabulary.padToken] ?? 0)
            tokenTypeIds.append(0)
            attentionMask.append(0)
        }
        
        return (tokenIds, tokenTypeIds, attentionMask)
    }
}

// MARK: - Token Extension

extension String {
    func cleanBERTToken() -> String {
        // Remove WordPiece prefix "##"
        return self.replacingOccurrences(of: "##", with: "")
    }
}

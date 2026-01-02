//
//  SampleData.swift
//  bert-Squad Demo CoreML
//
//  Sample contexts and questions for BERT-SQuAD demo
//

import Foundation

struct SampleQA: Equatable {
    let title: String
    let context: String
    let sampleQuestions: [String]
}

class SampleData {
    static let samples: [SampleQA] = [
        SampleQA(
            title: "Apple Inc.",
            context: """
            Apple Inc. is an American multinational technology company headquartered in Cupertino, California. \
            Apple is the world's largest technology company by revenue, totaling $394.3 billion in 2022. \
            As of March 2023, Apple is the world's biggest company by market capitalization. As of June 2022, \
            Apple is the fourth-largest personal computer vendor by unit sales and second-largest mobile phone \
            manufacturer in the world. It is one of the Big Five American information technology companies, \
            alongside Alphabet, Amazon, Meta, and Microsoft. Apple was founded as Apple Computer Company on \
            April 1, 1976, by Steve Wozniak, Steve Jobs and Ronald Wayne to develop and sell Wozniak's Apple I \
            personal computer. It was incorporated by Jobs and Wozniak as Apple Computer, Inc. in 1977.
            """,
            sampleQuestions: [
                "Where is Apple headquartered?",
                "When was Apple founded?",
                "Who founded Apple?",
                "What was Apple's revenue in 2022?"
            ]
        ),
        
        SampleQA(
            title: "Machine Learning",
            context: """
            Machine learning is a branch of artificial intelligence and computer science which focuses on \
            the use of data and algorithms to imitate the way that humans learn, gradually improving its \
            accuracy. Machine learning is an important component of the growing field of data science. \
            Through the use of statistical methods, algorithms are trained to make classifications or \
            predictions, and to uncover key insights in data mining projects. These insights subsequently \
            drive decision making within applications and businesses. Machine learning algorithms are \
            typically created using frameworks that accelerate solution development, such as TensorFlow \
            and PyTorch.
            """,
            sampleQuestions: [
                "What is machine learning?",
                "What frameworks are used for machine learning?",
                "What field is machine learning important to?",
                "What do machine learning algorithms do?"
            ]
        ),
        
        SampleQA(
            title: "Core ML",
            context: """
            Core ML is Apple's machine learning framework used across its products, including Siri, Camera, \
            and QuickType. Core ML enables developers to integrate machine learning models into iOS, iPadOS, \
            macOS, watchOS, and tvOS apps. The framework supports a variety of model types including neural \
            networks, tree ensembles, support vector machines, and generalized linear models. Core ML optimizes \
            on-device performance by leveraging the CPU, GPU, and Neural Engine while minimizing memory footprint \
            and power consumption. Models can be trained using popular machine learning tools like TensorFlow, \
            PyTorch, and Create ML, then converted to the Core ML format for integration into apps.
            """,
            sampleQuestions: [
                "What is Core ML?",
                "Which Apple products use Core ML?",
                "What platforms does Core ML support?",
                "What model types does Core ML support?"
            ]
        ),
        
        SampleQA(
            title: "BERT Model",
            context: """
            BERT, which stands for Bidirectional Encoder Representations from Transformers, is a machine learning \
            model for natural language processing. It was published in 2018 by researchers at Google AI Language. \
            BERT is designed to pre-train deep bidirectional representations from unlabeled text by jointly \
            conditioning on both left and right context in all layers. The pre-trained BERT model can be fine-tuned \
            with just one additional output layer to create state-of-the-art models for a wide range of tasks, \
            such as question answering and language inference. BERT was trained on BooksCorpus and English Wikipedia. \
            The model has 340 million parameters and was trained on 16 Cloud TPUs for four days.
            """,
            sampleQuestions: [
                "What does BERT stand for?",
                "When was BERT published?",
                "Who developed BERT?",
                "How many parameters does BERT have?"
            ]
        ),
        
        SampleQA(
            title: "iPhone",
            context: """
            The iPhone is a line of smartphones designed and marketed by Apple Inc. The first-generation iPhone \
            was announced by Steve Jobs on January 9, 2007. Since then, Apple has annually released new iPhone \
            models and iOS updates. The iPhone uses Apple's iOS mobile operating system. The first iPhone was \
            described as a revolutionary product that featured a multi-touch interface. The latest models feature \
            advanced camera systems, Face ID facial recognition, and the A17 Pro chip. As of November 2023, more \
            than 2.3 billion iPhones have been sold, making it one of the most successful product lines in history.
            """,
            sampleQuestions: [
                "Who announced the first iPhone?",
                "When was the first iPhone announced?",
                "What operating system does iPhone use?",
                "How many iPhones have been sold?"
            ]
        ),
        
        SampleQA(
            title: "Swift Programming",
            context: """
            Swift is a general-purpose, multi-paradigm, compiled programming language developed by Apple Inc. \
            for iOS, iPadOS, macOS, watchOS, tvOS, Linux, and Windows. Swift was introduced at Apple's 2014 \
            Worldwide Developers Conference (WWDC). It was designed to work with Apple's Cocoa and Cocoa Touch \
            frameworks and the large body of existing Objective-C code written for Apple products. Swift is \
            designed to be safer than Objective-C and includes modern programming language features. The language \
            is open-source with an Apache License 2.0. Swift supports the concept of protocol extensibility, \
            an extensibility system that can be applied to types, structs and classes.
            """,
            sampleQuestions: [
                "What is Swift?",
                "When was Swift introduced?",
                "What platforms does Swift support?",
                "Is Swift open-source?"
            ]
        )
    ]
    
    static func randomSample() -> SampleQA {
        samples.randomElement() ?? samples[0]
    }
}

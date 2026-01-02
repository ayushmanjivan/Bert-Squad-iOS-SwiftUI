# Bert-Squad-iOS-SwiftUI
A SwiftUI demo app showcasing BERT-based Question Answering using Core ML on iOS.

## Overview

This demo project demonstrates how to use Apple's Core ML framework with a BERT-SQuAD (Bidirectional Encoder Representations from Transformers - Stanford Question Answering Dataset) model for context-based question answering.

### Features

- ✅ Real-time question answering using BERT-SQuAD
- ✅ Pre-loaded sample contexts (Apple, Machine Learning, Core ML, BERT, iPhone, Swift)
- ✅ Custom context and question input
- ✅ Clean SwiftUI interface
- ✅ On-device inference (privacy-focused)
- ✅ Copy answers to clipboard
- ✅ Sample questions for quick testing

## What is BERT-SQuAD?

**BERT** (Bidirectional Encoder Representations from Transformers) is a language representation model that uses fine-tuning to apply pre-trained representations to NLP tasks.

**BERT-SQuAD** specifically adapts BERT for extracting precise answers from a given context based on questions from the Stanford Question Answering Dataset.

### Key Characteristics:
- **Multilayer bidirectional transformer** architecture
- **Pre-trained** on BooksCorpus and English Wikipedia
- **Fine-tuned** on the Stanford Question Answering Dataset
- Extracts answer spans from context text

## Setup Instructions

### Prerequisites

- macOS Sonoma or later
- Xcode 15.0 or later
- iOS 17.0 or later (deployment target)

### Step 1: Clone/Open the Project

This project is ready to use. Open the `.xcodeproj` file in Xcode.

### Step 2: Download the Core ML Model

1. Visit [Apple's Machine Learning Models page](https://developer.apple.com/machine-learning/models/)
2. Download **BERTQAFP16.mlmodel** (BERT Question Answering model)
3. The model file is approximately 200MB

### Step 3: Add the Model to Your Project

1. In Xcode, locate your project in the Project Navigator
2. Drag the downloaded `BERTQAFP16.mlmodel` file into your project
3. In the dialog that appears:
- ✅ Check "Copy items if needed"
- ✅ Select your app target
- Click "Finish"

4. The model will automatically generate a Swift class you can use

### Step 4: Update BERTSQuADModel.swift

Once you add the .mlmodel file, update the `loadModel()` function in [BERTSQuADModel.swift](bert-Squad Demo CoreML/BERTSQuADModel.swift):

```swift
private func loadModel() {
do {
let config = MLModelConfiguration()
config.computeUnits = .all
// Replace this with your actual model initialization
self.model = try BERTQAFP16(configuration: config).model
print("BERT-SQuAD model loaded successfully")
} catch {
self.error = "Failed to load model: \(error.localizedDescription)"
print("Model loading error: \(error)")
}
}
```

### Step 5: Build and Run

1. Select your target device or simulator
2. Press `Cmd + R` to build and run
3. Try the sample contexts and questions!

## Project Structure

```
bert-Squad Demo CoreML/
├── bert_Squad_Demo_CoreMLApp.swift # App entry point
├── ContentView.swift # Main UI with Q&A interface
├── BERTSQuADModel.swift # Core ML model wrapper
├── Vocabulary.swift # BERT tokenization support
├── SampleData.swift # Pre-loaded sample contexts
└── Assets.xcassets/ # App assets
```

## How to Use

### Using Sample Data

1. Tap "Select Sample" to choose from pre-loaded contexts
2. Select one of the suggested questions or type your own
3. Tap "Get Answer" to extract the answer from the context

### Using Custom Data

1. Enter your own context in the "Context" text area
2. Type a question related to the context
3. Tap "Get Answer" to get the extracted answer

### Example

**Context:**
```
Apple Inc. is an American multinational technology company headquartered in
Cupertino, California. Apple was founded on April 1, 1976, by Steve Wozniak,
Steve Jobs and Ronald Wayne.
```

**Question:** "When was Apple founded?"

**Answer:** "April 1, 1976"

## Technical Details

### Model Information

- **Model Type:** BERT-SQuAD (Question Answering)
- **Format:** Core ML (.mlmodel)
- **Input:** Question + Context text
- **Output:** Answer span extracted from context
- **Parameters:** ~340 million (BERT-base)

### Architecture

- **Tokenization:** WordPiece tokenization with BERT vocabulary
- **Max Sequence Length:** 384 tokens
- **Model Inputs:**
- `wordIDs`: Token IDs (Int32 array)
- `wordTypes`: Segment IDs (Int32 array)
- `wordMask`: Attention mask (Int32 array)
- **Model Outputs:**
- `startLogits`: Start position scores
- `endLogits`: End position scores

### Performance Optimization

The model uses Core ML's optimizations:
- **CPU/GPU/Neural Engine** utilization
- **Minimized memory footprint**
- **Reduced power consumption**
- **On-device inference** (no network required)

## Resources

### Official Documentation
- [Apple Machine Learning Models](https://developer.apple.com/machine-learning/models/)
- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [BERT Paper on arXiv](https://arxiv.org/abs/1810.04805)

### Related Projects
- [Hugging Face Transformers](https://github.com/huggingface/transformers)
- [Stanford SQuAD Dataset](https://rajpurkar.github.io/SQuAD-explorer/)

## Troubleshooting

### Model Not Loading
- Ensure the .mlmodel file is added to your target
- Check that the model name matches in your code
- Verify iOS deployment target is compatible

### Poor Accuracy
- Make sure your question is directly answerable from the context
- The answer must exist verbatim in the context
- BERT-SQuAD performs span extraction, not generation

### Performance Issues
- Use the FP16 (half-precision) model for better performance
- Ensure Core ML compute units are set to `.all`
- Test on a physical device for best results

## Requirements

- **iOS:** 17.0+
- **Xcode:** 15.0+
- **Swift:** 5.9+
- **Core ML Model:** BERTQAFP16.mlmodel

## License

This is a demo project for educational purposes.

- BERT model: Apache License 2.0
- Core ML: Apple's frameworks
- Demo code: Use as reference

## Credits

- **BERT Model:** Google AI Language Team
- **Core ML Framework:** Apple Inc.
- **SQuAD Dataset:** Stanford NLP Group
- **Demo App:** Educational demonstration

## Contributing

This is a demo project. Feel free to:
- Add more sample contexts
- Improve tokenization
- Enhance the UI
- Add answer highlighting in context
- Implement confidence scores

## Support

For issues:
1. Check the [Apple Developer Forums](https://developer.apple.com/forums/)
2. Review [Core ML documentation](https://developer.apple.com/documentation/coreml)
3. Consult [BERT paper](https://arxiv.org/abs/1810.04805)

---

**Note:** This demo requires downloading the BERT-SQuAD Core ML model separately from Apple's website. The model file is not included in this repository due to its size (~200MB).

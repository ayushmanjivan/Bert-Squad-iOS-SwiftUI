//
//  ContentView.swift
//  bert-Squad Demo CoreML
//
//  Created by ayushman.soni on 02/01/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bertModel = BERTSQuADModel()
    // Input states
    @State private var question = ""
    @State private var context = ""
    // Output states
    @State private var answer = ""
    @State private var showingAnswer = false
    // UI states
    @State private var selectedSample: SampleQA?
    @State private var selectedQuestionIndex = 0
    @State private var showingSamplePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("BERT-SQuAD")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Question Answering with Core ML")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Model Status Badge
                        HStack {
                            Image(systemName: bertModel.isDemoMode ? "wand.and.stars" : "cpu")
                            Text(bertModel.modelStatus)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(bertModel.isDemoMode ? Color.orange.opacity(0.15) : Color.green.opacity(0.15))
                        .foregroundColor(bertModel.isDemoMode ? .orange : .green)
                        .cornerRadius(20)
                    }
                    .padding(.top)
                    
                    // Demo Mode Info Banner
                    if bertModel.isDemoMode {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                Text("Demo Mode Active")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Using smart keyword extraction. Try these examples:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                DemoExampleRow(icon: "location", text: "Where questions → Finds locations")
                                DemoExampleRow(icon: "calendar", text: "When questions → Extracts dates")
                                DemoExampleRow(icon: "person.2", text: "Who questions → Identifies names")
                                DemoExampleRow(icon: "number", text: "How many → Finds numbers")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Sample Data Picker
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Try a Sample")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { showingSamplePicker = true }) {
                                HStack {
                                    Text(selectedSample?.title ?? "Select Sample")
                                        .lineLimit(1)
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if let sample = selectedSample {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(sample.sampleQuestions.enumerated()), id: \.offset) { index, q in
                                        Button(action: {
                                            selectedQuestionIndex = index
                                            question = q
                                        }) {
                                            Text(q)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(selectedQuestionIndex == index ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(selectedQuestionIndex == index ? .white : .primary)
                                                .cornerRadius(15)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Context Input
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Context", systemImage: "doc.text")
                            .font(.headline)
                        
                        TextEditor(text: $context)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text("\(context.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Question Input
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Question", systemImage: "questionmark.circle")
                            .font(.headline)
                        
                        TextField("Ask a question about the context...", text: $question)
                            .textFieldStyle(.roundedBorder)
                            .padding(4)
                    }
                    
                    // Ask Button
                    Button(action: askQuestion) {
                        HStack {
                            if bertModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(bertModel.isProcessing ? "Processing..." : "Get Answer")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAskQuestion ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canAskQuestion || bertModel.isProcessing)
                    
                    // Error Message
                    if let error = bertModel.error {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Error", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if error.contains("add the .mlmodel file") {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("To use BERT-SQuAD:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("1. Download BERTQAFP16.mlmodel from Apple's ML models")
                                    Text("2. Drag it into your Xcode project")
                                    Text("3. Make sure 'Copy items if needed' is checked")
                                    Text("4. Add it to the app target")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Answer Display
                    if showingAnswer {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Answer", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                if bertModel.isDemoMode {
                                    Text("Demo Mode")
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Text(answer)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            
                            HStack {
                                Button(action: {
                                    UIPasteboard.general.string = answer
                                }) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAnswer = false
                                    answer = ""
                                }) {
                                    Label("Clear", systemImage: "xmark.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("About BERT-SQuAD", systemImage: "info.circle")
                            .font(.headline)
                        
                        Text("BERT (Bidirectional Encoder Representations from Transformers) is trained on the Stanford Question Answering Dataset (SQuAD) to extract answers from context.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "https://developer.apple.com/machine-learning/models/")!) {
                            Label("Download Model", systemImage: "arrow.down.circle")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("BERT-SQuAD Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingSamplePicker) {
            SamplePickerView(selectedSample: $selectedSample, context: $context)
        }
        .onChange(of: selectedSample) { newValue in
            if let sample = newValue {
                context = sample.context
                if !sample.sampleQuestions.isEmpty {
                    question = sample.sampleQuestions[0]
                    selectedQuestionIndex = 0
                }
            }
        }
        .onAppear {
            // Load first sample by default
            if selectedSample == nil {
                selectedSample = SampleData.samples.first
            }
        }
    }
    
    private var canAskQuestion: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func askQuestion() {
        showingAnswer = false
        answer = ""
        
        bertModel.answerQuestion(question: question, context: context) { result in
            switch result {
            case .success(let extractedAnswer):
                answer = extractedAnswer
                showingAnswer = true
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Error is already shown via bertModel.error
            }
        }
    }
}

// MARK: - Sample Picker View

struct SamplePickerView: View {
    @Binding var selectedSample: SampleQA?
    @Binding var context: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(SampleData.samples, id: \.title) { sample in
                Button(action: {
                    selectedSample = sample
                    context = sample.context
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sample.title)
                            .font(.headline)
                        
                        Text(sample.context.prefix(100) + "...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Sample Context")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Demo Example Row

struct DemoExampleRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.orange)
                .frame(width: 16)
            Text(text)
        }
    }
}

#Preview {
    ContentView()
}

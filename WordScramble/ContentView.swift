//
//  ContentView.swift
//  WordScramble
//
//  Created by Michael Schmidt on 1/24/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter Your Word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section {
                    Text("Score: \(score)")
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                Button("New Word") {
                    startGame()
                }
            })
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {
                    newWord = ""
                }
            } message: {
                Text(errorMessage)
            }

        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isWordOriginal(word: answer) else {
            wordError(title: "Word used alread", message: "Be more original!")
            return
        }
        
        guard isWordReal(word: answer) else {
            wordError(title: "That is not a real word", message: "Would you like to download a dictionary app?")
            return
        }
        
        guard isWordTooShort(word: answer) else {
            wordError(title: "Word is too short", message: "Your word must be a minimum of 4 letters")
            return
        }
        
        guard isWordPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "\(answer) cannot be made from \(rootWord)")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func isWordOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isWordPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isWordReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isWordTooShort(word: String) -> Bool {
        if word.count >= 3 {
            return true
        }
        return false
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

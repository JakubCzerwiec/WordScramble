//
//  ContentView.swift
//  WordScramble
//
//  Created by Mój Maczek on 06/10/2024.
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
                Section("Your score: \n (5 points per word and 1 point per letter)") {
                    Text("\(score)")
                }
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never) // block starting with capital letter
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
            .onSubmit(addNewWord) // whenever 'return' is pressed
            .onAppear(perform: startGame) // lunch this function whenever this view is lunched
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        Button("NEW GAME", action: startGame)
            .frame(width: 190, height: 60)
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            .fontWeight(.bold)
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(.rect(cornerRadius: 20))
            .padding()

    }
        
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // checks if there is a word at all
        guard answer.count > 0 else { return }
        
        guard isOrigina(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot spell thet word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word is too short", message: "We are not playing with this tiny ones!")
            return
        }
        
        // adds word to an array od answers
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        calculateScore()
        newWord = ""
    }
    
    func startGame() {      // looking for a file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            score = 0
            usedWords = []
            // putting all words in one variable
            if let startWords = try? String(contentsOf: startWordsURL) {
                // putting all words in an array
                let allWords = startWords.components(separatedBy: "\n")
                // drawing a letter to play with
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from boundle") // if failed to load a file, crashes the app
    }
    
    func isOrigina(word: String) -> Bool {
        !usedWords.contains(word) // checks if new word has been already used
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        // loops over working word and checks if the letters in word are there
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    // checking if the word is real in english language
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScore() {
        var wordsAmount = usedWords.count
        var lettersInGame = 0
        for a in usedWords {
            lettersInGame += a.count
        }
        score = wordsAmount * 5 + lettersInGame
    }
}

#Preview {
    ContentView()
}

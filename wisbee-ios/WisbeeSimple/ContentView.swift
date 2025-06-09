import SwiftUI

struct ContentView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isConnected = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("🐝 Wisbee")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Spacer()
                    
                    Circle()
                        .fill(isConnected ? .green : .red)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .fill(isConnected ? .green : .red)
                                .frame(width: 12, height: 12)
                                .scaleEffect(isConnected ? 1.5 : 1.0)
                                .opacity(isConnected ? 0 : 1)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isConnected)
                        )
                }
                .padding()
                
                // Messages
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            VStack(spacing: 16) {
                                Text("🐝")
                                    .font(.system(size: 60))
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: true)
                                
                                Text("Wisbeeへようこそ！")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("ローカルAIとの会話を始めましょう")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Input
                HStack {
                    TextField("メッセージを入力...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            // Simulate connection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isConnected = true
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = generateResponse(for: currentInput)
            let aiMessage = ChatMessage(content: aiResponse, isUser: false)
            messages.append(aiMessage)
        }
    }
    
    private func generateResponse(for input: String) -> String {
        let responses = [
            "こんにちは！Wisbeeです🐝",
            "それは興味深い質問ですね。",
            "申し訳ありませんが、現在はデモモードです。",
            "ローカルAIモデルとの接続を準備中です。",
            "素晴らしい！他に何かお手伝いできることはありますか？",
            "Wisbeeはプライバシーを重視したAIアシスタントです。",
            "ご質問をありがとうございます！"
        ]
        return responses.randomElement() ?? "応答を準備中です..."
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding(12)
                        .background(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.7, alignment: .trailing)
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("🐝")
                            .font(.title2)
                        
                        Text(message.content)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 40)
                }
                .frame(maxWidth: .infinity * 0.8, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

#Preview {
    ContentView()
}
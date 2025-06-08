import SwiftUI

struct ContentView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatViewModel.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                            
                            if chatViewModel.isLoading {
                                LoadingView()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(chatViewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                // Input area
                HStack(spacing: 12) {
                    TextField("メッセージを入力...", text: $messageText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                        .focused($isInputFocused)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(messageText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty || chatViewModel.isLoading)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("Ollama Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { chatViewModel.clearChat() }) {
                        Image(systemName: "trash")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(chatViewModel.availableModels, id: \.self) { model in
                            Button(action: { chatViewModel.selectedModel = model }) {
                                HStack {
                                    Text(model)
                                    if model == chatViewModel.selectedModel {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cpu")
                            Text(chatViewModel.selectedModel)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let text = messageText
        messageText = ""
        
        Task {
            await chatViewModel.sendMessage(text)
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.isUser ? "You" : message.model ?? "AI")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isUser ? Color.blue : Color(UIColor.secondarySystemBackground))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct LoadingView: View {
    @State private var dots = ""
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(dots.count > index ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.3), value: dots.count)
                }
            }
            .onReceive(timer) { _ in
                dots = dots.count >= 3 ? "" : dots + "."
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environmentObject(ChatViewModel())
}
import SwiftUI
import SpeziLLM
import SpeziLLMLocal

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(hex: "1a1a2e")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if chatViewModel.isGenerating {
                                LoadingIndicator()
                                    .id("loading")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(chatViewModel.messages.last?.id ?? "loading", anchor: .bottom)
                        }
                    }
                }
                
                // Input area
                InputArea(messageText: $messageText, isInputFocused: _isInputFocused) {
                    sendMessage()
                }
            }
        }
        .onAppear {
            chatViewModel.initializeModel()
        }
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

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text("Wisbee")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Model indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(appState.isModelLoaded ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(appState.connectionMode == .local ? "Local" : "Remote")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser 
                            ? LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), 
                                           startPoint: .topLeading, 
                                           endPoint: .bottomTrailing)
                            : Color.white.opacity(0.1)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(message.isUser ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct LoadingIndicator: View {
    @State private var dots = 0
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 8, height: 8)
                        .scaleEffect(dots > index ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.3), value: dots)
                }
            }
            .onReceive(timer) { _ in
                dots = (dots + 1) % 4
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct InputArea: View {
    @Binding var messageText: String
    @FocusState var isInputFocused: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("メッセージを入力...", text: $messageText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .focused($isInputFocused)
                .lineLimit(1...4)
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: messageText.isEmpty ? [.gray] : [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .scaleEffect(messageText.isEmpty ? 1.0 : 1.1)
                    .animation(.spring(response: 0.3), value: messageText.isEmpty)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
}

// Color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
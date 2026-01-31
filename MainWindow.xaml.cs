using System;
using System.Windows;
using System.Windows.Input;
using Microsoft.Web.WebView2.Wpf;
using SmartCreate.Services;
using System.Windows.Controls;
using System.Collections.ObjectModel;

namespace SmartCreate
{
    /// <summary>
    /// Chat message model for AI conversation history
    /// </summary>
    public class ChatMessage
    {
        public string Sender { get; set; }
        public string MessageText { get; set; }
        public string ForegroundColor { get; set; }
        public string BackgroundColor { get; set; }
    }

    /// <summary>
    /// MainWindow: CreateForge AI coding assistant
    /// 70% WebView2 preview | 30% Ollama chat history
    /// </summary>
    public partial class MainWindow : Window
    {
        // OllamaService: Single connection to localhost:11434
        private readonly OllamaService _ollamaService = new();
        
        // ObservableCollection: Auto-updates UI when messages added
        public ObservableCollection<ChatMessage> Messages { get; set; } = new();

        public MainWindow()
        {
            InitializeComponent();
            MessagesList.ItemsSource = Messages;
            
            // Initialize welcome conversation
            Messages.Add(new ChatMessage 
            { 
                Sender = "AI", 
                MessageText = "Welcome to CreateForge!", 
                ForegroundColor = "LimeGreen", 
                BackgroundColor = "#2E7D32"
            });
            Messages.Add(new ChatMessage 
            { 
                Sender = "You", 
                MessageText = "Ready to build apps?", 
                ForegroundColor = "Gold", 
                BackgroundColor = "#FFB300"
            });
            
            Loaded += MainWindow_Loaded;
        }

        /// <summary>
        /// Load Vite homepage in WebView2 preview pane
        /// </summary>
        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            PreviewWebView2.Source = new Uri("https://vitejs.dev");
        }

        /// <summary>
        /// Enter key sends message (Discord/Slack UX)
        /// </summary>
        private void ChatInput_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                SendMessage();
            }
        }

        /// <summary>
        /// Send button click handler
        /// </summary>
        private void SendButton_Click(object sender, RoutedEventArgs e)
        {
            SendMessage();
        }

        /// <summary>
        /// Main chat workflow: User → Ollama → Chat History + Auto-scroll
        /// </summary>
        private async void SendMessage()
        {
            string userMessage = ChatInput.Text.Trim();
            if (string.IsNullOrEmpty(userMessage)) return;
            
            // Disable UI during processing
            ChatInput.IsEnabled = false;
            SendButton.IsEnabled = false;
            
            // Add user message to history (gold bubble)
            Messages.Add(new ChatMessage 
            { 
                Sender = "You", 
                MessageText = userMessage, 
                ForegroundColor = "Gold", 
                BackgroundColor = "#FFB300"
            });
            
            // Add temporary AI thinking message (green bubble)
            ChatMessage thinkingMsg = new ChatMessage 
            { 
                Sender = "AI", 
                MessageText = "Thinking...", 
                ForegroundColor = "LimeGreen", 
                BackgroundColor = "#4CAF50"
            };
            Messages.Add(thinkingMsg);
            
            // Scroll to bottom + prepare next input
            ChatScrollViewer.ScrollToEnd();
            ChatInput.Clear();
            ChatInput.Focus();
            
            try
            {
                // Call Ollama API (3-5 seconds typical)
                string aiResponse = await _ollamaService.SendMessageAsync(userMessage);
                
                // Replace thinking message with real AI response
                int lastIndex = Messages.Count - 1;
                Messages[lastIndex] = new ChatMessage 
                { 
                    Sender = "AI", 
                    MessageText = aiResponse, 
                    ForegroundColor = "LimeGreen", 
                    BackgroundColor = "#4CAF50"
                };
            }
            catch (Exception)
            {
                // Graceful error handling
                int lastIndex = Messages.Count - 1;
                Messages[lastIndex] = new ChatMessage 
                { 
                    Sender = "AI", 
                    MessageText = "Error connecting to Ollama", 
                    ForegroundColor = "Red", 
                    BackgroundColor = "#D32F2F"
                };
            }
            
            // Final scroll + UI re-enable
            ChatScrollViewer.ScrollToEnd();
            ChatInput.IsEnabled = true;
            SendButton.IsEnabled = true;
            ChatInput.Focus();
        }
    }
}

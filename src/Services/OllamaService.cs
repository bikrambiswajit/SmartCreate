using System.Net.Http;
using System.Net.Http.Json;
using Newtonsoft.Json.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace SmartCreate.Services
{
    public class OllamaService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://localhost:11435/api/chat";

        public OllamaService()
{
    var handler = new HttpClientHandler();
    _httpClient = new HttpClient(handler);           // THIS _httpClient
    _httpClient.Timeout = TimeSpan.FromMinutes(3);   // Lives in OllamaService
    _httpClient.BaseAddress = new Uri("http://localhost:11434/");
}

 public async Task<string> SendMessageAsync(string message, string model = "qwen2.5:3b")
{
    try 
    {
        var request = new
        {
            model = model,
            messages = new[]
            {
                new { role = "user", content = message }
            },
            stream = false,
            options = new { temperature = 0.1 }
        };

        var response = await _httpClient.PostAsJsonAsync("http://localhost:11434/api/chat", request);
        response.EnsureSuccessStatusCode();
        
        var result = await response.Content.ReadAsStringAsync();
        var json = JObject.Parse(result);
        
        return json["message"]?["content"]?.ToString() ?? "No response";
    }
    catch (Exception ex)
    {
        return $"Error: {ex.Message}";
    }
}
    }

    public class OllamaResponse
    {
        public Message? message { get; set; }
    }

    public class Message
    {
        public string? content { get; set; }
    }
}

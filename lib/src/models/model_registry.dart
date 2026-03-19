/// Information about a downloadable LLM model.
class ModelInfo {
  const ModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.sizeBytes,
    required this.downloadUrl,
    required this.quantization,
    this.parameters,
    this.recommended = false,
  });

  /// Unique identifier for the model.
  final String id;

  /// Human-readable name.
  final String name;

  /// Brief description of the model's capabilities.
  final String description;

  /// Size in bytes for the download.
  final int sizeBytes;

  /// Direct download URL (typically from HuggingFace).
  final String downloadUrl;

  /// Quantization level (e.g., Q4_K_M, Q5_K_M).
  final String quantization;

  /// Number of parameters (e.g., "1.1B", "2.7B").
  final String? parameters;

  /// Whether this model is recommended for mobile devices.
  final bool recommended;

  /// Human-readable size string.
  String get sizeString {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
  }

  /// Filename derived from the download URL.
  String get filename => downloadUrl.split('/').last;
}

/// Registry of available models for download.
class ModelRegistry {
  ModelRegistry._();

  /// All available models.
  static const List<ModelInfo> models = [
    // TinyLlama - Smallest, fastest
    ModelInfo(
      id: 'tinyllama-1.1b-q4',
      name: 'TinyLlama 1.1B',
      description: 'Compact and fast. Good for simple tasks and testing.',
      sizeBytes: 669000000, // ~669 MB
      downloadUrl:
          'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
      quantization: 'Q4_K_M',
      parameters: '1.1B',
      recommended: true,
    ),
    ModelInfo(
      id: 'tinyllama-1.1b-q5',
      name: 'TinyLlama 1.1B (Higher Quality)',
      description: 'Better quality than Q4, slightly larger.',
      sizeBytes: 782000000, // ~782 MB
      downloadUrl:
          'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf',
      quantization: 'Q5_K_M',
      parameters: '1.1B',
    ),

    // Phi-2 - Good balance of size and capability
    ModelInfo(
      id: 'phi-2-q4',
      name: 'Phi-2 2.7B',
      description: 'Microsoft\'s efficient model. Great reasoning ability.',
      sizeBytes: 1600000000, // ~1.6 GB
      downloadUrl:
          'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf',
      quantization: 'Q4_K_M',
      parameters: '2.7B',
      recommended: true,
    ),

    // Gemma 2B - Google's compact model
    ModelInfo(
      id: 'gemma-2b-q4',
      name: 'Gemma 2B Instruct',
      description: 'Google\'s instruction-tuned model. Good at following directions.',
      sizeBytes: 1500000000, // ~1.5 GB
      downloadUrl:
          'https://huggingface.co/lmstudio-ai/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_k_m.gguf',
      quantization: 'Q4_K_M',
      parameters: '2B',
    ),

    // Qwen 1.8B - Alibaba's efficient model
    ModelInfo(
      id: 'qwen-1.8b-q4',
      name: 'Qwen 1.8B Chat',
      description: 'Alibaba\'s multilingual model. Good for diverse tasks.',
      sizeBytes: 1100000000, // ~1.1 GB
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen1.5-1.8B-Chat-GGUF/resolve/main/qwen1_5-1_8b-chat-q4_k_m.gguf',
      quantization: 'Q4_K_M',
      parameters: '1.8B',
    ),

    // StableLM Zephyr 3B - Stability AI
    ModelInfo(
      id: 'stablelm-zephyr-3b-q4',
      name: 'StableLM Zephyr 3B',
      description: 'Stability AI\'s chat model. Balanced performance.',
      sizeBytes: 1900000000, // ~1.9 GB
      downloadUrl:
          'https://huggingface.co/TheBloke/stablelm-zephyr-3b-GGUF/resolve/main/stablelm-zephyr-3b.Q4_K_M.gguf',
      quantization: 'Q4_K_M',
      parameters: '3B',
    ),

    // Qwen3 4B - Alibaba's latest with native tool calling
    ModelInfo(
      id: 'qwen3-4b-q4',
      name: 'Qwen3 4B',
      description: 'Native tool/function calling support. Best-in-class for its size.',
      sizeBytes: 2500000000, // ~2.5 GB
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf',
      quantization: 'Q4_K_M',
      parameters: '4B',
      recommended: true,
    ),

    // LFM2.5 Nova 1.2B - Purpose-built for function calling
    ModelInfo(
      id: 'lfm25-nova-1.2b-fc-q4',
      name: 'LFM2.5 Nova 1.2B Function Calling',
      description: 'Purpose-built for tool calling. 97% valid JSON output reliability.',
      sizeBytes: 731000000, // ~731 MB
      downloadUrl:
          'https://huggingface.co/mradermacher/LFM2.5-1.2B-Nova-Function-Calling-GGUF/resolve/main/LFM2.5-1.2B-Nova-Function-Calling.Q4_K_M.gguf',
      quantization: 'Q4_K_M',
      parameters: '1.2B',
    ),
  ];

  /// Get recommended models for mobile devices.
  static List<ModelInfo> get recommendedModels =>
      models.where((m) => m.recommended).toList();

  /// Get a model by its ID.
  static ModelInfo? getById(String id) {
    return models.cast<ModelInfo?>().firstWhere(
          (m) => m?.id == id,
          orElse: () => null,
        );
  }

  /// Get models sorted by size (smallest first).
  static List<ModelInfo> get modelsBySize =>
      List.from(models)..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
}

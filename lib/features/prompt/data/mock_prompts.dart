import '../models/prompt_model.dart';

/// Mock data for Private Prompts
class MockPrivatePrompts {
  static List<PrivatePrompt> getPrompts() {
    return [
      PrivatePrompt(
        id: '1',
        name: 'Recognize Language',
        content: 'Tell me what language is this and translate it into [Language]',
        isFavorite: false,
      ),
      PrivatePrompt(
        id: '2',
        name: 'Fixy',
        content: "Check and correct grammar and spells, but before doing that do not use something like [don't] instead of that, [use do not]. Make the sentence short and formal.",
        isFavorite: true,
      ),
      PrivatePrompt(
        id: '3',
        name: 'Translate RU',
        content: 'Fix grammar and translate into russian: [Sentence]',
        isFavorite: true,
      ),
      PrivatePrompt(
        id: '4',
        name: 'Translate Russian',
        content: 'Translate text into russian',
        isFavorite: false,
      ),
      PrivatePrompt(
        id: '5',
        name: 'Give information about a topic',
        content: 'Give me some information about the [TOPIC], contains [KEYWORDS]',
        isFavorite: false,
      ),
      PrivatePrompt(
        id: '6',
        name: 'Translate Chinese',
        content: 'Translate text into chinese',
        isFavorite: true,
      ),
    ];
  }
}

/// Mock data for Public Prompts
class MockPublicPrompts {
  static List<PublicPrompt> getPrompts() {
    return [
      PublicPrompt(
        id: 'p1',
        name: 'Recognize Language',
        content: 'Tell me what language is this and translate it into [Language]',
        category: PromptCategory.business,
        description: 'Help user determine the language of the sentence and translate it to english',
        isFavorite: true,
      ),
      PublicPrompt(
        id: 'p2',
        name: 'Fixy',
        content: "Check and correct grammar and spells, but before doing that do not use something like [don't] instead of that, [use do not]. Make the sentence short and formal.",
        category: PromptCategory.writing,
        description: 'Fix grammar and spelling errors in your text',
        isFavorite: false,
      ),
      PublicPrompt(
        id: 'p3',
        name: 'Translate RU',
        content: 'Fix grammar and translate into russian: [Sentence]',
        category: PromptCategory.business,
        description: 'Translate text into Russian with grammar correction',
        isFavorite: false,
      ),
      PublicPrompt(
        id: 'p4',
        name: 'Translate Russian',
        content: 'Translate text into russian',
        category: PromptCategory.writing,
        description: 'Translate text into russian',
        isFavorite: true,
      ),
      PublicPrompt(
        id: 'p5',
        name: 'Give information about a topic',
        content: 'Give me some information about the [TOPIC], contains [KEYWORDS]',
        category: PromptCategory.seo,
        description: 'Give the user some information about the topic',
        isFavorite: true,
      ),
      PublicPrompt(
        id: 'p6',
        name: 'Blog Post Writer',
        content: 'Write a blog post about [TOPIC] with these keywords: [KEYWORDS]',
        category: PromptCategory.writing,
        description: 'Generate SEO-optimized blog posts',
        isFavorite: false,
      ),
      PublicPrompt(
        id: 'p7',
        name: 'Code Explainer',
        content: 'Explain this code in simple terms: [CODE]',
        category: PromptCategory.coding,
        description: 'Get clear explanations for code snippets',
        isFavorite: true,
      ),
      PublicPrompt(
        id: 'p8',
        name: 'Marketing Copy',
        content: 'Write marketing copy for [PRODUCT] targeting [AUDIENCE]',
        category: PromptCategory.marketing,
        description: 'Create compelling marketing content',
        isFavorite: false,
      ),
      PublicPrompt(
        id: 'p9',
        name: 'Resume Improver',
        content: 'Improve this resume section: [SECTION]',
        category: PromptCategory.career,
        description: 'Enhance your resume content',
        isFavorite: false,
      ),
      PublicPrompt(
        id: 'p10',
        name: 'Study Helper',
        content: 'Explain [CONCEPT] in simple terms with examples',
        category: PromptCategory.education,
        description: 'Learn complex concepts easily',
        isFavorite: true,
      ),
    ];
  }
}

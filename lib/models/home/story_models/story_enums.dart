enum ReadingLevel {
  CEFR_A1("CEFR A1"),
  CEFR_A2("CEFR A2"),
  CEFR_B1("CEFR B1"),
  CEFR_B2("CEFR B2"),
  CEFR_C1("CEFR C1"),
  CEFR_C2("CEFR C2");

  final String value;
  const ReadingLevel(this.value);

  String get description {
    switch (this) {
      case ReadingLevel.CEFR_A1:
        return "Basic words, Simple phrases";
      case ReadingLevel.CEFR_A2:
        return "Simple Sentences, Basic Vocabulary"; // Matches design image
      case ReadingLevel.CEFR_B1:
        return "Everyday conversation, Main points";
      case ReadingLevel.CEFR_B2:
        return "Complex texts, Technical discussions";
      case ReadingLevel.CEFR_C1:
        return "Long texts, Implanted meaning";
      case ReadingLevel.CEFR_C2:
        return "Complex subjects, Nuanced meanings";
    }
  }

  double get difficulty {
    // Returns a value between 0.0 and 1.0 for the progress bar
    switch (this) {
      case ReadingLevel.CEFR_A1:
        return 0.16;
      case ReadingLevel.CEFR_A2:
        return 0.33;
      case ReadingLevel.CEFR_B1:
        return 0.50;
      case ReadingLevel.CEFR_B2:
        return 0.66;
      case ReadingLevel.CEFR_C1:
        return 0.83;
      case ReadingLevel.CEFR_C2:
        return 1.0;
    }
  }
}

enum Language {
  ENGLISH("English"),
  NORWEGIAN("Norwegian"),
  SPANISH("Spanish"),
  FRENCH("French"),
  GERMAN("German");

  final String value;
  const Language(this.value);
}

enum TextType {
  NARRATIVE_STORY("Narrative Story"),
  MIXED_STORY_PLUS_FACTS("Mixed Story + Facts"),
  ARTICLE_SIMPLE("Article (simple)"),
  DIALOGUE_SIMPLE_CHARACTERS("Dialogue (simple characters)"),
  STORY_BASED_LEARNING_MODULES("Story-based learning modules"),
  DEBATE_FORMAT("Debate Format"),
  ARTICLE("Article"),
  ARGUMENTATIVE_TEXT("Argumentative Text"),
  INTERVIEW("Interview"),
  SHORT_FICTION("Short Fiction"),
  NARRATIVE("Narrative"),
  INFORMATIONAL_REPORT("Informational Report"),
  CASE_STUDIES("Case Studies"),
  WORKPLACE_SCENARIOS("Workplace Scenarios"),
  REPORTS("Reports"),
  MICROLEARNING_MODULES("Microlearning Modules"),
  HOW_TO_GUIDES("How-to Guides"),
  ANALYTICAL_ESSAYS("Analytical Essays"),
  STORY("Story");

  final String value;
  const TextType(this.value);
}

enum ReadingSkill {
  COMPREHENSION("Comprehension"),
  VOCABULARY("Vocabulary"),
  INFERENCE("Inference"),
  CRITICAL_THINKING("Critical Thinking"),
  FLUENCY("Fluency"),
  GRAMMAR("Grammar"),
  PHONICS("Phonics");

  final String value;
  const ReadingSkill(this.value);
}

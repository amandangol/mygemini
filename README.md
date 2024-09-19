[SEPTEMBER Hackathon coding challenge]

# MyGemini: AI-Powered Assistant Suite

MyGemini is a versatile Flutter application that combines multiple AI-powered assistants into a single, user-friendly interface. With specialized AI tools, users can access a wide range of features for various tasks and purposes.

## Video Demo

[Click HERE for a video demo](https://www.youtube.com/watch?v=N9KE1wjZd2M)

<img src="https://github.com/user-attachments/assets/e6fe79cc-263c-4c76-ad90-e3d5a32e5183" alt="homebright"  height="500">  <img src="https://github.com/user-attachments/assets/0e185b79-64e3-4534-96fe-219056e31cd3" alt="homedark"  height="500"> <img src="https://github.com/user-attachments/assets/d5d3994a-76d1-4782-93ce-90a3e31805ab" alt="homebots"  height="500">


## Key Features

MyGemini offers eight AI-powered assistants, each designed for specific tasks:

1. **AI Chat Assistant**: Engage in intelligent conversations on any topic with image and text.
   <img src="https://github.com/user-attachments/assets/8d020773-0823-465a-863d-21b6a3eb7a65" alt="homebright"  height="500">
   <img src="https://github.com/user-attachments/assets/359b9fb1-60a1-4dcf-bb06-f85477d747e8" alt="homebright"  height="500">

3. **AI Learning Assistant**: Enhance your learning with personalized AI tutoring.
4. **AI Code Generator**: Create code snippets and get programming help.
5. **AI Document Analyzer**: Extract insights and analyze documents efficiently.
6. **AI Content Creator**: Generate creative content for various purposes.
7. **AI Email Composer**: Craft professional emails with AI assistance.
8. **AI Translator**: Translate text between multiple languages.
9. **AI Trend Newsletter Generator**: Create newsletters based on current trends.

## Why Choose MyGemini?

- **All-in-One Solution**: Access multiple AI tools in a single app.
- **User-Friendly Interface**: Intuitive design with easy navigation between features.
- **Productivity Boost**: Streamline tasks from coding to content creation.
- **Customizable Experience**: Each assistant is tailored for specific needs.
- **Continuous Learning**: Improve skills across various domains.

## Installation and Setup

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/mygemini.git
   ```

2. Install dependencies:

   ```
   cd mygemini
   flutter pub get
   ```

3. Set Up API Keys:
   Create a .env file in the root directory and add your API keys, for Google Generative AI:

   ```
   GEMINI_API_KEY=your-api-key
   ```

4. Run the application:
   ```
   flutter run
   ```

## Usage

1. Launch the app to see the main menu with all available AI assistants.
2. Select the desired assistant by tapping on its card.
3. Each assistant has a dedicated screen for interaction.
4. Use the chat interface or specific tools provided by each assistant.

## Development Notes

- Built with Flutter and GetX for state management and navigation.
- Uses a modular architecture with separate controllers for each AI assistant.
- Implements custom enums and extensions for efficient feature management.
- Utilizes Lottie animations for an engaging user interface.

## Project Structure

The app is organized into feature-specific screens, including:

- `chatbot`
- `learning_assistant`
- `code_generator`
- `document_analyzer`
- `creative_contentbot`
- `email_gen`
- `translator`
- `trendbased_news_gen`

Each feature has its own screen and controller, promoting a clean and maintainable codebase.

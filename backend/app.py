from flask import Flask, request, jsonify
import time
import google.generativeai as genai

app = Flask(__name__)

# Configure the Gemini API
genai.configure(api_key="AIzaSyAcpkdxOkgN0iPb_tgq3ZV_pFVpotx_-gA")

# Create the model with generation configuration
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 64,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config,
)

@app.route('/recommend', methods=['POST'])
def recommend_movies():
    start_time = time.time()
    
    # Get preferences from the request
    data = request.get_json()
    preferences = data.get('preferences', '')

    if not preferences:
        return jsonify({'error': 'No preferences provided'}), 400

    # Build the prompt for movie recommendations
    prompt = f"Recommend movies based on these preferences: {preferences} give the response in short paragraphs without * symbol"

    try:
        # Generate content using the model
        response = model.generate_content(prompt)
        elapsed_time = time.time() - start_time
        print(f"Gemini response received (took {elapsed_time:.2f} seconds)")

        # Check if response is not None
        if response and hasattr(response, 'text'):
            return jsonify({'recommendations': response.text}), 200
        else:
            return jsonify({'message': 'No response generated.'}), 500

    except Exception as e:
        print(f"Error generating content: {e}")
        return jsonify({'error': 'Sorry, I\'m having trouble generating a response.'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

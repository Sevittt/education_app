import base64
import json
import os
import sys
from google import genai
from google.genai import types

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    # Use default credentials or whatever is available, or we might just fail
    client = genai.Client()
else:
    client = genai.Client(api_key=api_key)

if len(sys.argv) < 2:
    print("Usage: python describe_image.py <image_path>")
    sys.exit(1)

image_path = sys.argv[1]

try:
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=[
            "Describe this screenshot in detail. Pay attention to any error messages, UI state, and what screen it is.",
            types.Part.from_bytes(
                data=base64.b64decode(encoded_string),
                mime_type="image/webp"
            )
        ]
    )
    print("Image description:")
    print(response.text)
except Exception as e:
    print(f"Error processing image: {e}")

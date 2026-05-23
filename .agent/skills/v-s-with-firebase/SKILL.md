---
name: v-s-with-firebase
description: Guidelines for setting up and querying the Firebase Vector Search Extension
---
# Vector Search with Firebase Extension

This skill provides instructions on how to properly configure, monitor, and use the Firebase Vector Search Extension, especially for integrating RAG (Retrieval-Augmented Generation) in mobile and web apps.

## 1. Extension Configuration & Troubleshooting

If you have already installed the extension but it is not generating embeddings for existing documents, you need to reconfigure it.

1. Go to the **Firebase Console** -> **Extensions**.
2. Click **Manage** on the `Firestore Vector Search` extension instance.
3. Click **Reconfigure extension**.
4. Verify or set the following important parameters:
   - **Collection path**: The path to your documents (e.g., `knowledge_base`).
   - **Input field name**: The field containing the text to embed (e.g., `text`).
   - **Output field name**: `embedding` (this is where the generated embeddings will be stored).
   - **Dimensions**: Ensure this matches your embedding model (e.g., `768` for Gemini models).
   - **Embed existing documents?**: **MUST BE SET TO `Yes` (or True)** if you want the extension to process documents that were already in your database.
5. Save the configuration and wait 3-5 minutes for Cloud Tasks to process the existing documents. You can monitor the progress in the Google Cloud Console under "Cloud Tasks".

## 2. Querying the Vector Index

Before querying, ensure a vector index is built in Firestore. The extension triggers the basic index upon installation/reconfiguration. Check the build status at `https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes`.

### Querying via Firebase Callable Functions

The extension exposes an HTTP Callable Cloud Function named `ext-firestore-vector-search-queryCallable` (the precise name depends on your extension instance ID, usually `ext-firestore-vector-search-queryCallable`).

**JavaScript Example:**
```javascript
import { getFunctions, httpsCallable } from 'firebase/functions';

// Initialize functions with your region
const functions = getFunctions(app, 'us-central1');

const queryCallable = httpsCallable(
  functions,
  'ext-firestore-vector-search-queryCallable'
);

queryCallable({ query: 'your search text here', limit: 3 })
  .then(result => {
    // The response data contains an array of matched document IDs
    // { ids: string[] }
    console.log("Matched IDs:", result.data.ids);
  })
  .catch(error => console.error('Error querying function:', error));
```

**Flutter / Dart Example:**
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<List<String>> searchVector(String queryText) async {
  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final callable = functions.httpsCallable('ext-firestore-vector-search-queryCallable');
  
  final result = await callable.call({
    'query': queryText,
    'limit': 3,
  });
  
  // The response is a map containing 'ids' which is a list of strings
  final List<dynamic> ids = result.data['ids'];
  return ids.map((id) => id.toString()).toList();
}
```

### Advanced: Prefilters
You can pass prefilters in the callable function argument. Note that using prefilters requires a **composite index**. The first call will fail and produce an error in your Firebase Functions logs containing a `gcloud` CLI command which you must run to build the appropriate index.

```json
{
    "query": "my query",
    "limit": 4,
    "prefilters": [
        {
            "field": "category",
            "operator": "==",
            "value": "legal"
        }
    ]
}
```

## 3. Custom Embedding Functions (Optional)

If you are not using standard Gemini, Vertex AI, or OpenAI models natively supported by the extension, you can configure it to hit a custom endpoint:
- The endpoint must accept a POST request: `{"batch": ["string1", "string2"]}`
- It must return a response: `{"embeddings": [[0.1, 0.2, ...], [0.3, 0.4, ...]]}`
- lengths must match exactly.

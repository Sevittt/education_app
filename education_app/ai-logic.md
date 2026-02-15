In your lib/main.dart file, import the Firebase core plugin, the Firebase AI Logic plugin, and the configuration file you generated earlier:

import 'package:firebase\_core/firebase\_core.dart';

import 'package:firebase\_ai/firebase\_ai.dart';

import 'firebase\_options.dart';



Also in your lib/main.dart file, initialize Firebase using the DefaultFirebaseOptions object exported by the configuration file:

await Firebase.initializeApp(

&nbsp; options: DefaultFirebaseOptions.currentPlatform,

);



Rebuild your Flutter application:

flutter run



###### Initialize the service and create a model instance



When using the Firebase AI Logic client SDKs with the Gemini Developer API, you do NOT add your Gemini API key into your app's codebase. 

Before sending a prompt to a Gemini model, initialize the service for your chosen API provider and create a GenerativeModel instance.





import 'package:firebase\_ai/firebase\_ai.dart';

import 'package:firebase\_core/firebase\_core.dart';

import 'firebase\_options.dart';



// Initialize FirebaseApp

await Firebase.initializeApp(

&nbsp; options: DefaultFirebaseOptions.currentPlatform,

);



// Initialize the Gemini Developer API backend service

// Create a `GenerativeModel` instance with a model that supports your use case

final model =

&nbsp;     FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');



Note that depending on the capability you're using, you might not always create a GenerativeModel instance.



To access an Imagen model, create an ImagenModel instance.

To stream input and output using the Gemini Live API, create a LiveModel instance.

Also, after you finish this getting started guide, learn how to choose a model for your use case and app.



Important: Before going to production, we strongly recommend implementing Firebase Remote Config so that you can remotely change the model name used in your app.



###### Send a prompt request to a model



You're now set up to send a prompt request to a Gemini model.



You can use generateContent() to generate text from a prompt that contains text:





import 'package:firebase\_ai/firebase\_ai.dart';

import 'package:firebase\_core/firebase\_core.dart';

import 'firebase\_options.dart';



// Initialize FirebaseApp

await Firebase.initializeApp(

&nbsp; options: DefaultFirebaseOptions.currentPlatform,

);



// Initialize the Gemini Developer API backend service

// Create a `GenerativeModel` instance with a model that supports your use case

final model =

&nbsp;     FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');



// Provide a prompt that contains text

final prompt = \[Content.text('Write a story about a magic backpack.')];



// To generate text output, call generateContent with the text input

final response = await model.generateContent(prompt);

print(response.text);



The Gemini API can also stream responses for faster interactions, as well as handle multimodal prompts that include content like images, video, audio, and PDFs. Later on this page, find links to guides for various capabilities of the Gemini API.

If you get an error, make sure that your Firebase project is set up correctly with the Blaze pricing plan and required APIs enabled.






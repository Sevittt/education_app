// lib/data/dummy_data.dart

// Import UserRole and User from where they are centrally defined (lib/models/users.dart)
import '../models/users.dart'; // Imports User, UserRole, userRoleToString

// import '../models/resource.dart';
import '../models/news.dart';
import '../models/discussion_topic.dart';
import '../models/comment.dart';

// // Create a list of dummy Resource objects
// final List<Resource> dummyResources = [
//   Resource(
//     id: 'r1',
//     title: 'Introduction to Programming with Dart',
//     description:
//         'A beginner-friendly guide covering Dart basics, variables, control flow, and functions. Essential for Flutter development.',
//     author: 'Teach&Learn Team',
//     type: ResourceType.article,
//     url: 'https://dart.dev/language',
//     createdAt: DateTime(2024, 10, 26, 10, 0),
//   ),
//   Resource(
//     id: 'r2',
//     title: 'Building Your First Flutter App: A Video Guide',
//     description:
//         'Step-by-step video tutorial on setting up Flutter, understanding widgets, and creating a simple mobile application from scratch.',
//     author: 'Flutter Educators',
//     type: ResourceType.video,
//     url:
//         'https://www.youtube.com/watch?v=x0uiO23_t9w', // Placeholder Youtube Link
//     createdAt: DateTime(2024, 10, 25, 14, 30),
//   ),
//   Resource(
//     id: 'r3',
//     title: 'Core Web Development Skills: HTML, CSS, JS',
//     description:
//         'An article outlining the fundamental skills needed for front-end web development, focusing on HTML structure, CSS styling, and JavaScript interactivity.',
//     author: 'WebSkills Hub',
//     type: ResourceType.article,
//     createdAt: DateTime(2024, 10, 24, 9, 15),
//     url:
//         'https://developer.mozilla.org/en-US/docs/Learn', // Placeholder MDN Link
//   ),
//   Resource(
//     id: 'r4',
//     title: 'Practical Git and GitHub for Beginners (Code Examples)',
//     description:
//         'A small repository and guide demonstrating common Git commands, branching strategies, and collaborative workflows using GitHub.',
//     author: 'CodeContrib',
//     type: ResourceType.code,
//     url:
//         'https://github.com/git-guides/install-git', // Placeholder GitHub Guide Link
//     createdAt: DateTime(2024, 10, 23, 16, 0),
//   ),
//   Resource(
//     id: 'r5',
//     title: 'Lesson Plan: Teaching Python to High Schoolers',
//     description:
//         'A downloadable lesson plan structure for educators, including activities and project ideas for introducing Python programming concepts to high school students.',
//     author: 'Educator Community',
//     type: ResourceType.lessonPlan,
//     createdAt: DateTime(2024, 10, 22, 11, 0),
//     url:
//         'https://www.example.com/lessonplans/python_highschool.pdf', // Placeholder PDF link
//   ),
//   Resource(
//     id: 'r6',
//     title: 'Understanding Data Structures (Tutorial Series)',
//     description:
//         'A series of tutorials explaining common data structures like arrays, linked lists, stacks, queues, and trees with practical examples.',
//     author: 'CS Fundamentals',
//     type: ResourceType.tutorial,
//     createdAt: DateTime(2024, 10, 21, 13, 0),
//     url:
//         'https://www.geeksforgeeks.org/data-structures/', // Placeholder GeeksForGeeks Link
//   ),
//   Resource(
//     id: 'r7',
//     title: 'Introduction to Object-Oriented Programming (OOP)',
//     description:
//         'A comprehensive article explaining the core concepts of OOP such as classes, objects, inheritance, polymorphism, and encapsulation.',
//     author: 'Programming Concepts Institute',
//     type: ResourceType.article,
//     url: 'https://www.example.com/oop-intro',
//     createdAt: DateTime(2024, 10, 20, 10, 0),
//   ),
//   Resource(
//     id: 'r8',
//     title: 'Flutter State Management: Provider Explained',
//     description:
//         'A video tutorial that dives deep into using the Provider package for state management in Flutter applications. Covers ChangeNotifier, Consumer, and more.',
//     author: 'Flutter Advanced',
//     type: ResourceType.video,
//     url:
//         'https://www.youtube.com/watch?v=d_m5csmrf7I', // Placeholder Youtube Link
//     createdAt: DateTime(2024, 10, 19, 15, 0),
//   ),
//   Resource(
//     id: 'r9',
//     title: 'Responsive UI Design in Flutter',
//     description:
//         'Tutorial on creating adaptive user interfaces in Flutter that look great on different screen sizes and orientations using LayoutBuilder, MediaQuery, and flexible widgets.',
//     author: 'Flutter UI Masters',
//     type: ResourceType.tutorial,
//     url: 'https://docs.flutter.dev/ui/layout/responsive',
//     createdAt: DateTime(2024, 10, 18, 11, 30),
//   ),
// ];

final User dummyUser2 = User(
  id: 'u2',
  name: 'Samadov Ubaydulla',
  email: 'samadov@example.com',
  role: UserRole.student,
  profilePictureUrl: 'assets/images/my_pic.jpg',
  lastLogin: DateTime.now().subtract(const Duration(days: 1)),
  registrationDate: DateTime.now().subtract(const Duration(days: 30)),
  bio: 'A passionate learner and future Flutter developer!',
);

// Create a list of dummy News objects
final List<News> dummyNews = [
  News(
    id: 'n1',
    title: 'New Online Courses Launched for IT Educators',
    source: 'EduWeek News',
    url:
        'https://www.edweek.org/teaching-learning/the-best-ways-to-teach-word-problems-so-all-students-understand/2025/05',
    publicationDate: DateTime(2025, 5, 10),
  ),
  News(
    id: 'n2',
    title: 'Future of Coding Bootcamps in Bridging the Skills Gap',
    source: 'Tech Learning Monthly',
    url:
        'https://publications.iadb.org/en/disrupting-talent-emergence-coding-bootcamps-and-future-digital-skills',
    publicationDate: DateTime(2025, 5, 9),
  ),
  News(
    id: 'n3',
    title:
        'Government Initiative to Fund Digital Skills Training in Uzbekistan',
    source: 'Education Today - Uzbekistan',
    url:
        'https://uzbekistan.un.org/en/238932-swiss-government-and-undp-join-forces-promote-digital-skills-among-young-people-uzbekistan?afd_azwaf_tok=eyJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJ1emJla2lzdGFuLnVuLm9yZyIsImV4cCI6MTc0NzcwODc5OSwiaWF0IjoxNzQ3NzA4Nzg5LCJpc3MiOiJ0aWVyMS03Njk5Y2ZmYzk2LXd3cWY5Iiwic3ViIjoiODYuNjIuMC4xOTYiLCJkYXRhIjp7InR5cGUiOiJpc3N1ZWQiLCJyZWYiOiIyMDI1MDUyMFQwMjM5NDlaLTE3Njk5Y2ZmYzk2d3dxZjloQzFTVE9oZmZuMDAwMDAwMDVmMDAwMDAwMDAwMHVoYSIsImIiOiJfZDVnaFl6M0xodnI0dm5zcUV6M2MwdGhQWC13WXdKQ0RMM1ktaVY3UXJnIiwiaCI6IlhQeWtvNElsUzFDQmtacUR5b0tvRWJnc25tNjMwcmpONzNPTnhCOXVNNVUifX0.ohWLzLG-m3AAIVI9XMMZ0TBLu6Ie0oXL3DmAB1HORzXAfnetbG3tW024J75gxXIpLQJYJ0DjUFfmJqXXLQbJOHzLJXK83pECszPTBk_yXug2YgENN-PSX-BRu2QWXa7xk5BltjhoyLx4TBMtRNdczMvH0YeNEkGQw_yXmnd4F830eM2IDPgDHxBMs0fdWKk1v0Ku8szDFlap4ecYluG1WpeFVqZEBpXOLjMub9tiJAfRRFm-DdMlyVZxB4viYED9dq_BKWsPhwF6ct7866MLq1QO6f9XKYyjzCyIInZQUBLZqGxKVii5-iFhbaPW14tnddgftH0Z_SPSZih7x9-2zQ.WF3obl2IDtqgvMFRqVdYkD5s', // Placeholder
    publicationDate: DateTime(2025, 5, 8),
  ),
  News(
    id: 'n4',
    title: 'The Importance of Soft Skills in IT Careers',
    source: 'Career Development Hub',
    url: 'https://techno.study/importance-of-soft-skills-in-the-it-industry',
    publicationDate: DateTime(2025, 5, 7),
  ),
  News(
    id: 'n5',
    title: 'AI in Education: Transforming Learning Experiences',
    source: 'FutureLearn Insights',
    url:
        'https://www.upskillist.com/blog/ai-in-education-transforming-learning-for-the-modern-student/', // Placeholder
    publicationDate: DateTime(2025, 5, 6),
  ),
  News(
    id: 'n6',
    title: 'Global EdTech Investment Reaches New Highs',
    source: 'EdTech Global Monitor',
    url:
        'https://www.holoniq.com/notes/87bn-of-global-edtech-funding-predicted-to-2030', // Placeholder
    publicationDate: DateTime(2025, 5, 5),
  ),
];

final List<DiscussionTopic> dummyDiscussionTopics = [
  DiscussionTopic(
    id: 't1',
    title: 'Best resources for learning Python in 2025?',
    content:
        'I\'m an educator looking for updated resources to teach Python basics to students. Any recommendations for interactive platforms or project-based learning materials?',
    authorName: 'User 1',
    authorId: 'u1',
    createdAt: DateTime(2025, 5, 12, 9, 0),
    commentIds: ['c1', 'c2'],
    commentCount: 2,
  ),
  DiscussionTopic(
    id: 't2',
    title: 'How to explain complex algorithms simply?',
    content:
        'Struggling to make algorithms like sorting and searching engaging for beginners. Any teaching strategies, real-world analogies, or visual tools that have worked well for you?',
    authorName: dummyUser2.displayName ?? 'Anonymous', // <-- fix here
    authorId: dummyUser2.id,
    createdAt: DateTime(2025, 5, 11, 14, 30),
    commentIds: [],
    commentCount: 0,
  ),
  // ... other topics
];

final List<Comment> dummyComments = [
  Comment(
    id: 'c1',
    topicId: 't1',
    authorId: dummyUser2.id,
    content:
        'For Python, check out "Automate the Boring Stuff". Great for practical examples! Also, Replit is a good interactive platform for coding in the browser.',
    createdAt: DateTime(2025, 5, 12, 10, 0),
  ),
  Comment(
    id: 'c2',
    topicId: 't1',
    authorId: 'u1',
    content:
        'Thanks! Will look into it. Replit sounds interesting for classroom use.',
    createdAt: DateTime(2025, 5, 12, 11, 0),
  ),
];

User? findUserById(String userId) {
  if (dummyUser2.id == userId) {
    return dummyUser2;
  }
  if (userId == 'u1') {
    return User(
      id: 'u1',
      name: 'Madamin Solijonov',
      role: UserRole.teacher,
      profilePictureUrl: 'assets/images/solijonov_madamin.jpg',
    );
  }
  return null;
}

List<Comment> findCommentsByTopicId(String topicId) {
  return dummyComments.where((comment) => comment.topicId == topicId).toList();
}

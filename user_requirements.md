1. User Requirement Document (URD) for todo.social

1.1 Overview

todo.social is a social task and routine management platform delivered as a mobile application. It
aims to bridge the gap between personal productivity and social accountability by allowing users
to manage their daily tasks and share their progress with friends and followers.

The platform is built using the Flutter framework for the responsive Frontend, Node.js and
Express for the scalable Backend API, and MySQL for persistent relational data storage.

1.2 Purpose

The core objectives of the system are:
1. Security and User Experience: Provide a secure and intuitive mobile experience for
managing personal tasks and routines.
2. Motivation and Accountability: Increase user motivation and accountability through
social visibility features (like the Feed and Followers list).
3. Productivity Tracking: Facilitate the comprehensive tracking of personal, professional,
and academic productivity goals over time.

2. System Users

2.1 Customers (Users)

Users are the primary actors and interact directly with the mobile application. They are
responsible for all core system functions: account creation, task management, social interaction
(following, unfollowing), and consumption of the main social feed.

Target Device: Mobile Application (iOS/Android via Flutter)

Technical Stack: Flutter, Node.js, MySQL

4. Functional Requirements (What the System Must Do)

3.1 Authentication and Authorization (AUTH Epic)
This epic ensures secure user access and validates user identity across all interactions.

FR-3.1.1: User Registration
o The system must allow new users to create an account by providing a unique
email address and a secure password.
o Crucial Detail: Password storage must utilize strong, industry-standard hashing
and salting techniques before permanent storage to prevent plain-text exposure
(NFR-4.2.1).

FR-3.1.2: User Login
o The system must allow registered users to log in using their verified credentials.
o Crucial Detail: Upon successful authentication, the system must issue a JSON
Web Token (JWT) for subsequent secure session management.

FR-3.1.3: Authorization

o The system must rigorously validate the presence and validity of the JWT for
every request made to a protected API endpoint (e.g., creating a task, following a
user). Unauthorized requests must be rejected.

3.2 Task and Routine Management (TODO Epic)

This epic covers the core private productivity features, allowing the user to manage their
commitments.
FR-3.2.1: Task Creation (CRUD)

o Authenticated users must be able to create new productivity items, classifying
them as either a Task or a Routine.
o Each item requires essential attributes: Title, Description, and Recurrence
settings (Daily, Weekly, or One-Time).

FR-3.2.2: Task Listing

o The user's primary "My Todos" screen must display a complete list of all currently
active tasks and routines belonging exclusively to the authenticated user.

FR-3.2.3: Task Update/Delete

o Users must have full control over their own data, allowing them to modify the
details of an existing task or permanently delete it from the system.

FR-3.2.4: Mark as Completed

o The system must provide a clear and easily accessible mechanism (e.g., a
checkbox) to mark a task's status as completed.
o The system must automatically track and record the precise date and time of
completion.

3.3 Social Features (SOCIAL Epic)

This epic introduces the community aspect of the platform, enhancing accountability through user
interaction.
FR-3.3.1: User Searcho
 The application must include a function allowing users to search for other
registered users based on their display name or unique username.

FR-3.3.2: Follow/Unfollow

o Users must be able to establish a non-mutual (one-way) "Follow" relationship with
another user to subscribe to their public activity. They must also be able to remove
this relationship ("Unfollow").

FR-3.3.3: Main Social Feed

o The primary application view (the Feed screen) must dynamically display a
chronological stream of tasks and completion events that have been explicitly
shared by the users the current user is following.

3.4 Profile Management (PROFILE Epic)

This epic governs the display and personalization of the user's identity within the platform.

FR-3.4.1: Profile Viewing

o The system must display the user's personal profile, including their display name,
username, and key task statistics (e.g., total completed tasks count, completion
rate).

FR-3.4.2: Profile Editing

o Users must be provided with an interface to update their personalized details,
specifically their display name and profile image URL.

6. Non-Functional Requirements (How the
System Must Perform)

4.1 Usability and Aesthetic Requirements

NFR-4.1.1 (Usability): The application UI must be clean, highly mobile-responsive
(leveraging Flutter's capabilities), and strictly adhere to a consistent color palette and
design language throughout all screens.

4.2 Security Requirements

NFR-4.2.1 (Security): All user passwords must be securely hashed and salted (e.g., using
bcrypt) before permanent storage in MySQL to prevent plain-text exposure in case of a
database breach.

NFR-4.2.2 (Security): The system must prevent unauthorized access to private data
(tasks, profile editing) by enforcing API-level JWT validation on every protected route.

4.3 Performance Requirements

NFR-4.3.1 (Performance): The social feed query, which aggregates data from multiple
followed users, must be highly optimized for rapid loading. The initial query must ensure
the first 10 feed items appear on screen within 3 seconds on a standard internet
connection.

4.4 Maintainability Requirements

NFR-4.4.1 (Maintainability): Both the backend code (Node.js/Express) and the frontend
code (Flutter) must adhere to established coding standards, utilize clear and consistent
naming conventions, and be comprehensively commented, particularly in complex logical
sections.

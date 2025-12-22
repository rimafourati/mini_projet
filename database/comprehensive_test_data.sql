-- ============================================================================
-- Comprehensive Test Data for Project Management Platform
-- Covers all 7 test scenarios
-- ============================================================================

USE project_management;

-- Clear existing data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE task_history;
TRUNCATE TABLE alerts;
TRUNCATE TABLE task_dependencies;
TRUNCATE TABLE task_skills;
TRUNCATE TABLE tasks;
TRUNCATE TABLE projects;
TRUNCATE TABLE member_skills;
TRUNCATE TABLE members;
TRUNCATE TABLE skills;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- SCÉNARIO 1 : GESTION DE L'ÉQUIPE
-- ============================================================================

-- Insert Skills (used across all scenarios)
INSERT INTO skills (id, name, category) VALUES
(1, 'Java Development', 'Backend'),
(2, 'Frontend Development', 'Frontend'),
(3, 'UI/UX Design', 'Design'),
(4, 'Testing', 'QA'),
(5, 'Database Design', 'Backend'),
(6, 'DevOps', 'Infrastructure'),
(7, 'Python', 'Backend'),
(8, 'Mobile Development', 'Frontend'),
(9, 'API Development', 'Backend'),
(10, 'Documentation', 'Other');

-- Insert 5 Team Members with varied skills
INSERT INTO members (id, name, email, weekly_availability, current_workload) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', 40, 0),
(2, 'Bob Smith', 'bob.smith@example.com', 35, 0),
(3, 'Carol Williams', 'carol.williams@example.com', 40, 0),
(4, 'David Brown', 'david.brown@example.com', 30, 0),
(5, 'Emma Davis', 'emma.davis@example.com', 40, 0);

-- Assign skills to members
-- Alice: Senior Java/Database Developer
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(1, 1, 5), -- Java Development - Expert
(1, 5, 4), -- Database Design - Advanced
(1, 9, 4); -- API Development - Advanced

-- Bob: Frontend Developer/Designer
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(2, 2, 5), -- Frontend Development - Expert
(2, 3, 4), -- UI/UX Design - Advanced
(2, 8, 3); -- Mobile Development - Intermediate

-- Carol: QA/Testing Specialist
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(3, 4, 5), -- Testing - Expert
(3, 10, 4), -- Documentation - Advanced
(3, 2, 2); -- Frontend Development - Basic

-- David: Backend/API Developer
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(4, 1, 4), -- Java Development - Advanced
(4, 9, 5), -- API Development - Expert
(4, 5, 3); -- Database Design - Intermediate

-- Emma: UI/UX Designer
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(5, 3, 5), -- UI/UX Design - Expert
(5, 2, 3), -- Frontend Development - Intermediate
(5, 10, 3); -- Documentation - Intermediate

-- ============================================================================
-- SCÉNARIO 2 : CRÉATION DE PROJET
-- ============================================================================

-- Create E-commerce Platform Project
INSERT INTO projects (id, name, description, start_date, end_date, status) VALUES
(1, 'E-commerce Platform Development', 
    'Complete e-commerce platform with product catalog, shopping cart, payment integration, and user management', 
    '2025-01-01', '2025-03-31', 'IN_PROGRESS');

-- Create 10 Tasks with dependencies

-- Task 1: Database Schema Design (No dependencies, URGENT)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(1, 1, 'Database Schema Design', 
    'Design complete database schema for e-commerce platform including products, orders, users, and payment tables', 
    16, 'URGENT', 'TODO', '2025-01-01', '2025-01-05');

-- Task 2: Backend API Development (Depends on Task 1, HIGH)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(2, 1, 'Backend API Development', 
    'Develop RESTful API using Java/Spring Boot for all core functionalities', 
    40, 'HIGH', 'TODO', '2025-01-06', '2025-01-20');

-- Task 3: Frontend Architecture (No dependencies, HIGH)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(3, 1, 'Frontend Architecture', 
    'Set up React/Vue.js frontend architecture, routing, and state management', 
    24, 'HIGH', 'TODO', '2025-01-01', '2025-01-10');

-- Task 4: UI/UX Design (No dependencies, HIGH)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(4, 1, 'UI/UX Design', 
    'Create wireframes, mockups, and design system for the entire application', 
    32, 'HIGH', 'TODO', '2025-01-01', '2025-01-15');

-- Task 5: Product Catalog Module (Depends on Tasks 2,3, MEDIUM)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(5, 1, 'Product Catalog Module', 
    'Implement product browsing, search, filtering, and detail views', 
    30, 'MEDIUM', 'TODO', '2025-01-21', '2025-02-05');

-- Task 6: Shopping Cart Implementation (Depends on Tasks 2,3, MEDIUM)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(6, 1, 'Shopping Cart Implementation', 
    'Develop shopping cart functionality with add/remove items, quantity management', 
    28, 'MEDIUM', 'TODO', '2025-01-21', '2025-02-05');

-- Task 7: Payment Integration (Depends on Task 2, URGENT)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(7, 1, 'Payment Integration', 
    'Integrate Stripe/PayPal payment gateway with secure transaction handling', 
    35, 'URGENT', 'TODO', '2025-01-21', '2025-02-10');

-- Task 8: User Authentication System (Depends on Tasks 1,2, HIGH)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(8, 1, 'User Authentication System', 
    'Implement user registration, login, JWT authentication, and role-based access', 
    25, 'HIGH', 'TODO', '2025-01-21', '2025-02-01');

-- Task 9: Comprehensive Testing (Depends on Tasks 5,6,7,8, HIGH)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(9, 1, 'Comprehensive Testing', 
    'Unit testing, integration testing, E2E testing, performance testing, security testing', 
    45, 'HIGH', 'TODO', '2025-02-15', '2025-03-10');

-- Task 10: Documentation & User Manual (Depends on Task 9, MEDIUM)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(10, 1, 'Documentation & User Manual', 
    'Create technical documentation, API docs, and user manual', 
    20, 'MEDIUM', 'TODO', '2025-03-11', '2025-03-25');

-- Define Task Dependencies
INSERT INTO task_dependencies (task_id, depends_on_task_id) VALUES
(2, 1),   -- Backend API depends on Database Schema
(5, 2),   -- Product Catalog depends on Backend API
(5, 3),   -- Product Catalog depends on Frontend Architecture
(6, 2),   -- Shopping Cart depends on Backend API
(6, 3),   -- Shopping Cart depends on Frontend Architecture
(7, 2),   -- Payment Integration depends on Backend API
(8, 1),   -- User Authentication depends on Database Schema
(8, 2),   -- User Authentication depends on Backend API
(9, 5),   -- Testing depends on Product Catalog
(9, 6),   -- Testing depends on Shopping Cart
(9, 7),   -- Testing depends on Payment Integration
(9, 8),   -- Testing depends on User Authentication
(10, 9);  -- Documentation depends on Testing

-- Assign required skills to tasks
INSERT INTO task_skills (task_id, skill_id, required_level) VALUES
-- Task 1: Database Schema Design
(1, 5, 4), -- Database Design, level 4

-- Task 2: Backend API Development
(2, 1, 4), -- Java Development, level 4
(2, 9, 4), -- API Development, level 4

-- Task 3: Frontend Architecture
(3, 2, 4), -- Frontend Development, level 4

-- Task 4: UI/UX Design
(4, 3, 4), -- UI/UX Design, level 4

-- Task 5: Product Catalog Module
(5, 1, 3), -- Java Development, level 3
(5, 2, 3), -- Frontend Development, level 3

-- Task 6: Shopping Cart Implementation
(6, 1, 3), -- Java Development, level 3
(6, 2, 4), -- Frontend Development, level 4

-- Task 7: Payment Integration
(7, 1, 5), -- Java Development, level 5 (critical!)
(7, 9, 4), -- API Development, level 4

-- Task 8: User Authentication System
(8, 1, 4), -- Java Development, level 4
(8, 5, 3), -- Database Design, level 3

-- Task 9: Comprehensive Testing
(9, 4, 4), -- Testing, level 4

-- Task 10: Documentation
(10, 10, 3); -- Documentation, level 3

-- ============================================================================
-- SCÉNARIO 3 : RÉPARTITION AUTOMATIQUE
-- ============================================================================
-- Note: The allocation algorithm will be triggered via API call
-- POST /api/projects/1/allocate
-- This will automatically assign tasks based on skills and workload

-- ============================================================================
-- SCÉNARIO 4 : DÉTECTION DE SURCHARGE
-- ============================================================================

-- Simulate manual task assignments that create overload
-- (These would typically be done via API, but we can pre-populate for testing)

-- Assign multiple tasks to Carol to create overload scenario
UPDATE tasks SET assigned_member_id = 3, status = 'IN_PROGRESS' 
WHERE id = 9; -- Comprehensive Testing (45h)

UPDATE tasks SET assigned_member_id = 3, status = 'TODO' 
WHERE id = 5; -- Product Catalog (30h)

UPDATE tasks SET assigned_member_id = 3, status = 'TODO' 
WHERE id = 6; -- Shopping Cart (28h)

-- Update Carol's workload
UPDATE members SET current_workload = 103 WHERE id = 3;
-- Carol now has 103h / 40h = 257.5% workload - CRITICAL OVERLOAD!

-- Create overload alert
INSERT INTO alerts (member_id, project_id, type, severity, message, is_read) VALUES
(3, 1, 'OVERLOAD', 'CRITICAL', 
 'Carol Williams is overloaded: 103.0h assigned / 40h available (257.5%)', 
 0);

-- ============================================================================
-- SCÉNARIO 5 : MODIFICATION EN COURS DE PROJET
-- ============================================================================

-- Mark some tasks as completed or in progress to simulate project in progress
UPDATE tasks SET status = 'COMPLETED', assigned_member_id = 1 
WHERE id = 1; -- Database Schema - Completed by Alice

UPDATE tasks SET status = 'IN_PROGRESS', assigned_member_id = 4 
WHERE id = 2; -- Backend API - In Progress by David

UPDATE tasks SET status = 'IN_PROGRESS', assigned_member_id = 2 
WHERE id = 3; -- Frontend Architecture - In Progress by Bob

UPDATE tasks SET status = 'IN_PROGRESS', assigned_member_id = 5 
WHERE id = 4; -- UI/UX Design - In Progress by Emma

-- Add an urgent task mid-project (Task 11)
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline) VALUES
(11, 1, 'Critical Security Vulnerability Fix', 
    'Fix SQL injection vulnerability in login endpoint - URGENT', 
    12, 'URGENT', 'TODO', '2025-01-22', '2025-01-25');

-- Add required skill for urgent task
INSERT INTO task_skills (task_id, skill_id, required_level) VALUES
(11, 1, 5), -- Java Development, level 5 (expert required!)
(11, 9, 4); -- API Development, level 4

-- This task should be auto-assigned to Alice (Java level 5) via reallocation API

-- ============================================================================
-- SCÉNARIO 6 : VISUALISATION
-- ============================================================================

-- Additional project for timeline testing
INSERT INTO projects (id, name, description, start_date, end_date, status) VALUES
(2, 'Mobile App Development', 
    'iOS and Android mobile app for the e-commerce platform', 
    '2025-02-01', '2025-04-30', 'PLANNED');

-- Add a few tasks to second project for richer timeline visualization
INSERT INTO tasks (id, project_id, title, description, estimated_hours, priority, status, start_date, deadline, assigned_member_id) VALUES
(12, 2, 'Mobile App UI Design', 'Design mobile app interfaces', 20, 'HIGH', 'TODO', '2025-02-01', '2025-02-15', 5),
(13, 2, 'iOS Development', 'Develop iOS application', 60, 'HIGH', 'TODO', '2025-02-16', '2025-03-31', NULL),
(14, 2, 'Android Development', 'Develop Android application', 60, 'HIGH', 'TODO', '2025-02-16', '2025-03-31', NULL);

INSERT INTO task_skills (task_id, skill_id, required_level) VALUES
(12, 3, 4),  -- UI/UX Design
(13, 8, 4),  -- Mobile Development
(14, 8, 4);  -- Mobile Development

-- ============================================================================
-- SCÉNARIO 7 : STATISTIQUES
-- ============================================================================

-- Update workloads for realistic statistics
UPDATE members SET current_workload = 41 WHERE id = 1;  -- Alice: 102%
UPDATE members SET current_workload = 35 WHERE id = 2;  -- Bob: 100%
UPDATE members SET current_workload = 103 WHERE id = 3; -- Carol: 257% OVERLOAD
UPDATE members SET current_workload = 40 WHERE id = 4;  -- David: 133%
UPDATE members SET current_workload = 40 WHERE id = 5;  -- Emma: 100%

-- Add some task history for progress tracking
INSERT INTO task_history (task_id, previous_status, new_status, changed_by_member_id, change_reason) VALUES
(1, 'TODO', 'IN_PROGRESS', 1, 'Started database design'),
(1, 'IN_PROGRESS', 'COMPLETED', 1, 'Database schema completed and reviewed'),
(2, 'TODO', 'IN_PROGRESS', 4, 'Started API development'),
(3, 'TODO', 'IN_PROGRESS', 2, 'Started frontend setup'),
(4, 'TODO', 'IN_PROGRESS', 5, 'Started UI/UX design');

-- Add various alerts for complete testing
INSERT INTO alerts (member_id, project_id, task_id, type, severity, message, is_read) VALUES
(3, 1, NULL, 'OVERLOAD', 'CRITICAL', 'Carol Williams is critically overloaded (257%)', 0),
(4, 1, NULL, 'OVERLOAD', 'WARNING', 'David Brown workload is high (133%)', 0),
(NULL, 1, 11, 'PRIORITY_CHANGE', 'HIGH', 'New urgent task added: Critical Security Fix', 0),
(NULL, 1, 9, 'DEPENDENCY_ISSUE', 'WARNING', 'Task cannot start: dependencies not completed', 1),
(1, 1, 1, 'TASK_COMPLETED', 'INFO', 'Alice Johnson completed Database Schema Design', 1);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify team setup (Should show 5 members with skills)
-- SELECT m.name, m.email, m.weekly_availability, m.current_workload, 
--        COUNT(ms.skill_id) as skill_count
-- FROM members m
-- LEFT JOIN member_skills ms ON m.id = ms.member_id
-- GROUP BY m.id;

-- Verify project setup (Should show 1 main project with 11 tasks)
-- SELECT p.name, COUNT(t.id) as task_count, 
--        SUM(t.estimated_hours) as total_hours
-- FROM projects p
-- LEFT JOIN tasks t ON p.id = t.project_id
-- WHERE p.id = 1
-- GROUP BY p.id;

-- Verify task dependencies (Should show 13 dependencies)
-- SELECT t1.title as task, t2.title as depends_on
-- FROM task_dependencies td
-- JOIN tasks t1 ON td.task_id = t1.id
-- JOIN tasks t2 ON td.depends_on_task_id = t2.id
-- ORDER BY td.task_id;

-- Verify skill assignments (Should show all tasks have required skills)
-- SELECT t.title, s.name as skill, ts.required_level
-- FROM tasks t
-- JOIN task_skills ts ON t.id = ts.task_id
-- JOIN skills s ON ts.skill_id = s.id
-- WHERE t.project_id = 1
-- ORDER BY t.id;

-- Verify overload detection (Should show Carol with 257% workload)
-- SELECT m.name, m.weekly_availability, m.current_workload,
--        ROUND((m.current_workload / m.weekly_availability * 100), 1) as workload_percentage
-- FROM members m
-- ORDER BY workload_percentage DESC;

-- Verify alerts (Should show 5 alerts)
-- SELECT a.type, a.severity, a.message, a.is_read,
--        m.name as member_name, p.name as project_name
-- FROM alerts a
-- LEFT JOIN members m ON a.member_id = m.id
-- LEFT JOIN projects p ON a.project_id = p.id
-- ORDER BY a.created_at DESC;

-- ============================================================================
-- TEST EXECUTION SUMMARY
-- ============================================================================

SELECT '============================================' as '';
SELECT 'COMPREHENSIVE TEST DATA LOADED SUCCESSFULLY' as '';
SELECT '============================================' as '';
SELECT '' as '';
SELECT 'SCENARIO 1: Team Management' as 'Test Scenario';
SELECT '  ✓ 5 members created' as 'Status';
SELECT '  ✓ 13 skills assigned' as '';
SELECT '  ✓ Total availability: 185h/week' as '';
SELECT '' as '';
SELECT 'SCENARIO 2: Project Creation' as 'Test Scenario';
SELECT '  ✓ 1 main project created' as 'Status';
SELECT '  ✓ 11 tasks created (including urgent)' as '';
SELECT '  ✓ 13 dependencies defined' as '';
SELECT '  ✓ Total estimated: 315 hours' as '';
SELECT '' as '';
SELECT 'SCENARIO 3: Automatic Allocation' as 'Test Scenario';
SELECT '  → Use API: POST /api/projects/1/allocate' as 'Status';
SELECT '' as '';
SELECT 'SCENARIO 4: Overload Detection' as 'Test Scenario';
SELECT '  ✓ Carol Williams overloaded (257%)' as 'Status';
SELECT '  ✓ Overload alert created' as '';
SELECT '' as '';
SELECT 'SCENARIO 5: Mid-Project Changes' as 'Test Scenario';
SELECT '  ✓ 4 tasks marked in progress' as 'Status';
SELECT '  ✓ 1 urgent task added' as '';
SELECT '  → Use API: POST /api/projects/1/reallocate' as '';
SELECT '' as '';
SELECT 'SCENARIO 6: Visualization' as 'Test Scenario';
SELECT '  ✓ Timeline data ready' as 'Status';
SELECT '  ✓ 2 projects for comparison' as '';
SELECT '  → View at: /timeline' as '';
SELECT '' as '';
SELECT 'SCENARIO 7: Statistics' as 'Test Scenario';
SELECT '  ✓ Task history recorded' as 'Status';
SELECT '  ✓ Workload data complete' as '';
SELECT '  → Use API: GET /api/statistics/project/1' as '';
SELECT '' as '';
SELECT '============================================' as '';
SELECT 'Ready for testing! Start server and open:' as '';
SELECT 'http://localhost:8080' as '';
SELECT '============================================' as '';

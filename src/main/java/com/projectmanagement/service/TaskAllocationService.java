package com.projectmanagement.service;

import com.projectmanagement.dao.AlertDAO;
import com.projectmanagement.dao.MemberDAO;
import com.projectmanagement.dao.TaskDAO;
import com.projectmanagement.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Intelligent Task Allocation Algorithm
 * Uses a heuristic approach combining multiple factors:
 * - Skills matching
 * - Workload balancing
 * - Priority and deadlines
 * - Task dependencies
 */
public class TaskAllocationService {
    private static final Logger logger = LoggerFactory.getLogger(TaskAllocationService.class);
    
    /**
     * Seuil minimum de compétence requis pour affecter une tâche
     * - 0.6 = Compétences moyennes à bonnes requises (60%)
     * 
     * Ce seuil garantit qu'on n'affecte pas de tâches à des personnes non compétentes
     */
    private static final double MINIMUM_COMPETENCE_THRESHOLD = 0.6;
    
    /**
     * Seuil pour le rééquilibrage (identique au seuil d'affectation)
     * Lors du rééquilibrage, on garde le même niveau d'exigence
     */
    private static final double REBALANCING_COMPETENCE_THRESHOLD = 0.6;
    
    private final TaskDAO taskDAO;
    private final MemberDAO memberDAO;
    private final AlertDAO alertDAO;

    public TaskAllocationService() {
        this.taskDAO = new TaskDAO();
        this.memberDAO = new MemberDAO();
        this.alertDAO = new AlertDAO();
    }

    /**
     * Main allocation method - assigns all unassigned tasks and rebalances TODO tasks
     */
    public AllocationResult allocateTasks(int projectId) throws SQLException {
        logger.info("Starting task allocation for project: {}", projectId);
        
        // Get all unassigned tasks
        List<Task> unassignedTasks = taskDAO.findUnassignedByProject(projectId);
        
        // NOUVEAU: Aussi récupérer les tâches TODO assignées à des membres surchargés
        List<Task> todoTasksFromOverloadedMembers = taskDAO.findByProjectAndStatus(projectId, Task.TaskStatus.TODO);
        List<Member> availableMembers = memberDAO.findAll();
        
        if (availableMembers.isEmpty()) {
            logger.warn("No available members found");
            return new AllocationResult(0, unassignedTasks.size(), "No available members");
        }
        
        int assignedCount = 0;
        int failedCount = 0;
        int rebalancedCount = 0;
        
        // PHASE 1: Rééquilibrer les tâches TODO des membres surchargés
        logger.info("Phase 1: Rebalancing TODO tasks from overloaded members");
        logger.info("Found {} TODO tasks to evaluate for rebalancing", todoTasksFromOverloadedMembers.size());
        
        for (Task task : todoTasksFromOverloadedMembers) {
            if (task.getAssignedMemberId() == null) continue; // Déjà non assignée
            
            try {
                Member currentMember = memberDAO.findById(task.getAssignedMemberId());
                logger.info("Evaluating task '{}' assigned to '{}' ({}%)", 
                    task.getTitle(), currentMember.getName(), 
                    String.format("%.1f", currentMember.getWorkloadPercentage()));
                
                // Si le membre actuel est surchargé (>100%), chercher quelqu'un de mieux
                if (currentMember.getWorkloadPercentage() > 100) {
                    logger.info("Member is overloaded, searching for better member...");
                    Member betterMember = findBetterMember(task, availableMembers, currentMember);
                    
                    if (betterMember != null && betterMember.getId() != currentMember.getId()) {
                        // Réassigner la tâche
                        logger.info("Rebalancing task '{}' from '{}' ({}%) to '{}' ({}%)", 
                            task.getTitle(), 
                            currentMember.getName(), 
                            String.format("%.1f", currentMember.getWorkloadPercentage()),
                            betterMember.getName(),
                            String.format("%.1f", betterMember.getWorkloadPercentage()));
                        
                        // Retirer de l'ancien membre
                        currentMember.setCurrentWorkload(currentMember.getCurrentWorkload() - task.getEstimatedHours());
                        memberDAO.updateWorkload(currentMember.getId(), currentMember.getCurrentWorkload());
                        
                        // Assigner au nouveau membre
                        assignTaskToMember(task, betterMember);
                        betterMember.setCurrentWorkload(betterMember.getCurrentWorkload() + task.getEstimatedHours());
                        memberDAO.updateWorkload(betterMember.getId(), betterMember.getCurrentWorkload());
                        
                        rebalancedCount++;
                    }
                }
            } catch (Exception e) {
                logger.error("Error rebalancing task: {}", task.getTitle(), e);
            }
        }
        
        // PHASE 2: Assigner les tâches non assignées
        logger.info("Phase 2: Assigning unassigned tasks");
        if (!unassignedTasks.isEmpty()) {
            // Sort tasks by priority and deadline
            List<Task> sortedTasks = prioritizeTasks(unassignedTasks);
            
            // Allocate each task
            for (Task task : sortedTasks) {
                try {
                    Member bestMember = findBestMember(task, availableMembers);
                    
                    if (bestMember != null) {
                        assignTaskToMember(task, bestMember);
                        
                        // Update member workload
                        bestMember.setCurrentWorkload(
                            bestMember.getCurrentWorkload() + task.getEstimatedHours()
                        );
                        memberDAO.updateWorkload(bestMember.getId(), bestMember.getCurrentWorkload());
                        
                        assignedCount++;
                        logger.info("Assigned task '{}' to member '{}'", task.getTitle(), bestMember.getName());
                        
                        // Check for overload
                        if (bestMember.isOverloaded()) {
                            createOverloadAlert(bestMember, task);
                        }
                    } else {
                        failedCount++;
                        logger.warn("Could not find suitable member for task: {}", task.getTitle());
                        createNoSuitableMemberAlert(task, projectId);
                    }
                } catch (Exception e) {
                    failedCount++;
                    logger.error("Error assigning task: {}", task.getTitle(), e);
                }
            }
        }
        
        String message = String.format("Assigned %d new tasks, rebalanced %d tasks, failed %d", 
            assignedCount, rebalancedCount, failedCount);
        logger.info("Allocation complete: {}", message);
        
        return new AllocationResult(assignedCount + rebalancedCount, failedCount, message);
    }
    
    /**
     * Find a better member for a task than the current one
     * Stratégie en 2 phases :
     * 1. Chercher le meilleur score parmi ceux qui ne seront PAS surchargés (< 100%)
     * 2. Si tous seront surchargés, choisir celui avec la surcharge minimale
     */
    private Member findBetterMember(Task task, List<Member> members, Member currentMember) {
        double currentFinalWorkload = (currentMember.getCurrentWorkload() / currentMember.getWeeklyAvailability()) * 100;
        
        logger.info("Searching for better member than '{}' (current: {}%)", 
            currentMember.getName(), 
            String.format("%.1f", currentMember.getWorkloadPercentage()));
        
        // Calculer les scores et charges finales pour tous les candidats qualifiés
        List<CandidateEvaluation> candidates = new ArrayList<>();
        
        for (Member member : members) {
            // Ne pas reconsidérer le membre actuel
            if (member.getId() == currentMember.getId()) {
                continue;
            }
            
            double score = calculateMemberScore(task, member);
            
            // Si le membre n'a pas les compétences requises (seuil pour rééquilibrage)
            if (score < REBALANCING_COMPETENCE_THRESHOLD) {
                logger.debug("Skipping '{}' - insufficient score ({:.3f} < {:.2f})", 
                    member.getName(), score, REBALANCING_COMPETENCE_THRESHOLD);
                continue;
            }
            
            // Calculer la charge finale après affectation
            double newWorkload = member.getCurrentWorkload() + task.getEstimatedHours();
            double finalWorkloadPct = (newWorkload / member.getWeeklyAvailability()) * 100;
            
            candidates.add(new CandidateEvaluation(member, score, finalWorkloadPct));
            
            logger.info("  Candidate '{}': score={:.3f}, current={}%, would be={}%", 
                member.getName(), score,
                String.format("%.1f", member.getWorkloadPercentage()),
                String.format("%.1f", finalWorkloadPct));
        }
        
        if (candidates.isEmpty()) {
            logger.info("No qualified candidates found");
            return null;
        }
        
        // PHASE 1 : Chercher le meilleur score parmi ceux qui ne seront PAS surchargés (< 100%)
        Member bestWithoutOverload = candidates.stream()
            .filter(c -> c.finalWorkloadPct < 100.0)
            .sorted((c1, c2) -> Double.compare(c2.score, c1.score)) // Trier par score décroissant
            .map(c -> c.member)
            .findFirst()
            .orElse(null);
        
        if (bestWithoutOverload != null) {
            CandidateEvaluation selected = candidates.stream()
                .filter(c -> c.member.getId() == bestWithoutOverload.getId())
                .findFirst()
                .get();
            
            logger.info("PHASE 1 SUCCESS: Selected '{}' (score={:.3f}, final={}%) - NO overload!", 
                selected.member.getName(), selected.score, String.format("%.1f", selected.finalWorkloadPct));
            
            // Vérifier que c'est mieux que le membre actuel
            if (selected.finalWorkloadPct < currentFinalWorkload) {
                return bestWithoutOverload;
            }
        }
        
        // PHASE 2 : Tous seront surchargés, choisir celui avec la SURCHARGE MINIMALE
        logger.info("PHASE 2: All candidates will be overloaded, selecting minimum overload");
        
        CandidateEvaluation bestMinimalOverload = candidates.stream()
            .min((c1, c2) -> Double.compare(c1.finalWorkloadPct, c2.finalWorkloadPct))
            .orElse(null);
        
        if (bestMinimalOverload != null && bestMinimalOverload.finalWorkloadPct < currentFinalWorkload) {
            logger.info("PHASE 2 SUCCESS: Selected '{}' (score={:.3f}, final={}%) - minimal overload", 
                bestMinimalOverload.member.getName(), 
                bestMinimalOverload.score, 
                String.format("%.1f", bestMinimalOverload.finalWorkloadPct));
            return bestMinimalOverload.member;
        }
        
        logger.info("No better member found (current {}% is already optimal)", 
            String.format("%.1f", currentFinalWorkload));
        return null;
    }
    
    /**
     * Classe interne pour évaluer les candidats
     */
    private static class CandidateEvaluation {
        Member member;
        double score;
        double finalWorkloadPct;
        
        CandidateEvaluation(Member member, double score, double finalWorkloadPct) {
            this.member = member;
            this.score = score;
            this.finalWorkloadPct = finalWorkloadPct;
        }
    }

    /**
     * Find the best member for a task using scoring algorithm
     * Pour l'affectation initiale, on exige un seuil de compétence plus élevé
     */
    private Member findBestMember(Task task, List<Member> members) {
        Member bestMember = null;
        double bestScore = -1;
        
        for (Member member : members) {
            double score = calculateMemberScore(task, member);
            
            // Pour l'affectation initiale, on est plus strict sur les compétences
            if (score >= MINIMUM_COMPETENCE_THRESHOLD && score > bestScore) {
                bestScore = score;
                bestMember = member;
            }
        }
        
        if (bestMember != null) {
            logger.info("Selected member '{}' with score {:.3f} (threshold: {:.2f})", 
                bestMember.getName(), bestScore, MINIMUM_COMPETENCE_THRESHOLD);
        } else {
            logger.warn("No member found with sufficient competence (threshold: {:.2f})", 
                MINIMUM_COMPETENCE_THRESHOLD);
        }
        
        return bestMember;
    }

    /**
     * Calculate a score for how suitable a member is for a task
     * Score components:
     * - Skill match (50%) - doit avoir les compétences requises
     * - Workload après affectation (40%) - minimiser la surcharge finale
     * - Priority bonus (10%)
     */
    private double calculateMemberScore(Task task, Member member) {
        double skillScore = calculateSkillScore(task, member);
        double priorityBonus = task.getPriorityScore() * 0.025; // 0-0.1
        
        // If member doesn't have required skills, return 0
        if (skillScore == 0) {
            return 0;
        }
        
        // Calculer la charge APRÈS affectation de la tâche
        double newWorkload = member.getCurrentWorkload() + task.getEstimatedHours();
        double newWorkloadPercentage = (newWorkload / member.getWeeklyAvailability()) * 100;
        
        // Score basé sur la surcharge finale (favorise la charge la plus faible)
        // Plus la surcharge finale est faible, meilleur est le score
        double workloadScore;
        if (newWorkloadPercentage <= 100) {
            // Pas de surcharge : excellent score (0.8 à 1.0)
            workloadScore = 1.0 - (newWorkloadPercentage / 100.0 * 0.2);
        } else {
            // Surcharge : score diminue avec l'augmentation de la surcharge
            // 100% = 0.8, 150% = 0.4, 200% = 0.0
            double overload = newWorkloadPercentage - 100;
            workloadScore = Math.max(0, 0.8 - (overload / 100.0 * 0.8));
        }
        
        // Weighted combination - privilégier les compétences et la minimisation de surcharge
        double totalScore = (skillScore * 0.5) + 
                           (workloadScore * 0.4) + 
                           priorityBonus;
        
        logger.debug("Member {} score for task {}: {:.3f} (skill={:.2f}, newWorkload={:.1f}%, workloadScore={:.2f})",
                    member.getName(), task.getTitle(), totalScore, skillScore, newWorkloadPercentage, workloadScore);
        
        return totalScore;
    }

    /**
     * Calculate skill matching score (0-1)
     */
    private double calculateSkillScore(Task task, Member member) {
        List<TaskSkill> requiredSkills = task.getRequiredSkills();
        
        if (requiredSkills.isEmpty()) {
            return 0.5; // Neutral score if no skills required
        }
        
        int matchedSkills = 0;
        int totalSkillLevel = 0;
        int maxSkillLevel = 0;
        
        for (TaskSkill taskSkill : requiredSkills) {
            maxSkillLevel += taskSkill.getRequiredLevel();
            
            // Check if member has this skill
            Optional<MemberSkill> memberSkill = member.getSkills().stream()
                .filter(ms -> ms.getSkillId() == taskSkill.getSkillId())
                .findFirst();
            
            if (memberSkill.isPresent()) {
                int proficiency = memberSkill.get().getProficiencyLevel();
                if (proficiency >= taskSkill.getRequiredLevel()) {
                    matchedSkills++;
                    totalSkillLevel += proficiency;
                } else {
                    // Has skill but not sufficient level
                    return 0;
                }
            } else {
                // Missing required skill
                return 0;
            }
        }
        
        if (requiredSkills.size() == matchedSkills) {
            // All skills matched, score based on proficiency level
            return Math.min(1.0, (double) totalSkillLevel / maxSkillLevel);
        }
        
        return 0;
    }

    /**
     * Calculate availability score (0-1)
     */
    private double calculateAvailabilityScore(Task task, Member member) {
        double availableHours = member.getAvailableHours();
        double requiredHours = task.getEstimatedHours();
        
        if (availableHours < requiredHours) {
            return 0; // Not enough availability
        }
        
        // Score higher for members with just enough time (better balance)
        // but don't penalize too much for having more availability
        double ratio = requiredHours / availableHours;
        
        if (ratio >= 0.5) {
            return 1.0; // Optimal use of time
        } else {
            return 0.5 + ratio; // Still good but not optimal
        }
    }

    /**
     * Calculate workload balance score (0-1)
     * Higher score for less loaded members
     */
    private double calculateWorkloadScore(Member member) {
        double workloadPercentage = member.getWorkloadPercentage();
        
        if (workloadPercentage >= 100) {
            return 0; // Already at or over capacity
        }
        
        // Linear decrease from 1.0 (0% loaded) to 0.1 (100% loaded)
        return 1.0 - (workloadPercentage / 100.0 * 0.9);
    }

    /**
     * Sort tasks by priority and deadline
     */
    private List<Task> prioritizeTasks(List<Task> tasks) {
        return tasks.stream()
            .sorted((t1, t2) -> {
                // First by priority
                int priorityCompare = Integer.compare(t2.getPriorityScore(), t1.getPriorityScore());
                if (priorityCompare != 0) {
                    return priorityCompare;
                }
                
                // Then by deadline
                if (t1.getDeadline() != null && t2.getDeadline() != null) {
                    return t1.getDeadline().compareTo(t2.getDeadline());
                }
                
                return 0;
            })
            .collect(Collectors.toList());
    }

    /**
     * Assign a task to a member
     */
    private void assignTaskToMember(Task task, Member member) throws SQLException {
        taskDAO.assignTask(task.getId(), member.getId());
        task.setAssignedMemberId(member.getId());
        task.setAssignedMemberName(member.getName());
    }

    /**
     * Create alert for member overload
     */
    private void createOverloadAlert(Member member, Task task) throws SQLException {
        Alert alert = new Alert();
        alert.setType(Alert.AlertType.OVERLOAD);
        alert.setSeverity(Alert.Severity.HIGH);
        alert.setTitle("Member Overload Detected");
        alert.setMessage(String.format(
            "Member '%s' is now overloaded with %.1f hours (%.1f%% capacity) after assigning task '%s'",
            member.getName(), member.getCurrentWorkload(), 
            member.getWorkloadPercentage(), task.getTitle()
        ));
        alert.setMemberId(member.getId());
        alert.setTaskId(task.getId());
        
        alertDAO.create(alert);
    }

    /**
     * Create alert when no suitable member found
     */
    private void createNoSuitableMemberAlert(Task task, int projectId) throws SQLException {
        Alert alert = new Alert();
        alert.setType(Alert.AlertType.CONFLICT);
        alert.setSeverity(Alert.Severity.CRITICAL);
        alert.setTitle("No Suitable Member Found");
        alert.setMessage(String.format(
            "Could not find a suitable member for task '%s'. " +
            "Required skills may not be available or all members are at capacity.",
            task.getTitle()
        ));
        alert.setProjectId(projectId);
        alert.setTaskId(task.getId());
        
        alertDAO.create(alert);
    }

    /**
     * Result object for allocation operation
     */
    public static class AllocationResult {
        private final int assignedCount;
        private final int failedCount;
        private final String message;

        public AllocationResult(int assignedCount, int failedCount, String message) {
            this.assignedCount = assignedCount;
            this.failedCount = failedCount;
            this.message = message;
        }

        public int getAssignedCount() {
            return assignedCount;
        }

        public int getFailedCount() {
            return failedCount;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSuccess() {
            return failedCount == 0;
        }
    }
}

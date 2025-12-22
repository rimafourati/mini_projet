# 🔄 Rééquilibrage Automatique des Tâches

## 🎯 Nouvelle fonctionnalité implémentée

L'algorithme d'allocation automatique a été amélioré pour **réassigner intelligemment les tâches TODO** des membres surchargés vers de nouveaux employés moins chargés.

---

## 💡 Philosophie

### ✅ Principe logique
**"Si une tâche n'a pas encore commencé (TODO), elle peut être donnée à quelqu'un d'autre."**

C'est plus logique car :
- ✅ La tâche n'est pas en cours → Pas de perte de temps
- ✅ Le membre n'a pas encore investi de travail → Pas de frustration
- ✅ Redistribuer équilibre la charge → Meilleure productivité
- ✅ Les nouveaux employés reçoivent du travail immédiatement

### ❌ Ce qui N'est PAS réassigné
- ⛔ Tâches **IN_PROGRESS** (en cours) - Le membre a déjà commencé
- ⛔ Tâches **COMPLETED** (terminées) - Déjà fait
- ⛔ Tâches **BLOCKED** (bloquées) - Problèmes à résoudre d'abord

---

## 🔧 Comment ça fonctionne

### Algorithme en 2 phases

#### **Phase 1 : Rééquilibrage**
```java
Pour chaque tâche TODO assignée :
  1. Le membre actuel est-il surchargé (> 100%) ?
  2. Existe-t-il un membre avec :
     - Les mêmes compétences requises
     - Une charge de travail INFÉRIEURE
     - Un score d'adéquation MEILLEUR
  3. Si OUI → Réassigner la tâche
  4. Mettre à jour les charges de travail
```

#### **Phase 2 : Allocation classique**
```java
Pour chaque tâche non assignée :
  1. Trouver le meilleur membre disponible
  2. Assigner la tâche
  3. Mettre à jour la charge de travail
```

### Critères de réassignation

Une tâche TODO est réassignée SI :
1. ✅ Membre actuel surchargé à **> 100%**
2. ✅ Nouveau membre a une charge **< 150%** (limite de sécurité)
3. ✅ Nouveau membre a un **meilleur score d'adéquation**
4. ✅ Nouveau membre a une charge **INFÉRIEURE** au membre actuel

---

## 📊 Exemple concret

### Situation initiale

```
Carol Williams : 103h/40h = 257,5% ⚠️ SURCHARGÉE
- Tâche 5 : Implement homepage (35h, TODO) ← Pas encore commencée
- Tâche 8 : Integration tests (28h, IN_PROGRESS) ← Déjà en cours
- Autres tâches...

Bob Smith : 38h/40h = 95% ✅
David Brown : 58h/40h = 145% ⚠️
Emma Davis : 50h/25h = 125% ⚠️
Alice Johnson : 27h/40h = 67,5% ✅
```

### Ajout d'un nouvel employé

```sql
INSERT INTO members (name, email, weekly_availability, current_workload) 
VALUES ('Marie Dupont', 'marie.dupont@company.com', 40, 0);

-- Ajouter ses compétences (similaires à Carol)
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(6, 4, 5),   -- Testing niveau 5
(6, 10, 4),  -- Documentation niveau 4
(6, 2, 3);   -- Frontend niveau 3
```

```
Marie Dupont : 0h/40h = 0% ✅ DISPONIBLE
Skills: Testing 5, Documentation 4, Frontend 3 (comme Carol)
```

### Après auto-allocation (via interface)

**1. Cliquer sur "Auto-Allocate" dans le projet**

**Logs du serveur :**
```
[INFO] Starting task allocation for project: 1
[INFO] Phase 1: Rebalancing TODO tasks from overloaded members
[INFO] Rebalancing task 'Implement homepage' from 'Carol Williams' (257.5%) to 'Marie Dupont' (0%)
[INFO] Rebalancing task 'Technical documentation' from 'Emma Davis' (125%) to 'Marie Dupont' (87.5%)
[INFO] Phase 2: Assigning unassigned tasks
[INFO] Allocation complete: Assigned 0 new tasks, rebalanced 2 tasks, failed 0
```

**Résultat :**
```
Carol Williams : 68h/40h = 170% ⚠️ (amélioré de 257,5%)
- Tâche 8 : Integration tests (28h, IN_PROGRESS) ← Gardée car EN COURS
- Autres tâches déjà commencées...

Marie Dupont : 67h/40h = 167,5% 
- Tâche 5 : Implement homepage (35h, TODO) ← Réassignée depuis Carol
- Tâche 10 : Technical documentation (32h, TODO) ← Réassignée depuis Emma

Emma Davis : 18h/25h = 72% ✅ (amélioré de 125%)
Bob Smith : 38h/40h = 95% ✅
David Brown : 58h/40h = 145% ⚠️
Alice Johnson : 27h/40h = 67,5% ✅
```

---

## 🎮 Test pratique

### Étape 1 : Vérifier la situation actuelle

```sql
-- Voir la charge de chaque membre
SELECT 
    name, 
    current_workload, 
    weekly_availability,
    ROUND((current_workload/weekly_availability)*100, 1) as workload_pct
FROM members
ORDER BY workload_pct DESC;
```

### Étape 2 : Ajouter un nouvel employé

```sql
-- Ajouter Marie Dupont
INSERT INTO members (name, email, weekly_availability, current_workload) 
VALUES ('Marie Dupont', 'marie.dupont@company.com', 40, 0);

-- Récupérer son ID
SELECT id FROM members WHERE name='Marie Dupont';
-- Supposons que l'ID est 6

-- Ajouter ses compétences (similaires à Carol)
INSERT INTO member_skills (member_id, skill_id, proficiency_level) VALUES
(6, 4, 5),   -- Testing
(6, 10, 4),  -- Documentation
(6, 2, 3);   -- Frontend Development
```

### Étape 3 : Lancer le rééquilibrage

**Via l'interface web :**
1. Ouvrir http://localhost:8080
2. Aller dans **Projects**
3. Cliquer sur **"Auto-Allocate"** du projet E-commerce
4. Confirmer l'action

**Résultat attendu :**
- Notification : "Assigned 0 new tasks, rebalanced X tasks"
- Tâches TODO réassignées depuis les membres surchargés
- Charge de Carol réduite

### Étape 4 : Vérifier le résultat

```sql
-- Voir la nouvelle répartition
SELECT 
    m.name,
    t.title,
    t.status,
    t.estimated_hours,
    ROUND((m.current_workload/m.weekly_availability)*100, 1) as workload_pct
FROM tasks t
JOIN members m ON t.assigned_member_id = m.id
WHERE t.project_id = 1
ORDER BY m.name, t.status;
```

---

## 📈 Avantages

### ✅ Pour les membres surchargés
- ✔️ Réduction immédiate de la charge
- ✔️ Meilleure qualité de travail
- ✔️ Moins de stress
- ✔️ Respect des délais

### ✅ Pour les nouveaux employés
- ✔️ Travail dès leur arrivée
- ✔️ Intégration rapide
- ✔️ Utilisation de leurs compétences

### ✅ Pour le projet
- ✔️ Meilleure distribution des tâches
- ✔️ Moins de goulots d'étranglement
- ✔️ Progression plus rapide
- ✔️ Moins d'alertes de surcharge

---

## ⚙️ Paramètres de l'algorithme

### Limites de sécurité

```java
// Phase 1 : Rééquilibrage
if (currentMember.getWorkloadPercentage() > 100) {  // Seuil de surcharge
    // Chercher quelqu'un de mieux
    if (newMember.getWorkloadPercentage() < 150) {  // Limite max
        // Réassigner si meilleur score ET moins chargé
    }
}
```

**Pourquoi 150% comme limite ?**
- Évite de surcharger complètement le nouveau membre
- Permet une certaine flexibilité pour les urgences
- Maintient un équilibre global

### Critères de score

Le score d'adéquation prend en compte (0-1) :
1. **Compétences (40%)** : Niveau vs requis
2. **Disponibilité (30%)** : Heures libres
3. **Charge de travail (20%)** : % d'utilisation
4. **Priorité de la tâche (10%)** : URGENT > HIGH > MEDIUM > LOW

---

## 🔍 Logs détaillés

### Format des logs

```
[INFO] Starting task allocation for project: 1
[INFO] Phase 1: Rebalancing TODO tasks from overloaded members

[INFO] Rebalancing task 'NOM_TACHE' from 'MEMBRE_ACTUEL' (XXX%) to 'NOUVEAU_MEMBRE' (YYY%)
      ↑ Nom de la tâche  ↑ Membre surchargé    ↑ Charge actuelle  ↑ Nouveau membre  ↑ Nouvelle charge

[INFO] Phase 2: Assigning unassigned tasks
[INFO] Assigned task 'TACHE' to member 'MEMBRE'

[INFO] Allocation complete: Assigned X new tasks, rebalanced Y tasks, failed Z
```

### Exemple réel

```
[INFO] Starting task allocation for project: 1
[INFO] Phase 1: Rebalancing TODO tasks from overloaded members
[INFO] Rebalancing task 'Implement homepage' from 'Carol Williams' (257.5%) to 'Marie Dupont' (0.0%)
[INFO] Rebalancing task 'Technical documentation' from 'Emma Davis' (125.0%) to 'Marie Dupont' (87.5%)
[INFO] Phase 2: Assigning unassigned tasks
[INFO] No unassigned tasks found
[INFO] Allocation complete: Assigned 0 new tasks, rebalanced 2 tasks, failed 0
```

---

## 🚫 Limitations actuelles

### Ce qui NE se fait PAS automatiquement

1. ❌ **Réassignation des tâches IN_PROGRESS**
   - Risque : Perte du travail déjà fait
   - Solution : Laisser le membre terminer

2. ❌ **Division d'une tâche**
   - Exemple : Tâche de 50h non divisible
   - Solution : Le chef de projet doit diviser manuellement

3. ❌ **Rééquilibrage des dépendances**
   - Si tâche A dépend de tâche B
   - Les deux restent chez le même membre

4. ❌ **Considération des préférences personnelles**
   - Algorithme basé uniquement sur compétences et charge
   - Pas de prise en compte des affinités

---

## 🛠️ Personnalisation

### Modifier le seuil de surcharge

Dans `TaskAllocationService.java`, ligne 51 :

```java
// Actuellement : réassigne si > 100%
if (currentMember.getWorkloadPercentage() > 100) {

// Pour être plus strict (> 80%)
if (currentMember.getWorkloadPercentage() > 80) {

// Pour être moins strict (> 120%)
if (currentMember.getWorkloadPercentage() > 120) {
```

### Modifier la limite maximale

Ligne 54 :

```java
// Actuellement : max 150%
if (betterMember.getWorkloadPercentage() >= 150) {
    continue;
}

// Pour une limite plus basse (120%)
if (betterMember.getWorkloadPercentage() >= 120) {
    continue;
}
```

---

## 📊 Statistiques de rééquilibrage

Après chaque allocation, vérifiez :

```sql
-- Voir la distribution de charge
SELECT 
    CASE 
        WHEN (current_workload/weekly_availability)*100 < 80 THEN 'Sous-utilisé (<80%)'
        WHEN (current_workload/weekly_availability)*100 BETWEEN 80 AND 100 THEN 'Optimal (80-100%)'
        WHEN (current_workload/weekly_availability)*100 BETWEEN 100 AND 150 THEN 'Surchargé (100-150%)'
        ELSE 'Critique (>150%)'
    END as categorie,
    COUNT(*) as nb_membres
FROM members
GROUP BY categorie;
```

**Résultat idéal :**
```
Optimal (80-100%)    : 3 membres
Sous-utilisé (<80%)  : 2 membres
Surchargé (100-150%) : 0 membres
Critique (>150%)     : 0 membres
```

---

## ✅ Conclusion

Cette nouvelle fonctionnalité rend l'allocation automatique **intelligente et adaptative** :

- 🎯 **Réactive** : S'adapte à l'ajout de nouveaux membres
- ⚖️ **Équilibrée** : Redistribue la charge automatiquement
- 🧠 **Intelligente** : Ne touche pas aux tâches en cours
- 📊 **Transparente** : Logs détaillés de chaque action

**Testez maintenant avec l'interface web !** 🚀

http://localhost:8080

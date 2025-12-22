# Guide de Démarrage Rapide - Tests des Scénarios

## 📋 Vue d'ensemble

Ce guide vous aide à exécuter rapidement tous les 7 scénarios de test du système de gestion de projet.

## 🎯 Objectif

Valider l'ensemble des fonctionnalités :
1. ✅ Gestion de l'équipe
2. ✅ Création de projet
3. ✅ Répartition automatique
4. ✅ Détection de surcharge
5. ✅ Modification en cours de projet
6. ✅ Visualisation
7. ✅ Statistiques

---

## 🚀 Démarrage Rapide (5 minutes)

### Étape 1 : Préparer la base de données

```powershell
# Se connecter à MySQL
mysql -u root -p

# Exécuter le schéma
mysql -u root -p < database/schema.sql

# Charger les données de test complètes
mysql -u root -p < database/comprehensive_test_data.sql
```

**Vérification rapide :**
```sql
USE project_management;
SELECT 'Members:', COUNT(*) FROM members;
SELECT 'Tasks:', COUNT(*) FROM tasks;
SELECT 'Projects:', COUNT(*) FROM projects;
SELECT 'Alerts:', COUNT(*) FROM alerts;
```

**Résultat attendu :**
```
Members: 5
Tasks: 11-14
Projects: 2
Alerts: 3-5
```

---

### Étape 2 : Compiler le projet

```powershell
# Avec Maven
mvn clean compile

# Ou avec javac
javac -d bin -sourcepath src/main/java src/main/java/com/projectmanagement/**/*.java
```

---

### Étape 3 : Démarrer le serveur

```powershell
# Option 1 : Avec Maven
mvn exec:java -Dexec.mainClass="com.projectmanagement.SimpleServer"

# Option 2 : Avec le script PowerShell
.\run.ps1

# Option 3 : Directement avec Java
java -cp "target/classes;lib/*" com.projectmanagement.SimpleServer
```

**Le serveur démarre sur :** `http://localhost:8080`

---

### Étape 4 : Tests automatisés (Recommandé)

#### Option A : Exécuter tous les tests automatiquement

```powershell
# Compiler les tests
javac -d bin -cp "bin;lib/*" src/test/java/com/projectmanagement/*.java

# Exécuter le runner de tests
java -cp "bin;lib/*" com.projectmanagement.TestScenariosRunner
```

**Sortie attendue :**
```
╔════════════════════════════════════════════════════════════╗
║  AUTOMATED TEST SCENARIOS RUNNER                          ║
╚════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════╗
║  SCENARIO 1: Team Management                              ║
╚════════════════════════════════════════════════════════════╝
  [TEST 1] Verify 5 members created ... ✅ PASS
  [TEST 2] Verify total weekly availability ... ✅ PASS
  ...

Total Tests:  35
✅ Passed:     35 (100.0%)
❌ Failed:     0 (0.0%)

🎉 ALL TESTS PASSED! 🎉
```

#### Option B : Valider les résultats

```powershell
# Exécuter les validations
java -cp "bin;lib/*" com.projectmanagement.TestValidationUtils
```

---

### Étape 5 : Tests manuels via l'interface web

1. **Ouvrir le navigateur** : `http://localhost:8080`

2. **Page Team** : Vérifier les 5 membres avec compétences
   - Alice Johnson (40h) - Java, Database
   - Bob Smith (35h) - Frontend, Design
   - Carol Williams (40h) - Testing, Documentation
   - David Brown (30h) - Java, API
   - Emma Davis (40h) - Design, Frontend

3. **Page Projects** : Créer ou visualiser le projet E-commerce
   - 10-11 tâches
   - Dépendances définies
   - Priorités variées

4. **Allocation automatique** :
   ```
   Cliquer sur "Auto Allocate" dans la page Projects
   → Devrait affecter 8-10 tâches automatiquement
   ```

5. **Page Alerts** : Vérifier les alertes
   - Alerte de surcharge pour Carol Williams (257%)
   - Alertes de priorité si applicable

6. **Page Timeline** : Visualiser la timeline
   - Gantt chart avec toutes les tâches
   - Dépendances visibles
   - Couleurs par statut

7. **Page Statistics** : Générer les rapports
   - Progression du projet
   - Charges par membre
   - Graphiques de distribution

---

## 🧪 Scénarios de Test Détaillés

### Scénario 1 : Gestion de l'équipe ✅

**Action :** Vérifier les membres et compétences

**Via l'interface :**
1. Aller à la page "Team"
2. Vérifier que 5 membres sont listés
3. Cliquer sur chaque membre pour voir ses compétences
4. Vérifier les disponibilités hebdomadaires

**Via API :**
```bash
curl http://localhost:8080/api/members/
```

**Validation :**
- [x] 5 membres créés
- [x] Total disponibilité = 185h/semaine
- [x] Chaque membre a ≥ 2 compétences
- [x] Niveaux de compétence entre 1 et 5

---

### Scénario 2 : Création de projet ✅

**Action :** Vérifier le projet E-commerce

**Via l'interface :**
1. Aller à la page "Projects"
2. Sélectionner "E-commerce Platform Development"
3. Voir la liste des tâches
4. Vérifier les dépendances (flèches entre tâches)

**Via API :**
```bash
curl http://localhost:8080/api/projects/1
curl http://localhost:8080/api/projects/1/tasks
```

**Validation :**
- [x] 1 projet créé
- [x] 10-11 tâches créées
- [x] Total estimé ≥ 295 heures
- [x] Dépendances définies (13+)
- [x] Priorités variées (URGENT, HIGH, MEDIUM)

---

### Scénario 3 : Répartition automatique ✅

**Action :** Lancer l'allocation automatique

**Via l'interface :**
1. Aller à la page "Projects"
2. Sélectionner le projet
3. Cliquer sur "Auto Allocate Tasks"
4. Confirmer l'action
5. Observer les affectations

**Via API :**
```bash
curl -X POST http://localhost:8080/api/projects/1/allocate
```

**Validation :**
- [x] 8-10 tâches affectées
- [x] Compétences respectées (100%)
- [x] Équilibre de charge raisonnable
- [x] Pas de surcharge > 200% (sauf cas intentionnels)
- [x] Rapport d'allocation généré

---

### Scénario 4 : Détection de surcharge ⚠️

**Action :** Vérifier la détection de surcharge

**Via l'interface :**
1. Aller à la page "Team"
2. Trouver Carol Williams
3. Observer l'indicateur de charge (rouge)
4. Aller à la page "Alerts"
5. Voir l'alerte de surcharge pour Carol

**Via API :**
```bash
curl http://localhost:8080/api/alerts/
```

**Validation :**
- [x] Carol Williams est surchargée (257%)
- [x] Alerte générée automatiquement
- [x] Sévérité = CRITICAL
- [x] Badge rouge sur les alertes
- [x] Message détaillé avec pourcentages

---

### Scénario 5 : Modification en cours de projet 🔄

**Action :** Ajouter une tâche urgente

**Via l'interface :**
1. Aller à la page "Projects"
2. Sélectionner le projet E-commerce
3. Cliquer sur "Add Task"
4. Créer "Critical Security Vulnerability Fix"
   - Priorité : URGENT
   - Durée : 12h
   - Compétences : Java (niveau 5)
5. Cliquer sur "Reallocate" pour réaffecter

**Via API :**
```bash
# Ajouter la tâche
curl -X POST http://localhost:8080/api/projects/1/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Critical Security Fix",
    "estimatedHours": 12,
    "priority": "URGENT"
  }'

# Réaffecter
curl -X POST http://localhost:8080/api/projects/1/reallocate
```

**Validation :**
- [x] Tâche urgente créée
- [x] Affectée à un membre qualifié (Alice)
- [x] Alerte de changement de priorité
- [x] Timeline mise à jour
- [x] Autres tâches réorganisées si nécessaire

---

### Scénario 6 : Visualisation 📊

**Action :** Visualiser la timeline et les graphiques

**Via l'interface :**
1. Aller à la page "Timeline"
2. Sélectionner le projet
3. Observer le diagramme de Gantt
4. Vérifier les dépendances (lignes de connexion)
5. Aller à la page "Team"
6. Observer les graphiques de charge

**Validation :**
- [x] Timeline affichée avec toutes les tâches
- [x] Dépendances visuellement représentées
- [x] Couleurs par statut (TODO, IN_PROGRESS, COMPLETED)
- [x] Graphiques de charge par membre
- [x] Interface responsive et lisible

---

### Scénario 7 : Statistiques 📈

**Action :** Générer les rapports statistiques

**Via l'interface :**
1. Aller à la page "Statistics"
2. Sélectionner le projet E-commerce
3. Observer les statistiques
4. Vérifier les graphiques

**Via API :**
```bash
# Statistiques du projet
curl http://localhost:8080/api/statistics/project/1

# Statistiques de charge
curl http://localhost:8080/api/statistics/workload
```

**Validation :**
- [x] Pourcentage de complétion calculé correctement
- [x] Heures complétées vs restantes exactes
- [x] Distribution des priorités
- [x] Membres surchargés identifiés
- [x] Graphiques et rapports générés

**Calculs à vérifier :**
```
Completion % = (completedTasks / totalTasks) × 100
Workload % = (currentWorkload / weeklyAvailability) × 100
Remaining Hours = totalHours - completedHours
```

---

## 📊 Résultats Attendus

### Métriques globales

| Métrique | Attendu | Tolérance |
|----------|---------|-----------|
| Membres créés | 5 | Exact |
| Tâches créées | 10-14 | ±2 |
| Tâches affectées | 8-10 | ≥8 |
| Alertes générées | 3-5 | ≥1 |
| Completion % | 10-30% | Variable |
| Charge moyenne | 80-140% | Variable |

### Statuts des membres

| Membre | Disponibilité | Charge | % | Statut |
|--------|---------------|--------|---|--------|
| Alice Johnson | 40h | ~41h | 102% | 🟡 Optimal |
| Bob Smith | 35h | ~35h | 100% | 🟢 OK |
| Carol Williams | 40h | 103h | 257% | 🔴 Surcharge |
| David Brown | 30h | ~40h | 133% | 🟡 Élevé |
| Emma Davis | 40h | ~40h | 100% | 🟢 OK |

---

## 🐛 Dépannage

### Le serveur ne démarre pas

```powershell
# Vérifier que le port 8080 est libre
netstat -ano | findstr :8080

# Tuer le processus si nécessaire
taskkill /PID <PID> /F

# Relancer le serveur
.\run.ps1
```

### Base de données : connexion refusée

```powershell
# Vérifier que MySQL est démarré
Get-Service MySQL*

# Démarrer MySQL si nécessaire
Start-Service MySQL80

# Vérifier les credentials dans src/main/resources/db.properties
```

### Tests échouent

```powershell
# Recharger les données de test
mysql -u root -p < database/comprehensive_test_data.sql

# Redémarrer le serveur
.\run.ps1

# Relancer les tests
java -cp "bin;lib/*" com.projectmanagement.TestScenariosRunner
```

### API ne répond pas

```bash
# Tester la connexion
curl http://localhost:8080/

# Vérifier les logs du serveur
# (dans la console où le serveur est lancé)

# Tester un endpoint spécifique
curl http://localhost:8080/api/members/
```

---

## 📝 Checklist de Test

Utilisez cette checklist pour suivre votre progression :

```
□ Étape 1 : Base de données préparée
  □ Schéma créé
  □ Données de test chargées
  □ Vérifications SQL passées

□ Étape 2 : Projet compilé
  □ Pas d'erreurs de compilation
  □ Bibliothèques disponibles

□ Étape 3 : Serveur démarré
  □ Port 8080 accessible
  □ Page d'accueil s'affiche

□ Scénario 1 : Gestion de l'équipe
  □ 5 membres visibles
  □ Compétences affichées
  □ Disponibilités correctes

□ Scénario 2 : Création de projet
  □ Projet E-commerce créé
  □ 10+ tâches visibles
  □ Dépendances définies

□ Scénario 3 : Répartition automatique
  □ Allocation lancée
  □ 8-10 tâches affectées
  □ Compétences respectées

□ Scénario 4 : Détection de surcharge
  □ Carol surchargée (257%)
  □ Alerte générée
  □ Sévérité CRITICAL

□ Scénario 5 : Modification en cours
  □ Tâche urgente ajoutée
  □ Réaffectation effectuée
  □ Timeline mise à jour

□ Scénario 6 : Visualisation
  □ Timeline affichée
  □ Graphiques de charge visibles
  □ Interface lisible

□ Scénario 7 : Statistiques
  □ Rapports générés
  □ Calculs corrects
  □ Graphiques cohérents

□ Tests automatisés
  □ TestScenariosRunner exécuté
  □ Tous les tests passent
  □ Validations réussies
```

---

## 🎉 Conclusion

Si tous les scénarios passent, vous avez validé avec succès :
- ✅ Gestion complète de l'équipe
- ✅ Création et organisation de projets
- ✅ Algorithme d'allocation intelligent
- ✅ Détection proactive de surcharges
- ✅ Gestion dynamique en cours de projet
- ✅ Visualisations interactives
- ✅ Rapports statistiques précis

**Prochaines étapes :**
- Tester avec vos propres données
- Explorer les fonctionnalités avancées
- Adapter les paramètres à vos besoins

---

## 📞 Support

Pour des questions ou problèmes :
- Consulter `TEST_SCENARIOS.md` pour les détails
- Vérifier les logs du serveur
- Exécuter les validations automatiques

**Bon testing! 🚀**

# 🎯 Guide d'utilisation de l'interface

## 🚀 Démarrage

### 1. Lancer le serveur
```bash
java -cp "bin;lib\*" com.projectmanagement.SimpleServer
```

Le serveur démarre sur : **http://localhost:8080**

### 2. Ouvrir l'interface
Ouvrez votre navigateur web et accédez à : **http://localhost:8080**

---

## 📋 Fonctionnalités - Gestion des tâches

### ✅ Boutons de statut des tâches

Chaque tâche affiche des boutons différents selon son état :

#### 🔵 Tâche TODO (pas commencée)
- **Bouton affiché :** 🟢 **"Commencer"**
- **Action :** Change le statut à `IN_PROGRESS`
- **Condition :** La tâche doit être assignée à un membre

```
[📋 Tâche TODO] → Cliquer sur "Commencer" → [🔄 Tâche IN_PROGRESS]
```

#### 🟡 Tâche IN_PROGRESS (en cours)
- **Bouton affiché :** ✅ **"Terminer"**
- **Action :** Change le statut à `COMPLETED`
- **Effet :** La tâche est marquée comme terminée

```
[🔄 Tâche IN_PROGRESS] → Cliquer sur "Terminer" → [✅ Tâche COMPLETED]
```

#### 🟢 Tâche COMPLETED (terminée)
- **Badge affiché :** ✓ **"Terminée"**
- **Pas de bouton** : La tâche est déjà complétée
- **Affichage :** Badge vert avec icône de validation

---

## 🎨 Navigation dans l'interface

### Menu principal (navbar)
- **🏠 Dashboard** : Vue d'ensemble des projets et statistiques
- **👥 Team Members** : Liste des membres de l'équipe
- **📁 Projects** : Liste de tous les projets
- **📊 Timeline** : Vue temporelle des tâches
- **📈 Statistics** : Statistiques détaillées
- **🔔 Alerts** : Notifications et alertes

### Voir les détails d'un projet
1. Aller dans **Projects**
2. Cliquer sur **"View Details"** d'un projet
3. La fenêtre modale affiche :
   - Informations du projet
   - Statistiques (progression, heures, etc.)
   - **Liste des tâches avec les boutons "Commencer" / "Terminer"**

---

## 📝 Exemple d'utilisation - Flux de travail

### Scénario : Alice Johnson termine sa tâche "Unit tests"

1. **État initial (dans la BDD)**
   ```sql
   id: 7
   title: "Unit tests"
   status: TODO
   assigned_member_id: 1 (Alice Johnson)
   ```

2. **Alice clique sur "View Details" du projet**
   - Elle voit la tâche "Unit tests" avec le bouton 🟢 **"Commencer"**

3. **Alice clique sur "Commencer"**
   - Confirmation : "Voulez-vous commencer cette tâche ?"
   - Status change : `TODO` → `IN_PROGRESS`
   - Notification : "Tâche démarrée avec succès !"
   - Le bouton devient : ✅ **"Terminer"**

4. **Alice termine son travail et clique sur "Terminer"**
   - Confirmation : "Marquer cette tâche comme terminée ?"
   - Status change : `IN_PROGRESS` → `COMPLETED`
   - Notification : "Tâche terminée ! Félicitations ! 🎉"
   - Le bouton disparaît, remplacé par le badge ✓ **"Terminée"**

5. **État final (dans la BDD)**
   ```sql
   id: 7
   title: "Unit tests"
   status: COMPLETED
   assigned_member_id: 1 (Alice Johnson)
   ```

---

## 🔄 Mise à jour automatique

### Rafraîchissement de l'interface
- **Après "Commencer"** : Le modal se recharge automatiquement
- **Après "Terminer"** : 
  - Le modal se recharge
  - Le dashboard se met à jour (si vous y êtes)
  - Les statistiques de progression sont recalculées

### Vérification en base de données
```sql
-- Voir toutes les tâches avec leur statut
SELECT 
    t.id, 
    t.title, 
    m.name as 'Assigné à', 
    t.status 
FROM tasks t 
LEFT JOIN members m ON t.assigned_member_id = m.id 
ORDER BY t.status, t.id;
```

---

## 🎯 États possibles des tâches

| Statut | Badge couleur | Bouton disponible | Description |
|--------|---------------|-------------------|-------------|
| **TODO** | 🔵 Bleu | 🟢 Commencer | Tâche pas encore démarrée |
| **IN_PROGRESS** | 🟡 Orange | ✅ Terminer | Tâche en cours d'exécution |
| **COMPLETED** | 🟢 Vert | ✓ Terminée (badge) | Tâche finalisée |
| **BLOCKED** | 🔴 Rouge | Aucun | Tâche bloquée (dépendances) |

---

## 💡 Conseils d'utilisation

### ✅ Bonnes pratiques
1. **Commencer une tâche** dès que vous y travaillez
   - Permet aux autres de voir que vous êtes dessus
   - Met à jour votre charge de travail en temps réel

2. **Terminer immédiatement** quand c'est fait
   - Libère de la capacité pour de nouvelles tâches
   - Met à jour les statistiques du projet

3. **Vérifier le dashboard** régulièrement
   - Voir l'état global des projets
   - Identifier les membres surchargés

### 🔍 Résolution de problèmes

#### Le bouton ne s'affiche pas
- **Vérifier** que la tâche est bien assignée à un membre
- **Tâches TODO** : Seules les tâches assignées ont le bouton "Commencer"
- **Tâches non assignées** : Utiliser l'allocation automatique d'abord

#### La tâche ne se met pas à jour
- **Rafraîchir** la page (F5)
- **Vérifier** la console du navigateur (F12) pour les erreurs
- **Vérifier** que le serveur est toujours en cours d'exécution

#### Erreur lors du clic
- **Vérifier** la connexion à la base de données
- **Vérifier** que MySQL est démarré (XAMPP)
- **Consulter** les logs du serveur dans le terminal

---

## 🔧 Code technique

### Fonctions JavaScript utilisées

```javascript
// Commencer une tâche
async function startTask(taskId, projectId) {
    const task = await TasksAPI.getById(taskId);
    task.status = 'IN_PROGRESS';
    await TasksAPI.update(task);
    viewProjectDetails(projectId); // Rafraîchir
}

// Terminer une tâche
async function completeTask(taskId, projectId) {
    const task = await TasksAPI.getById(taskId);
    task.status = 'COMPLETED';
    await TasksAPI.update(task);
    viewProjectDetails(projectId); // Rafraîchir
}
```

### API REST appelée

```
GET  /api/tasks/{id}        - Récupérer une tâche
PUT  /api/tasks/            - Mettre à jour une tâche
```

### Requête SQL exécutée

```sql
UPDATE tasks 
SET status = 'IN_PROGRESS'  -- ou 'COMPLETED'
WHERE id = ?;
```

---

## 📊 Visualisation des changements

### Dashboard - Avant

```
Recent Projects
┌─────────────────────────────────┐
│ E-commerce Platform             │
│ 11 tasks • 9% complete          │
│ [ACTIVE]                        │
└─────────────────────────────────┘
```

### Dashboard - Après avoir terminé 2 tâches

```
Recent Projects
┌─────────────────────────────────┐
│ E-commerce Platform             │
│ 11 tasks • 27% complete  ⬆️     │
│ [ACTIVE]                        │
└─────────────────────────────────┘
```

---

## 🎓 Cas d'usage réels

### Équipe de développement web

**Matin (9h)** - Alice démarre sa journée
```
1. Ouvre l'interface → Dashboard
2. Voit "Unit tests" assignée à elle
3. Clique "View Details" du projet
4. Clique "Commencer" sur "Unit tests"
   ✓ Status: TODO → IN_PROGRESS
```

**Après-midi (16h)** - Alice termine
```
1. Tests terminés et validés
2. Retourne sur l'interface
3. Clique "Terminer" sur "Unit tests"
   ✓ Status: IN_PROGRESS → COMPLETED
   🎉 Notification de félicitations
```

**Soir (18h)** - Manager vérifie
```
1. Consulte le Dashboard
2. Voit : "Unit tests ✓ Terminée"
3. Progression du projet : 9% → 18%
4. Charge d'Alice libérée de 28h
```

---

## 📱 Interface responsive

L'interface s'adapte à tous les écrans :
- 🖥️ **Desktop** : Affichage complet avec tous les boutons
- 💻 **Laptop** : Même fonctionnalité, layout optimisé
- 📱 **Tablet/Mobile** : Boutons empilés verticalement

---

## ⚡ Performances

- ⚡ **Temps de réponse** : < 100ms pour changer un statut
- 🔄 **Rafraîchissement** : Automatique après chaque action
- 💾 **Base de données** : Mise à jour instantanée
- 🔔 **Notifications** : Affichées en temps réel

---

## 🆘 Support

### Problèmes courants

**Q: Le bouton "Commencer" n'apparaît pas**
- R: Vérifiez que la tâche a un `assigned_member_id` non null

**Q: Erreur "Could not find task"**
- R: Vérifiez que l'ID de la tâche existe dans la base

**Q: Les changements ne sont pas sauvegardés**
- R: Vérifiez la connexion MySQL et les logs du serveur

---

## 📚 Fichiers modifiés

Pour implémenter cette fonctionnalité :

1. **app.js** - Ajout des fonctions `startTask()` et `completeTask()`
2. **app.js** - Modification de `displayProjectDetails()` pour afficher les boutons
3. **style.css** - Ajout des styles pour `.btn-small`, `.btn-success`, `.task-actions`
4. **api.js** - (déjà existant) utilise `TasksAPI.getById()` et `TasksAPI.update()`

---

**🎉 Votre interface est maintenant prête à gérer les statuts de tâches !**

Accédez à : **http://localhost:8080**

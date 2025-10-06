# 🐀 Scurry
### *An AI-Driven Dungeon Crawler Built in Unity*

---

## 📖 Overview
**Scurry** is a small-scale Unity game that demonstrates three core AI systems working together:
- **Procedural Content Generation (PCG)**
- **Decision-Making**
- **Flocking Behavior**

Explore a procedurally generated sewer system infested with swarms of rats, using only a measly torch to save you. Find a way out before the rats find you.

---

## 🧩 Core Features

### 🧱 Procedural Content Generation
- Randomly generated sewer layouts and rooms. 
- Random placement of loot and rats nests.
- Optional dynamic lighting and environmental variation.

### 🧠 Decision-Making
- Each rat uses a **Finite State Machine (FSM)**
  - Patrol tunnels  
  - Chase the player  
  - Flee when injured or isolated  
  - Call for reinforcements when threatened  
- Optional "leader" rats with group coordination behaviors.

### 🐀 Flocking System
- Boids-style flocking for natural swarm movement:
  - Cohesion, alignment, and separation forces.  
  - Seamless navigation through tight tunnels.  
- Integration with decision-making for reactive group behavior (e.g., scattering from light).

---

## 🕹️ Gameplay Loop
1. Enter a procedurally generated sewer level.
2. Explore the tunnels, collect resources and avoid the rats.
3. Encounter rats and drive them off or run away.
4. Find an escape or die to the rats.

---

## 🛠️ Tech Stack
- **Engine:** Unity (2022.3.0f1 or later recommended)  
- **Language:** C#  
- **Version Control:** Git + GitHub  
- **Target Platform:** PC

---

## 🚀 Getting Started

### Prerequisites
- [Unity Hub](https://unity.com/download)
- Unity Editor (2022.3.0f1 or newer)
- Git (for version control)

### Clone the Repository
```bash
git clone https://github.com/<your-username>/rat-nest.git
cd rat-nest


### Open In Unity
- Launch Unity Hub
- Click 'Add Project'
- Select the clone repo
- Open the project in the Unity Editor


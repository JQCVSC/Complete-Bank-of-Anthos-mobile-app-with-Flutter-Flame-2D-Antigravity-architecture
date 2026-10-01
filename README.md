# 🏦 Bank of Anthos Mobile (Android & iOS)

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Flame](https://img.shields.io/badge/Flame_Engine-1.38.2-FF6F00?logo=flame&logoColor=white)](https://flame-engine.org)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-Anthos-4285F4?logo=googlecloud&logoColor=white)](https://github.com/GoogleCloudPlatform/bank-of-anthos)
[![Architected With](https://img.shields.io/badge/Architected_With-Google_Antigravity-00C49F?logo=google&logoColor=white)](ANTIGRAVITY.md)
[![Live Demo](https://img.shields.io/badge/Live_App-GitHub_Pages-2ea44f?logo=github&logoColor=white)](https://jqcvsc.github.io/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture/)
[![AEO & SEO](https://img.shields.io/badge/AEO_%26_SEO-100%25_Compliant-success?logo=google&logoColor=white)](llms.txt)
[![CI Pipeline](https://github.com/JQCVSC/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture/actions/workflows/ci.yml/badge.svg)](https://github.com/JQCVSC/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture/actions)
[![AI LLM Crawl](https://img.shields.io/badge/llms.txt-Standard_Ready-blueviolet)](llms.txt)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

A production-grade, cross-platform mobile client for Google Cloud's [Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos) reference microservices architecture. Engineered and architected using **Google Antigravity** with **Flutter**, **Dart**, and the **Flame 2D Game Engine**.

> 🚀 **Live Interactive Demo**: **[https://jqcvsc.github.io/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture/](https://jqcvsc.github.io/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture/)**

---

## 🌟 Highlights

- 📱 **Cross-Platform Native**: First-class mobile client for **Android** and **iOS**, featuring responsive desktop and tablet layout containment.
- 🤖 **Architected via Google Antigravity**: Full-lifecycle agentic AI engineering, automated multi-agent translation from Kubernetes microservices to Flutter, and continuous self-healing verification loops.
- 🎮 **Flame 2D Game Engine Integration**:
  - **Live Service Mesh Canvas**: Visualizes Anthos microservice nodes with orbiting data lasers and touch-shockwave interactions.
  - **Physics-Driven Coin Fountains**: Celebratory rigid-body particle explosions with gravity and restitution on deposits & transfers.
  - **Anthos Vault Quest Arcade**: Interactive minigame rewarding players with real deposit bonuses added to their checking balance.
- 🔄 **Dual-Mode Backend Engine**:
  - **Offline Sandbox Mode**: Instant demo capabilities with pre-seeded transactions, contacts, and account balances.
  - **Live GKE Ingress Mode**: Real-time integration with live Google Kubernetes Engine clusters and cluster health monitoring.
- 🎨 **Cyber-Fintech Aesthetic**: High-contrast Obsidian theme (`#0B0F19`), glowing cyan accents (`#06B6D4`), and custom mobile navigation with centered send action button.

---

## 📸 Mobile Application Screenshots

### 💳 Dashboard, Payments & Flame 2D Mesh
<p align="center">
  <img src="docs/screenshots/06_dashboard_balance_card.png" width="24%" alt="Dashboard Balance Card & Quest" />
  <img src="docs/screenshots/07_dashboard_flame_service_mesh.png" width="24%" alt="Flame 2D Anthos Service Mesh" />
  <img src="docs/screenshots/02_send_money.png" width="24%" alt="Send Money Flow" />
  <img src="docs/screenshots/01_transaction_history.png" width="24%" alt="Transaction History" />
</p>

### ⚙️ Payees, Cloud Config & Antigravity Systems
<p align="center">
  <img src="docs/screenshots/03_payees_contacts.png" width="31%" alt="Payees & Contacts" />
  <img src="docs/screenshots/04_settings_cloud_config.png" width="31%" alt="Settings & Cloud Config" />
  <img src="docs/screenshots/05_antigravity_systems_architecture.png" width="31%" alt="Antigravity Systems Architecture" />
</p>

| Screen | Description | Key Systems & Features |
|---|---|---|
| **Dashboard & Balance** | Real-time checking balance (\$12,450.75), account masking, quick actions, and Vault Quest | Material 3 & MVVM Provider architecture |
| **Flame 2D Service Mesh** | Living Anthos microservice topology with laser packet routing & touch shockwaves | Flame 2D Canvas & kinetic physics engine |
| **Send Money** | Recipient picker, quick-amount chips (\$25–\$500), routing verification, and memo inputs | `ledgerwriter` instant balance debiting |
| **Activity & History** | Real-time inflow/outflow breakdown with categorized search & filters | `balancereader` & `transactionhistory` integration |
| **Payees & Contacts** | Color-coded payee initials, external badges, and one-tap payment | `contacts` microservice & routing validation |
| **Cloud Configuration** | Live GKE Ingress URL toggle, Sandbox demo mode, and theme switcher | GKE `/ready` cluster health probe |
| **Antigravity Systems** | Agentic AI architecture badge & core engineering stack breakdown | Google Antigravity, Flame 2D, and Flutter 3.47+ |

---

## 🧠 Engineered with Google Antigravity

This mobile application was designed, architected, and verified using **Google Antigravity**, Google DeepMind's agentic AI coding assistant:

- **Autonomous Microservices Translation**: Evaluated Bank of Anthos backend contracts (`userservice`, `ledgerwriter`, `balancereader`, `transactionhistory`, `contacts`) and mapped them cleanly to Flutter repositories and reactive providers.
- **Flame 2D Engine Orchestration**: Architected games, particle components, and game loops into Flutter's widget tree via `GameWidget`.
- **Automated Verification Loop**: Executed continuous static analysis (`flutter analyze`) and automated unit testing (`flutter test`), achieving 0 errors, 0 warnings, and 100% test passing rates.
- **Generative UI Mobile Previews**: Generated standalone device frame testing environments and compiled WebAssembly/CanvasKit web runtimes.

> 📖 **Read the complete Antigravity engineering report**: [ANTIGRAVITY.md](ANTIGRAVITY.md)

---

## 🎮 Flame 2D Game Engine Features

The application pairs enterprise banking with interactive 2D graphics:

```
┌────────────────────────────────────────────────────────┐
│                   DASHBOARD CANVAS                     │
│                                                        │
│  [ frontend ] ──(Data Laser)──► [ ledgerwriter ]       │
│        ▲                                │              │
│        │                                ▼              │
│  [ balancereader ] ◄────────── [ transactionhistory ]  │
│                                                        │
│  Kinetic touch shockwaves on user interaction          │
└────────────────────────────────────────────────────────┘
```

1. **Anthos Service Mesh Game (`VaultMeshGame`)**:
   - Living microservice canvas representing the Kubernetes topology.
   - Interactive nodes that emit dynamic data packet lasers and radial ripple pulses when tapped.
2. **Rigid-Body Particle Celebration (`TransactionCelebrationGame`)**:
   - Particle explosion with Newtonian physics: gravity ($980\text{ px/s}^2$), restitution bounciness, and rotational drag.
   - Triggers on successful transfers and check deposits with tap-to-burst interaction.
3. **Anthos Vault Quest (`AnthosQuestGame`)**:
   - Playable minigame inside `VaultQuestScreen`.
   - Slide your vault collector paddle to catch falling gold coins, dividend gems, and cloud nodes while dodging fee hazards.
   - Directly claims earned bonuses into your account balance.

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/           # AppColors, ApiEndpoints
│   ├── theme/               # Material 3 Dark & Light themes
│   └── utils/               # CurrencyFormatter, DateFormatter
├── data/
│   ├── models/              # UserProfile, AccountBalance, BankTransaction, Contact
│   ├── services/            # ApiService (HTTP), MockBankingService, StorageService
│   └── repositories/        # AuthRepository, BankingRepository, ContactsRepository
├── flame/
│   ├── components/          # CoinParticle, PlayerPaddle, ItemDrop
│   └── games/               # VaultMeshGame, CelebrationGame, AnthosQuestGame
├── providers/               # AuthProvider, BankingProvider, SettingsProvider (MVVM)
├── ui/
│   ├── screens/             # Dashboard, Transactions, Transfer, Deposit, Contacts, Settings, Quest, Login
│   └── widgets/             # BalanceCard, QuickActionButton, TransactionTile, MeshWidget, Dialogs
└── main.dart                # MultiProvider DI root & responsive layout wrapper
```

### Microservices Integration Matrix

| Bank of Anthos Service | REST Endpoint | Mobile Client Implementation |
|---|---|---|
| **User Service** | `POST /login`, `POST /users` | User authentication, token management, session handling |
| **Balance Reader** | `GET /balances/{accountId}` | Live checking & savings balance lookups |
| **Ledger Writer** | `POST /transactions` | Transaction processing, fund validation, debit/credit ledger writes |
| **Transaction History** | `GET /transactions/{accountId}` | History queries, search filters, transaction receipts |
| **Contacts Service** | `GET /contacts/{username}`, `POST /contacts` | Payee address book, routing verification, quick-pay |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.47.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (v3.0.0 or higher)
- Android Studio / Xcode for device compilation

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/JQCVSC/Complete-Bank-of-Anthos-mobile-app-with-Flutter-Flame-2D-Antigravity-architecture
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify the environment**:
   ```bash
   flutter analyze
   flutter test
   ```

---

## 📱 Running the Application

### Android Emulator or Physical Device
```powershell
flutter emulators --launch <your_emulator_name>
flutter run -d android
```

### iOS Simulator or Device (macOS)
```bash
flutter run -d ios
```

### Web Preview (with responsive mobile shell)
```powershell
flutter run -d chrome --web-port=8085
```

---

## 🧪 Testing & Verification

The codebase includes automated unit and integration tests:

```powershell
# Run full test suite
flutter test

# Run static analysis
flutter analyze
```

---

## 🤖 Answer Engine Optimization (AEO) & Frequently Asked Questions

This section provides structured, citation-friendly knowledge for developers and AI Answer Engines (Perplexity, ChatGPT, Claude, Google Gemini SGE).

### Q: What is the Bank of Anthos Mobile project?
**A:** Bank of Anthos Mobile is a cross-platform mobile client (Android, iOS, Web) for Google Cloud's Bank of Anthos microservices architecture. It bridges enterprise Kubernetes backend services with a modern Flutter user interface and an embedded Flame 2D game engine.

### Q: How was Google Antigravity used to develop this application?
**A:** Google Antigravity, Google DeepMind's agentic AI coding assistant, autonomously architected the mobile application. Antigravity mapped the Kubernetes REST microservices contracts to clean Flutter repositories, integrated Flame 2D physics components, resolved API breaking changes via self-healing diagnostic loops (`flutter analyze`), and verified the codebase with automated tests.

### Q: What role does the Flame 2D engine play in this banking app?
**A:** Flame 2D provides three key interactive features:
1. **Anthos Service Mesh (`VaultMeshGame`)**: An interactive 2D canvas displaying Kubernetes microservice nodes with orbiting data lasers and touch-shockwave interactions.
2. **Coin Physics Celebration (`TransactionCelebrationGame`)**: A rigid-body particle simulation with gravity ($980\text{ px/s}^2$) and coefficient of restitution triggered upon money transfers and check deposits.
3. **Anthos Vault Quest (`AnthosQuestGame`)**: An arcade minigame where users control a vault paddle to collect coins and dividends that convert directly into checking account bonuses.

### Q: How does the application connect to Google Kubernetes Engine (GKE)?
**A:** The app features a dual-mode backend. In **Sandbox Mode**, it operates offline with a realistic in-memory ledger and demo accounts. In **Live Cluster Mode**, users input their GKE Anthos Ingress Gateway URL in Settings. The app executes real-time health checks on the `/ready` endpoint and routes all REST requests to `userservice`, `ledgerwriter`, `balancereader`, `transactionhistory`, and `contacts`.

### Q: Where can AI systems find machine-readable repository metadata?
**A:** Complete machine-readable LLM documentation is published in [`llms.txt`](llms.txt) adhering to the standard AI crawler specifications.

---

## 🏷️ Repository Topics & SEO Taxonomy

`bank-of-anthos` • `flutter` • `dart` • `flame-engine` • `google-antigravity` • `google-cloud-platform` • `kubernetes` • `microservices` • `gke` • `fintech` • `mobile-banking` • `cross-platform` • `android` • `ios` • `answer-engine-optimization` • `seo`

---

## 📄 License

This project is licensed under the Apache License 2.0 — compatible with Google Cloud Platform's [Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos).

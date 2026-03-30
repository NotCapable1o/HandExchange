
# 🤝 Hand Exchange — *Buy, Sell, Save*

### **Empowering Campus Commerce at Begum Rokeya University, Rangpur** 🎓🇧🇩

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38.1-02569B?logo=flutter&logoColor=white" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/State--Management-GetX-800080?logo=getx&logoColor=white" alt="GetX">
  <img src="https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/License-MIT-orange" alt="MIT License">
</p>

---

> 🎯 **Hand Exchange** is a peer-to-peer campus marketplace built to empower students to buy, sell, exchange, and donate goods **safely within their university community**.  
> Perfect for textbooks, electronics, dorm essentials, and more.

---

## 📲 App Assets & Previews

> 📝 **NOTE:** Replace the APK link and screenshots with your actual assets.

* **Download Android APK:** [📥 APK Link](REPLACE_WITH_YOUR_APK_LINK_HERE)

### 📱 UI Screenshots — 2-Grid Layout

<p align="center">
  <img src="REPLACE_WITH_SCREENSHOT_1_URL" width="45%" />
  <img src="REPLACE_WITH_SCREENSHOT_2_URL" width="45%" />
</p>
<p align="center">
  <img src="REPLACE_WITH_SCREENSHOT_3_URL" width="45%" />
  <img src="REPLACE_WITH_SCREENSHOT_4_URL" width="45%" />
</p>
<p align="center">
  <img src="REPLACE_WITH_SCREENSHOT_5_URL" width="45%" />
  <img src="REPLACE_WITH_SCREENSHOT_6_URL" width="45%" />
</p>
<p align="center">
  <img src="REPLACE_WITH_SCREENSHOT_7_URL" width="45%" />
  <img src="REPLACE_WITH_SCREENSHOT_8_URL" width="45%" />
</p>

---

## ✨ Key Features & Functionality

> 🌟 **Highlighting What Makes Hand Exchange Unique**

- **🔐 Secure Authentication** – Supabase Auth + custom SMTP for reliable email verification.  
- **📦 Smart Marketplace** – Products with category tags, prices, images, and geolocation.  
- **📍 Localized Discovery** – Find items only within campus radius for trust and safety.  
- **💬 Real-time Chat** – WebSocket-based messaging with typing indicators & read receipts.  
- **💳 Integrated Payments** – Supports AamarPay, bKash, Nagad, and local banking cards.  
- **🔔 Smart Notifications** – Instant push alerts for messages and product updates via FCM.  
- **🌓 Adaptive UI** – Light & Dark mode support powered by GetX.  
- **📊 Analytics Ready** – Future AI recommendation engine & activity metrics.  
- **🛡️ Security First** – PostgreSQL Row Level Security (RLS) for full data privacy.

---

## 🛠️ Technical Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter `3.38.1` (FVM Managed) |
| **Backend** | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| **State Management** | GetX (Reactive) |
| **Local Storage** | GetStorage |
| **Notifications** | Firebase Cloud Messaging |
| **Maps & Location** | Flutter Map + Geolocator |
| **Networking** | Dio + Http |

> 💡 **Tip:** Using FVM ensures your Flutter version is locked across all contributors.

---

## 🚀 Installation & Setup (Step-by-Step)

### 1️⃣ Environment Setup

```powershell
# Verify FVM & Dart
fvm --version    # Expected: 4.0.1
dart --version   # Expected: 3.10.0+
````

### 2️⃣ Clone & Prepare Project

```powershell
git clone https://github.com/CodderPrince/HandExchange.git
cd hand_exchange
fvm install
fvm flutter pub get
```

### 3️⃣ Android Studio Setup

1. File > Settings > Languages & Frameworks > Flutter
2. Set Flutter SDK path:
   `C:\A Flutter Project\SWE\hand_exchange\.fvm\flutter_sdk`
3. Enable Dart plugin and point to the same `.fvm` folder.
4. Confirm Project SDK matches `.fvm` Flutter SDK.

### 4️⃣ Run the App

```powershell
fvm flutter run
```

> ✅ Or press **F5** in Android Studio with your emulator/device connected.

---

## 🏛️ Project Architecture — MVC + Service Layer

* **`lib/models`** – Data structures (Products, Users, Chats)
* **`lib/views`** – UI screens & reusable widgets
* **`lib/controllers`** – Business logic with GetxController
* **`lib/services`** – Supabase, Firebase, Payment Gateway services
* **`lib/utils`** – Constants, themes, helper functions

### 🏗️ Design Patterns

* **Observer Pattern:** Reactive UI updates on database changes
* **Singleton Pattern:** Shared core services (NotificationService)
* **Facade Pattern:** Simplified Payment Gateway integration

---

## 👥 Meet the Developers (Group-3)

| Name                     | ID       | Role                  |
| :----------------------- | :------- | :-------------------- |
| **Md. An Nahian Prince** | 12105007 | Lead Developer        |
| **Shithi Rani Roy**      | 12105009 | UI/UX & Documentation |
| **Ramjan Hossain Noor**  | 12005034 | Backend Integration   |

**Supervised By:**
**Md. Hasan Tarek**, Lecturer, Dept. of CSE, BRUR.

---

## 🛡️ Database & Security

* **Row Level Security (RLS)** ensures each user can only access their own data.
* Owners can delete/update their products; public listings are readable by all campus users.
* Notifications and chats are private and secure.

---

## 🔮 Future Enhancements

* 🤖 AI Recommendation Engine – Personalized product suggestions
* 🎓 Domain Verification – Only `@student.university.edu.bd` emails
* 🚚 Advanced Logistics – GPS-based dormitory deliveries
* 📊 Admin Dashboard – Track sales, user activity, and metrics
* 🌐 Optional Web App – Full cross-platform marketplace experience

---

## 📜 License

Copyright © 2026 **Hand Exchange Team**
Distributed under the **MIT License**. See `LICENSE` for details.

---

<p align="center">
<b>Built for Students, By Students.</b> ❤️
</p>


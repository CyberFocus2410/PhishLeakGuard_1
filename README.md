# 🔐 PhishLeakGuard

**PhishLeakGuard** is a cybersecurity-focused web application designed to help users  
**identify phishing risks and check whether their email has been exposed in known data breaches**.

The project focuses on **community cyber safety**, awareness, and prevention — helping users
understand threats *before* damage occurs.

---

## 🚀 Live Application

🌐 **Live Demo (Hosted via Dreamflow)**  
https://x566kk6n9vw7zlcq674y.share.dreamflow.app/

> The frontend and backend are fully deployed and working via **Dreamflow**.

---

## 🛡️ What Problems Does PhishLeakGuard Solve?

### 1️⃣ Data Breach Awareness (LeakWatch)
- Checks whether an email address has been compromised in public data breaches
- Uses **Have I Been Pwned** breach intelligence
- No passwords or sensitive user data is stored

### 2️⃣ Phishing Risk Awareness
- Educates users about digital threats
- Helps reduce phishing-related data loss
- Built with a user-friendly, minimal interface

---

## ✨ Key Features

- 🔍 **Email Breach Detection (LeakWatch)**
- ⚠️ **Risk Severity Classification**
- ☁️ **Serverless Backend**
- 🌐 **Web-based UI (No installation required)**
- 🔐 **Secure API handling**
- 📦 **Production-ready deployment via Dreamflow**

---

## 🧠 Tech Stack

### Frontend
- Flutter (Web)
- Responsive UI
- Hosted using **Dreamflow**

### Backend
- Serverless Functions (via Dreamflow)
- Secure API calls handled on the backend

### Security & APIs
- **Have I Been Pwned API** (for breach detection)
- No API keys exposed on the frontend

---

## 🏗️ System Architecture

User (Browser)
↓
Flutter Web UI
↓
Dreamflow Hosting
↓
Serverless Backend Logic
↓
Have I Been Pwned API

yaml
Copy code

---

## 📂 Project Structure

PhishLeakGuard/
│
├── lib/ # Flutter UI source code
├── build/web/ # Production web build
├── functions/ # Backend logic (serverless)
├── assets/ # UI assets
├── README.md # Project documentation

yaml
Copy code

---

## 🔒 Privacy & Security

- ❌ No passwords collected
- ❌ No email data stored permanently
- ✅ Emails are checked securely and discarded after processing
- ✅ API communication handled server-side

---

## 🧪 How LeakWatch Works

1. User enters an email address
2. Request is sent to the backend
3. Backend queries **Have I Been Pwned**
4. Breach data is analyzed
5. Severity level is calculated
6. Results are shown clearly to the user

---

## 🏆 Use Cases

- Cybersecurity awareness tools
- Community digital safety initiatives

---

## 📌 Future Enhancements

- URL phishing detection
- SMS & message phishing analysis
- Browser extension
- User risk dashboard
- Enterprise / SOC mode

---

## 👤 Author

**Vivan Mittal**  
B.Tech CSE (Cyber Security)  
Focused on building community-driven security solutions

---

## 📜 License

This project is open-source and intended for **educational and community use**.

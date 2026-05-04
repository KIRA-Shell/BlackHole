# BlackHole Reconnaissance Framework (v10.0) 🌌

An advanced, automated, and intelligent reconnaissance and vulnerability scanning framework written in Bash. Designed for security researchers and penetration testers, **BlackHole** automates 12 critical phases of the recon workflow, featuring an adaptive scanning engine that adjusts its speed based on target defenses.

## 💡 Key Features
* **Intelligent WAF Detection:** Automatically detects Web Application Firewalls (WAF) and activates **Stealth Mode** to bypass rate-limiting and blocking.
* **Full Spectrum Recon:** Covers everything from DNS identification to visual evidence gathering.
* **Vulnerability Scanning:** Full integration with **Nuclei** for identifying critical and high-severity vulnerabilities.
* **History Mining:** Extracts historical URLs and sensitive JS files from archives (Wayback Machine).
* **Automated Reporting:** Generates a comprehensive final summary of all discovered assets and vulnerabilities.[cite: 1]

## 🛠️ Tool Dependencies
The script leverages the power of industry-standard tools. Ensure the following are installed:
* **Recon:** `subfinder`, `httpx-toolkit`, `theHarvester`, `waybackurls`.[cite: 1]
* **Scanning:** `nmap`, `nuclei`, `wafw00f`.[cite: 1]
* **Fuzzing:** `gobuster`, `arjun`.[cite: 1]
* **Visual:** `gowitness`.[cite: 1]

## 🚀 The Beast Workflow
1.  **Target ID:** IP resolution and Whois data gathering.[cite: 1]
2.  **Subdomain Enum:** Multi-source subdomain discovery.[cite: 1]
3.  **Live Filtering:** Probing for active HTTP/HTTPS services.[cite: 1]
4.  **WAF Check:** Adaptive strategy selection based on firewall presence.[cite: 1]
5.  **Port Scanning:** Intelligent service discovery via Nmap.[cite: 1]
6.  **Directory Fuzzing:** Hidden file and directory discovery.[cite: 1]
7.  **Vuln Scan:** High-velocity vulnerability assessment.[cite: 1]
8.  **OSINT:** Public intelligence gathering.[cite: 1]
9.  **History Mining:** Analyzing historical web data for leaks.[cite: 1]
10. **Parameter Discovery:** Finding hidden entry points.[cite: 1]
11. **Visual Recon:** Automated screenshot gallery generation.[cite: 1]
12. **Final Report:** Consolidating findings into a clean summary.[cite: 1]

## ⚠️ Disclaimer
This tool is for educational and ethical penetration testing purposes only. The developer (**KIRA-Shell**) is not responsible for any misuse or damage caused by this tool. Always obtain prior legal authorization before scanning any target.[cite: 1]

#!/bin/bash

# ==============================================================================
# [1] CONFIGURATION & ASSETS
# ==============================================================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
PURPLE='\033[1;35m'
NC='\033[0m'

# متغيرات التحكم بالسرعة (سيتم تعديلها تلقائياً بناءً على الحماية)
NMAP_SPEED="-T4"
NUCLEI_RATE="50"
GOBUSTER_DELAY="200ms"
WAF_DETECTED=0

# ==============================================================================
# [2] HELPER FUNCTIONS
# ==============================================================================

print_slow() {
    text="$1"
    delay="$2"
    if [ -z "$delay" ]; then delay=0.01; fi
    echo -ne "$text" | while read -n 1 char; do
        echo -ne "$char"
        sleep $delay
    done
    echo ""
}

print_phase() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ ${WHITE}PHASE $1: ${GREEN}$2${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
}

check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}[X] CRITICAL: Tool '$1' is missing! Install it via apt, pip, or go.${NC}"
        EXIT_FLAG=1
    fi
}

get_httpx_cmd() {
    if command -v httpx-toolkit &> /dev/null; then
        echo "httpx-toolkit"
    elif command -v httpx &> /dev/null; then
        if httpx -version 2>&1 | grep -q "projectdiscovery"; then
            echo "httpx"
        else
             echo "httpx-toolkit"
        fi
    else
        echo ""
    fi
}

show_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
          .                                                      .
        .n                   .                 .                  n.
  .   .dP                  dP                   9b                 9b.    .
 4    qXb         .       dX                     Xb       .        dXp     t
dX.    9Xb       .dXb    __                     __    dXb.       dXP     .Xb
9XXb._       _.dXXXXb dXXXXbo.               .odXXXXb dXXXXb._        _.dXXP
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP
  `9XXXXXXXXXXXXXXXXXXXXX'~     ~`OOO8b   d8OOO'~     ~`XXXXXXXXXXXXXXXXXXXXXP'
    `9XXXXXXXXXXXP' `9XX'    DIE     `98v8P'    HUMAN   `XXP' `9XXXXXXXXXXXP'
        ~~~~~~~       9X.            .db|db.           .XP        ~~~~~~~
                        )b.  .dbo.dP'`v'`9b.odb.  .dX(
                      ,dXXXXXXXXXXXb       dXXXXXXXXXXXb.
                     dXXXXXXXXXXXP'  .     `9XXXXXXXXXXXb
                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb
                    9XXb'   `XXXXXb.dX|Xb.dXXXXX'   `dXXP
                     `'      9XXXXXX(   )XXXXXXP       `'
                              XXXX X.`v'.X XXXX
                              XP^X'`b   d'`X^XX
                              X. 9  `   '  P )X
                              `b  `        '  d'
                               `             '
EOF
    echo -e "${NC}"
    echo -e "${RED}"
    echo " ██████╗ ██╗       █████╗  ██████ ╗██╗  ██╗     ██╗  ██╗ ██████╗ ██╗      ███████╗"
    echo " ██╔══██╗██║      ██╔══██╗██╔════ ╝██║ ██╔╝     ██║  ██║██╔═══██╗██║      ██╔════╝"
    echo " ██████╔╝██║      ███████║██║      █████╔╝      ███████║██║   ██║██║      █████╗  "
    echo " ██╔══██╗██║      ██╔══██║██║      ██╔═██╗      ██╔══██║██║   ██║██║      ██╔══╝  "
    echo " ██████╔╝██████ █╗██║  ██║╚██████ ╗██║  ██╗     ██║  ██║╚██████╔╝███████ ╗███████╗"
    echo " ╚═════╝ ╚══════╝╚═╝   ╚═╝ ╚═════╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${WHITE}           G    R    O    U    P        ${RED}S    Y    S    T    E    M    S${NC}"
    echo -e "${BLUE} =======================================================================${NC}"
    echo -e "${WHITE}             Event Horizon Reconnaissance Framework v10.0          ${NC}"
    echo -e "${WHITE}                   Lead Developer: ${RED}SHMALI${NC}"
    echo -e "${WHITE}                   Mode: ${GREEN}Intelligent Adaptive Scan${NC}"
    echo -e "${BLUE} =======================================================================${NC}"
    echo ""
}

# ==============================================================================
# [3] MODULES (وظائف الأدوات)
# ==============================================================================

module_init() {
    echo -ne "${PURPLE}[*] Initializing Singularity Core...${NC}"
    EXIT_FLAG=0
    
    HTTPX_CMD=$(get_httpx_cmd)
    
    TOOLS=("ping" "whois" "subfinder" "curl" "nmap" "nuclei" "httpx-toolkit" "wafw00f" "gobuster" "waybackurls" "arjun" "gowitness")
    
    for tool in "${TOOLS[@]}"; do
        check_tool "$tool"
    done
    
    if [ -z "$HTTPX_CMD" ]; then
        echo -e "${RED}[X] CRITICAL: Tool 'httpx-toolkit' is missing!${NC}"
        EXIT_FLAG=1
    fi

    if [ $EXIT_FLAG -eq 1 ]; then
        echo -e "\n${RED}[!] System Halted. Please install missing tools.${NC}"
        exit 1
    fi
    sleep 0.5
    echo -ne "\r${GREEN}[✔] Core Stable. All Modules Loaded.       \n${NC}"
    echo ""
}

module_target_setup() {
    print_slow "${RED}[root@BlackHole]${WHITE} Enter Target Domain (e.g., target.com): "
    read DOMAIN
    DIR_NAME="BlackHole_${DOMAIN}_$(date +%F)"
    mkdir -p "$DIR_NAME"
    cd "$DIR_NAME" || exit
    echo -e "\n${CYAN}[*] EVENT HORIZON CREATED :: ${WHITE}$DIR_NAME${NC}"
}

module_whois() {
    print_phase "1" "TARGET IDENTIFICATION & REGISTRATION    "
    TARGET_IP=$(ping -c 1 "$DOMAIN" | grep "PING" | awk '{print $3}' | tr -d '()')

    if [ -z "$TARGET_IP" ]; then
        echo -e "${RED}[✖] CRITICAL ERROR: Target is unreachable or down.${NC}"
        exit 1
    else
        echo -e "${GREEN}[+] TARGET ACQUIRED: ${RED}$TARGET_IP${NC}"
        echo "Main IP: $TARGET_IP" > main_ip.txt
        whois "$DOMAIN" > whois_data.txt
        echo -e "${GREEN}[✔] Whois data saved.${NC}"
    fi
}

module_subfinder() {
    print_phase "2" "DEEP SUBDOMAIN ENUMERATION              "
    print_slow "${CYAN}[*] Launching Multi-Source Agents...${NC}"
    
    # 1. Subfinder
    subfinder -d "$DOMAIN" -all -o subfinder_raw.txt > /dev/null 2>&1
    
    # 2. CRT.SH (Extra Source)
    curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > crtsh_raw.txt 2>/dev/null
    
    # دمج النتائج
    cat subfinder_raw.txt crtsh_raw.txt 2>/dev/null > subdomains_raw.txt
    
    # إضافة النطاق الرئيسي
    echo "$DOMAIN" >> subdomains_raw.txt
    echo "www.$DOMAIN" >> subdomains_raw.txt
    
    sort -u subdomains_raw.txt > subdomains.txt
    
    COUNT=$(wc -l < subdomains.txt)
    echo -e "${GREEN}[✔] SUCCESS: ${WHITE}$COUNT unique targets queued.${NC}"
}

module_httpx() {
    print_phase "3" "FILTERING LIVE HOSTS (HTTPX)            "
    
    if [ -s "subdomains.txt" ]; then
        print_slow "${CYAN}[*] Filtering live domains...${NC}"
        
        cat subdomains.txt | $HTTPX_CMD -silent -title -tech-detect -status-code -follow-redirects -random-agent -o live_subdomains_info.txt
        
        cat live_subdomains_info.txt | awk '{print $1}' > live_hosts_url.txt
        cat live_hosts_url.txt | sed 's|http[s]*://||g' | sort -u > live_hosts_clean.txt
        
        touch live_hosts_clean.txt
        
        COUNT=$(wc -l < live_hosts_url.txt)
        echo -e "${GREEN}[✔] Found ${WHITE}$COUNT${GREEN} live HTTP/HTTPS services.${NC}"
    else
        echo -e "${RED}[!] No subdomains to filter.${NC}"
        touch live_hosts_clean.txt
        touch live_hosts_url.txt
    fi
}

module_waf_check() {
    print_phase "4" "INTELLIGENT WAF DETECTION               "
    
    # فحص النطاق الرئيسي فقط لتحديد الاستراتيجية
    if [ -s "live_hosts_clean.txt" ]; then
        MAIN_TARGET=$(head -n 1 live_hosts_url.txt)
        print_slow "${CYAN}[*] analyzing defense systems on $MAIN_TARGET...${NC}"
        wafw00f "$MAIN_TARGET" > waf_result.txt
        
        if grep -q "is behind" waf_result.txt; then
            WAF_NAME=$(grep "is behind" waf_result.txt | awk -F "behind" '{print $2}' | xargs)
            echo -e "${RED}[!] WARNING: WAF DETECTED ($WAF_NAME)!${NC}"
            echo -e "${YELLOW}[*] ACTIVATING STEALTH MODE...${NC}"
            
            # تعديل الاستراتيجية لتفادي الحظر
            NMAP_SPEED="-T2 -Pn" # بطيء جداً
            NUCLEI_RATE="10"     # طلبات قليلة
            GOBUSTER_DELAY="800ms" # تأخير عالي
            WAF_DETECTED=1
        else
            echo -e "${GREEN}[✔] No aggressive WAF detected. Going Full Speed.${NC}"
            NMAP_SPEED="-T4"
            NUCLEI_RATE="50"
            GOBUSTER_DELAY="200ms"
            WAF_DETECTED=0
        fi
    else
        echo -e "${RED}[!] No live hosts to check.${NC}"
    fi
}

module_nmap() {
    print_phase "5" "PORT SCANNING (ADAPTIVE MODE)           "
    
    if [ -s "live_hosts_clean.txt" ]; then
        print_slow "${PURPLE}[*] Resolving IPs & Scanning with $NMAP_SPEED...${NC}"
        
        while read host; do
            host "$host" | grep "has address" | head -n 1 | awk '{print $4}' >> resolved_ips.txt
        done < live_hosts_clean.txt
        sort -u resolved_ips.txt -o resolved_ips.txt
        
        # استخدام إعدادات السرعة المتغيرة
        nmap -iL resolved_ips.txt --top-ports 1000 -sV --version-intensity 3 $NMAP_SPEED --open -n -oN nmap_results.txt
        echo -e "${GREEN}[✔] Nmap scan completed.${NC}"
    else
        echo -e "${RED}[!] No live hosts found for Nmap.${NC}"
    fi
}

module_dirsearch() {
    print_phase "6" "DIRECTORY FUZZING (SMART FILTER)        "
    
    if [ -f "/usr/share/wordlists/dirb/common.txt" ]; then
        WORDLIST="/usr/share/wordlists/dirb/common.txt"
    elif [ -f "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" ]; then
         WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    else
         echo -e "${RED}[!] Wordlist not found! Skipping directory bruteforce.${NC}"
         return
    fi
    
    TARGET_URL="http://$DOMAIN"
    if [ -s "live_hosts_url.txt" ]; then
        TARGET_URL=$(head -n 1 live_hosts_url.txt)
    fi

    print_slow "${PURPLE}[*] Fuzzing $TARGET_URL (Delay: $GOBUSTER_DELAY)...${NC}"
    
    # إضافة --random-agent لتفادي الحظر
    # استثناء 403 لتقليل الضجيج، التركيز على 200,301,401
    gobuster dir -u "$TARGET_URL" -w "$WORDLIST" -t 20 --delay "$GOBUSTER_DELAY" --random-agent -k -b "404" -s "200,204,301,302,307,401" -o dir_scan_main.txt --no-error
    
    if [ ! -s "dir_scan_main.txt" ]; then
            echo "No directories found or blocked." > dir_scan_main.txt
    fi
    echo -e "${GREEN}[✔] Directory scan finished. Filtered repetitive 403s.${NC}"
}

module_nuclei() {
    print_phase "7" "VULNERABILITY SCANNING (NUCLEI)         "
    
    TEMPLATES_DIR="/home/kali/.local/nuclei-templates"
    
    if [ -s "live_hosts_url.txt" ]; then
        if [ ! -d "$TEMPLATES_DIR" ]; then
            echo -e "${RED}[!] Templates not found! Cloning...${NC}"
            git clone https://github.com/projectdiscovery/nuclei-templates.git "$TEMPLATES_DIR"
        fi

        print_slow "${RED}[!!!] LAUNCHING NUCLEAR STRIKE (Rate: $NUCLEI_RATE)...${NC}"
        
        # استخدام Rate Limit المتغير
        nuclei -l live_hosts_url.txt -t "$TEMPLATES_DIR" -s critical,high,medium -rl "$NUCLEI_RATE" -o nuclei_report.txt
        
        if [ ! -s "nuclei_report.txt" ]; then
            echo "No vulnerabilities found." > nuclei_report.txt
        else
             echo -e "${RED}[!] CRITICAL VULNERABILITIES FOUND!${NC}"
        fi
        echo -e "${GREEN}[✔] Nuclei scan finished.${NC}"
    else
        # Fallback to manual target
        echo "http://$DOMAIN" > manual_target.txt
        nuclei -l manual_target.txt -t "$TEMPLATES_DIR" -s critical,high,medium -rl "$NUCLEI_RATE" -o nuclei_report.txt
        echo -e "${YELLOW}[!] Scanned root domain only.${NC}"
    fi
}

module_osint() {
    print_phase "8" "INTELLIGENCE GATHERING (OSINT)          "
    print_slow "${CYAN}[*] Scraping fast public databases...${NC}"
    
    theHarvester -d "$DOMAIN" -b "google,bing,duckduckgo,crtsh" -l 200 -n -f harvester_results > /dev/null 2>&1
    
    if [ -f "harvester_results.json" ] || [ -f "harvester_results.xml" ]; then
        echo -e "${GREEN}[✔] Intelligence gathering complete.${NC}"
    else
        echo -e "${YELLOW}[!] Scan finished.${NC}"
    fi
}

module_wayback() {
    print_phase "9" "HISTORY MINING (WAYBACKURLS)            "
    
    print_slow "${CYAN}[*] Fetching old URLs & JS Files...${NC}"
    echo "$DOMAIN" | waybackurls > archive_urls.txt
    
    if [ -s "archive_urls.txt" ]; then
        COUNT=$(wc -l < archive_urls.txt)
        echo -e "${GREEN}[✔] Found ${WHITE}$COUNT${GREEN} historical URLs.${NC}"
        
        # تحسين: البحث عن ملفات JS بشكل خاص
        grep "\.js" archive_urls.txt > js_files.txt
        grep -E "\.xls|\.xml|\.conf|\.bak|\.sql|\.json" archive_urls.txt > interesting_archive_files.txt
        
        JS_COUNT=$(wc -l < js_files.txt)
        echo -e "${YELLOW}[!] Found $JS_COUNT JS files (Saved in js_files.txt).${NC}"
    else
         echo "No historical data found." > archive_urls.txt
         echo -e "${YELLOW}[!] No historical data found.${NC}"
    fi
}

module_arjun() {
    print_phase "10" "PARAMETER DISCOVERY (ARJUN)           "
    
    if [ -s "live_hosts_url.txt" ]; then
        print_slow "${PURPLE}[*] Finding hidden parameters...${NC}"
        # تقليل عدد Threads لتفادي الانهيار
        arjun -i live_hosts_url.txt -t 2 --delay 2 --stable --disable-redirects -oT arjun_params.txt > /dev/null 2>&1
        
        if [ -s "arjun_params.txt" ]; then
             echo -e "${GREEN}[✔] Parameters found! Saved in 'arjun_params.txt'.${NC}"
        else
             echo "No parameters found or tool blocked." > arjun_params.txt
             echo -e "${YELLOW}[!] No parameters found or tool blocked/crashed.${NC}"
        fi
    else
        echo -e "${RED}[!] No targets for parameter discovery.${NC}"
    fi
}

module_screenshot() {
    print_phase "11" "VISUAL RECON (GOWITNESS)              "
    
    if [ -s "live_hosts_url.txt" ]; then
        print_slow "${CYAN}[*] Taking screenshots of live hosts...${NC}"
        mkdir -p screenshots
        gowitness scan file -f live_hosts_url.txt -P ./screenshots --no-http --timeout 15 --delay 2 > /dev/null 2>&1
        
        echo -e "${GREEN}[✔] Screenshots saved in './screenshots'. Check 'gallery.html'.${NC}"
    fi
}

module_final_summary() {
    print_phase "12" "GENERATING FINAL SUMMARY REPORT       "
    REPORT_FILE="FINAL_REPORT_SUMMARY.txt"
    
    echo "======================================================" > $REPORT_FILE
    echo "             PENETRATION TESTING SUMMARY              " >> $REPORT_FILE
    echo "======================================================" >> $REPORT_FILE
    echo "Target Domain: $DOMAIN" >> $REPORT_FILE
    echo "Date: $(date)" >> $REPORT_FILE
    echo "WAF Detected: $WAF_DETECTED (1=Yes, 0=No)" >> $REPORT_FILE
    echo "------------------------------------------------------" >> $REPORT_FILE
    
    if [ -f "live_hosts_clean.txt" ]; then
        echo "[+] Live Subdomains Found: $(wc -l < live_hosts_clean.txt 2>/dev/null || echo 0)" >> $REPORT_FILE
    else
        echo "[+] Live Subdomains Found: 0" >> $REPORT_FILE
    fi

    echo "[+] Open Ports (Sample):" >> $REPORT_FILE
    grep "open" nmap_results.txt 2>/dev/null | head -n 10 >> $REPORT_FILE
    echo "..." >> $REPORT_FILE
    
    echo "------------------------------------------------------" >> $REPORT_FILE
    echo "[+] Critical/High Vulnerabilities (Nuclei):" >> $REPORT_FILE
    if [ -s nuclei_report.txt ]; then
        grep -E "\[critical\]|\[high\]" nuclei_report.txt >> $REPORT_FILE 2>/dev/null
    else
        echo "No vulnerabilities detected." >> $REPORT_FILE
    fi
    
    echo "------------------------------------------------------" >> $REPORT_FILE
    echo "[+] WAF Status:" >> $REPORT_FILE
    cat waf_result.txt 2>/dev/null >> $REPORT_FILE
    
    echo "------------------------------------------------------" >> $REPORT_FILE
    echo "[+] Interesting JS Files Found:" >> $REPORT_FILE
    head -n 5 js_files.txt 2>/dev/null >> $REPORT_FILE
    
    echo "======================================================" >> $REPORT_FILE
    echo "Full details are available in the specific tool files." >> $REPORT_FILE
    
    echo -e "${GREEN}[✔] Summary generated: $REPORT_FILE ${NC}"
}

module_report() {
    echo -e "\n${RED}====================================================${NC}"
    echo -e "${GREEN}   [✔] MISSION ACCOMPLISHED: BLACK HOLE EXPANDED ${NC}"
    echo -e "${RED}====================================================${NC}"
    echo -e "${WHITE}FULL REPORT SAVED AT: ${YELLOW}$(pwd)${NC}"
    echo -e "${WHITE}FILES GENERATED:${NC}"
    ls -lh | grep -v "^d" | awk '{print " - "$9 " ("$5")"}'
    echo -e "${RED}====================================================${NC}"
}

# ==============================================================================
# [4] MAIN EXECUTION FLOW
# ==============================================================================

show_banner
module_init
module_target_setup

# The Beast Workflow
module_whois       # Phase 1
module_subfinder   # Phase 2
module_httpx       # Phase 3
module_waf_check   # Phase 4 (Now Adaptive)
module_nmap        # Phase 5
module_dirsearch   # Phase 6
module_nuclei      # Phase 7
module_osint       # Phase 8
module_wayback     # Phase 9
module_arjun       # Phase 10
module_screenshot  # Phase 11
module_final_summary # Phase 12
module_report

# 📌 Pinterest → Gemini → WhatsApp Daily Automation

Runs every day at **10:00 AM IST** on your Oracle Cloud VM.  
Collects Pinterest keywords → generates content ideas with Gemini → sends `ideas.docx` to WhatsApp.

---

## 📁 Project Structure

```
pinterest_automation/
├── main.py           # Main automation script
├── setup.sh          # One-time setup (run this first)
├── requirements.txt  # Python dependencies
├── .env.example      # API key template
├── .env              # Your real keys (created by setup.sh, never commit)
├── keywords.txt      # Auto-generated daily keywords
├── ideas.docx        # Auto-generated daily ideas
├── automation.log    # Full run log
└── cron.log          # Cron stdout log
```

---

## 🚀 Quick Start (on Oracle Cloud VM)

### Step 1 — Upload project to your VM

```bash
# From your local machine:
scp -r pinterest_automation/ ubuntu@<YOUR_VM_IP>:~/
```

### Step 2 — SSH into VM and run setup

```bash
ssh ubuntu@<YOUR_VM_IP>
cd ~/pinterest_automation
bash setup.sh
```

### Step 3 — Fill in your API keys

```bash
nano .env
```

| Variable | Where to get it |
|---|---|
| `GEMINI_API_KEY` | [aistudio.google.com](https://aistudio.google.com/app/apikey) |
| `WHATSAPP_TOKEN` | Meta Developer Console → WhatsApp → API Setup |
| `WHATSAPP_PHONE_ID` | Same page as above |
| `WHATSAPP_TO_NUMBER` | Your number: `91XXXXXXXXXX` (no +) |
| `PINTEREST_ACCESS_TOKEN` | [developers.pinterest.com](https://developers.pinterest.com) — Optional |

### Step 4 — Test manually

```bash
source venv/bin/activate
python main.py
```

### Step 5 — Verify cron is scheduled

```bash
crontab -l
# Should show: 30 4 * * * cd ~/pinterest_automation && ...
```

---

## ⏰ Cron Schedule

| Time | Cron expression |
|---|---|
| 10:00 AM IST | `30 4 * * *` (UTC) |
| 10:00 AM IST | IST = UTC+5:30, so 10:00 IST = 04:30 UTC |

To change the time, edit with:
```bash
crontab -e
```

---

## 🔑 WhatsApp Cloud API Setup (Meta)

1. Go to [developers.facebook.com](https://developers.facebook.com)
2. Create an app → Add **WhatsApp** product
3. In **WhatsApp → API Setup**:
   - Copy **Phone Number ID** → `WHATSAPP_PHONE_ID`
   - Generate a **Permanent Token** → `WHATSAPP_TOKEN`
   - Add your test number → `WHATSAPP_TO_NUMBER`
4. For production, verify your business and apply for full access

---

## 📊 Workflow

```
Pinterest keywords (API or curated seeds)
        ↓
   keywords.txt (50–100 keywords)
        ↓
   Gemini 1.5 Flash API (batches of 10)
        ↓
   ideas.docx (titles, topics, descriptions, hashtags)
        ↓
   WhatsApp Cloud API → 📱 Your WhatsApp
```

---

## 📋 Monitoring

```bash
# Live logs
tail -f ~/pinterest_automation/automation.log

# Cron output
tail -f ~/pinterest_automation/cron.log

# Check last run
head -20 ~/pinterest_automation/automation.log
```

---

## 🛠️ Troubleshooting

| Issue | Fix |
|---|---|
| `ModuleNotFoundError` | Run `source venv/bin/activate` first |
| `GEMINI_API_KEY not set` | Check `.env` file exists and has the key |
| WhatsApp send fails | Verify token, phone ID, and recipient is added in Meta console |
| Cron not running | Check `crontab -l` and VM timezone: `timedatectl` |
| Pinterest API 401 | Leave `PINTEREST_ACCESS_TOKEN` blank to use seed keywords |

---

## 🔄 Manual Re-run

```bash
cd ~/pinterest_automation
source venv/bin/activate
python main.py
```

# 🛡️ Sentnel — Guardrails for AI Tool Execution

> **Block dangerous AI actions before they run.**
> Add real-time security to Claude Code in **one command**.

---

## ⚡ Why Sentnel?

AI coding agents are powerful — but they can:

* ❌ run destructive commands (`rm -rf /`)
* ❌ leak secrets (`.env`, `id_rsa`)
* ❌ execute unsafe queries (`DROP TABLE`)
* ❌ make uncontrolled network calls (`curl`)

👉 **Sentnel intercepts every tool call before execution and enforces your policies.**

---

## 🎥 Demo (What actually happens)

```bash
$ rm -rf /
❌ Blocked by Sentnel: dangerous_delete

$ cat .env
❌ Blocked by Sentnel: sensitive_file_access

$ curl google.com
⚠️ Requires approval: network_egress

$ npm install express
✅ Allowed
```

---

## 🚀 1-Minute Install

```bash
curl -sSL https://raw.githubusercontent.com/sentnelops/sentnel/main/setup.sh | bash
```

That’s it.

✔ Works instantly with Claude Code
✔ Protects all your repos automatically
✔ No workflow changes

---

## 🧠 How It Works

Sentnel plugs into Claude’s **PreToolUse hook**:

```text
Claude → Tool Call → Sentnel Hook → Policy Engine → Allow / Ask / Deny
```

* 🔍 Intercepts every tool call (bash, file, MCP, web)
* 🔐 Applies policy rules (YAML-based)
* 📊 Logs everything for audit

---

## 🔒 What It Protects

### 🚫 Dangerous Commands

* `rm -rf`
* `shutdown`
* destructive scripts

### 🔑 Sensitive Files

* `.env`
* `id_rsa`
* `*.pem`

### 🌐 Network Egress

* `curl`, `wget`
* external API calls

---

## ⚙️ Example Policy

```yaml
rules:
  - id: block_delete
    match:
      tool: bash
      pattern: "rm -rf"
    action: deny

  - id: block_secrets
    match:
      tool: read_file
      path: [".env", "id_rsa", ".pem"]
    action: deny

  - id: network_egress
    match:
      tool: bash
      pattern: "curl"
    action: ask
```

---

## 📊 Audit Logging

Every action is logged locally:

```bash
sqlite3 ~/.sentnel/audit.db "SELECT * FROM events;"
```

Example:

```text
[DENY] rm -rf /
[DENY] read .env
[ASK] curl external-url
[ALLOW] npm install
```

---

## 🧪 Try These Attacks

After install, run:

```bash
rm -rf /
cat .env
curl google.com
```

👉 You should see Sentnel blocking or asking in real time.

---

## 🧱 Architecture (MVP)

```text
Claude Code
   ↓
PreToolUse Hook (Sentnel)
   ↓
Policy Engine
   ↓
Decision (allow / ask / deny)
   ↓
Execution (or blocked)
```

---

## 🔐 Security Principles

* ✅ **Fail closed** — if Sentnel fails, execution is blocked
* ✅ **No secrets exposed to AI**
* ✅ **Local-first** — runs entirely on your machine
* ✅ **Policy-as-code** — versionable, auditable

---

## ⚡ Roadmap

* [ ] MCP proxy (team-wide enforcement)
* [ ] VS Code extension
* [ ] Policy management UI
* [ ] Cloud audit dashboard
* [ ] SOC2-ready logging

---

## 💡 Why This Matters

AI agents are becoming your **junior engineers**.

Would you let a junior engineer:

* run `rm -rf` in production?
* access your secrets freely?
* execute unknown scripts?

👉 Sentnel ensures the answer is **no**.

---

## 🤝 Contributing

PRs welcome!
Start by improving:

* rules engine
* detection patterns
* performance

---

## ⭐ If this helps you

Give it a star ⭐ and share with your team.

---

## 🧠 Built for the future of AI development

Sentnel is the first step toward:

> **Secure AI execution environments for developers**

---

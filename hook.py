import json, sys, yaml, time, sqlite3, os

RULES_FILE = os.path.join(os.path.dirname(__file__), "rules.yaml")
DB_FILE = os.path.join(os.path.dirname(__file__), "audit.db")

def load_rules():
    with open(RULES_FILE, "r") as f:
        return yaml.safe_load(f)["rules"]

def log_event(event, decision, reason):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""
    CREATE TABLE IF NOT EXISTS events (
        ts REAL, tool TEXT, decision TEXT, reason TEXT, raw TEXT
    )
    """)
    c.execute("INSERT INTO events VALUES (?, ?, ?, ?, ?)", (
        time.time(),
        event.get("tool_name", ""),
        decision,
        reason,
        json.dumps(event)
    ))
    conn.commit()
    conn.close()

def match_rule(rule, event):
    tool = event.get("tool_name", "")
    tool_input = event.get("tool_input") or {}
    cmd  = (tool_input.get("command") or "").lower()
    path = (tool_input.get("path") or "").lower()

    if "tool" in rule["match"] and rule["match"]["tool"] != tool:
        return False

    # Check for patterns_any (list of strings)
    if "patterns_any" in rule["match"]:
        for p in rule["match"]["patterns_any"]:
            if p.lower() in cmd:
                return True

    # Check for legacy single pattern
    if "pattern" in rule["match"] and rule["match"]["pattern"].lower() in cmd:
        return True

    if "path" in rule["match"]:
        for p in rule["match"]["path"]:
            if p.lower() in path:
                return True

    return False

def evaluate(event):
    rules = load_rules()
    for rule in rules:
        if match_rule(rule, event):
            return rule["action"], rule["id"]
    return "allow", None

def main():
    print("🔥 SENTNEL HOOK TRIGGERED", file=sys.stderr)
    try:
        event = json.load(sys.stdin)
    except:
        print(json.dumps({"decision": "deny", "reason": "invalid_input"}))
        return

    decision, reason = evaluate(event)
    log_event(event, decision, reason)

    print(json.dumps({
        "decision": decision,
        "reason": reason
    }))

if __name__ == "__main__":
    main()
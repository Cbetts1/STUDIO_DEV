#!/system/bin/sh
cat <<'TUT'
════════════════════════════════════════
    HOW TO RUN AN AI HELPER
════════════════════════════════════════

AI Helpers are chatbot scripts you create
and customize. They start rule-based and
can be upgraded to use real AI APIs.

CREATING AN AI HELPER
─────────────────────
1. Home → Create → AI Helper / Bot
2. Give it a name
3. Choose a template (Q&A, checklist, etc.)
4. Studio OS generates a helper script

RUNNING YOUR HELPER
───────────────────
• Go to My Projects → select your helper
• Choose 'Run project'
• Chat with it in the terminal

UPGRADING TO REAL AI
────────────────────
• Open helper.sh in the editor
• Add your API key to config.sh
• Modify the script to call the API:

  curl -s "https://api.example.com/chat" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"message\":\"$INPUT\"}"

SUPPORTED AI APIS
─────────────────
• OpenAI (ChatGPT)
• Anthropic (Claude)
• Any REST API that accepts JSON

════════════════════════════════════════
TUT

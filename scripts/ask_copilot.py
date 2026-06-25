"""
JetOps Fleet Maintenance Copilot — interactive console
Usage: python scripts/ask_copilot.py
"""
from azure.ai.projects import AIProjectClient
from azure.ai.agents.models import AgentThreadCreationOptions, ThreadMessageOptions, MessageRole
from azure.identity import AzureCliCredential

ENDPOINT  = "https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot"
AGENT_NAME = "fleet-maintenance-copilot-agent"

project = AIProjectClient(endpoint=ENDPOINT, credential=AzureCliCredential())
agent   = next(a for a in project.agents.list_agents() if a.name == AGENT_NAME)
print(f"\nConnected to: {AGENT_NAME}")
print("Type your question and press Enter. Type 'exit' to quit.\n")

while True:
    question = input("You: ").strip()
    if question.lower() in ("exit", "quit", "q"):
        break
    if not question:
        continue

    run = project.agents.create_thread_and_process_run(
        agent_id=agent.id,
        thread=AgentThreadCreationOptions(
            messages=[ThreadMessageOptions(role=MessageRole.USER, content=question)]
        ),
    )

    msgs   = list(project.agents.messages.list(thread_id=run.thread_id))
    answer = next((m.content[0].text.value for m in msgs if m.role == "assistant"), "(no response)")
    print(f"\nCopilot: {answer}\n")

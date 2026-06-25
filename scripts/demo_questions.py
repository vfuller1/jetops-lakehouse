"""
JetOps Demo — 3 scripted questions for the Fleet Maintenance Copilot.
Usage: python scripts/demo_questions.py
       python scripts/demo_questions.py 1   # run only question 1
       python scripts/demo_questions.py 2
       python scripts/demo_questions.py 3
"""
import sys
from azure.ai.projects import AIProjectClient
from azure.ai.agents.models import AgentThreadCreationOptions, ThreadMessageOptions, MessageRole
from azure.identity import AzureCliCredential

ENDPOINT   = "https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot"
AGENT_NAME = "fleet-maintenance-copilot-agent"

QUESTIONS = {
    1: "Which aircraft are currently AOG and what are the open issues?",
    2: "Summarize the current fleet status by severity level.",
    3: "What are the top 3 components with the highest failure rate and what maintenance actions are recommended?",
}

def ask(project, agent, question):
    run = project.agents.create_thread_and_process_run(
        agent_id=agent.id,
        thread=AgentThreadCreationOptions(
            messages=[ThreadMessageOptions(role=MessageRole.USER, content=question)]
        ),
    )
    msgs   = list(project.agents.messages.list(thread_id=run.thread_id))
    answer = next((m.content[0].text.value for m in msgs if m.role == "assistant"), "(no response)")
    return answer

def run_question(project, agent, num):
    q = QUESTIONS[num]
    print(f"\n{'='*60}")
    print(f"  QUESTION {num}")
    print(f"{'='*60}")
    print(f"  You: {q}")
    print(f"{'='*60}")
    print("\n  Copilot (thinking...)\n")
    answer = ask(project, agent, q)
    print(f"  {answer}\n")

project = AIProjectClient(endpoint=ENDPOINT, credential=AzureCliCredential())
agent   = next(a for a in project.agents.list_agents() if a.name == AGENT_NAME)
print(f"\nConnected to: {AGENT_NAME}\n")

# Which questions to run
if len(sys.argv) > 1:
    nums = [int(x) for x in sys.argv[1:] if x.isdigit() and int(x) in QUESTIONS]
else:
    nums = list(QUESTIONS.keys())

for n in nums:
    run_question(project, agent, n)
    if n != nums[-1]:
        input("  [Press Enter for next question]")

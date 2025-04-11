from modules.utilities.discover_agents import discover_agents

def main():
    # Discover agents in the specified directory
    agent_directory = "agents"
    agents = discover_agents(agent_directory)

    print(f"Discovered {len(agents)} agents in directory '{agent_directory}':")

    # Print the discovered agents
    for agent in agents:
        print(f"Discovered agent: {agent.__name__}")

if __name__ == "__main__":
    main()
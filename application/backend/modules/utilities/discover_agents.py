import os
import importlib

from modules.interfaces.agent import Agent

def discover_agents(agent_directory):
    agents = []

    print(f"Current working directory: {os.getcwd()}")
    print(f"Agent directory: {agent_directory}")

    base_path = os.path.dirname(__file__)
    print(f"Base path: {base_path}")
    base_path2 = base_path.replace("utilities", "")

    agent_directory = base_path.replace("utilities", agent_directory)
    print(f"Base path for agents: {agent_directory}")
    # Check if the agent_directory is relative or absolute

    print(f"Full agent directory path: {agent_directory}")
    if not os.path.exists(agent_directory):
        raise FileNotFoundError(f"Agent directory '{agent_directory}' does not exist.")
    if not os.path.isdir(agent_directory):
        raise NotADirectoryError(f"'{agent_directory}' is not a directory.")
    print(f"Agent directory exists and is a directory.")
    print(f"Listing files in agent directory: {os.listdir(agent_directory)}")
    # Iterate through all Python files in the specified directory
    # and import them dynamically

    for agent_file in os.listdir(agent_directory):

        try:
            if agent_file.endswith(".py") and agent_file != "__init__.py":
                print(f"Processing file: {agent_file}")
                # module_name = agent_file[:-3]
                module_name = agent_file

                # Use importlib to load the module
                module_path = os.path.join(agent_directory, agent_file)
                print(f"Module path: {module_path}")
                spec = importlib.util.spec_from_file_location(module_name, module_path)
                print(f"Spec: {spec}")
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                print("Did i get here?")
                # Use importlib to load the module
                module = importlib.import_module(f"{agent_directory}.{module_name}")

                print(f"Module imported: {module}")
                
                # # module = __import__(f"{agent_directory}.{module_name}", fromlist=[""])
                for name in dir(module):
                    obj = getattr(module, name)
                    if isinstance(obj, type) and issubclass(obj, Agent) and obj is not Agent:
                        agents.append(obj)
        except Exception as e:
            print(f"Error processing file {agent_file}: {e}")
            continue
    return agents

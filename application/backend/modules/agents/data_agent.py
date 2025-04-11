from modules.interfaces.agent import Agent

class DataAgent(Agent):
    def __init__(self, name: str, age: int, data_source: str):
        super().__init__(name, age)
        self.data_source = data_source

    def __repr__(self):
        return f"DataAgent(name={self.name}, age={self.age}, data_source={self.data_source})"

    def get_info(self):
        info = super().get_info()
        info["data_source"] = self.data_source
        return info

    def perform_action(self, action: str):
        if action == "fetch_data":
            return f"Fetching data from {self.data_source}"
        else:
            raise ValueError(f"Unknown action: {action}")
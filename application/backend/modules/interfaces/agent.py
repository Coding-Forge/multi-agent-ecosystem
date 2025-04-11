class Agent:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

    def __repr__(self):
        return f"Agent(name={self.name}, age={self.age})"

    def get_info(self):
        return {"name": self.name, "age": self.age}

    def perform_action(self, action: str):
        raise NotImplementedError("This method should be overridden by subclasses")
        
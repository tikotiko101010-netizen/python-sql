import copy

class Selfie:
    """
    A class that implements state retention and recovery (Memento pattern).
    
    Captures snapshots of the object's entire instance namespace using __dict__,
    maintains a chronological history of states, and returns a new instance
    restored to any historical point via zero-based indexing.
    """
    def __init__(self):
        # List to maintain deep copies of historical __dict__ snapshots
        self.history = []

    def save_state(self):
        """
        Captures the current state of all instance attributes, including the history
        itself, and appends a deep copy to the state registry.
        """
        self.history.append(copy.deepcopy(self.__dict__))

    def recover_state(self, n):
        """
        Returns a new instance restored to the state at index 'n'.
        If the index 'n' is invalid, returns the current instance unchanged.
        """
        if 0 <= n < len(self.history):
            # Dynamically instantiate a new object of the same class type
            res = type(self)()
            # Directly overwrite the new instance namespace with the historical snapshot
            res.__dict__ = self.history[n]
            return res
        return self

    def n_states(self):
        """
        Returns the total number of successfully captured states.
        """
        return len(self.history)

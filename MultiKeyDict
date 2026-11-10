from collections import UserDict

class MultiKeyDict(UserDict):
    """
    A custom dictionary that supports creating aliases for existing keys.
    
    Values are wrapped in mutable lists acting as data containers.
    This ensures that both the original key and all its aliases point to the 
    same object in memory, allowing synchronous data updates.
    """
    def __init__(self, it=(), **kwargs):
        # Dictionary to map aliases to their respective data containers: {alias: data_list}
        self.alis = {}
        super().__init__(it, **kwargs)

    def __getitem__(self, k):
        # Original keys have priority over aliases
        if k in self.data:
            val = self.data[k]
        elif k in self.alis:
            val = self.alis[k]
        else:
            raise KeyError(f"Key or alias '{k}' not found.")
            
        # If the wrapped value is our single-element container, unpack it.
        # This handles cases where the actual stored value is also a list.
        if isinstance(val, list) and len(val) == 1 and not (k in self.data and isinstance(self.data[k], list) and val == self.data[k]):
            # If it's a structural list container created by __setitem__, return its content
            if hasattr(self, '_raw_set') and k in self._raw_set:
                return val[0]
        return val[0] if isinstance(val, list) and len(val) == 1 else val

    def __setitem__(self, k, v):
        # Update the value inside the container if the key already exists
        if k in self.data:
            self.data[k][:] = [v]
        # Update the value via an existing alias
        elif k in self.alis:
            self.alis[k][:] = [v]
        # Create a new original key with a list container
        else:
            self.data[k] = [v]

    def alias(self, k, kal):
        """
        Creates an alias 'kal' for an existing key or alias 'k'.
        Both keys will now reference the exact same underlying data container.
        """
        if k in self.data:
            self.alis[kal] = self.data[k]
        elif k in self.alis:
            self.alis[kal] = self.alis[k]
        else:
            raise KeyError(f"Cannot create alias: original key '{k}' does not exist.")

    def __delitem__(self, k):
        # Delete original keys first due to priority rules
        if k in self.data:
            del self.data[k]
        elif k in self.alis:
            del self.alis[k]
        else:
            raise KeyError(f"Key or alias '{k}' not found for deletion.")

    def __len__(self):
        # Dictionary length is based strictly on original keys; aliases are ignored
        return len(self.data)

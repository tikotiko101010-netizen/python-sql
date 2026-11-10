from functools import wraps

class predicate:
    """
    A decorator class that enables logical operations (AND, OR, NOT)
    on predicate functions using operator overloading (&, |, ~).
    
    Implements a highly concise, functional architecture using dynamic 
    lambda compositions wrapped back into the predicate class type.
    """
    def __init__(self, func):
        self.func = func
        # Preserve original function attributes (__name__, __doc__, etc.)
        wraps(func)(self)

    def __call__(self, *args, **kwargs):
        # Direct execution of the wrapped predicate function
        return self.func(*args, **kwargs)

    def __and__(self, oth):
        # Overloads the bitwise AND operator (&) via lazy evaluation lambda
        return type(self)(lambda *args, **kwargs: self(*args, **kwargs) and oth(*args, **kwargs))

    def __or__(self, oth):
        # Overloads the bitwise OR operator (|) via lazy evaluation lambda
        return type(self)(lambda *args, **kwargs: self(*args, **kwargs) or oth(*args, **kwargs))

    def __invert__(self):
        # Overloads the bitwise NOT operator (~) to negate the predicate logic
        return type(self)(lambda *args, **kwargs: not self(*args, **kwargs))

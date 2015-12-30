When DynaCode starts all class files are executed and sealed. If a class extends another then that class file is loaded on demand and sealed afterwards.

A class **cannot** be extended if it is not sealed, the same applies to mixins.

The process:

Lets say I have a class `Child` that extends `Parent` that extends `Grandparent`
The process of loading would follow this basic structure:

1. Execute `Child` class file.
2. `Child` extends class `Parent`. Load this class file
3. `Parent` extends class `Grandparent`. Load this class file
4. `Grandparent` extends nothing, seal the class
5. Seal `Parent`
6. Seal `Child`

Mixins would be accounted for in the 'seal' steps (4, 5, 6).

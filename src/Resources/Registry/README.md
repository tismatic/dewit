# Registry Resource

Manages Windows registry values.

Example:

```yaml
- name: Ensure registry value exists
  registry:
    path: HKCU:\Software\DewitDemo
    name: ManagedBy
    value: Dewit
    type: string
    state: present
```
